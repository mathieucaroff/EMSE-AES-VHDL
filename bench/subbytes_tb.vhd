-- Mathieu CAROFF
-- 2019-01-13
-- Subbytes test bench

use work.util_type.all;

library ieee;
use ieee.std_logic_1164.all;

entity subbytes_tb is
end subbytes_tb;

architecture behav of subbytes_tb is

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

    component subbytes
        port(
            state_i : in  byte16;
            state_o : out byte16
        );
    end component;

    for subbytes_0 : subbytes
        use entity work.subbytes;
    for tool_test_bench_byte16_0 : tool_test_bench_byte16
        use entity work.tool_test_bench_byte16;
    signal state_is, state_os : byte16 := (others => x"00");

begin
    --  Component instantiation.
    tool_test_bench_byte16_0 :
    tool_test_bench_byte16 generic map(
        name => "subbytes",
        test128_array => (
            (
                x"0000000000011020F0FF52097C54177D",
                x"63636363637CCAB78C1600011020F0FF"
            )
            ,
            (
                x"01001001001020F0FF52097C54177D00",
                x"7C63CA7C63CAB78C1600011020F0FF63"
            )
        )
    ) port map(
        input_state_o  => state_is,
        output_state_i => state_os
    );
    
    subbytes_0 : subbytes
    port map(
        state_i => state_is,
        state_o => state_os
    );
end behav;
