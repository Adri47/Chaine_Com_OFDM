library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity compteur is
    Port ( CE : in STD_LOGIC;   
           H : in STD_LOGIC;    
           RST : in STD_LOGIC;  
           dataout : out STD_LOGIC_VECTOR (2 downto 0));
end compteur;

architecture Behavioral of compteur is

begin
    process(H,RST)
    variable cpt_value: integer range 0 to 6;
    begin
        if(RST = '1') then
            cpt_value := 0;
            dataout <= "000";
        elsif (H'event and H ='1') then
            if(CE = '1') then
                if(cpt_value<6) then
                    cpt_value := cpt_value + 1;
                else
                    cpt_value:=0;
                end if;
            end if;
             dataout <= std_logic_vector(to_unsigned(cpt_value, 3));
        end if;
    end process;
end Behavioral;
