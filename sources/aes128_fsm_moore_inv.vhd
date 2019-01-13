-- Mathieu CAROFF
-- 2019-01-06
-- Compute the Inverse AES cipher

use work.util_type.all;
use work.util_str.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity aes128_fsm_moore_inv is
    port(
        clk_i        : in b;
        reset_i      : in b;
        start_i      : in b;
        
        key_i        : in bit128;
        data_i       : in bit128;
        data_o       : out bit128;
        
        aes_on_o      : out b
    );

end aes128_fsm_moore_inv;

architecture behavioral of aes128_fsm_moore_inv is
    
    component aes_round_inv
        port(
            skip_mc_i    : in b; -- Skip (Inverse) Mix Columns?
            skip_sb_sr_i : in b; -- Skip (Inverse) SubBytes and ShiftRows?
    
            roundkey_i   : in byte16;
            state_i      : in byte16;
            state_o      : out byte16
        );
    end component;

    component keyschedule_fake
        port(
            round_index_i : in bit4;  -- between 0 and 14, target index
            
            key_i      : in  byte16;  -- the key to copy
            roundkey_o : out byte16  -- the roundkey (result)
        );
    end component;

    for aes_round_inv_0 : aes_round_inv use entity work.aes_round_inv;
    for keyschedule_fake_0 : keyschedule_fake use entity work.keyschedule_fake;

    -- FSM Moore
    signal key_is, key_next_is : byte16 := (others => x"00");
    signal data_s, data_next_s : byte16 := (others => x"00");
    signal count_s, count_next_s : bit4;
    -- `key_is` stores the key, and allows `start_i` to set a new key value.
    -- `data_s` stores the changing data, and allows `start_i` to set a new value.
    -- `count_s` decounts the steps done by the fsm, and allows `start_i` to reset it to 10.

    -- Key Schedule
    -- Signals to write inputs and read outputs using processes.
    signal round_index_is : bit4 := x"0";
    signal roundkey_os : byte16 := (others => x"00");

    -- Inverse AES Round
    -- Signals to write inputs and read outputs using processes.
    signal skip_mc_is, skip_sb_sr_is : b := '0';
    signal roundkey_is, state_is, state_os : byte16 := (others => x"00");

begin

    -- MOORE Machine
    
    -- Process 1
    -- Reset handling and state update
    process (clk_i, reset_i)
    begin
        if reset_i = '1' then
            key_is  <= (others => x"00");
            data_s <= (others => x"00");
            count_s <= x"F";
        elsif clk_i'event and clk_i = '1' then
            key_is  <= key_next_is; 
            data_s <= data_next_s;
            count_s <= count_next_s;
        elsif clk_i'event then
            -- report "count : x""" & hex(count_s) & """";
            -- report "data : x""" & hex(byte2bit(data_s)) & """";
            -- report "";
        end if;
    end process;

    -- Process 2.a
    -- Computing the next state
    key_next_is <= bit2byte(key_i) when start_i = '1' else key_is;

    count_next_s <=
        x"a" when start_i = '1' else
        count_s when count_s = x"F" else std_logic_vector(
           unsigned(count_s) - 1
        );

    keyschedule_fake_0 :
        keyschedule_fake
        port map(
            round_index_i => count_s,
            
            key_i => key_is,
            roundkey_o => roundkey_os
        );

    roundkey_is <= roundkey_os;

    state_is <= data_s;

    aes_round_inv_0 :
        aes_round_inv
        port map(
            skip_mc_i => skip_mc_is,
            skip_sb_sr_i => skip_sb_sr_is,

            roundkey_i => roundkey_is,
            state_i => state_is,
            state_o => state_os
        );
    
    data_next_s <=
        bit2byte(data_i) when start_i = '1' else
        state_os when count_s /= x"F" else
        data_s
    ;
    
    process (count_s)
    begin

        case count_s is
            when x"0" => -- 0
                skip_mc_is <= '1';
                skip_sb_sr_is <= '1';
            when x"a" => -- 10
                skip_mc_is <= '1';
                skip_sb_sr_is <= '0';
            when others => -- 1-9
                skip_mc_is <= '0';
                skip_sb_sr_is <= '0';
        end case;

    end process;
    
    -- Process 3
    -- Output combinatorics
    data_o <= byte2bit(data_s);
    aes_on_o <= '0' when count_s = x"F" else '1';

end behavioral;