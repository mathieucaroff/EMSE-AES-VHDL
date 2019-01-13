-- Mathieu CAROFF
-- 2018-19-04
-- GF multiplication tables

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.util_type.all;
entity gftimes2box is
    port (
        byte_i : in  bit8;
        byte_o : out bit8
    );
end gftimes2box;


architecture gftimes2box_arch of gftimes2box is

    constant times2_lut : lut256 := (
        -- 0      1      2      3      4      5      6      7      8      9      A      B      C      D      E      F
        x"00", x"02", x"04", x"06", x"08", x"0A", x"0C", x"0E", x"10", x"12", x"14", x"16", x"18", x"1A", x"1C", x"1E", -- 0
        x"20", x"22", x"24", x"26", x"28", x"2A", x"2C", x"2E", x"30", x"32", x"34", x"36", x"38", x"3A", x"3C", x"3E", -- 1
        x"40", x"42", x"44", x"46", x"48", x"4A", x"4C", x"4E", x"50", x"52", x"54", x"56", x"58", x"5A", x"5C", x"5E", -- 2
        x"60", x"62", x"64", x"66", x"68", x"6A", x"6C", x"6E", x"70", x"72", x"74", x"76", x"78", x"7A", x"7C", x"7E", -- 3
        x"80", x"82", x"84", x"86", x"88", x"8A", x"8C", x"8E", x"90", x"92", x"94", x"96", x"98", x"9A", x"9C", x"9E", -- 4
        x"A0", x"A2", x"A4", x"A6", x"A8", x"AA", x"AC", x"AE", x"B0", x"B2", x"B4", x"B6", x"B8", x"BA", x"BC", x"BE", -- 5
        x"C0", x"C2", x"C4", x"C6", x"C8", x"CA", x"CC", x"CE", x"D0", x"D2", x"D4", x"D6", x"D8", x"DA", x"DC", x"DE", -- 6
        x"E0", x"E2", x"E4", x"E6", x"E8", x"EA", x"EC", x"EE", x"F0", x"F2", x"F4", x"F6", x"F8", x"FA", x"FC", x"FE", -- 7
        x"1B", x"19", x"1F", x"1D", x"13", x"11", x"17", x"15", x"0B", x"09", x"0F", x"0D", x"03", x"01", x"07", x"05", -- 8
        x"3B", x"39", x"3F", x"3D", x"33", x"31", x"37", x"35", x"2B", x"29", x"2F", x"2D", x"23", x"21", x"27", x"25", -- 9
        x"5B", x"59", x"5F", x"5D", x"53", x"51", x"57", x"55", x"4B", x"49", x"4F", x"4D", x"43", x"41", x"47", x"45", -- A
        x"7B", x"79", x"7F", x"7D", x"73", x"71", x"77", x"75", x"6B", x"69", x"6F", x"6D", x"63", x"61", x"67", x"65", -- B
        x"9B", x"99", x"9F", x"9D", x"93", x"91", x"97", x"95", x"8B", x"89", x"8F", x"8D", x"83", x"81", x"87", x"85", -- C
        x"BB", x"B9", x"BF", x"BD", x"B3", x"B1", x"B7", x"B5", x"AB", x"A9", x"AF", x"AD", x"A3", x"A1", x"A7", x"A5", -- D
        x"DB", x"D9", x"DF", x"DD", x"D3", x"D1", x"D7", x"D5", x"CB", x"C9", x"CF", x"CD", x"C3", x"C1", x"C7", x"C5", -- E
        x"FB", x"F9", x"FF", x"FD", x"F3", x"F1", x"F7", x"F5", x"EB", x"E9", x"EF", x"ED", x"E3", x"E1", x"E7", x"E5"  -- F
    );

begin

    byte_o <= times2_lut(to_integer(unsigned(byte_i(7 downto 0))));

end gftimes2box_arch;
