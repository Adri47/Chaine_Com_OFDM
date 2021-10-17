
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hamenc is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (3 downto 0);
           i_dv : in STD_LOGIC;
           o_data : out STD_LOGIC_VECTOR (7 downto 0);
           o_dv : out STD_LOGIC);
end hamenc;

architecture Behavioral of hamenc is

begin

    o_data(6) <= i_data(3);
    o_data(5) <= i_data(2);
    o_data(4) <= i_data(1);
    o_data(3) <= i_data(0);
    o_data(2) <= i_data(3) XOR i_data(2) XOR i_data(1);
    o_data(1) <= i_data(2) XOR i_data(1) XOR i_data(0);
    o_data(0) <= i_data(3) XOR i_data(2) XOR i_data(0);
    o_data(7) <= '0';

end Behavioral;
