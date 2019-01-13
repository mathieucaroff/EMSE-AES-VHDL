---
title: "PCSN Project Report"
author: [Mathieu CAROFF]
date: "2019-01-10"
keywords: [AES, VHDL, EMSE]
geometry: margin=3cm
output: pdf_document
---

Problem
=======

Propose a working architecture model for a hardware AES decryption
module.

Conventions
===========

Name and location
=================

- Source files must be placed in the directory `sources/`.
- Test bench files must be placed in the directory `bench/`.
- The name of test bench entities must be formed by the concatenation of the
  name of the entity they test with the suffix `_tb`.
- Source and bench files must define exactly one entity. The entity header and
  architecture must be in the same file. The stem of the name of the file must
  be that of the entity it defines.
- Input port names must end in `_i` and outputs in `_o`. Signal names must end
  in `_s`. I took the freedom to also use `_is` and `_os` for input and output
  related signals.
- At the bare minimum, a file must have a comment stating its purpose. The use
  of any math formula as well as constructs that were not part of the VHDL
  lesson should be explained in the comments too.

The following conventions were not required in the project
specifications, but were used in the project:

- Names taken from the AES specification are written as a single word.
  For instance, `addroundkey`.
- Otherwise, all names are written in snake lowercase. For instance,
  `aes_round_inv_tb`.

Module design
=============

Inverse AES
===========

This module provides one entity which accepts a 128 bit key and a 128
bit ciphered message to decipher.

The inverse AES module (`aes128_fst_moore_inv`) accepts:

- the input data to decipher `data_i`, as a 128 bit block
- the 128 bit key to use for that

It supports:

- a reset signal `reset_i`.

It requires:

- a running clock throughout the computations
- a start signal specifying whether a new key and data pair should be read or not

It outputs:

- the plain text block `data_o`
- a signal `aes_on_o` which tells whether the module is running or has
  finished

To do the inverse cipher, Inverse AES uses two components:

- Key Schedule (`keyschedule_fake`)
- Inverse AES Round (`aes_round_inv`)

Inverse AES has a number of responsibilities of its own:

- Keeping the current state in memory
- Being able to load a new state in memory when `start_i` is high
- Repeatedly doing AES rounds and keeping the count of how many have
  already been done, signaling the first and the last round to the
- Stopping the computations and signaling it when the last round
  finishes.

## Implementation as a Moore machine

The implementation of the Moore machine was split in three parts. One
handles the clock and reset, another, the biggest, handles the
computation of the next state of the machine from the input and the
current state, and the third part computes the output from the state of
the machine.

### 1. Handling the clock

``` {.sourceCode .VHDL}
process (clk_i, reset_i)
begin
    if reset_i = '1' then
        key_is  <= (others => x"00");
        data_s <= (others => x"00");
        count_s <= x"F";
    elsif clk_i'event and clk_i = '1' then
        key_is  <= key_next_is;
        data_s <= data_next_s;
        count_s <= count_next_s;
    end if;
end process;
```

There is not much to see here. The complete state of the machine consists
of its key, its data, and the value of its round counter. They are reset
in case of reset and evolve to their next state upon the rising edge of the
clock.

### 2. Computing the next state

#### 2.1 The key

``` {.sourceCode .VHDL}
key_next_is <= bit2byte(key_i) when start_i = '1' else key_is;
```

The case of the key is very simple it needs be updated only when the
start signals says so, otherwise it does not change. It was implemented
using a single implicit process.

### 2.2 The counter

``` {.sourceCode .VHDL}
count_next_s <=
    x"a" when start_i = '1' else
    count_s when count_s = x"F" else
    std_logic_vector(unsigned(count_s) - 1);
```

The exact implementation of how the counter computes the decreasing
indexes of isn't specified by this code, however, we see that it is
initialised at 0xA (11) and decreases down to 0xF (-1), at each tick and
finally stops changing.

### 2.3 The data

This one is the most complicated. The fundamental pare is below:

``` {.sourceCode .VHDL}
data_next_s <=
    bit2byte(data_i) when start_i = '1' else
    state_os when count_s /= x"F" else
    data_s
;
```

`data_i` is the input data given through that port of the inverse
cypher module. It should be loaded only when the start signal is
received. Otherwise, the signal should either be held to its value, if
the transformation finished, or should be changed to the result of a one
AES round.

``` {.sourceCode .VHDL}
state_is <= data_s;

aes_round_inv_0 :
    aes_round_inv
    port map(
        skip_mc_i => skip_mc_is,
        skip_sb_sr_i => skip_sb_sr_is,

        roundkey_i => roundkey_is,
        state_i => state_is,
        state_o => state_os
    );

process (count_s)
begin

    case count_s is
        when x"0" => -- 0
            skip_mc_is <= '1';
            skip_sb_sr_is <= '1';
        when x"a" => -- 10
            skip_mc_is <= '1';
            skip_sb_sr_is <= '0';
        when others => -- 1-9
            skip_mc_is <= '0';
            skip_sb_sr_is <= '0';
    end case;

end process;
```

Depending on which round index we are calculating, the Inverse Mix
Column step and the Inverse Subbytes and Shift Rows might need to be
skipped. This is what this process does.

For the sake of comprehensivity, we'll also mention the instantiation of
Key Schedule, even though it was not implemented and is only able to
output the values for a single key.

``` {.sourceCode .VHDL}
keyschedule_fake_0 :
    keyschedule_fake
    port map(
        round_index_i => count_s,

        key_i => key_is,
        roundkey_o => roundkey_os
    );

roundkey_is <= roundkey_os;
```

### 3. Computing the output from the current state

The output is quite simple to produce. The data are just the copy of the current
data state of Moore machine. The readiness of the results is best inferred from
the counter. Once the counter reaches its final position, the result is ready.

``` {.sourceCode .VHDL}
data_o <= byte2bit(data_s);
aes_on_o <= '0' when count_s = x"F" else '1';
```

Inverse Subbytes
----------------

Inverse Subbytes applies Sbox to each byte of the input state. This is
done by instantiating 16 inverse Sboxes, which will do the computation
in parallel. Since our state type is just an array of bytes, a single
generate loop suffice to create the 16 inverse Sboxes, see the code extract
below.

``` {.sourceCode .VHDL}
GEN_A:
for k in 0 to 16 - 1 generate
    SBOX_A: sbox port map(
        byte_i => state_i(k),
        byte_o => state_o(k)
    );
end generate;
```

Below is an example of a test bench entry. The first line is
the input, and the second line is the expected output.

```VHDL
x"63636363637CCAB78C1600011020F0FF",
x"0000000000011020F0FF52097C54177D"
```

Inverse Sbox
------------

The inverse Sbox was implemented as a lookup table. Lookup table trade
silicon surface for speed. Since a computation circuit also uses
surface, lookup tables are relatively cheap when they don't exceed 255
elements. The exact details of the final implementation are not
specified by the entity, see the code extract below, but lookup tables are
usually made using multiplexers with hard-wired inputs.

``` {.sourceCode .VHDL}
byte_o <= lut(to_integer(unsigned(byte_i)));
```

Below is an example of test bench entry.

```VHDL
"00000000",
"01010010" -- :0x52
```

Add Round Key
-------------

Physically, Add Round Key only consists in 128 XOR gates which allow
XOR-ing the 128 bits of the current state with the 128 bits of the
current round key. VHDL provides a xor function operating on
`std_logic_vector`s, see the code extract below. To be able to use this
function, we perform conversion from our custom `byte16` type to the
standard `std_logic_vector` using two functions implemented in
`util_type`.

``` {.sourceCode .VHDL}
bit_state_s <= byte2bit(roundkey_i) xor byte2bit(state_i);
state_o     <= bit2byte(bit_state_s);
```

In the below test bench entry example, the two first lines
are inputs and the last line is the expected output.

```VHDL
x"00112233445566778899AABBCCDDEEFF",
x"000102030405060708090A0B0C0D0E0F",
x"00102030405060708090A0B0C0D0E0F0"
```

Inverse Shiftrows
-----------------

The Inverse Shift Rows step consists in transposing the different bytes of
the state to a new position. Yet, it is important to note that the AES
Specifies the numbering of the bytes, counting in columns, rather than
counting in rows as is usually the case for matrices. This means that, in
a single line representation of the state, Inverse Shift Rows will not
transpose close to one another, but distant. See example below:

Below is an example.

``` {.sourceCode .text}
0055AAFF4499EE3388DD2277CC1166BB
00112233445566778899AABBCCDDEEFF
```

As it consists in a simple and very regular transposition, it can created
using two nested generate loops.

When I first tried to use variables to compute the source and
destination indexes of each byte, I discovered it is not possible to use
variables in generates. This actually makes sense, since variables are
runtime mechanisms while generates are, supposedly, compile-time
constructs. Furthermore, while variables are to be used in sequential
sections of code, generates create code pieces that are to be executed
in parallel. It is however possible to use constants in generate loops,
as constants can be handled at compile time. They are by far
sufficient, see the code extract below.

``` {.sourceCode .VHDL}
GEN_A:
for k in 0 to 4 - 1 generate
begin
    GEN_B:
    for m in 0 to 4 - 1 generate
        -- stackoverflow.com/q/47302553
        constant src : natural := 4 * ((k + m) mod 4) + m;
        constant dst : natural := 4 * k + m;
    begin
        state_o(src) <= state_i(dst);
    end generate;
end generate;
```

Inverse Mix Columns
-------------------

The transformation of Mix Column is that of a matrix multiplication by
a constant and regular matrix, but using the multiplication in the
Gallois field "GF(2\^8), modulo x\^4 + 1". It consists in a
multiplication over 256 bits, where addition is the XOR, and the product
is xored with the reducing polynomial 0b00011011 (0x1B), each time an
overflow occurs during the multiplication.

The implementation of such a multiplication being error-prone in VHDL,
we decided to use lookup tables instead. The tables are generated
formatted using a custom C program, see Gallois Field Multiplication Box.

Since each of the 16 coefficient of the matrix needs to be multiplied
by the four coefficients (14, 11, 13, 9) of the predefined matrix, we
need to use 64 boxes in total. This is what is done in the code below.
For each coefficient of the result state, the four GF multiplication
boxes corresponding to it are instantiated. The result of each of them
is then XORed into a single output result.

I learned through making and debugging this entity that it may be worth
creating an "Inverse Mix Single Column" entity before making "Inverse Mix
Column", because the debugging process is less tedious when the
modified data is smaller than when it is big. If I had to implement
another Inverse Mix Columns, in some language, I would start by writing
the code for that single column entity.

``` {.sourceCode .VHDL}
GEN_HORIZONTAL:
for k in 0 to 4 - 1 generate
begin
    GEN_VERTICAL:
    for m in 0 to 4 - 1 generate
        for gftimes14box_comp : gftimes14box
            use entity work.gftimes14box;
        -- (3 other gftimes*box_comp ommitted)
    begin

        --  Component instantiation.
        gftimes14box_comp :
        gftimes14box port map(
            byte_i => state_i(4 * k + (m + 0) mod 4),
            byte_o => state_0(4 * k + m)
        );

        -- (gftimes11box and gftimes13box omitted)

        gftimes9box_comp :
        gftimes9box port map(
            byte_i => state_i(4 * k + (m + 3) mod 4),
            byte_o => state_3(4 * k + m)
        );

        state_o(4 * k + m) <=
            state_0(4 * k + m) xor
            state_1(4 * k + m) xor
            state_2(4 * k + m) xor
            state_3(4 * k + m);

    end generate;
end generate;
```

Below is a set of test values used in the test bench of
the Inverse Mix Column entity. It is interesting to see how
regular the changes in the output can be when the change in
input is simple.

```VHDL
(
    x"00000000000000000000000000000000",
    x"00000000000000000000000000000000"
)
,
(
    x"01010302000000000000000000000000",
    x"00000001000000000000000000000000"
)
,
(
    x"00000000000000000000000001010302",
    x"00000000000000000000000000000001"
)
,
(
    x"00000000000000000000000010103020",
    x"00000000000000000000000000000010"
)
,
(
    x"02010103000000000000000000000000",
    x"01000000000000000000000000000000"
)
,
(
    x"046681e5e0cb199a48f8d37a2806264c",
    x"d4bf5d30e0b452aeb84111f11e2798e5"
)
```

GF Times \* box
---------------

The code for the entities gftimes2box through gftimes14box were
generated using the C program `generate_tables.c`. This program is
simple to use:

``` {.sourceCode .bash}
make generate_tables
./generate_tables 2 > gftimes2box.vhd
./generate_tables 2 3 9 11 13 14 > gfmuliplicationbox.vhd
```

It produces correctly formatted lookup tables, with comments to help
reading it visually, which can be useful to write tests.

Utility packages
----------------

The files `util_type.vhd` and `util_str.vhd` declare package. The type
declarations in `util_type` allow to write shorter and more readable
VHDL code, as well as code easier to refactor. It also provides two 
conversion functions: `byte2bit` and `bit2bytes`, operating between
arrays of bytes and vectors of bits. Similarly, `util_str` provides
conversion from `std_logic_vector` to string, as a binary representation
of the vector, using `bin`, or as a hexadecimal representation of the
vector, provided the number of bits it's made of is a multiple of 4,
using `hex`.

Finally, `util_control.vhd` contains a single simple function to replace
ternary condition, and was created to serve in the test bench of a key
schedule register.

Please note that each of those three packages have their own test bench.

Test benches
============

As previously mentioned, all test benches are in the folder `bench/`.
Test benches for simple entities are generated using the homemade
Python 3 script `genBench.py`.

Test bench generation with `genBench.py`
----------------------------------------

The generation script can handle simple entities with one or two inputs,
and always one output. The types of the input(s) and output must be the
same, and be either 8 bits or 16 bytes.

This script actually uses the template benches in `template/` and the
bench input examples in `bench_config` to generate the tests. It also
acquires the input and output port names from the files source files.

The templates in template are configured to delegate the work of
manipulating the array of test and sending the values from that array to
the component.

Test bench results
------------------

The results of running all the test benches with
`bash run.sh --run-all`:

``` {.sourceCode .output}
$ ./run.sh --run-all
(R:addroundkeys) tools:@104ns::: addroundkeys end
(R:aes128_fsm_moore_inv)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
bench/aes128_fsm_moore_inv_tb.vhd:136:9:@113ns::: end
(R:aes_round_inv)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!
bench/aes_round_inv_tb.vhd:190:9:@108ns::: end
(R:gftimes14box) tools:@105ns::: gftimes14box end
(R:keyschedule_fake) bench/keyschedule_fake_tb.vhd:119:9:@104ns::: end
(R:mixcolumns_inv) tools:@117ns::: mixcolumns_inv end
(R:mixcolumns) tools:@116ns::: mixcolumns end
(R:sbox_inv) tools:@112ns::: sbox_inv end
(R:sbox) tools:@112ns::: sbox end
(R:shiftrows_inv) tools:@105ns::: shiftrows_inv end
(R:shiftrows) tools:@105ns::: shiftrows end
(R:subbytes_inv) tools:@102ns::: subbytes_inv end
(R:subbytes) tools:@102ns::: subbytes end
(R:util_control) bench/util_control_tb.vhd:20:9:@0ms::: end
(R:util_str) bench/util_str_tb.vhd:22:9:@0ms::: end
(R:util_type) bench/util_type_tb.vhd:29:9:@0ms::: end
```

`./run.sh --build --run-all` runs all test benches found in `bench/`, in
alphabetical order. We can see here that no error arose during those tests.
The test benches for `aes128_fsm_moore_inv` and `aes_round_inv` issue
respectively 161 and 96 GHDL warnings about `std_logic` metavalues being
replaced by 0, even though the asserts made on the test bench are otherwise all
correct. The original GHDL warning corresponding to one exclamation mark is:

```text
numeric_std-body.v93:2098:7:@0ms:(assertion warning): NUMERIC_STD.TO_INTEGER:
metavalue detected, returning 0
```

Through tweaking of the first process of `aes128_fsm_moore_inv`, it can be
enabled to print its intermediate states. This is done by uncommenting three
report lines in the first process. We then obtain the following output:

``` {.sourceCode .output}
(A:aes128_fsm_moore_inv) 
(R:aes128_fsm_moore_inv)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
count : x"F"
data : x"00000000000000000000000000000000"

count : x"A"
data : x"D6EFA6DC4CE8EFD2476B9546D76ACDF0"

count : x"9"
data : x"A540F9576763DDE6C5A584B9D8FD10CA"

count : x"8"
data : x"24BBBB7D8A0BFB944C4D621FF4FA643E"

count : x"7"
data : x"66DA7E47F0FD87D9AE385058CF51AD38"

count : x"6"
data : x"799E687B7C10650704039F058D6632DD"

count : x"5"
data : x"223DD550B85B7AA1D93831A20A016129"

count : x"4"
data : x"2998BB64CB93342C83C48E4E8F5B75DD"

count : x"3"
data : x"B46C7A92D79AC972E11487EF506DC2D5"

count : x"2"
data : x"C9D600FCD07B5D005C5AC4BF6D608EDA"

count : x"1"
data : x"9735FC29C5A52EA16D60ED2A9AED6606"

count : x"0"
data : x"791B6662478EB7C88B817CE465AA6F03"

count : x"F"
data : x"526573746F20656E2076696C6C65203F"

end
```

These values match the values checked for in the test bench of
`aes_round_inv`.

Note about the coding style
---------------------------

When I discovered VHDL, I liked its use of ada which is a very well designed
language compared to C. It uses a lot of keywords, which pleases me, if not
a bit too verbal. My only complaint about the language would be the lack of
the trailing comma even today, while it is known to be a useful feature for
developers using source controls (pleonasm here).

However, I have complaints to address toward the most common practice: using
alignment, even when indentation could have sufficed.

### Alignment vs Indentation

In comparison with most VHDL coding styles, the style I used, avoids
constraining code alignment (aka. alignment), and use non-constraining
code alignment (aka indentation) whenever possible, the exception being
single line constructs. Below are two examples explaining this
principle.

``` {.sourceCode .VHDL}
state_o(4 * k + m) <= state_0(4 * k + m) xor
                      state_1(4 * k + m) xor
                      state_2(4 * k + m) xor
                      state_3(4 * k + m);
```

``` {.sourceCode .VHDL}
state_o(4 * k + m) <=
    state_0(4 * k + m) xor
    state_1(4 * k + m) xor
    state_2(4 * k + m) xor
    state_3(4 * k + m);
```

It can be argued that the line return before the assignment is
unnatural, the non-constraining code alignment has however several
advantages:

- Text editors usually don't handle precise line alignment correctly
  when using tabs. The consequence of this is that when opening the
  file in a different editor, with a different tab size configuration,
  the alignment is lost, and the code becomes uglier than unaligned.
- Text editors may not handle alignment at all, while they all handle
  indenting which is what non-constraining code alignment
  fundamentally is.
- With non-constraining code alignment, a change in the length of
  first line does not induce a change of alignment in the following
  lines.

The latter point has three implications:

- It is possible to refactor variable names without worrying about
  breaking the formatting.
- Regarding, version control software, a change in the just the
  first line won't be seen as a change in the whole block, thus the
  diff outputs will be clearer and easier to read. It also helps
  avoiding merge collisions.
- Managing constraining code alignment costs time to the developer.

The exception I made to the use of non-constraining code alignment was
the case of variable declarations, where non-constraining code alignment
doubles the use of vertical space and arguably reduces readability, see
example below:

``` {.sourceCode .VHDL}
port(
    skip_mc_i
        : in b;
    skip_sb_sr_i
        : in b;

    roundkey_i
        : in byte16;
    state_i
        : in byte16;
    state_o
        : out byte16
);
```

``` {.sourceCode .VHDL}
port(
    skip_mc_i    : in b;
    skip_sb_sr_i : in b;

    roundkey_i   : in byte16;
    state_i      : in byte16;
    state_o      : out byte16
);
```

### Placement of parenthesis

In most VHDL style, the closing parenthesis and braces are placed at the
end of the last line of the block or group. In comparison, I placed the
closing parenthesis on a separate line. The idea is to help see missing
parenthesis, though arguably, it's more a matter of taste than a
decision of practical importance.

The build script
----------------

If you've obtained the source through a .zip file, chances are all files
VHDL were already generated, so you just want to compile them:

* Using _GHDL: https://gist.github.com/mathieucaroff/73ccbd30638d9b37b7129a7b7b8d7726 `./run.sh --build`. You can also use `./run.sh --run-all` to afterward.
* Using Model Sim `./run.sh --do vcom`

The building script `./run.sh` takes care of a number of problems:

- Issuing VHDL generation commands for benches and sources
  (`./run.sh --generate).
- Copying the generated files, along with the hand-written sources, to
  the directories `sources/` and `bench/` (`./run.sh --copy`). Only
  modified files will be copied.
- Compiling all the sources and benches (`./run.sh --build`).
- Removing the file creating during any one of the three above steps
  (`./run.sh --clean (generate|copy|build)`).
- Running all test benches whose name can be guessed from that of files
  in `bench/`.

As long as the arguments are only "--option"s, they can be indefinitely
chained, and they will be executed sequentially. The script, however, can also be
used for specific entities, which can be useful when debugging it for the first
time:

`./run.sh --copy test aes128_fsm_moore_inv`

This presentation of the script isn't exhaustive, yet there's one last
interesting feature to be mentioned, the `--do` system, which is a set
of preloaded `./run.sh` commands. The three available commands are:

- `--do vcom`, to compile using vcom.
- `--do test`, to be used if the code from obtained from source control,
  like github, and thus the generated files are not included.
- `--do clean`, to run the three available clean tasks.

Conclusion
==========

This open source hardware design contains all the working pieces to do any kind
of AES. Even though it only does Inverse Cypher for 128bits AES at the moment,
the addition of the cypher and the other sizes of key options shouldn't be a big
concern anymore.

With this project, I learned, once more, the importance of thinking ahead and
that of test cases of gradual complexity inside your test cases, as well as
well chosen signal report to help understand what is going on. It was a
pleasure to work with test files, making return trips between test benches and
source files to progressively add complexity almost felt like Test Driven
programming at times.

There's still some room for other interesting improvements. This project used a
test bench generator which extracts ports types and names to match them with
four predefined categories, but this is a rather limiting situation. With a
more sophisticated extractor, using a proper VHDL parser, it would be possible
to provide test skeleton generation for about any VHDL entity.