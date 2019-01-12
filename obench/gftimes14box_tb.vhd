-- Mathieu CAROFF
-- 2018-11-19
-- gftimes14box test bench
use work.util_type.all;

library ieee;
use ieee.std_logic_1164.all;

entity gftimes14box_tb is
end gftimes14box_tb;

architecture behav of gftimes14box_tb is

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

    component gftimes14box
        port(
            byte_i : in  bit8;
            byte_o : out bit8
        );
    end component;

    for gftimes14box_0 : gftimes14box use entity work.gftimes14box;
    for tool_test_bench_bit8_0 : tool_test_bench_bit8
        use entity work.tool_test_bench_bit8;
    
    signal byte_is, byte_os : bit8 := x"00";

begin
    tool_test_bench_bit8_0 : tool_test_bench_bit8
    generic map(
        name => "gftimes14box",
        test8_array => (
            (x"00", x"00"),
            (x"01", x"0E"),
            (x"10", x"E0"),
            (x"F0", x"D7"),
            (x"FF", x"8D")
        )
    )
    port map(
        input_byte_o  => byte_is,
        output_byte_i => byte_os
    );
    
    gftimes14box_0 : gftimes14box
    port map(
        byte_i => byte_is,
        byte_o => byte_os
    );
end behav;