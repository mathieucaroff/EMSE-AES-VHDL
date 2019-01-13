-- Mathieu CAROFF
-- 2018-11-23
-- Inverse Subbytes
use work.util_type.all;

library ieee;
use ieee.std_logic_1164.all;

entity subbytes_inv is
    port(
        state_i : in  byte16;
        state_o : out byte16
    );
end subbytes_inv;

architecture behavioral of subbytes_inv is

    component sbox_inv
        port(
            byte_i : in  bit8;
            byte_o : out bit8
        );
    end component;

begin

    GEN_A:
    for k in 0 to 16 - 1 generate
        SBOX_INV_A: sbox_inv port map(
            byte_i => state_i(k),
            byte_o => state_o(k)
        );
    end generate;

end behavioral;