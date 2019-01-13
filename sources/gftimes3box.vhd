-- Mathieu CAROFF
-- 2018-19-04
-- GF multiplication tables

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.util_type.all;
entity gftimes3box is
    port (
        byte_i : in  bit8;
        byte_o : out bit8
    );
end gftimes3box;


architecture gftimes3box_arch of gftimes3box is

    constant times3_lut : lut256 := (
        -- 0      1      2      3      4      5      6      7      8      9      A      B      C      D      E      F
        x"00", x"03", x"06", x"05", x"0C", x"0F", x"0A", x"09", x"18", x"1B", x"1E", x"1D", x"14", x"17", x"12", x"11", -- 0
        x"30", x"33", x"36", x"35", x"3C", x"3F", x"3A", x"39", x"28", x"2B", x"2E", x"2D", x"24", x"27", x"22", x"21", -- 1
        x"60", x"63", x"66", x"65", x"6C", x"6F", x"6A", x"69", x"78", x"7B", x"7E", x"7D", x"74", x"77", x"72", x"71", -- 2
        x"50", x"53", x"56", x"55", x"5C", x"5F", x"5A", x"59", x"48", x"4B", x"4E", x"4D", x"44", x"47", x"42", x"41", -- 3
        x"C0", x"C3", x"C6", x"C5", x"CC", x"CF", x"CA", x"C9", x"D8", x"DB", x"DE", x"DD", x"D4", x"D7", x"D2", x"D1", -- 4
        x"F0", x"F3", x"F6", x"F5", x"FC", x"FF", x"FA", x"F9", x"E8", x"EB", x"EE", x"ED", x"E4", x"E7", x"E2", x"E1", -- 5
        x"A0", x"A3", x"A6", x"A5", x"AC", x"AF", x"AA", x"A9", x"B8", x"BB", x"BE", x"BD", x"B4", x"B7", x"B2", x"B1", -- 6
        x"90", x"93", x"96", x"95", x"9C", x"9F", x"9A", x"99", x"88", x"8B", x"8E", x"8D", x"84", x"87", x"82", x"81", -- 7
        x"9B", x"98", x"9D", x"9E", x"97", x"94", x"91", x"92", x"83", x"80", x"85", x"86", x"8F", x"8C", x"89", x"8A", -- 8
        x"AB", x"A8", x"AD", x"AE", x"A7", x"A4", x"A1", x"A2", x"B3", x"B0", x"B5", x"B6", x"BF", x"BC", x"B9", x"BA", -- 9
        x"FB", x"F8", x"FD", x"FE", x"F7", x"F4", x"F1", x"F2", x"E3", x"E0", x"E5", x"E6", x"EF", x"EC", x"E9", x"EA", -- A
        x"CB", x"C8", x"CD", x"CE", x"C7", x"C4", x"C1", x"C2", x"D3", x"D0", x"D5", x"D6", x"DF", x"DC", x"D9", x"DA", -- B
        x"5B", x"58", x"5D", x"5E", x"57", x"54", x"51", x"52", x"43", x"40", x"45", x"46", x"4F", x"4C", x"49", x"4A", -- C
        x"6B", x"68", x"6D", x"6E", x"67", x"64", x"61", x"62", x"73", x"70", x"75", x"76", x"7F", x"7C", x"79", x"7A", -- D
        x"3B", x"38", x"3D", x"3E", x"37", x"34", x"31", x"32", x"23", x"20", x"25", x"26", x"2F", x"2C", x"29", x"2A", -- E
        x"0B", x"08", x"0D", x"0E", x"07", x"04", x"01", x"02", x"13", x"10", x"15", x"16", x"1F", x"1C", x"19", x"1A"  -- F
    );

begin

    byte_o <= times3_lut(to_integer(unsigned(byte_i(7 downto 0))));

end gftimes3box_arch;
