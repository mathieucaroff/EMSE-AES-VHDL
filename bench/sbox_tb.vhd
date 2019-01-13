-- Mathieu CAROFF
-- 2019-01-13
-- SBox test bench

use work.util_type.all;

library ieee;
use ieee.std_logic_1164.all;

entity sbox_tb is
end sbox_tb;

architecture behav of sbox_tb is

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

    component sbox
        port(
            byte_i : in  bit8;
            byte_o : out bit8
        );
    end component;

    for sbox_0 : sbox
        use entity work.sbox;
    for tool_test_bench_bit8_0 : tool_test_bench_bit8
        use entity work.tool_test_bench_bit8;
    signal byte_is, byte_os : bit8 := x"00";

begin
    tool_test_bench_bit8_0 :
    tool_test_bench_bit8 generic map(
        name => "sbox",
        test8_array => (
            ("00000000", "01100011")
            , -- :0x63
            ("00000001", "01111100")
            , -- :0x7C
            ("00010000", "11001010")
            , -- :0xCA
            ("00100000", "10110111")
            , -- :0xB7
            ("11110000", "10001100")
            , -- :0x8C
            ("11111111", "00010110")
            , -- :0x16
            ("01010010", "00000000")
            , -- 0x52:
            ("00001001", "00000001")
            , -- 0x09:
            ("01111100", "00010000")
            , -- 0x7C:
            ("01010100", "00100000")
            , -- 0x54:
            ("00010111", "11110000")
            , -- 0x17:
            ("01111101", "11111111")  -- 0x7D:
        )
    ) port map(
        input_byte_o  => byte_is,
        output_byte_i => byte_os
    );
    
    sbox_0 : sbox
    port map(
        byte_i => byte_is,
        byte_o => byte_os
    );
end behav;
