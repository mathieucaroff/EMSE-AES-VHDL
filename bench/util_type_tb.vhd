-- Mathieu CAROFF
-- 2018-12-04
-- util_type.vhd
-- Testing utilitary functions provided by util_type

library ieee;

use ieee.std_logic_1164.all;
use work.util_type.all;

entity util_type_tb is
end entity;

architecture util_type_tb_arch of util_type_tb is
begin
    process is
        constant z : bit128 := x"00112233445566778899AABBCCDDEEFF";
        constant y : bit128 := x"004488CC115599DD2266AAEE3377BBFF";
        constant a : byte16 := bit2byte(z);
        constant b : byte16 := bit2byte(y);
    begin

        assert a = a report "error aa";
        assert transpose(a) = transpose(a) report "error tata";
        assert transpose(a) = b report "error tab";
        assert transpose(b) = a report "error tba";
        assert transpose(transpose(a)) = a report "error taa";

        report "end";

        wait;
    end process;
end architecture;
