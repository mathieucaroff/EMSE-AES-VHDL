-- Mathieu CAROFF
-- 2018-12-31
-- Inverse AES Round test bench

use work.util_str.all;
use work.util_type.all;

library ieee;

use std.textio.all;
use ieee.numeric_std.all;

use ieee.std_logic_1164.all;

entity aes_round_inv_tb is
end aes_round_inv_tb;   

architecture behav of aes_round_inv_tb is

    component aes_round_inv
        port(
            skip_mc_i    : in b; -- Skip (Inverse) Mix Columns?
            skip_sb_sr_i : in b; -- Skip (Inverse) SubBytes and ShiftRows?

            roundkey_i   : in byte16;
            state_i      : in byte16;
            state_o      : out byte16
        );
    end component;


    for aes_round_inv_0 : aes_round_inv use entity work.aes_round_inv;

    signal skip_mc_is, skip_sb_sr_is : b := '0';
    signal roundkey_is, state_is, state_os : byte16 := (others => x"00");

begin

    --  Component instantiation.
    aes_round_inv_0 :
        aes_round_inv
        port map(
            skip_mc_i => skip_mc_is,
            skip_sb_sr_i => skip_sb_sr_is,

            roundkey_i => roundkey_is,
            state_i => state_is,            
            state_o => state_os
        );

    --  This process does the real job.
    process

        type pattern_type is record
            skip_mc_i    : b;
            skip_sb_sr_i : b;
    
            roundkey_i   : bit128;
            state_i      : bit128;
            state_o      : bit128;
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
                -- The whole inverse round
                skip_mc_i    => '0',
                skip_sb_sr_i => '0',
                
                roundkey_i => x"00000000000000000000000000000000",
                state_i    => x"00000000000000000000000000000000",
                state_o    => x"52525252525252525252525252525252"
            )
            ,
            (
                -- The whole inverse round
                skip_mc_i    => '0',
                skip_sb_sr_i => '0',
                
                roundkey_i => x"00000000000000000000000000000000",
                state_i    => x"02010103020101030000000001010302",
                state_o    => x"09525252095252525252520952525252"
            )
            ,
            (
                -- Round 10 -- Just AddRoundKey
                skip_mc_i    => '1',
                skip_sb_sr_i => '1',
                
                roundkey_i => x"d014f9a8c9ee2589e13f0cc8b6630ca6",
                state_i    => x"d6efa6dc4ce8efd2476b9546d76acdf0",
                state_o    => x"06fb5f748506ca5ba654998e6109c156"
            )
            ,
            (
                -- Round 10 -- Without MixColumn
                skip_mc_i    => '1',
                skip_sb_sr_i => '0',
                
                roundkey_i => x"d014f9a8c9ee2589e13f0cc8b6630ca6",
                state_i    => x"d6efa6dc4ce8efd2476b9546d76acdf0",
                state_o    => x"a540f9576763dde6c5a584b9d8fd10ca"
            )
            ,
            (
                -- Round 9 -- The whole inverse round 
                skip_mc_i    => '0',
                skip_sb_sr_i => '0',
                
                roundkey_i => x"ac7766f319fadc2128d12941575c006e",
                state_i    => x"a540f9576763dde6c5a584b9d8fd10ca",
                state_o    => x"24bbbb7d8a0bfb944c4d621ff4fa643e"
            )
            ,
            (
                -- Round 8 -- The whole inverse round 
                skip_mc_i    => '0',
                skip_sb_sr_i => '0',
                
                roundkey_i => x"ead27321b58dbad2312bf5607f8d292f",
                state_i    => x"24bbbb7d8a0bfb944c4d621ff4fa643e",
                state_o    => x"66da7e47f0fd87d9ae385058cf51ad38"
            )
            ,
            (
                -- Round 1 -- The whole inverse round 
                skip_mc_i    => '0',
                skip_sb_sr_i => '0',
                
                roundkey_i => x"a0fafe1788542cb123a339392a6c7605",
                state_i    => x"9735fc29c5a52ea16d60ed2a9aed6606",
                state_o    => x"791b6662478eb7c88b817ce465aa6f03"
            )
            ,
            (
                -- Round 0 -- Just AddRoundKey
                skip_mc_i    => '1',
                skip_sb_sr_i => '1',
                
                roundkey_i => x"2b7e151628aed2a6abf7158809cf4f3c",
                state_i    => x"791b6662478eb7c88b817ce465aa6f03",
                state_o    => x"526573746f20656e2076696c6c65203f"
            )
        );

    begin    
        wait for 99 ns;
        for k in test_array'range loop
        
            --```python
            --liB = "skip_mc_i, skip_sb_sr_i".split(", ")
            --liV = "roundkey_i, state_i".split(", ")
            --templateB = "{ws:{m}} <= test_array(k).{w};"
            --templateV = "{ws:{m}} <= bit2byte(test_array(k).{w});"
            --m = 1 + max(map(len,liB+liV))
            --for templ, li in [(templateB, liB), (templateV, liV)]:
            --    print("\n".join(templ.format(ws=w + "s", w=w, m=m) for w in li))
            --```
            
            skip_mc_is    <= test_array(k).skip_mc_i;
            skip_sb_sr_is <= test_array(k).skip_sb_sr_i;
            roundkey_is   <= bit2byte(test_array(k).roundkey_i);
            state_is      <= bit2byte(test_array(k).state_i);

            wait for 1 ns;
        
            assert state_os = bit2byte(test_array(k).state_o)
            report
                "" &"error ("
                &NL&"  skipMC : " & bin("" & test_array(k).skip_mc_i)
                &NL&"  skipSB : " & bin("" & test_array(k).skip_sb_sr_i)
                &NL&"  rndKey : " & hex(test_array(k).roundkey_i)
                &NL&"  stateI : " & hex(test_array(k).state_i)
                &NL&"  stateO {" 
                &NL&"    expected : " & hex(test_array(k).state_o)
                &NL&"    got      : " & hex(byte2bit(state_os))
                &NL&"  }"
                &NL&")"
            severity error;

        end loop;
        wait for 1 ns;
        report "end";
        wait;
    end process;
end behav;
