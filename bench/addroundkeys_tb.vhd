-- Mathieu CAROFF
-- 2019-01-13
-- Add Round Keys test bench

use work.util_type.all;

library ieee;
use ieee.std_logic_1164.all;

entity addroundkeys_tb is
end addroundkeys_tb;

architecture behav of addroundkeys_tb is

    component tool_test_bench_byte16_3
        generic(
            name : string;
            test128_array : bit128_3_array
        );
        port(
            input0_state_o : out byte16;
            input1_state_o : out byte16;
            output_state_i : in  byte16
        );
    end component;

    component addroundkeys
        port(
            roundkey_i : in  byte16;
            state_i    : in  byte16;
            state_o    : out byte16
        );
    end component;

    for addroundkeys_0 : addroundkeys
        use entity work.addroundkeys;
    for tool_test_bench_byte16_3_0 : tool_test_bench_byte16_3
        use entity work.tool_test_bench_byte16_3;
    signal state0_is, state1_is, state_os : byte16 := (others => x"00");

begin
    tool_test_bench_byte16_3_0 :
    tool_test_bench_byte16_3 generic map(
        name => "addroundkeys",
        test128_array => (
            (
                x"00112233445566778899AABBCCDDEEFF",
                x"000102030405060708090A0B0C0D0E0F",
                x"00102030405060708090A0B0C0D0E0F0"
            )
            ,
            (
                x"00112233445566778899AABBCCDDEEFF",
                x"00102030405060708090A0B0C0D0E0F0",
                x"000102030405060708090A0B0C0D0E0F"
            )
            ,
            (
                x"00102030405060708090A0B0C0D0E0F0",
                x"000102030405060708090A0B0C0D0E0F",
                x"00112233445566778899AABBCCDDEEFF"
            )
            ,
            (
                x"341020304C7766000090A0B0C0D0E015",
                x"420102031112AC0080000A0B0C0D0E34",
                x"761122335D65CA008090AABBCCDDEE21"
            )
        )
    ) port map(
        input0_state_o => state0_is,
        input1_state_o => state1_is,
        output_state_i => state_os
    );
    
    addroundkeys_0 : addroundkeys
    port map(
        roundkey_i => state0_is,
        state_i    => state1_is,
        state_o    => state_os
    );
end behav;
