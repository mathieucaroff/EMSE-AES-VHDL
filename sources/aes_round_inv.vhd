-- Mathieu CAROFF
-- 2019-01-05
-- Inverse AES Round
-- Compute one round of inverse AES, skipping the specified transformations

-- I was wondering how long it would take me to type a sentence rather than to speak it.
-- 18s (.73)
-- vs 5s
-- About 3.5 times more.
-- 3 to 4 times longer.

use work.util_type.all;

use work.util_str.all;

library ieee;
use ieee.std_logic_1164.all;

entity aes_round_inv is
    port(
        skip_mc_i    : in b; -- Skip (Inverse) Mix Columns?
        skip_sb_sr_i : in b; -- Skip (Inverse) SubBytes and ShiftRows?

        roundkey_i   : in byte16;
        state_i      : in byte16;
        state_o      : out byte16
    );

end aes_round_inv;

architecture behavioral of aes_round_inv is

    component addroundkeys
        port(
            roundkey_i : in  byte16;
            state_i    : in  byte16;
            state_o    : out byte16
        );
    end component;

    component mixcolumns_inv
        port(
            state_i : in  byte16;
            state_o : out byte16
        );
    end component;

    component shiftrows_inv
        port(
            state_i : in  byte16;
            state_o : out byte16
        );
    end component;

    component subbytes_inv
        port(
            state_i : in  byte16;
            state_o : out byte16
        );
    end component;

    for subbytes_inv_0 : subbytes_inv
        use entity work.subbytes_inv;
    for shiftrows_inv_0 : shiftrows_inv
        use entity work.shiftrows_inv;
    for mixcolumns_inv_0 : mixcolumns_inv
        use entity work.mixcolumns_inv;
    for addroundkeys_0 : addroundkeys
        use entity work.addroundkeys;

    signal
        addroundkeys_os,
        mixcolumns_os,
        shiftrows_os,
        subbytes_os,
        shiftrows_is
        : byte16 := (others => x"00");

begin

    addroundkeys_0 : addroundkeys
    port map(
        roundkey_i => roundkey_i,
        state_i    => state_i,
        state_o    => addroundkeys_os
    );

    mixcolumns_inv_0 : mixcolumns_inv
    port map(
        state_i => addroundkeys_os,
        state_o => mixcolumns_os
    );
    
    shiftrows_is <= mixcolumns_os when skip_mc_i = '0' else addroundkeys_os;
    
    shiftrows_inv_0 : shiftrows_inv
    port map(
        state_i => shiftrows_is,
        state_o => shiftrows_os
    );
    
    subbytes_inv_0 : subbytes_inv
    port map(
        state_i => shiftrows_os,
        state_o => subbytes_os
    );

    state_o <=
        subbytes_os when skip_sb_sr_i = '0' else
        mixcolumns_os when skip_mc_i = '0' else
        addroundkeys_os
    ;

    -- Note: The second case (mixcolumns_os) should never happen.
    
--    GEN_TIME:
--    for k in 102 to 104 - 1 generate
--        process begin wait for k * 1 ns; report ""
--        -- &NL&"outp: " & hex(byte2bit(state_o))
--        &NL&"adrk: " & hex(byte2bit(addroundkeys_os))
--        &NL&"mxcl: " & hex(byte2bit(mixcolumns_os))
--        &NL&"shft: " & hex(byte2bit(shiftrows_os))
--        &NL&"subb: " & hex(byte2bit(subbytes_os));
--        wait;end process;
--    end generate;

end behavioral;