-- Mathieu CAROFF
-- 2018-11-20
-- util_str_tb.vhd
-- Test for string functions bin() and hex() of `util_str.vhd`

library ieee;

use ieee.std_logic_1164.all;
use work.util_str.all;

entity util_str_tb is
end entity;

architecture util_str_tb_arch of util_str_tb is
begin
    process is
        constant byte : std_logic_vector(12 - 1 downto 0) := "000001001111";
    begin
        assert bin(byte) = "000001001111" report "bin() error";
        assert hex(byte) = "04F" report "hex() error";
        
        report "end";
        wait;
    end process;
end architecture;
