{author}{date}-- {description}

use work.util_type.all;

library ieee;
use ieee.std_logic_1164.all;

entity {name}_tb is
end {name}_tb;

architecture behav of {name}_tb is

    component tool_test_bench_bit8_3
        generic(
            name : string;
            test8_array : bit8_3_array
        );
        port(
            input0_byte_o : out bit8;
            input1_byte_o : out bit8;
            output_byte_i : in  bit8
        );
    end component;

    component {name}
        port(
            {byte0_i:{s}} : in  bit8;
            {byte1_i:{s}} : in  bit8;
            {byte_o:{s}} : out bit8
        );
    end component;

    for {name}_0 : {name}
        use entity work.{name};
    for tool_test_bench_bit8_3_0 : tool_test_bench_bit8_3
        use entity work.tool_test_bench_bit8_3;
    signal byte0_is, byte1_is, byte_os : bit8 := x"00";

begin
    tool_test_bench_bit8_3_0 :
    tool_test_bench_bit8_3 generic map(
        name => "{name}",
        test8_array => ({test_array}
        )
    ) port map(
        input0_byte_o => byte0_is,
        input1_byte_o => byte1_is,
        output_byte_i => byte_os
    );
    
    {name}_0 : {name}
    port map(
        {byte0_i:{s}} => byte0_is,
        {byte1_i:{s}} => byte1_is,
        {byte_o:{s}} => byte_os
    );
end behav;
