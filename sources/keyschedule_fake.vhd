-- Mathieu CAROFF
-- 2019-01-11
-- Key Schedule Fake
-- A key schedule which outputs precomputed roundkeys,
-- only for a specific key.

use work.util_type.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keyschedule_fake is
    port(
        round_index_i : in bit4; -- between 0 and 14, target index
        
        key_i      : in  byte16; -- the key to expand
        roundkey_o : out byte16  -- the roundkey (result)
    );
end keyschedule_fake;

architecture behavioral of keyschedule_fake is
    
    type bit128array is array (0 to 11 - 1) of bit128;

    constant keytable : bit128array := (
        x"2b7e151628aed2a6abf7158809cf4f3c",
        x"a0fafe1788542cb123a339392a6c7605",
        x"f2c295f27a96b9435935807a7359f67f",
        x"3d80477d4716fe3e1e237e446d7a883b",
        x"ef44a541a8525b7fb671253bdb0bad00",
        x"d4d1c6f87c839d87caf2b8bc11f915bc",
        x"6d88a37a110b3efddbf98641ca0093fd",
        x"4e54f70e5f5fc9f384a64fb24ea6dc4f",
        x"ead27321b58dbad2312bf5607f8d292f",
        x"ac7766f319fadc2128d12941575c006e",
        x"d014f9a8c9ee2589e13f0cc8b6630ca6"
    );
    
    constant zeroes : bit128 := x"00000000000000000000000000000000";
    
    signal round_index_int_s : natural := 0;

begin

    assert (byte2bit(key_i) = keytable(0)) or (byte2bit(key_i) = zeroes);

    round_index_int_s <= to_integer(unsigned(round_index_i));
    
    assert round_index_int_s < 11 or round_index_int_s = 15;

    roundkey_o <=
        (others => x"00") when round_index_int_s = 15
        else bit2byte(keytable(round_index_int_s))
    ;

end behavioral;
