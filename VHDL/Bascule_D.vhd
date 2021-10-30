----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.02.2021 08:34:47
-- Design Name: 
-- Module Name: bascule - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Bascule_D is
    
    Port ( 
       clk : in STD_LOGIC;
       reset : in STD_LOGIC;
       ce : in STD_LOGIC;
       D : in STD_LOGIC;
       Q : out STD_LOGIC
       );
end bascule_D;


architecture Behavioral of bascule_D is

begin
    bascule : process(clk,reset)
        begin
            if(reset='1')then
                Q<= '0';
            elsif clk = '1' and clk'event then
                if(ce='1')then
                     Q<= D;
                end if;
            end if;
    end process;


end Behavioral;