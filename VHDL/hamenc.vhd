
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hamenc is
    Port ( clk      : in STD_LOGIC;
           rst      : in STD_LOGIC;
           i_data   : in STD_LOGIC_VECTOR (3 downto 0);
           i_dv     : in STD_LOGIC;
           o_data   : out STD_LOGIC_VECTOR (7 downto 0);
           o_dv     : out STD_LOGIC);
end hamenc;

architecture Behavioral of hamenc is

begin

process(clk, rst) 
    begin 
    if rst = '1' then
        o_data <= (others => '0');
        o_dv   <= '0';
   
    elsif clk'event and clk = '1' then
        if i_dv = '1'then 
            o_dv      <= '1';
            o_data(6) <= i_data(3);
            o_data(5) <= i_data(2);
            o_data(4) <= i_data(1);
            o_data(3) <= i_data(0);
            o_data(2) <= i_data(3) XOR i_data(2) XOR i_data(1);
            o_data(1) <= i_data(2) XOR i_data(1) XOR i_data(0);
            o_data(0) <= i_data(3) XOR i_data(2) XOR i_data(0);
            o_data(7) <= '0';
        
      else 
        o_data <= (others => '0');
        o_dv   <= '0';
      end if;
   end if;
end process;
--o_dv      <= i_dv;
--o_data(6) <= i_data(3);
--o_data(5) <= i_data(2);
--o_data(4) <= i_data(1);
--o_data(3) <= i_data(0);
--o_data(2) <= i_data(3) XOR i_data(2) XOR i_data(1);
--o_data(1) <= i_data(2) XOR i_data(1) XOR i_data(0);
--o_data(0) <= i_data(3) XOR i_data(2) XOR i_data(0);
--o_data(7) <= '0';


end Behavioral;
