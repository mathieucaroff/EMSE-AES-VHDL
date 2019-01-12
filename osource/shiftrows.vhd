-- Mathieu CAROFF
-- 2018-11-23
-- Shiftrows
use work.util_type.all;

library ieee;
use ieee.std_logic_1164.all;

entity shiftrows is
    port(
        state_i : in  byte16;
        state_o : out byte16
    );
end shiftrows;

architecture behavioral of shiftrows is

begin

    GEN_A:
    for k in 0 to 4 - 1 generate
    begin
        GEN_B:
        for m in 0 to 4 - 1 generate
            -- stackoverflow.com/q/47302553
            constant src : natural := 4 * k + m;
            constant dst : natural := 4 * ((k + m) mod 4) + m;
        begin
            --process begin report "src:" & Integer'Image(src) & "; dst:" & Integer'Image(dst) & ";";
            --wait; end process;
            
            --state_o(8 * (src + 1) - 1 downto 8 * src) <= state_i(8 * (dst + 1) - 1 downto 8 * dst);
            state_o(src) <= state_i(dst);
        end generate;
    end generate;

end behavioral;