----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:54:52 02/01/2021 
-- Design Name: 
-- Module Name:    top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.constants.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  game : in STD_LOGIC;
			  start : in STD_LOGIC;
			  paddleSize : in STD_LOGIC;
			  speedSelect1 : in STD_LOGIC;
			  ballSizeSelect : in STD_LOGIC;
			  speedSelect2 : in STD_LOGIC;
			  btnU : in  STD_LOGIC;
           btnD : in  STD_LOGIC;
           btnL : in  STD_LOGIC;
           btnR : in  STD_LOGIC;
			  btnC : in  STD_LOGIC;
			  cathode : out STD_LOGIC_VECTOR(6 downto 0);
			  an : out STD_LOGIC_VECTOR(3 downto 0);
           RGB : out  STD_LOGIC_VECTOR (11 downto 0);
           hsync_o : out  STD_LOGIC;
           vsync_o : out  STD_LOGIC);
end top;

architecture Behavioral of top is
	
	signal vcount : std_logic_vector(9 downto 0);
	signal hcount : std_logic_vector(9 downto 0); 
	
	constant vBP : integer := 29; 
	constant vFP : integer := 10;
	constant vSP : integer := 2;
	constant vDT : integer := 480;
	constant vTV : integer := 521;
	
	constant hBP : integer := 48; 
	constant hFP : integer := 16;
	constant hSP : integer := 96;
	constant hDT : integer := 640;
	constant hTV : integer := 800;
	
	signal von : std_logic;
	signal hon : std_logic;
	
	signal temp_25 : std_logic := '0';
	signal clk_25 : std_logic := '0';
	
	signal temp_1 : std_logic := '0';
	signal counter_1 : integer range 0 to 124999 := 0; -- 400Hz
	signal temp_2 : std_logic := '0';
	signal counter_2 : integer range 0 to 833332 := 0; -- 60Hz
	signal temp_3 : std_logic := '0';
	signal counter_3 : integer range 0 to 555554 := 0; --100Hz
	
	signal paddle1 : std_logic_vector(9 downto 0) := "0011001101";
	signal paddleONE : std_logic_vector(0 downto 0);
	signal paddle2 : std_logic_vector(9 downto 0) := "0011001101";
	signal paddleTWO : std_logic_vector(0 downto 0);
	signal ballX : std_logic_vector(9 downto 0) := "0100111011";
	signal ballY : std_logic_vector(9 downto 0) := "0011101011";
	signal ballON : std_logic_vector(0 downto 0);
	
	signal border1 : std_logic_vector(0 downto 0);
	signal border2 : std_logic_vector(0 downto 0);
	signal border3 : std_logic_vector(0 downto 0);
	signal border4 : std_logic_vector(0 downto 0);
	
	signal width : integer := 70;
	constant width1 : integer := 70;
	constant width2 : integer := 120;
	
	signal ballSize : integer := 10;
	constant ballSize1 : integer := 10;
	constant ballSize2 : integer := 20;
	signal direction : std_logic_vector(1 downto 0) := "00";
	signal colour : std_logic_vector(11 downto 0) := "111100001111";
	
	signal paddleSpeed : std_logic;
	signal ballSpeed : std_logic;
	
	signal gameOver : std_logic;
	
	signal score : std_logic_vector(15 downto 0) := "0000000000000000";
	signal anode : std_logic_vector(3 downto 0);
	signal digit : std_logic_vector(3 downto 0);
	signal count_10ms : std_logic_vector(8 downto 0);
	signal enable : std_logic;

	signal logoON : boolean;
	signal gameOverON : boolean;
	signal posV : integer range 1 to vTV;
	signal posH : integer range 1 to hTV;

begin

	CLOCK_25 : process (clk, temp_25)
	begin
		if(clk'event and clk = '1') then
			temp_25 <= not temp_25;
		end if;
		
		if (temp_25'event and temp_25 = '1') then
			clk_25 <= not clk_25;
		end if;
	end process;
	
	SPEED_1 : process (clk, reset)
	begin
		if(reset = '1') then
			temp_1 <= '0';
			counter_1 <= 0;
			
		elsif(clk'event and clk = '1') then 
			if(counter_1 = 124999) then
				temp_1 <= not temp_1;
				counter_1 <= 0;
			else
				counter_1 <= counter_1 + 1;
			end if;
		
		end if;
	end process;
	
	SPEED_2 : process (clk, reset)
	begin
		if(reset = '1') then
			temp_2 <= '0';
			counter_2 <= 0;
			
		elsif(clk'event and clk = '1') then 
			if(counter_2 = 833332) then
				temp_2 <= not temp_2;
				counter_2 <= 0;
			else
				counter_2 <= counter_2 + 1;
			end if;
		
		end if;
	end process;
	
	SPEED_3 : process (clk, reset)
	begin
		if(reset = '1') then
			temp_3 <= '0';
			counter_3 <= 0;
			
		elsif(clk'event and clk = '1') then 
			if(counter_3 = 555554) then
				temp_3 <= not temp_3;
				counter_3 <= 0;
			else
				counter_3 <= counter_3 + 1;
			end if;
		
		end if;
	end process;
				
	VGA : process (clk_25) 
	begin
		if(clk_25'event and clk_25 = '1') then
			if hcount < hTV - 1 then
				hcount <= hcount + 1;
			else
				hcount <= (others => '0');
				
				if vcount < vTV - 1 then
					vcount <= vcount + 1;
				else
					vcount <= (others => '0');
				end if;
			end if;
			
			if hcount >= (hDT + hFP) and hcount < (hDT + hFP + hSP) then
				hon <= '0';
			else
				hon <= '1';
			end if;
			
			if vcount >= (vDT + vFP) and vcount < (vDT + vFP + vSP) then
				von <= '0';
			else
				von <= '1';
			end if;
			
		end if;
	end process;
	
	vsync_o <= von;
	hsync_o <= hon;
	
	
	logoON <= (posV >= (vBP + 200)) and (posV <= (vBP + 289)) and (posH >= (hBP + 150)) and (posH <= (hBP + 490)) and
				  logo(posV - (vBP + 200))(posH - (hBP + 150)) = '0' and game = '0';
				  
	gameOverON <= (posV >= (vBP + 137)) and (posV <= (vBP + 282)) and (posH >= (hBP + 175)) and (posH <= (hBP + 465)) and
				  gOver(posV - (vBP + 137))(posH - (hBP + 175)) = '0' and gameOver = '1' and game = '1';
				  
	
	paddleONE <= "1" when vcount > (paddle1 + vBP) and vcount < (paddle1 + vBP + width) and hcount > (hBP + 35) and hcount < (hBP + 50) and game = '1' else
					 "0";
	paddleTWO <= "1" when vcount > (paddle2 + vBP) and vcount < (paddle2 + vBP + width) and hcount > (hBP + 590) and hcount < (hBP + 605) and game = '1' else
					 "0";
	ballON <= "1" when vcount > (ballY + vBP) and vcount < (ballY + vBP + ballSize) and hcount > (hBP + ballX) and hcount < (hBP + ballX + ballSize) and game = '1' else
				 "0";
	border1 <= "1" when vcount > vBP and vcount < vBP + 5 and hcount > hBP and hcount < hDT + hBP else
					"0";
	border2 <= "1" when vcount > (475 + vBP) and vcount < (480 + vBP) and hcount > hBP and hcount < hDT + hBP else
					"0";
	border3 <= "1" when vcount > vBP and vcount < (480 + vBP) and hcount > hBP and hcount < hBP + 5 else
					"0";
	border4 <= "1" when vcount > vBP and vcount < (480 + vBP) and hcount > hBP + 630 and hcount < hBP + 640 else
					"0";	


	RGB <= "111111111111" WHEN paddleONE = "1" ELSE
			 "111111111111" WHEN paddleTWO = "1" ELSE
			 "111111111111" WHEN border1 = "1" ELSE
			 "111111111111" WHEN border2 = "1" ELSE
			 "111111111111" WHEN border3 = "1" ELSE
			 "111111111111" WHEN border4 = "1" ELSE
			 colour WHEN ballON = "1" ELSE
			 "111111111111" WHEN logoOn ELSE
			 "111111111111" WHEN gameOverON ELSE
			 "000000000000";

	
	with paddleSize select width <= 
		width1 when '0',
		width2 when '1';
		
	with speedSelect1 select paddleSpeed <= 
		temp_1 when '0',
		temp_2 when '1';
		
	with ballSizeSelect select ballSize <= 
		ballSize1 when '0',
		ballSize2 when '1';
		
	with speedSelect2 select ballSpeed <= 
		temp_2 when '0',
		temp_3 when '1';
		
	
	PADDLE_1 : process (paddleSpeed)
	 begin 
		if(paddleSpeed='1' and paddleSpeed'event) then
			if(paddle1 = "0011001101") then
				if(btnL = '1') then paddle1 <= paddle1 - 1;
				
				elsif(btnD = '1') then paddle1 <= paddle1 + 1;
			
				end if;
				
			elsif(paddle1 = 5) then
				if(btnD = '1') then paddle1 <= paddle1 + 1;
				
				elsif(btnC = '1') then paddle1 <= "0011001101";
				
				end if;
				
			elsif((paddle1 + width) = 475) then
				if(btnL = '1') then paddle1 <= paddle1 - 1;
				
				elsif(btnC = '1') then paddle1 <= "0011001101";
				
				end if;
				
			else
				if(btnL = '1') then paddle1 <= paddle1 - 1;
				
				elsif(btnD = '1') then paddle1 <= paddle1 + 1;
				
				elsif(btnC = '1') then paddle1 <= "0011001101";
				
				end if;
			end if;
		end if;
	 end process;
	 
	 
	 PADDLE_2 : process (paddleSpeed)
	 begin 
		if(paddleSpeed='1' and paddleSpeed'event) then
			
			if(paddle2 = "0011001101") then
				if(btnU = '1') then paddle2 <= paddle2 - 1;
				
				elsif(btnR = '1') then paddle2 <= paddle2 + 1;
			
				end if;
				
			elsif(paddle2 = 5) then
				if(btnR = '1') then paddle2 <= paddle2 + 1;
				
				elsif(btnC = '1') then paddle2 <= "0011001101";
				
				end if;
				
			elsif((paddle2 + width) = (475)) then
				if(btnU = '1') then paddle2 <= paddle2 - 1;
				
				elsif(btnC = '1') then paddle2 <= "0011001101";
				
				end if;
				
			else
				if(btnU = '1') then paddle2 <= paddle2 - 1;
				
				elsif(btnR = '1') then paddle2 <= paddle2 + 1;
				
				elsif(btnC = '1') then paddle2 <= "0011001101";
				
				end if;
			end if;
		end if;
	end process;

	--direction <= "00";

	BALL : process (ballSpeed)
	begin
		if(ballSpeed = '1' and ballSpeed'event) then
			if(start = '1') then 
				
				case (direction) is
					when "00" =>
						
						if(ballY <= 5) then
							ballX <= ballX - 1;
							ballY <= ballY + 1;
							direction <= "01";
							colour(11 downto 4) <= colour(7 downto 0);
							colour(3 downto 0) <= colour(11 downto 8);
						elsif(ballY >= paddle1 and ballY <= paddle1 + width and ballX = 50) then 
							ballX <= ballX - 1;
							ballY <= ballY + 1;
							direction <= "11";
							colour(11 downto 4) <= colour(7 downto 0);
							colour(3 downto 0) <= colour(11 downto 8);
							score <= score + 1;
						elsif(ballX <= 5) then
							ballX <= ballX;
							ballY <= ballY;
							gameOver <= '1';
						else
							ballX <= ballX - 1;
							ballY <= ballY - 1;
						end if;
						
						if(btnC = '1') then
							ballX <= "0100111011";
							ballY <= "0011101011";
							gameOver <= '0';
							score <= "0000000000000000";
						end if;
					
					when "01" => 
						if(ballY >= paddle1 and ballY <= paddle1 + width and ballX = 50) then 
							ballX <= ballX + 1;
							ballY <= ballY + 1;
							direction <= "10";
							colour(11 downto 4) <= colour(7 downto 0);
							colour(3 downto 0) <= colour(11 downto 8);
							score <= score + 1;
						elsif(ballX <= 5) then
							ballX <= ballX;
							ballY <= ballY;
							gameOver <= '1';
						elsif(ballY + ballSize = 475) then
							ballX <= ballX - 1;
							ballY <= ballY - 1;
							direction <= "00";
							colour(11 downto 4) <= colour(7 downto 0);
							colour(3 downto 0) <= colour(11 downto 8);
						else
							ballX <= ballX - 1;
							ballY <= ballY + 1;
						end if;
						
						if(btnC = '1') then
							ballX <= "0100111011";
							ballY <= "0011101011";
							gameOver <= '0';
							score <= "0000000000000000";
						end if;
					
					when "10" => 
						if(ballY + ballSize = 475) then
							ballX <= ballX + 1;
							ballY <= ballY - 1;
							direction <= "11";
							colour(11 downto 4) <= colour(7 downto 0);
							colour(3 downto 0) <= colour(11 downto 8);
						elsif(ballX + ballSize = 630) then
							ballX <= ballX;
							ballY <= ballY;
							gameOver <= '1';
						elsif(ballY >= paddle2 and ballY <= paddle2 + width and ballX + ballSize= 590) then 
							ballX <= ballX - 1;
							ballY <= ballY + 1;
							direction <= "01";
							colour(11 downto 4) <= colour(7 downto 0);
							colour(3 downto 0) <= colour(11 downto 8);
							score <= score + 1;
						else
							ballX <= ballX + 1;
							ballY <= ballY + 1;
						end if;
						
						if(btnC = '1') then
							ballX <= "0100111011";
							ballY <= "0011101011";
							gameOver <= '0';
							score <= "0000000000000000";
						end if;
					
					when "11" => 
						if(ballX + ballSize = 630) then
							ballX <= ballX;
							ballY <= ballY;
							gameOver <= '1';
							--direction <= "00";
						elsif(ballY = 5) then
							ballX <= ballX + 1;
							ballY <= ballY + 1;
							direction <= "10";
							colour(11 downto 4) <= colour(7 downto 0);
							colour(3 downto 0) <= colour(11 downto 8);
						elsif(ballY >= paddle2 and ballY <= paddle2 + width and ballX + ballSize= 590) then 
							ballX <= ballX - 1;
							ballY <= ballY - 1;
							direction <= "00";
							colour(11 downto 4) <= colour(7 downto 0);
							colour(3 downto 0) <= colour(11 downto 8);
							score <= score + 1;
						else
							ballX <= ballX + 1;
							ballY <= ballY - 1;
						end if;
						
						if(btnC = '1') then
							ballX <= "0100111011";
							ballY <= "0011101011";
							gameOver <= '0';
							score <= "0000000000000000";
						end if;
					
					when others =>
						ballX <= ballX;
						ballY <= ballY;
						
				end case;
				
--			elsif(start = '0') then 
--				if(btnC = '1') then
--					ballX <= "0100111011";
--					ballY <= "0011101011";
--					gameOver <= '0';
--					score <= "0000000000000000";
--				end if;
			end if;
		end if;
	end process;
		
	an <= anode;
	
	process(clk)
	begin
		if (clk'event and clk = '1') then
			if (reset = '1') then
				count_10ms <= (others => '0');
				enable <= '0';
			else
				if (count_10ms = 255 - 1) then
					count_10ms <= (others => '0');
					enable <= '1';
				else
					count_10ms <= count_10ms + 1;
					enable <= '0';
				end if;
			end if;
		end if;
	end process;

	process(clk)
	begin
		if (clk'event and clk = '1') then
			if (enable = '1') then
				case anode is 
					when "1110" => anode <= "1101";
					when "1101" => anode <= "1011";
					when "1011" => anode <= "0111";
					when "0111" => anode <= "1110";
					when others => anode <= "1110";
				end case;
			end if;
		end if;
	end process;
	
	process(anode, score)
	begin
		case anode is
			when "1110" => digit <= score(3 downto 0);
			when "1101" => digit <= score(7 downto 4);
			when "1011" => digit <= score(11 downto 8);
			when "0111" => digit <= score(15 downto 12);
			when others => digit <= score(15 downto 12);
		end case;
	end process;
	
	process(digit)
		begin
			case digit is
				when "0000" => cathode <= "1000000"; 
				when "0001" => cathode <= "1111001"; 
				when "0010" => cathode <= "0100100"; 
				when "0011" => cathode <= "0110000"; 
				when "0100" => cathode <= "0011001"; 
				when "0101" => cathode <= "0010010"; 
				when "0110" => cathode <= "0000010"; 
				when "0111" => cathode <= "1111000"; 
				when "1000" => cathode <= "0000000"; 
				when "1001" => cathode <= "0010000";
				when "1010" => cathode <= "0100000";
				when "1011" => cathode <= "0000011";
				when "1100" => cathode <= "1000110";
				when "1101" => cathode <= "0100001";
				when "1110" => cathode <= "0000110";
				when "1111" => cathode <= "0001110"; 
				when others => cathode <= "1111111"; 
			end case;
	end process;
	
	posV <= conv_integer(vcount);
	posH <= conv_integer(hcount);

end Behavioral;

