library IEEE;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;

entity P2S is
    GENERIC (width : positive :=4);
    Port ( clk               : in STD_LOGIC;
           reset             : in STD_LOGIC;
           load              : in STD_LOGIC;
           par_data          : in STD_LOGIC_VECTOR (width - 1 downto 0);
           serial_data       : out STD_LOGIC;
           serial_data_valid : out STD_LOGIC);
end P2S;

architecture Behavioral of P2S is

signal mem       : std_logic_vector(width - 1 DOWNTO 0);
signal start_cpt : std_logic;
signal compteur  : integer;


begin

process(clk, reset)
begin
    if reset = '1' then
        mem <= (others => '0');
        start_cpt <= '0';
    elsif clk'event and clk = '1' then
        if load = '1' then
            if compteur > 0 then
                mem <= par_data;
                start_cpt <= '1';
             else 
                start_cpt <= '0';
             end if;
        end if;
        if load = '0' then
            if compteur = 0 then
                start_cpt <= '0';
            end if;
        end if;
    end if;                
end process;

process(clk, reset)
begin
    if reset = '1' then
        serial_data <= '0';
        serial_data_valid <= '0';
        compteur <= width - 1;
    elsif clk'event and clk = '1' then
        if start_cpt = '1' then
            if compteur > 0 then
                compteur <= compteur - 1;
                serial_data <= mem(compteur - 1);
                serial_data_valid <= '1';
            else
                compteur <= (width - 1);
--                serial_data <= mem(compteur);
                serial_data_valid <= '0';
            end if;
        else
            compteur <= (width - 1);
            serial_data_valid <= '0';
        end if;
    end if;   
end process;
end Behavioral;