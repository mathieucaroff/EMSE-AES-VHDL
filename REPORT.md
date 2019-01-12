---
title: "PCSN Project Report"
author: [Mathieu CAROFF]
date: "2019-01-09"
keywords: [AES, VHDL, EMSE]
...

# Rought draft

## Problem

Propose a working architecture model for a hardware AES decryption module.

## Purpose of the report

* Show the understanding of Hardware conception acquired through the realisation of the project.

## Material of the report

_It should be structured in a relevant manner_
.

## Instructions of the report

Um? TODO: reread them.

## Make recommandations where required

## Make appropriate conclusions

_They should be supported by the evidence and analysis of the report_
.

## Constraints

* Use VHDL
* Use the given conventions

## Conventions

## Name and location

* Source files of must and be placed in the directory `sources/`.
* Test bench files must be placed in the directory `bench/`.
* The name of test bench entities must be formed by the concatenation of the
  name of the entity they test with the suffix `_tb`.
* Source and bench files must define exactly one entity. The entities header
  and architecture must be in the same file. The stem of the name of the file
  must that of the entity it defines.
* Input port names must end in  `_i` and outputs in `_o`. Signal names must end
  in `_s`. We took the freedom to replace `_s` by either of `_is` or `_os`, for
  input realted signales and output ones.
* At the bare minimum, a file must have a comment stating it's purpose. Math, as
  well as constructs that were not part of the lesson should be explained in
  comments too.

The following conventions were not required in the project specifications:

* Names taken from the AES specification are written as a single word. For instance, `addroundkey`.
* Otherwise, all names are written in snake lowercase. For instance, `aes_round_inv_tb`.

## Module design

### Inverse AES

This module provides one entity which accept a 128 bits key and a 128 bits

The inverse AES module accepts:

* the input data to decypher `data_i`, as a 128 bit block.

It supports:

* a reset signal `reset_i`.

It requires:

* a running clock
* a start signal

It outputs:

* the uncyphered block `data_o`
* a signal `aes_on_o` which tells whether the module is running or has finished

To do the uncypher, Inverse AES uses two components:

* Key Schedule (`keyschedule_fake`)
* Inverse AES Round (`aes_round_inv`)

Inverse AES has a number of responsabilities of it's own:

* Keeping the current state in memory
* Being able to load a new state in memory when `start_i` is high
* Repeteadly doing AES rounds and keeping the count of how many have already
  been done, signaling the first and the last round to the
* Stopping the computations and signaling it when the last

### Inverse Subbytes

 Inverse subbytes applies Sbox to each byte of the input state. This is done by
 instanciating 16 inverse Sboxes, which will do the computation in parallel.
 Since our state type is just an array of bytes, a single generate loop suffice
 to create the 16 inverse Sboxes, see code extract below.

*code taken from `sources/subbytes_inv.vhd`*

```vhdl
GEN_A:
for k in 0 to 16 - 1 generate
    SBOX_A: sbox port map(
        byte_i => state_i(k),
        byte_o => state_o(k)
    );
end generate;
```

#### Inverse Sbox

 The inverse Sbox was implemeted as a lookup table. Lookup table trade silicon
 surface for speed. Since a computation circuit also uses surface, lookup tables
 are relatively cheap when they don't exceed 255 elements. The exact details of
 the final implementation are not specified by the entity, see code extract
 below, but lookup tables are usually done using multiplexers with hard-wired
 inputs.

*code taken from `sources/sbox_inv.vhd`*

```vhdl
byte_o <= lut(to_integer(unsigned(byte_i)));
```

### Add Round Key

 Physically, Add Round Key only consists in 128 XOR gates which allow XOR-ing
 the 128 bits of the current state with the 128 bits of the current round key.
 VHDL provides a xor function operating on `std_logic_vector`s, see code extract
 below. To be able to use this function, we perform conversion from our custom
 `byte16` type to the standard `std_logic_vector` using two functions
 implemented in `util_type`.

*code taken from `sources/addroundkeys.vhd`*

```vhdl
bit_state_s <= byte2bit(roundkey_i) xor byte2bit(state_i);
state_o     <= bit2byte(bit_state_s);
```

### Inverse Shiftrows

 The Inverse Shift Rows step consist in tranposing the different bytes of the
 state to new position. Yet, it is important to note that the AES Specifies the
 numerotation of the bytes counting in columns, rather than counting in rows as
 is usually the case for matrices. This mean that, in a single line
 representation of the state, Inverse Shift Rows will not transpose close to one
 another, but distant. See example below:

*Inverse Shift Rows example, first line: input state, second line: output state*

```text
0055AAFF4499EE3388DD2277CC1166BB
00112233445566778899AABBCCDDEEFF
```

 As it consist in a simple and very regular transposition, it can created using
 generate loops.

 When I first tried to use variables to compute the source and destination
 indexes of each byte, I discovered it is not possible to use variables in
 generates. This actually make sense, since variables are runtime mechanismes
 while generates are, supposedly, compiletime constructs. Furthermore, while
 variables are to be used in sequential sections of code, generates create code
 pieces that are to be executed in parallel. It is however possible to use
 constants in generate loops, as constants can be handeled at compile time. They
 are by far sufficient, see code extract below.

*code taken from `sources/!_inv.vhd`*

```vhdl
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

### Inverse Mix Columns

 The transformation of Mix Column is that of a matrix multiplication with a
 constant and regular matrix, but using the multiplication in the Gallois field
 "GF(2^8), modulo x^4 + 1". It consists in a multiplication over 256 bits, where
 addition is xor, and the product is xored with the reducing polynomial
 0b00011011 (0x1B), each time an overflow occures during the multiplication.

 The implementation of such a multiplication being error-prone in vhdl, we
 decided to use lookup tables instead. The tables are generated formated using a
 custom C program, see Gallois Field Multiplication Box.

 Since each of the 16 coefficient of the matrix needs to be muliplied with the
 four coefficient (14, 11, 13, 9) of the predefined matrix, we need to use 64
 boxes in total. This is what is done in the code below. For each coefficient of
 the result state, the four GF multiplication boxes corresponding to it are
 instanciated. The result of each of them is then xored into a single output
 result.

 I learned through making and debugging this entity that it may be worth
 creating a "Inverse Mix Single Column" entity before making
 "Inverse Mix Column", because the debbugging process is less tedious when the
 modified data is small than when it is big. If I had to implement another
 Inverse Mix Columns, in some language, I would start by writing the code for
 that single column entity.

*code taken from `sources/!_inv.vhd`*

```vhdl
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

### GF Times * box

The code for the entities gftimes2box through gftimes14box were generated using
the C program `generate_tables.c`. This program is simple to use:

```bash
make generate_tables
./generate_tables 2 > gftimes2box.vhd
./generate_tables 2 3 9 11 13 14 > gfmuliplicationbox.vhd
```

It produces correctly formatted lookup tables, with comments to help reading it
visually, which can be usefull to right tests.

see code extract below

## Test benches

As previously mentionned, all test benches are in the folder `bench/`. Tests
benches for simple entities are were generated using the homemade Python 3 script
`genBench.py`.

### Test bench generation with `genBench.py`

The generation script can handle simple entities with one or two inputs, an
alwayse output. The types of the input(s) and output must be the same, and be
either 8 bits or 16 bytes.

This script actually uses the template benches in `template/` and the bench
input examples in `bench_config` to generate the tests. It also aquires the
input and output port names from the files source files.

### Test bench results

The results of running all the test benches with `bash run.sh --run-all`:

```text
$ ./run.sh --build --run-all
(R:addroundkeys) tools:@104ns::: addroundkeys end
(R:aes128_fsm_moore_inv)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
bench/aes128_fsm_moore_inv_tb.vhd:108:9:@111ns:!: data_os error: D6EFA6DC4CE8EFD2476B9546D76ACDF0
bench/aes128_fsm_moore_inv_tb.vhd:111:9:@111ns:!: aes_on_os error: 1
bench/aes128_fsm_moore_inv_tb.vhd:117:9:@112ns::: end
(R:aes_round_inv)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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

`./run.sh --build --run-all` runs all test benchs found in `bench/`, in
alphabetical order. We can see here that no error arised during those tests,
except for `aes128_fsm_moore_inv`, where the uncypher test failed, and for
`aes_round_inv` where 96 GHDL warnings of `std_logic` metavalue replaced by 0,
occured, even though the asserts made in the test bench were all correct.

### Note about the coding style

#### Alignement vs Indentation

 In comparison with most VHDL coding styles, the style I used avoids
 constraining code alignement (aka. alignement), and use non-constraining code
 alignement (aka indentation) whenever possible, the exception being single line
 constructs. Below are four example explaining this principle.

*constraining code alignement, common VHDL style*

```vhdl
state_o(4 * k + m) <= state_0(4 * k + m) xor
                      state_1(4 * k + m) xor
                      state_2(4 * k + m) xor
                      state_3(4 * k + m);
```

*non-constraining code alignement, style I used*

```vhdl
state_o(4 * k + m) <=
    state_0(4 * k + m) xor
    state_1(4 * k + m) xor
    state_2(4 * k + m) xor
    state_3(4 * k + m);
```

It can be argued that the line return before the assignement is unatural,
the non-constraining code alignement has however several advantages:

* Text editors usually don't handle precise line alignement correctly when using
  tabs. The consequence of this is that when opening the file in a different
  editor, with a different tab size configuration, the alignment is lost, and
  the code becomes uglier than unaligned.
* Text editors may not handle alignement at all, while they all handle indenting
  which is what non-constraining code alignement fundamentally is.
* With non-constraining code alignement, a change in the lenght of first line
  does not induce a change of alignement in the following lines.

The latter point has three implications:

* It is possible to refactor variable names without worrying about breaking the
  formatting.
* Regarding, source versioning software, a change in the just the first line won't be seen as a change in the whole block, thus the diff outputs will be clearer and easier to read. It also helps avoiding merge collisions.
* Managing constraining code alignement takes time to the developer.

 The exception I did to the use of non-constraining code alignement was the case
 of variable declaration, where non-constraining code alignement doubles the use
 of vertical space and arguably reduces readability, see example below:

*non-constraining code alignement*

```vhdl
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

*constraining code alignement, style I exceptionally used*

```vhdl
port(
    skip_mc_i    : in b;
    skip_sb_sr_i : in b;

    roundkey_i   : in byte16;
    state_i      : in byte16;
    state_o      : out byte16
);
```

#### Placement of parenthesis

In most VHDL style, the closing parenthesis and braces are place at the end of
the last line of the block or group. In comparison, I placed the closing
parenthesis on a separate line. The idea is to help see missing parenthesis,
though arguably, it's more a matter of taste than a decision of practiacal
importance.