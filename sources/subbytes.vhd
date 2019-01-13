-- Mathieu CAROFF
-- 2018-11-23
-- Subbytes
use work.util_type.all;

library ieee;
use ieee.std_logic_1164.all;

entity subbytes is
    port(
        state_i : in  byte16;
        state_o : out byte16
    );
end subbytes;

architecture behavioral of subbytes is

    component sbox
        port(
            byte_i : in  bit8;
            byte_o : out bit8
        );
    end component;

begin

    GEN_A:
    for k in 0 to 16 - 1 generate
        SBOX_A: sbox port map(
            byte_i => state_i(k),
            byte_o => state_o(k)
        );
    end generate;

end behavioral;