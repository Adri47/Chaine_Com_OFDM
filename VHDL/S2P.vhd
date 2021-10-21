-- Composant permettant de parralèliser une liaison série sur bits--
-- Dès que le signal  i_data_valid=1 on parralèlise les 4 prochains bits

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity S2P is
    GENERIC (width : positive :=4);
    Port ( clk          : in STD_LOGIC;
           reset        : in STD_LOGIC;
           i_data_valid : in STD_LOGIC;
           serial_data  : in STD_LOGIC;
           par_data     : out std_logic_vector(width - 1 downto 0);
           o_data_valid : out STD_LOGIC);
end S2P;

architecture Behavioral of S2P is

signal cpt : integer :=0;

begin

process (clk, reset)
begin
    if reset = '1' then
        par_data <= (others =>'0');
        o_data_valid <= '0';
        cpt <= width - 1;
    elsif (clk'event and clk = '1') then
        if i_data_valid = '1' then
            if cpt > 0 then
                par_data(cpt) <= serial_data;
                cpt <= cpt - 1;
                o_data_valid <= '0';
            else 
                par_data(cpt) <= serial_data;
                cpt <= width - 1;
                o_data_valid <= '1';
            end if;
        else 
            o_data_valid <= '0';
        end if;
     end if;
end process;
end Behavioral;