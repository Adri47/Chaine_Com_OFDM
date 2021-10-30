library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity transmitter is
    Port ( rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           enable : in STD_LOGIC;
           stream_in : in STD_LOGIC_VECTOR(7 downto 0);
           stream_out : out STD_LOGIC_VECTOR(7 downto 0);
           data_valid : out std_logic);
end transmitter;

architecture Behavioral of transmitter is   

component scrambler is
port(
   iClock            : in	std_logic;
   iReset            : in	std_logic;
   iEN      		 : in	std_logic;
   iData           	 : in	std_logic;
   oDataValid        : out  std_logic;
   oData      	     : out	std_logic);
end component;

component S2P is
generic (width: integer := 7);
port (
	clk          : in std_logic;
	reset        : in std_logic;
	i_data_valid : in std_logic;
	serial_data  : in std_logic;
	par_data     : out std_logic_vector(width-1 downto 0);
	o_data_valid : out std_logic);
end component;

component hamenc IS
   PORT(rst    : in  std_logic;
        clk    : in  std_logic;
        i_data : in  std_logic_vector(3 downto 0);
        i_dv   : in  std_logic;
        o_data : out std_logic_vector(7 downto 0);
        o_dv   : out std_logic);
end component;

component P2S is
generic (width: integer := 4);
port (
	clk : in std_logic;
	reset : in std_logic;
	load : in std_logic;
	par_data : in std_logic_vector(width-1 downto 0);
	serial_data : out std_logic;
	serial_data_valid : out std_logic);
end component;

component entrelaceur is
	port(
		iClock     : in	std_logic;
		iReset     : in	std_logic;
		iEN	       : in	std_logic;	-- compteur de 0 � 6
		iData      : in	std_logic;
		oData      : out std_logic;
		data_valid : out std_logic
	 );
end component;

component codeur_conv is
	port(
		iClock            : in	std_logic;
		iReset            : in	std_logic;
		iEN	    			: in	std_logic;
		iData            	: in	std_logic;
		oDataX           	: out std_logic;
		oDataY           	: out std_logic;
		oDataValid        : out STD_LOGIC
	 );
end component;

signal scrambler_out_dv, S2P_out_dv, bch_out_dv, p2s_out_dv : std_logic;
signal scrambler_out : std_logic;
signal inter_data_valid : std_logic;
signal S2P_out : std_logic_vector(3 downto 0);
signal bch_out : std_logic_vector(7 downto 0);
signal p2s_out : std_logic;
signal intrl_out : std_logic;
signal data_val : std_logic;
signal x1, x2 : std_logic;
signal data_valid_inter, data_valid_P2S : std_logic;


begin

scramb : scrambler port map(  iClock => clk,
                              iReset => rst,
                              iEN => enable,
                              iData => stream_in(0),
                              oDataValid => inter_data_valid,--scrambler_out_dv
                              oData  => scrambler_out);--scrambler_out
 
s2p_inst : S2P generic map(width => 4)
               port map( clk => clk,
                         reset => rst,
                         i_data_valid => inter_data_valid,
                         serial_data => scrambler_out,
                         par_data => S2P_out,
                         o_data_valid => data_val);

bch_enc : hamenc port map(rst => rst,
                          clk => clk,
                          i_data => S2P_out,
                          i_dv => data_val,
                          o_data => bch_out,
                          o_dv => bch_out_dv);

p2s_inst : P2S generic map(width  => 8)
               port map(clk => clk,
                        reset => rst,
                        load => bch_out_dv,
                        par_data => bch_out,
                        serial_data => P2S_out,
                        serial_data_valid => data_valid_P2S);

intrl : entrelaceur port map( iClock => clk,
                              iReset => rst,
                              iEN => data_valid_P2S,
                              iData => P2S_out,
                              oData => intrl_out,
                              data_valid => data_valid_inter);
                              
cc : codeur_conv port map(    iClock => clk,
                              iReset => rst,
                              iEN => data_valid_inter,
                              iData => intrl_out,
                              oDataX => x1,
                              oDataY => x2,
                              oDataValid => data_valid );

stream_out(7 downto 2) <= (others => '0');
stream_out(0) <= x1;
stream_out(1) <= x2;

--data_valid <= data_val;

end Behavioral;