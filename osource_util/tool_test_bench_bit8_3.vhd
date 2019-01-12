-- Mathieu CAROFF
-- 2018-12-28
-- Tool test bench for entities with two 8 bit inputs and
-- one 8 bit output
use work.util_str.all;
use work.util_type.all;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity tool_test_bench_bit8_3 is
    generic(
        name : string;
        test8_array : bit8_3_array
    );
    port(
        -- input{0,1}_byte_o is where we send the states we want to test
        -- output_byte_i is where we expect the output value
        input0_byte_o : out bit8 := (others => '0');
        input1_byte_o : out bit8 := (others => '0');
        output_byte_i : in  bit8 := (others => '0')
    );
end tool_test_bench_bit8_3;

architecture behav of tool_test_bench_bit8_3 is
begin
    --  This process does the real job.
    process
    begin    
        wait for 99 ns;

        --  Check each test entry.
        for k in test8_array'range loop
            
            --  Send the input state
            input0_byte_o <= test8_array(k).vec0_i;
            input1_byte_o <= test8_array(k).vec1_i;
            
            --  Wait for the results
            wait for 1 ns;
            
            --  Check the outputs
            assert output_byte_i = test8_array(k).vec_o
            report ""
                &NL& name & "_tb error ("
                &NL&"  input0 : " & hex(test8_array(k).vec0_i)
                &NL&"  input1 : " & hex(test8_array(k).vec1_i)
                &NL&"  expect : " & hex(test8_array(k).vec_o)
                &NL&"  got    : " & hex(output_byte_i)
                &NL&")"
            severity error;
            
        end loop;
        
        wait for 1 ns;
        report name & " end";
        
        --  Wait forever; this will finish the simulation.
        wait;
    end process;
end behav;
