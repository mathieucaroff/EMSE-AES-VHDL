{author}{date}-- {description}

use work.util_type.all;

library ieee;
use ieee.std_logic_1164.all;

entity {name}_tb is
end {name}_tb;

architecture behav of {name}_tb is

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

    component {name}
        port(
            {state0_i:{s}} : in  byte16;
            {state1_i:{s}} : in  byte16;
            {state_o:{s}} : out byte16
        );
    end component;

    for {name}_0 : {name}
        use entity work.{name};
    for tool_test_bench_byte16_3_0 : tool_test_bench_byte16_3
        use entity work.tool_test_bench_byte16_3;
    signal state0_is, state1_is, state_os : byte16 := (others => x"00");

begin
    tool_test_bench_byte16_3_0 :
    tool_test_bench_byte16_3 generic map(
        name => "{name}",
        test128_array => ({test_array}
        )
    ) port map(
        input0_state_o => state0_is,
        input1_state_o => state1_is,
        output_state_i => state_os
    );
    
    {name}_0 : {name}
    port map(
        {state0_i:{s}} => state0_is,
        {state1_i:{s}} => state1_is,
        {state_o:{s}} => state_os
    );
end behav;
