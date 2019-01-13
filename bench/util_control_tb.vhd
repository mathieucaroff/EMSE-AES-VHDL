-- Mathieu CAROFF
-- 2018-11-20
-- util_control_tb.vhd
-- Test of utilitary functions which manage control flow.

library ieee;

use ieee.std_logic_1164.all;
use work.util_control.all;

entity util_control_tb is
end entity;

architecture util_control_tb_arch of util_control_tb is
begin
    process is
    begin
        assert sel(true , "a", "b") = "a" report "error sel() 0" severity error;
        assert sel(false, "a", "b") = "b" report "error sel() 1" severity error;
        report "end";
        wait;
    end process;
end architecture;
