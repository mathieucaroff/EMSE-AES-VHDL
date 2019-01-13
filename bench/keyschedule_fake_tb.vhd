-- Mathieu CAROFF
-- 2018-01-11
-- Key Schedule test bench

use work.util_str.all;
use work.util_type.all;

library ieee;

use std.textio.all;
use ieee.numeric_std.all;

use ieee.std_logic_1164.all;

entity keyschedule_fake_tb is
end keyschedule_fake_tb;   

architecture behav of keyschedule_fake_tb is

    component keyschedule_fake
        port(
            round_index_i : in bit4;  -- between 0 and 14, target index
            
            key_i      : in  byte16;  -- the key to copy
            roundkey_o : out byte16  -- the roundkey (result)
        );
    end component;


    for keyschedule_fake_0 : keyschedule_fake use entity work.keyschedule_fake;

    constant key_bit_is : bit128 := x"2b7e151628aed2a6abf7158809cf4f3c";

    signal round_index_is : bit4 := x"0";
    signal key_is : byte16 := bit2byte(key_bit_is);

    signal roundkey_os : byte16 := (others => x"00");

begin
    --  Component instantiation.
    keyschedule_fake_0 :
        keyschedule_fake
        port map(
            round_index_i => round_index_is,
            
            key_i => key_is,
            roundkey_o => roundkey_os
        );

    --  This process does the real job.
    process

        type pattern_type is record
            round_index_i     : bit4;   -- between 0 and 14, target index

            key_i             : bit128; -- the key to copy
            roundkey_o        : bit128; -- the roundkey (result)
        end record;
        type pattern_array is array (natural range <>) of pattern_type;
        constant test_array : pattern_array := (
            -- These 5 tests are from the uncipher of
            -- cipyer text: d6 ef a6 dc 4c e8 ef d2 47 6b 95 46 d7 6a cd f0
            -- whose plain text is
            -- plain textt: d6 ef a6 dc 4c e8 ef d2 47 6b 95 46 d7 6a cd f0
            -- (ASCII) Resto en ville ?
            -- with the key
            -- key: 2b 7e 15 16 28 ae d2 a6 ab f7 15 88 09 cf 4f 3c
            
            (
                round_index_i => x"0",
                key_i         => x"2b7e151628aed2a6abf7158809cf4f3c",
                roundkey_o    => x"2b7e151628aed2a6abf7158809cf4f3c"
            )
            ,
            (
                round_index_i => x"1",
                key_i         => x"2b7e151628aed2a6abf7158809cf4f3c",
                roundkey_o    => x"a0fafe1788542cb123a339392a6c7605"
            )
            ,
            (
                round_index_i => x"A", -- 10
                key_i         => x"2b7e151628aed2a6abf7158809cf4f3c",
                roundkey_o    => x"d014f9a8c9ee2589e13f0cc8b6630ca6"
            )
            ,
            (
                round_index_i => x"2",
                key_i         => x"2b7e151628aed2a6abf7158809cf4f3c",
                roundkey_o    => x"f2c295f27a96b9435935807a7359f67f"
            )
        );

    begin    
        wait for 99 ns;
        for k in test_array'range loop


            round_index_is <= test_array(k).round_index_i;
            key_is         <= bit2byte(test_array(k).key_i);

            wait for 1 ns;

            assert roundkey_os = bit2byte(test_array(k).roundkey_o)
            report
                "" &"error ("
                &NL&"  rindex : " & hex(test_array(k).round_index_i)
                &NL&"  key_is : " & hex(test_array(k).key_i)
                &NL&"  roundkey_os {" 
                &NL&"    expected : " & hex(test_array(k).roundkey_o)
                &NL&"    got      : " & hex(byte2bit(roundkey_os))
                &NL&"  }"
                &NL&")"
            severity error
            ;

        end loop;
        wait for 1 ns;
        report "end";
        wait;
    end process;
end behav;
