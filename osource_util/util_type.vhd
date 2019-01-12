-- Mathieu CAROFF
-- 2018-12-04
-- util_type.vhd
-- Type declarations common to the project and utilitary functions

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package util_type is

    subtype b is std_logic;

    -- subtype bit16  is std_logic_vector(16 - 1 downto 0);

    subtype bit2   is std_logic_vector(  2 - 1 downto 0);
    subtype bit4   is std_logic_vector(  4 - 1 downto 0);    
    subtype bit8   is std_logic_vector(  8 - 1 downto 0);
    subtype bit32  is std_logic_vector( 32 - 1 downto 0);
    subtype bit128 is std_logic_vector(128 - 1 downto 0);
    subtype bit256 is std_logic_vector(256 - 1 downto 0);

    type bytearray is array (natural range <>) of bit8;

    subtype byte4  is bytearray(0 to  4 - 1);
    subtype byte16 is bytearray(0 to 16 - 1);
    subtype byte32 is bytearray(0 to 32 - 1);

    subtype lut1to10 is bytearray(1 to 10);
    subtype lut256   is bytearray(0 to 256 - 1);


    function byte2bit (bytevec : bytearray) return std_logic_vector;
    function bit2byte (bitvec : std_logic_vector) return bytearray;
    
    function transpose (state_i : byte16) return byte16;


    type bit8_2 is record
        vec_i, vec_o : bit8;
    end record;
    type bit8_2_array is array (natural range <>) of bit8_2;
    
    type bit128_2 is record
        vec_i, vec_o : bit128;
    end record;
    type bit128_2_array is array (natural range <>) of bit128_2;
    
    type bit8_3 is record
        vec0_i, vec1_i, vec_o : bit8;
    end record;
    type bit8_3_array is array (natural range <>) of bit8_3;
    
    type bit128_3 is record
        vec0_i, vec1_i, vec_o : bit128;
    end record;
    type bit128_3_array is array (natural range <>) of bit128_3;

end package;


package body util_type is

    function byte2bit (bytevec : bytearray) return std_logic_vector is
        variable m : natural;
        variable bitvec : std_logic_vector(8 * bytevec'length - 1 downto 0);
    begin
        for k in bytevec'range loop
            m := bytevec'length - 1 - k;
            bitvec(8 * (m + 1) - 1 downto 8 * m) := bytevec(k);
        end loop;
        
        return bitvec;
    end function;

    function bit2byte (bitvec : std_logic_vector) return bytearray is
        variable m : natural;
        variable bytevec : bytearray (0 to bitvec'length / 8 - 1);
    begin
        assert bitvec'length mod 8 = 0;
        
        for k in bytevec'range loop
            m := bytevec'length - 1 - k;
            bytevec(k) := bitvec(8 * (m + 1) - 1 downto 8 * m);
        end loop;
        
        return bytevec;
    end function;

    function transpose (state_i : byte16) return byte16 is
        variable state_o : byte16;
    begin
        for k in state_o'range loop
            state_o(k) := state_i(4 * (k mod 4) + k / 4);
        end loop;
        
        return state_o;
    end function;
    
end package body;
