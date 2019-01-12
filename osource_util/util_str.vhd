-- Mathieu CAROFF
-- 2018-11-20
-- util_str.vhd
-- Utilitary functions to convert vectors to strings

-- Test:
-- ```bash
-- ghdl -a util_str.vhd
-- ghdl -r util_str_tb
-- ```

-- The answer from Jonathan Bromley to the topic "std_logic_vector to string in hex format"
-- asked by Mad I.D. helped to write the functions below.
-- https://groups.google.com/forum/#!topic/comp.lang.vhdl/1RiLjbgoPy0

use work.util_type.all;

library ieee;
use ieee.std_logic_1164.all;

package util_str is

    constant NL : String := (1 => Character'Val(10));

    function bin(lvec : in std_logic_vector) return string;
    function hex(lvec : in std_logic_vector) return string;

end package;

package body util_str is

    function bin(lvec : in std_logic_vector) return string is
        variable text : string(lvec'length - 1 downto 0) := (others => '@');
        variable c : character;
    begin
        for k in lvec'range loop
            case lvec(k) is
                when '0'    => c := '0';
                when '1'    => c := '1';
                when 'U'    => c := 'U';
                when 'X'    => c := 'X';
                when 'Z'    => c := 'Z';
                when '-'    => c := '-';
                when others => c := '?';
            end case;
            text(k) := c;
        end loop;
        return text;
    end function;


    function hex(lvec : in std_logic_vector) return string is
        variable text : string(lvec'length / 4 - 1 downto 0) := (others => '@');
        variable c : character;
    begin
        assert lvec'length mod 4 = 0
        report "hex() works only with vectors whose length is a multiple of 4"
        severity FAILURE;
        for k in text'range loop
            case bit4'(lvec(4 * (k + 1) - 1 downto 4 * k)) is
                when "0000" => c := '0';
                when "0001" => c := '1';
                when "0010" => c := '2';
                when "0011" => c := '3';
                when "0100" => c := '4';
                when "0101" => c := '5';
                when "0110" => c := '6';
                when "0111" => c := '7';
                when "1000" => c := '8';
                when "1001" => c := '9';
                when "1010" => c := 'A';
                when "1011" => c := 'B';
                when "1100" => c := 'C';
                when "1101" => c := 'D';
                when "1110" => c := 'E';
                when "1111" => c := 'F';
                when others => c := '!';
            end case;
            
            text(k) := c;
        end loop;
        return text;
    end function;

end package body;
