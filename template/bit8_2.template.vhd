{author}{date}-- {description}

use work.util_type.all;

library ieee;
use ieee.std_logic_1164.all;

entity {name}_tb is
end {name}_tb;

architecture behav of {name}_tb is

    component tool_test_bench_bit8
        generic(
            name : string;
            test8_array : bit8_2_array
        );
        port(
            input_byte_o  : out bit8;
            output_byte_i : in  bit8
        );
    end component;

    component {name}
        port(
            {byte_i:{s}} : in  bit8;
            {byte_o:{s}} : out bit8
        );
    end component;

    for {name}_0 : {name}
        use entity work.{name};
    for tool_test_bench_bit8_0 : tool_test_bench_bit8
        use entity work.tool_test_bench_bit8;
    signal byte_is, byte_os : bit8 := x"00";

begin
    tool_test_bench_bit8_0 :
    tool_test_bench_bit8 generic map(
        name => "{name}",
        test8_array => ({test_array}
        )
    ) port map(
        input_byte_o  => byte_is,
        output_byte_i => byte_os
    );
    
    {name}_0 : {name}
    port map(
        {byte_i:{s}} => byte_is,
        {byte_o:{s}} => byte_os
    );
end behav;
