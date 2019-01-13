-- Mathieu CAROFF
-- 2019-01-13
-- Inverse Mix Columns test bench

use work.util_type.all;

library ieee;
use ieee.std_logic_1164.all;

entity mixcolumns_inv_tb is
end mixcolumns_inv_tb;

architecture behav of mixcolumns_inv_tb is

    component tool_test_bench_byte16
        generic(
            name : string;
            test128_array : bit128_2_array
        );
        port(
            input_state_o  : out byte16;
            output_state_i : in  byte16
        );
    end component;

    component mixcolumns_inv
        port(
            state_i : in  byte16;
            state_o : out byte16
        );
    end component;

    for mixcolumns_inv_0 : mixcolumns_inv
        use entity work.mixcolumns_inv;
    for tool_test_bench_byte16_0 : tool_test_bench_byte16
        use entity work.tool_test_bench_byte16;
    signal state_is, state_os : byte16 := (others => x"00");

begin
    --  Component instantiation.
    tool_test_bench_byte16_0 :
    tool_test_bench_byte16 generic map(
        name => "mixcolumns_inv",
        test128_array => (
            (
                x"00000000000000000000000001010302",
                x"00000000000000000000000000000001"
            )
            ,
            (
                x"01010302000000000000000000000000",
                x"00000001000000000000000000000000"
            )
            ,
            (
                x"00000000020101030000000000000000",
                x"00000000010000000000000000000000"
            )
            ,
            (
                x"02010103000000000000000000000000",
                x"01000000000000000000000000000000"
            )
            ,
            (
                x"00000000000000000000000000000000",
                x"00000000000000000000000000000000"
            )
            ,
            (
                x"00000000000000000000000010103020",
                x"00000000000000000000000000000010"
            )
            ,
            (
                x"046681e5e0cb199a48f8d37a2806264c",
                x"d4bf5d30e0b452aeb84111f11e2798e5"
            )
            ,
            (
                x"09379FA47E9901C7ED74ADF88FA110A4",
                x"362BAAB27EE343FF292DEA22BFEA0FC0"
            )
            ,
            
            (
                x"37CF023E4DF102104EC3D413B0811003",
                x"B619107BA00CA8AA3DAC33E84DAFA969"
            )
            ,
            (
                x"3B14950EAAEDE443056F44C51E3978A5",
                x"8806556FA6D033A53C55B032B89631E5"
            )
            ,
            (
                x"89EC3DEF908C374CFF37F9AB3D174AEE",
                x"DD211C5770BE19B04AD063633CF64C08"
            )
            ,
            (
                x"C6DC1E2563C16F5335B5AB755450D8DD",
                x"8DB817030EFA254FF83CDA405350DDDF"
            )
            ,
            (
                x"F6EC13A8C4D8E72613CA891E1BF87495",
                x"A5DC19C11F1C9D43EC39EA717346182F"
            )
            ,
            (
                x"1416CB016D1B5BFADFFA19444766A120",
                x"9339C7A56C07EF53357C03326727DA3A"
            )
            ,
            (
                x"288E8949AFA24E2A2A9E1FEA81F77177",
                x"B6CADBC1107B2321F23345C55D0B4D6B"
            )
            ,
            (
                x"CE69C85C3F8641467D66977F8B774D11",
                x"335453078C0795A0E4D1F3358A57176A"
            )
            ,
            (
                x"09379FA47E9901C7ED74ADF88FA110A4",
                x"362BAAB27EE343FF292DEA22BFEA0FC0"
            )
        )
    ) port map(
        input_state_o  => state_is,
        output_state_i => state_os
    );
    
    mixcolumns_inv_0 : mixcolumns_inv
    port map(
        state_i => state_is,
        state_o => state_os
    );
end behav;
