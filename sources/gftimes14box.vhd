-- Mathieu CAROFF
-- 2018-19-04
-- GF multiplication tables

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.util_type.all;
entity gftimes14box is
    port (
        byte_i : in  bit8;
        byte_o : out bit8
    );
end gftimes14box;


architecture gftimes14box_arch of gftimes14box is

    constant times14_lut : lut256 := (
        -- 0      1      2      3      4      5      6      7      8      9      A      B      C      D      E      F
        x"00", x"0E", x"1C", x"12", x"38", x"36", x"24", x"2A", x"70", x"7E", x"6C", x"62", x"48", x"46", x"54", x"5A", -- 0
        x"E0", x"EE", x"FC", x"F2", x"D8", x"D6", x"C4", x"CA", x"90", x"9E", x"8C", x"82", x"A8", x"A6", x"B4", x"BA", -- 1
        x"DB", x"D5", x"C7", x"C9", x"E3", x"ED", x"FF", x"F1", x"AB", x"A5", x"B7", x"B9", x"93", x"9D", x"8F", x"81", -- 2
        x"3B", x"35", x"27", x"29", x"03", x"0D", x"1F", x"11", x"4B", x"45", x"57", x"59", x"73", x"7D", x"6F", x"61", -- 3
        x"AD", x"A3", x"B1", x"BF", x"95", x"9B", x"89", x"87", x"DD", x"D3", x"C1", x"CF", x"E5", x"EB", x"F9", x"F7", -- 4
        x"4D", x"43", x"51", x"5F", x"75", x"7B", x"69", x"67", x"3D", x"33", x"21", x"2F", x"05", x"0B", x"19", x"17", -- 5
        x"76", x"78", x"6A", x"64", x"4E", x"40", x"52", x"5C", x"06", x"08", x"1A", x"14", x"3E", x"30", x"22", x"2C", -- 6
        x"96", x"98", x"8A", x"84", x"AE", x"A0", x"B2", x"BC", x"E6", x"E8", x"FA", x"F4", x"DE", x"D0", x"C2", x"CC", -- 7
        x"41", x"4F", x"5D", x"53", x"79", x"77", x"65", x"6B", x"31", x"3F", x"2D", x"23", x"09", x"07", x"15", x"1B", -- 8
        x"A1", x"AF", x"BD", x"B3", x"99", x"97", x"85", x"8B", x"D1", x"DF", x"CD", x"C3", x"E9", x"E7", x"F5", x"FB", -- 9
        x"9A", x"94", x"86", x"88", x"A2", x"AC", x"BE", x"B0", x"EA", x"E4", x"F6", x"F8", x"D2", x"DC", x"CE", x"C0", -- A
        x"7A", x"74", x"66", x"68", x"42", x"4C", x"5E", x"50", x"0A", x"04", x"16", x"18", x"32", x"3C", x"2E", x"20", -- B
        x"EC", x"E2", x"F0", x"FE", x"D4", x"DA", x"C8", x"C6", x"9C", x"92", x"80", x"8E", x"A4", x"AA", x"B8", x"B6", -- C
        x"0C", x"02", x"10", x"1E", x"34", x"3A", x"28", x"26", x"7C", x"72", x"60", x"6E", x"44", x"4A", x"58", x"56", -- D
        x"37", x"39", x"2B", x"25", x"0F", x"01", x"13", x"1D", x"47", x"49", x"5B", x"55", x"7F", x"71", x"63", x"6D", -- E
        x"D7", x"D9", x"CB", x"C5", x"EF", x"E1", x"F3", x"FD", x"A7", x"A9", x"BB", x"B5", x"9F", x"91", x"83", x"8D"  -- F
    );

begin

    byte_o <= times14_lut(to_integer(unsigned(byte_i(7 downto 0))));

end gftimes14box_arch;
