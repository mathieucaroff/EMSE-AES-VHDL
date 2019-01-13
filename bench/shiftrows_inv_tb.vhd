-- Mathieu CAROFF
-- 2019-01-13
-- Inverse Shiftrows test bench

use work.util_type.all;

library ieee;
use ieee.std_logic_1164.all;

entity shiftrows_inv_tb is
end shiftrows_inv_tb;

architecture behav of shiftrows_inv_tb is

    component tool_test_bench_byte16
        generic(
            name : string;
            test128_array : bit128_2_array
        );
        port(
            input_state_o  : out byte16;
            output_state_i : in  byte16
        );
    end component;

    component shiftrows_inv
        port(
            state_i : in  byte16;
            state_o : out byte16
        );
    end component;

    for shiftrows_inv_0 : shiftrows_inv
        use entity work.shiftrows_inv;
    for tool_test_bench_byte16_0 : tool_test_bench_byte16
        use entity work.tool_test_bench_byte16;
    signal state_is, state_os : byte16 := (others => x"00");

begin
    --  Component instantiation.
    tool_test_bench_byte16_0 :
    tool_test_bench_byte16 generic map(
        name => "shiftrows_inv",
        test128_array => (
            (
                x"0055AAFF4499EE3388DD2277CC1166BB",
                x"00112233445566778899AABBCCDDEEFF"
            )
            ,
            (
                x"06fb5f748506ca5ba654998e6109c156",
                x"0609995b85fbc18ea6065f566154ca74"
            )
            ,
            (
                x"84CB2929E4B4106E0261B0027BCAFBF3",
                x"84CAB06EE4CBFB0202B429F37B611029"
            )
            ,
            (
                x"9082F3CA1D1D5D53F0C899D174AD21C3",
                x"90AD99531D8221D1F01DF3C374C85DCA"
            )
            ,
            (
                x"002266DD111177AA220044BB333355CC",
                x"003344AA112255BB221166CC330077DD"
            )
        )
    ) port map(
        input_state_o  => state_is,
        output_state_i => state_os
    );
    
    shiftrows_inv_0 : shiftrows_inv
    port map(
        state_i => state_is,
        state_o => state_os
    );
end behav;
