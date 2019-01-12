-- Mathieu CAROFF
-- 2018-12-31
-- Inverse AES Round test bench

use work.util_str.all;
use work.util_type.all;

library ieee;

use std.textio.all;
use ieee.numeric_std.all;

use ieee.std_logic_1164.all;

entity aes128_fsm_moore_inv_tb is
end aes128_fsm_moore_inv_tb;   

architecture behav of aes128_fsm_moore_inv_tb is

    component aes128_fsm_moore_inv
        port(
            clk_i    : in  b;
            reset_i  : in  b;
            start_i  : in  b;
            
            key_i    : in  bit128;
            data_i   : in  bit128;
            data_o   : out bit128;
            
            aes_on_o : out b
        );
    end component;


    for aes128_fsm_moore_inv_0 : aes128_fsm_moore_inv use entity work.aes128_fsm_moore_inv;

    signal clk_is, reset_is, start_is, aes_on_os : b := '0';
    signal key_is, data_is, data_os : bit128 := (others => '0');

begin

    aes128_fsm_moore_inv_0 :
        aes128_fsm_moore_inv
        port map(
            clk_i    => clk_is,
            reset_i  => reset_is,
            start_i  => start_is,
            
            key_i    => key_is,
            data_i   => data_is,
            data_o   => data_os,
            
            aes_on_o => aes_on_os
        );

    process
    begin    
        wait for 99 ns;
        
        -- Testing the reset_i
        
        clk_is <= '0';
        
        reset_is <= '1';
        start_is <= '0';
        
        key_is   <= x"00000000000000000000000000000000";
        data_is  <= x"00000000000000000000000000000000";

        wait for 500 ps;

        clk_is <= '1';

        wait for 500 ps;

        assert data_os = x"00000000000000000000000000000000"
        report "data_os error: " & hex(data_os)
        ;
        assert aes_on_os = '0'
        report "aes_on_os error: " & bin("" & aes_on_os)
        ;
        
        
        -- Testing the inverse cypher
        
        clk_is <= '0';
        
        reset_is <= '0';
        start_is <= '1';
        
        key_is   <= x"2b7e151628aed2a6abf7158809cf4f3c";
        data_is  <= x"d6efa6dc4ce8efd2476b9546d76acdf0";

        wait for 500 ps;

        clk_is <= '1';

        wait for 500 ps;
        
        
        for i in 1 to 10 loop
            clk_is <= '0';
            wait for 500 ps;
            clk_is <= '1';
            wait for 500 ps;
        end loop;
        
        assert data_os = x"526573746f20656e2076696c6c65203f"
        report "data_os error: " & hex(data_os)
        ;
        assert aes_on_os = '0'
        report "aes_on_os error: " & bin("" & aes_on_os)
        ;


        wait for 1 ns;
        report "end";
        wait;
    end process;
end behav;
