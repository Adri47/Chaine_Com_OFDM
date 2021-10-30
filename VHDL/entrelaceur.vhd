library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity entrelaceur is
	port(
		iClock     : in	std_logic;
		iReset     : in	std_logic;
		iEN	       : in	std_logic;	-- compteur de 0 � 6
		iData      : in	std_logic;
		oData      : out std_logic;
		data_valid : out std_logic
	 );
end entity;

architecture Behavioral of entrelaceur is

component reg_entrelaceur is
	port(
	    iClock     : in std_logic;
		iEN_REG    : in	std_logic_vector(5 downto 0);
		iReset     : in	std_logic;
		iData      : in	std_logic;
		oData      : out std_logic_vector(5 downto 0)
	 );
end component;


component compteur is
	port(
		   CE : in STD_LOGIC;   
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
    
   
    
Activation_de_EN_reg: process (iReset,iClock)
begin 
  if (iReset = '1') then
            en_Reg       <= "0000000";
        elsif (iClock'event and iClock = '1') then
          if (iEN = '1') then
            case sel_mux is
                when "000" =>
                    en_Reg<="0000001";
                when "001" =>
                    en_Reg<="0000010";
                when "010" =>
                    en_Reg<="0000100";
                when "011" =>
                    en_Reg<="0001000";
                when "100" =>
                    en_Reg<="0010000";
                when "101" =>
                    en_Reg<="0100000";
                when "110" =>
                    en_Reg<="1000000";
                when OTHERS =>
                    en_Reg   <= "0000000";
            end case;
          else
            en_Reg <= "0000000";
        end if;
    end if;
end process;  



    reg : reg_entrelaceur port map( iClock => iClock,
                                    iReset => iReset,
                                    iEN_REG => en_Reg(6 downto 1),
                                    iData => iData,
                                    oData => mux_in(6 downto 1)
                                   );

    multiplexeur: process (mux_in, sel_mux) 
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

--process (iClock, iReset)
--begin
--    if iReset = '1' then
--        data_valid <= '0';
--    elsif (iClock'event and iClock = '1') then
--          if (iEN = '1') then
----            data_valid <= '1';
--            if ( sel_mux /= "110") then
--                 data_valid <= '1';
--            else 
--                data_valid <= '0';
--            end if;
--          else
--            data_valid <= '0';
--          end if;
--     end if;
--end process;

mux_in(0) <= iData;
data_valid<=iEN;

end Behavioral;
