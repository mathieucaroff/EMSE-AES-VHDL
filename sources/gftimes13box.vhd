-- Mathieu CAROFF
-- 2018-19-04
-- GF multiplication tables

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.util_type.all;
entity gftimes13box is
    port (
        byte_i : in  bit8;
        byte_o : out bit8
    );
end gftimes13box;


architecture gftimes13box_arch of gftimes13box is

    constant times13_lut : lut256 := (
        -- 0      1      2      3      4      5      6      7      8      9      A      B      C      D      E      F
        x"00", x"0D", x"1A", x"17", x"34", x"39", x"2E", x"23", x"68", x"65", x"72", x"7F", x"5C", x"51", x"46", x"4B", -- 0
        x"D0", x"DD", x"CA", x"C7", x"E4", x"E9", x"FE", x"F3", x"B8", x"B5", x"A2", x"AF", x"8C", x"81", x"96", x"9B", -- 1
        x"BB", x"B6", x"A1", x"AC", x"8F", x"82", x"95", x"98", x"D3", x"DE", x"C9", x"C4", x"E7", x"EA", x"FD", x"F0", -- 2
        x"6B", x"66", x"71", x"7C", x"5F", x"52", x"45", x"48", x"03", x"0E", x"19", x"14", x"37", x"3A", x"2D", x"20", -- 3
        x"6D", x"60", x"77", x"7A", x"59", x"54", x"43", x"4E", x"05", x"08", x"1F", x"12", x"31", x"3C", x"2B", x"26", -- 4
        x"BD", x"B0", x"A7", x"AA", x"89", x"84", x"93", x"9E", x"D5", x"D8", x"CF", x"C2", x"E1", x"EC", x"FB", x"F6", -- 5
        x"D6", x"DB", x"CC", x"C1", x"E2", x"EF", x"F8", x"F5", x"BE", x"B3", x"A4", x"A9", x"8A", x"87", x"90", x"9D", -- 6
        x"06", x"0B", x"1C", x"11", x"32", x"3F", x"28", x"25", x"6E", x"63", x"74", x"79", x"5A", x"57", x"40", x"4D", -- 7
        x"DA", x"D7", x"C0", x"CD", x"EE", x"E3", x"F4", x"F9", x"B2", x"BF", x"A8", x"A5", x"86", x"8B", x"9C", x"91", -- 8
        x"0A", x"07", x"10", x"1D", x"3E", x"33", x"24", x"29", x"62", x"6F", x"78", x"75", x"56", x"5B", x"4C", x"41", -- 9
        x"61", x"6C", x"7B", x"76", x"55", x"58", x"4F", x"42", x"09", x"04", x"13", x"1E", x"3D", x"30", x"27", x"2A", -- A
        x"B1", x"BC", x"AB", x"A6", x"85", x"88", x"9F", x"92", x"D9", x"D4", x"C3", x"CE", x"ED", x"E0", x"F7", x"FA", -- B
        x"B7", x"BA", x"AD", x"A0", x"83", x"8E", x"99", x"94", x"DF", x"D2", x"C5", x"C8", x"EB", x"E6", x"F1", x"FC", -- C
        x"67", x"6A", x"7D", x"70", x"53", x"5E", x"49", x"44", x"0F", x"02", x"15", x"18", x"3B", x"36", x"21", x"2C", -- D
        x"0C", x"01", x"16", x"1B", x"38", x"35", x"22", x"2F", x"64", x"69", x"7E", x"73", x"50", x"5D", x"4A", x"47", -- E
        x"DC", x"D1", x"C6", x"CB", x"E8", x"E5", x"F2", x"FF", x"B4", x"B9", x"AE", x"A3", x"80", x"8D", x"9A", x"97"  -- F
    );

begin

    byte_o <= times13_lut(to_integer(unsigned(byte_i(7 downto 0))));

end gftimes13box_arch;
