-- Mathieu CAROFF
-- 2019-01-13
-- Inverse Sbox test bench

use work.util_type.all;

library ieee;
use ieee.std_logic_1164.all;

entity sbox_inv_tb is
end sbox_inv_tb;

architecture behav of sbox_inv_tb is

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

    component sbox_inv
        port(
            byte_i : in  bit8;
            byte_o : out bit8
        );
    end component;

    for sbox_inv_0 : sbox_inv
        use entity work.sbox_inv;
    for tool_test_bench_bit8_0 : tool_test_bench_bit8
        use entity work.tool_test_bench_bit8;
    signal byte_is, byte_os : bit8 := x"00";

begin
    tool_test_bench_bit8_0 :
    tool_test_bench_bit8 generic map(
        name => "sbox_inv",
        test8_array => (
            ("00000000", "01010010")
            , -- :0x52
            ("00000001", "00001001")
            , -- :0x09
            ("00010000", "01111100")
            , -- :0x7C
            ("00100000", "01010100")
            , -- :0x54
            ("11110000", "00010111")
            , -- :0x17
            ("11111111", "01111101")
            , -- :0x7D
            ("01100011", "00000000")
            , -- 0x63:
            ("01111100", "00000001")
            , -- 0x7C:
            ("11001010", "00010000")
            , -- 0xCA:
            ("10110111", "00100000")
            , -- 0xB7:
            ("10001100", "11110000")
            , -- 0x8C:
            ("00010110", "11111111")  -- 0x16:
        )
    ) port map(
        input_byte_o  => byte_is,
        output_byte_i => byte_os
    );
    
    sbox_inv_0 : sbox_inv
    port map(
        byte_i => byte_is,
        byte_o => byte_os
    );
end behav;
