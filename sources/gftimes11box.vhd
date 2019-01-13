-- Mathieu CAROFF
-- 2018-19-04
-- GF multiplication tables

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.util_type.all;
entity gftimes11box is
    port (
        byte_i : in  bit8;
        byte_o : out bit8
    );
end gftimes11box;


architecture gftimes11box_arch of gftimes11box is

    constant times11_lut : lut256 := (
        -- 0      1      2      3      4      5      6      7      8      9      A      B      C      D      E      F
        x"00", x"0B", x"16", x"1D", x"2C", x"27", x"3A", x"31", x"58", x"53", x"4E", x"45", x"74", x"7F", x"62", x"69", -- 0
        x"B0", x"BB", x"A6", x"AD", x"9C", x"97", x"8A", x"81", x"E8", x"E3", x"FE", x"F5", x"C4", x"CF", x"D2", x"D9", -- 1
        x"7B", x"70", x"6D", x"66", x"57", x"5C", x"41", x"4A", x"23", x"28", x"35", x"3E", x"0F", x"04", x"19", x"12", -- 2
        x"CB", x"C0", x"DD", x"D6", x"E7", x"EC", x"F1", x"FA", x"93", x"98", x"85", x"8E", x"BF", x"B4", x"A9", x"A2", -- 3
        x"F6", x"FD", x"E0", x"EB", x"DA", x"D1", x"CC", x"C7", x"AE", x"A5", x"B8", x"B3", x"82", x"89", x"94", x"9F", -- 4
        x"46", x"4D", x"50", x"5B", x"6A", x"61", x"7C", x"77", x"1E", x"15", x"08", x"03", x"32", x"39", x"24", x"2F", -- 5
        x"8D", x"86", x"9B", x"90", x"A1", x"AA", x"B7", x"BC", x"D5", x"DE", x"C3", x"C8", x"F9", x"F2", x"EF", x"E4", -- 6
        x"3D", x"36", x"2B", x"20", x"11", x"1A", x"07", x"0C", x"65", x"6E", x"73", x"78", x"49", x"42", x"5F", x"54", -- 7
        x"F7", x"FC", x"E1", x"EA", x"DB", x"D0", x"CD", x"C6", x"AF", x"A4", x"B9", x"B2", x"83", x"88", x"95", x"9E", -- 8
        x"47", x"4C", x"51", x"5A", x"6B", x"60", x"7D", x"76", x"1F", x"14", x"09", x"02", x"33", x"38", x"25", x"2E", -- 9
        x"8C", x"87", x"9A", x"91", x"A0", x"AB", x"B6", x"BD", x"D4", x"DF", x"C2", x"C9", x"F8", x"F3", x"EE", x"E5", -- A
        x"3C", x"37", x"2A", x"21", x"10", x"1B", x"06", x"0D", x"64", x"6F", x"72", x"79", x"48", x"43", x"5E", x"55", -- B
        x"01", x"0A", x"17", x"1C", x"2D", x"26", x"3B", x"30", x"59", x"52", x"4F", x"44", x"75", x"7E", x"63", x"68", -- C
        x"B1", x"BA", x"A7", x"AC", x"9D", x"96", x"8B", x"80", x"E9", x"E2", x"FF", x"F4", x"C5", x"CE", x"D3", x"D8", -- D
        x"7A", x"71", x"6C", x"67", x"56", x"5D", x"40", x"4B", x"22", x"29", x"34", x"3F", x"0E", x"05", x"18", x"13", -- E
        x"CA", x"C1", x"DC", x"D7", x"E6", x"ED", x"F0", x"FB", x"92", x"99", x"84", x"8F", x"BE", x"B5", x"A8", x"A3"  -- F
    );

begin

    byte_o <= times11_lut(to_integer(unsigned(byte_i(7 downto 0))));

end gftimes11box_arch;
