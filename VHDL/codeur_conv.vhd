library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity codeur_conv is
    Port ( iClock : in STD_LOGIC;
           iReset : in STD_LOGIC;
           iEN : in STD_LOGIC;
           iData : in STD_LOGIC;
           oDataX : out STD_LOGIC;
           oDataY : out STD_LOGIC;
           oDataValid : out STD_LOGIC);
end codeur_conv;

architecture Behavioral of codeur_conv is

signal out1 : std_logic;
signal out2 : std_logic;
signal en : std_logic;


begin

process (iClock, iReset) begin
    if iReset = '1' then
        out1 <= '0';
    elsif (iClock'event and iClock = '1') then
        if (iEN = '1') then
            out1 <= iData;
        end if;
    end if;
end process;
    

process (iClock, iReset) begin
    if iReset = '1' then
        out2 <= '0';
    elsif (iClock'event and iClock = '1') then
        if (iEN = '1') then
            out2 <= out1;
        end if;
    end if;  
end process;

--process(iClock, iReset)
--begin
--   if(iReset = '1')   then
--      oDataValid <= '0';
--   elsif(iClock'EVENT and iClock = '1')   then
--      oDataValid <= iEN;      
--   end if;
--end process;
   
en <= iEN;
oDataValid  <= en;

oDataX <= iData XOR out2;
oDataY <= out1 XOR out2;

end Behavioral;
