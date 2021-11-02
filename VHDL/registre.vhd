library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity registre is
	port(iClock     : in std_logic;
		 iEN_REG    : in std_logic_vector(5 downto 0);
		 iReset     : in std_logic;
		 iData      : in std_logic;
		 oData      : out std_logic_vector(5 downto 0)
	    );
end entity;

architecture Behavioral of registre is

signal D: std_logic_vector(0 to 14);

begin
    REG_data_1 : process(iEN_REG, iReset,iClock)
    begin
        if (iReset = '1') then
             oData <= (others => '0');
             D <= (others => '0');
        elsif(rising_edge(iClock)) then
            case iEN_REG is
                when "000001" => 
                    oData(0) <= iData;
                when "000010" => 
                    D(0) <= iData;
                    oData(1) <= D(0);
                when "000100" => 
                    D(1) <= iData;
                    D(2) <=D(1);
                    oData(2) <= D(2);
                when "001000" => 
                   D(3) <= iData;
                   D(4) <=D(3);
                   D(5) <=D(4);
                   oData(3) <= D(5);
                when "010000" => 
                  D(6) <= iData;
                  D(7) <=D(6);
                  D(8) <=D(7);
                  D(9) <=D(8);
                  oData(4) <= D(9);
                when "100000" => 
                  D(10) <= iData;
                  D(11) <=D(10);
                  D(12) <=D(11);
                  D(13) <=D(12);
                  D(14) <=D(13);
                  oData(5) <= D(14);
                  when others =>          
            end case;
        end if;
    end process;
end Behavioral;