{author}{date}-- {description}

use work.util_type.all;

library ieee;
use ieee.std_logic_1164.all;

entity {name}_tb is
end {name}_tb;

architecture behav of {name}_tb is

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

    component {name}
        port(
            {state_i:{s}} : in  byte16;
            {state_o:{s}} : out byte16
        );
    end component;

    for {name}_0 : {name}
        use entity work.{name};
    for tool_test_bench_byte16_0 : tool_test_bench_byte16
        use entity work.tool_test_bench_byte16;
    signal state_is, state_os : byte16 := (others => x"00");

begin
    --  Component instantiation.
    tool_test_bench_byte16_0 :
    tool_test_bench_byte16 generic map(
        name => "{name}",
        test128_array => ({test_array}
        )
    ) port map(
        input_state_o  => state_is,
        output_state_i => state_os
    );
    
    {name}_0 : {name}
    port map(
        {state_i:{s}} => state_is,
        {state_o:{s}} => state_os
    );
end behav;
