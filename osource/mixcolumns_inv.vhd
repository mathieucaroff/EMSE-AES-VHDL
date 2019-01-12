-- Mathieu CAROFF
-- 2018-12-04
-- Inverse Mix Columns
use work.util_str.all;
use work.util_type.all;

library ieee;
use ieee.std_logic_1164.all;

entity mixcolumns_inv is
    port(
        state_i : in  byte16;
        state_o : out byte16
    );
end mixcolumns_inv;

architecture behavioral of mixcolumns_inv is
    signal
        state_0,
        state_1,
        state_2,
        state_3
        : byte16 := (others => x"00");

    component gftimes14box
        port(
            byte_i : in  bit8;
            byte_o : out bit8
        );
    end component;

    component gftimes11box
        port(
            byte_i : in  bit8;
            byte_o : out bit8
        );
    end component;

    component gftimes13box
        port(
            byte_i : in  bit8;
            byte_o : out bit8
        );
    end component;

    component gftimes9box
        port(
            byte_i : in  bit8;
            byte_o : out bit8
        );
    end component;

begin

    GEN_VERTICAL:
    for k in 0 to 4 - 1 generate
    begin
        GEN_ROW:
        for m in 0 to 4 - 1 generate
            for gftimes14box_comp : gftimes14box
                use entity work.gftimes14box;
        
            for gftimes11box_comp : gftimes11box
                use entity work.gftimes11box;
        
            for gftimes13box_comp : gftimes13box
                use entity work.gftimes13box;
        
            for gftimes9box_comp : gftimes9box
                use entity work.gftimes9box;
        begin

            --  Component instantiation.
            gftimes14box_comp :
            gftimes14box port map(
                byte_i => state_i(4 * k + (m + 0) mod 4),
                byte_o => state_0(4 * k + m)
            );
            
            gftimes11box_comp :
            gftimes11box port map(
                byte_i => state_i(4 * k + (m + 1) mod 4),
                byte_o => state_1(4 * k + m)
            );
            
            gftimes13box_comp :
            gftimes13box port map(
                byte_i => state_i(4 * k + (m + 2) mod 4),
                byte_o => state_2(4 * k + m)
            );
            
            gftimes9box_comp :
            gftimes9box port map(
                byte_i => state_i(4 * k + (m + 3) mod 4),
                byte_o => state_3(4 * k + m)
            );

            state_o(4 * k + m) <=
                state_0(4 * k + m) xor
                state_1(4 * k + m) xor
                state_2(4 * k + m) xor
                state_3(4 * k + m);

        end generate;
    end generate;

--    GEN_TIME:
--    for k in 100 to 104 - 1 generate
--        process begin wait for k * 1 ns; report NL&
----        "output :" & hex(byte2bit(state_so))&NL&
--            "state_0:" & hex(byte2bit(state_0)) &NL&
--            "state_1:" & hex(byte2bit(state_1)) &NL&
--            "state_2:" & hex(byte2bit(state_2)) &NL&
--            "state_3:" & hex(byte2bit(state_3)); wait;
--        end process;
--    end generate;

end behavioral;