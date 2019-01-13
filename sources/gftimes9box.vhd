-- Mathieu CAROFF
-- 2018-19-04
-- GF multiplication tables

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.util_type.all;
entity gftimes9box is
    port (
        byte_i : in  bit8;
        byte_o : out bit8
    );
end gftimes9box;


architecture gftimes9box_arch of gftimes9box is

    constant times9_lut : lut256 := (
        -- 0      1      2      3      4      5      6      7      8      9      A      B      C      D      E      F
        x"00", x"09", x"12", x"1B", x"24", x"2D", x"36", x"3F", x"48", x"41", x"5A", x"53", x"6C", x"65", x"7E", x"77", -- 0
        x"90", x"99", x"82", x"8B", x"B4", x"BD", x"A6", x"AF", x"D8", x"D1", x"CA", x"C3", x"FC", x"F5", x"EE", x"E7", -- 1
        x"3B", x"32", x"29", x"20", x"1F", x"16", x"0D", x"04", x"73", x"7A", x"61", x"68", x"57", x"5E", x"45", x"4C", -- 2
        x"AB", x"A2", x"B9", x"B0", x"8F", x"86", x"9D", x"94", x"E3", x"EA", x"F1", x"F8", x"C7", x"CE", x"D5", x"DC", -- 3
        x"76", x"7F", x"64", x"6D", x"52", x"5B", x"40", x"49", x"3E", x"37", x"2C", x"25", x"1A", x"13", x"08", x"01", -- 4
        x"E6", x"EF", x"F4", x"FD", x"C2", x"CB", x"D0", x"D9", x"AE", x"A7", x"BC", x"B5", x"8A", x"83", x"98", x"91", -- 5
        x"4D", x"44", x"5F", x"56", x"69", x"60", x"7B", x"72", x"05", x"0C", x"17", x"1E", x"21", x"28", x"33", x"3A", -- 6
        x"DD", x"D4", x"CF", x"C6", x"F9", x"F0", x"EB", x"E2", x"95", x"9C", x"87", x"8E", x"B1", x"B8", x"A3", x"AA", -- 7
        x"EC", x"E5", x"FE", x"F7", x"C8", x"C1", x"DA", x"D3", x"A4", x"AD", x"B6", x"BF", x"80", x"89", x"92", x"9B", -- 8
        x"7C", x"75", x"6E", x"67", x"58", x"51", x"4A", x"43", x"34", x"3D", x"26", x"2F", x"10", x"19", x"02", x"0B", -- 9
        x"D7", x"DE", x"C5", x"CC", x"F3", x"FA", x"E1", x"E8", x"9F", x"96", x"8D", x"84", x"BB", x"B2", x"A9", x"A0", -- A
        x"47", x"4E", x"55", x"5C", x"63", x"6A", x"71", x"78", x"0F", x"06", x"1D", x"14", x"2B", x"22", x"39", x"30", -- B
        x"9A", x"93", x"88", x"81", x"BE", x"B7", x"AC", x"A5", x"D2", x"DB", x"C0", x"C9", x"F6", x"FF", x"E4", x"ED", -- C
        x"0A", x"03", x"18", x"11", x"2E", x"27", x"3C", x"35", x"42", x"4B", x"50", x"59", x"66", x"6F", x"74", x"7D", -- D
        x"A1", x"A8", x"B3", x"BA", x"85", x"8C", x"97", x"9E", x"E9", x"E0", x"FB", x"F2", x"CD", x"C4", x"DF", x"D6", -- E
        x"31", x"38", x"23", x"2A", x"15", x"1C", x"07", x"0E", x"79", x"70", x"6B", x"62", x"5D", x"54", x"4F", x"46"  -- F
    );

begin

    byte_o <= times9_lut(to_integer(unsigned(byte_i(7 downto 0))));

end gftimes9box_arch;
