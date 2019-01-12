-- Mathieu CAROFF
-- 2018-12-04
-- Tool test bench for entities with 16 byte input / output
use work.util_str.all;
use work.util_type.all;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity tool_test_bench_byte16 is
    generic(
        name : string;
        test128_array : bit128_2_array
    );
    port(
        -- input_state_o is where we send the state we want to test
        -- output_state_i is where we expect the output value
        input_state_o  : out byte16 := (others => x"00");
        output_state_i : in  byte16 := (others => x"00")
    );
end tool_test_bench_byte16;

architecture behav of tool_test_bench_byte16 is
begin
    --  This process does the real job.
    process
        variable bit_output_state_i : bit128 := (others => '0');
    begin    
        wait for 99 ns;

        --  Check each test entry.
        for k in test128_array'range loop
            
            --  Send the input state
            input_state_o <= bit2byte(test128_array(k).vec_i);
            
            --  Wait for the results
            wait for 1 ns;
            
            --  Check the outputs.
            bit_output_state_i := byte2bit(output_state_i);
            assert bit_output_state_i = test128_array(k).vec_o
            report ""
                &NL& name & "_tb error ("
                &NL&"  input  : " & hex(test128_array(k).vec_i)
                &NL&"  expect : " & hex(test128_array(k).vec_o)
                &NL&"  got    : " & hex(bit_output_state_i)
                &NL&")"
            severity error;
            
        end loop;
        
        wait for 1 ns;
        report name & " end";
        
        --  Wait forever; this will finish the simulation.
        wait;
    end process;
end behav;
