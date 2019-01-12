-- Mathieu CAROFF
-- 2018-12-04
-- Mix Columns
use work.util_str.all;
use work.util_type.all;

library ieee;
use ieee.std_logic_1164.all;

entity mixcolumns is
    port(
        state_i : in  byte16;
        state_o : out byte16
    );
end mixcolumns;

architecture behavioral of mixcolumns is
    signal
        state_0,
        state_1,
        state_2,
        state_3
        : byte16 := (others => x"00");

    component gftimes2box
        port(
            byte_i : in  bit8;
            byte_o : out bit8
        );
    end component;

    component gftimes3box
        port(
            byte_i : in  bit8;
            byte_o : out bit8
        );
    end component;

begin

    GEN_HORIZONTAL:
    for k in 0 to 4 - 1 generate
    begin
        GEN_VERTICAL:
        for m in 0 to 4 - 1 generate
            for gftimes2box_comp : gftimes2box
                use entity work.gftimes2box;

            for gftimes3box_comp : gftimes3box
                use entity work.gftimes3box;
        begin

            gftimes2box_comp :
            gftimes2box port map(
                byte_i => state_i(4 * k + (m + 0) mod 4),
                byte_o => state_0(4 * k + m)
            );
            
            gftimes3box_comp :
            gftimes3box port map(
                byte_i => state_i(4 * k + (m + 1) mod 4),
                byte_o => state_1(4 * k + m)
            );

            state_o(4 * k + m) <=
                state_0(4 * k + m) xor
                state_1(4 * k + m) xor
                state_i(4 * k + (m + 2) mod 4) xor
                state_i(4 * k + (m + 3) mod 4);
                
        end generate;
    end generate;

--    GEN_TIME:
--    for k in 100 to 104 - 1 generate
--        process begin wait for k * 1 ns; report NL&
----        "output :" & hex(byte2bit(state_so)) &NL&
--        "s_0:" & hex(byte2bit(state_0)) &NL&
--        "s_1:" & hex(byte2bit(state_1)); wait;
--        end process;
--    end generate;

end behavioral;