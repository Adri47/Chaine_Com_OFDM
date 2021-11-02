library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity entrelaceur is
	port(
		iClock     : in	std_logic;
		iReset     : in	std_logic;
		iEN	       : in	std_logic;
		iData      : in	std_logic;
		oData      : out std_logic;
		data_valid : out std_logic
	 );
end entity;

architecture Behavioral of entrelaceur is

component registre is
	port(
	    iClock     : in std_logic;
		iEN_REG    : in	std_logic_vector(5 downto 0);
		iReset     : in	std_logic;
		iData      : in	std_logic;
		oData      : out std_logic_vector(5 downto 0)
	 );
end component;


component compteur is
	port( CE : in STD_LOGIC;   
          H : in STD_LOGIC;    
          RST : in STD_LOGIC;  
          dataout : out STD_LOGIC_VECTOR (2 downto 0)
	      );
end component;

signal mux_in : std_logic_vector(6 downto 0);
signal en_Reg : std_logic_vector(6 downto 0);
signal sel_mux : std_logic_vector(2 downto 0);

begin

cpt : compteur port map( H => iClock,
                          RST => iReset,
                          CE => iEN,
                          dataout => sel_mux
                          );
reg : registre port map( iClock => iClock,
                                iReset => iReset,
                                iEN_REG => en_Reg(6 downto 1),
                                iData => iData,
                                oData => mux_in(6 downto 1)
                               );
    
mux: process (mux_in, sel_mux) 
begin
    case sel_mux is
      when "000" => oData <= mux_in(0);
      when "001" => oData <= mux_in(1);
      when "010" => oData <= mux_in(2);
      when "011" => oData <= mux_in(3);
      when "100" => oData <= mux_in(4);
      when "101" => oData <= mux_in(5);
      when "110" => oData <= mux_in(6);
      when others => oData <= '0'; 
    end case;
end process;

                               
en_Reg <= "0000001" when sel_mux = "000" else 
          "0000010" when sel_mux = "001" else 
          "0000100" when sel_mux = "010" else
          "0001000" when sel_mux = "011" else 
          "0010000" when sel_mux = "100" else
          "0100000" when sel_mux = "101" else
          "1000000" when sel_mux = "110" else "0000000";

mux_in(0)<= iData when iEN='1' else '0';
data_valid<=iEN;

end Behavioral;