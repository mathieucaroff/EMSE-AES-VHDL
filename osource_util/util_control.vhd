-- Mathieu CAROFF
-- 2018-11-20
-- util_control.vhd
-- Utilitary functions to manage control flow.

use work.util_type.all;

library ieee;
use ieee.std_logic_1164.all;

package util_control is

    function sel(test : boolean; iftrue : string; iffalse: string) return string;

end package;

package body util_control is

    function sel(test : boolean; iftrue : string; iffalse: string) return string is
    begin
        if test then
            return iftrue;
        else
            return iffalse;
        end if;
    end function;

end package body;
