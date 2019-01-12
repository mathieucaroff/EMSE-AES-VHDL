-- Mathieu CAROFF
-- 2018-11-23
-- Add Round Keys
use work.util_type.all;

library ieee;
use ieee.std_logic_1164.all;

entity addroundkeys is
    port(
        roundkey_i : in  byte16;
        state_i    : in  byte16;
        state_o    : out byte16
    );
end addroundkeys;

architecture behavioral of addroundkeys is

    signal bit_state_s : bit128 := (others => '0');

begin

    bit_state_s <= byte2bit(roundkey_i) xor byte2bit(state_i);
    state_o     <= bit2byte(bit_state_s);

end behavioral;