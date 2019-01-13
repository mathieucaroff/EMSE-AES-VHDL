-- Mathieu CAROFF
-- 2019-01-13
-- Shiftrows test bench

use work.util_type.all;

library ieee;
use ieee.std_logic_1164.all;

entity shiftrows_tb is
end shiftrows_tb;

architecture behav of shiftrows_tb is

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

    component shiftrows
        port(
            state_i : in  byte16;
            state_o : out byte16
        );
    end component;

    for shiftrows_0 : shiftrows
        use entity work.shiftrows;
    for tool_test_bench_byte16_0 : tool_test_bench_byte16
        use entity work.tool_test_bench_byte16;
    signal state_is, state_os : byte16 := (others => x"00");

begin
    --  Component instantiation.
    tool_test_bench_byte16_0 :
    tool_test_bench_byte16 generic map(
        name => "shiftrows",
        test128_array => (
            (
                x"00112233445566778899AABBCCDDEEFF",
                x"0055AAFF4499EE3388DD2277CC1166BB"
            )
            ,
            (
                x"0609995b85fbc18ea6065f566154ca74",
                x"06fb5f748506ca5ba654998e6109c156"
            )
            ,
            (
                x"84CAB06EE4CBFB0202B429F37B611029",
                x"84CB2929E4B4106E0261B0027BCAFBF3"
            )
            ,
            (
                x"90AD99531D8221D1F01DF3C374C85DCA",
                x"9082F3CA1D1D5D53F0C899D174AD21C3"
            )
            ,
            (
                x"003344AA112255BB221166CC330077DD",
                x"002266DD111177AA220044BB333355CC"
            )
        )
    ) port map(
        input_state_o  => state_is,
        output_state_i => state_os
    );
    
    shiftrows_0 : shiftrows
    port map(
        state_i => state_is,
        state_o => state_os
    );
end behav;
