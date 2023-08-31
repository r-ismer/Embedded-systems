library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ws2812_tb is 
end ws2812_tb;

architecture tb of ws2812_tb is 

component ws2812 is 
port(
    clk         : in std_logic;
	nReset      : in std_logic;
	-- Internal interface (i.e. Avalon slave).
	address     : in std_logic_vector(6 downto 0);
	write       : in std_logic;
	read        : in std_logic;
	writedata   : in std_logic_vector(7 downto 0);
	readdata    : out std_logic_vector(7 downto 0);
	-- External interface (i.e. leds).
	do          : out std_logic
);
end component;

    signal clk         : std_logic := '0';
	signal nReset      : std_logic := '1';
	-- Internal interface (i.e. Avalon slave).
	signal address     : std_logic_vector(6 downto 0);
	signal write       : std_logic := '0';
	signal read        : std_logic := '0';
	signal writedata   : std_logic_vector(7 downto 0);
	signal readdata    : std_logic_vector(7 downto 0);
	-- External interface (i.e. leds).
	signal do          : std_logic;

    constant period : time := 20 ns;
    constant half_period : time := 10 ns;

begin

    UUT: ws2812 port map (
        clk => clk,
        nReset => nReset,
        address => address,
        write => write,
        read => read,
        writedata => writedata,
        readdata => readdata,
        do => do       
    );

    CLOCK:
    clk <= '1' after 10 ns when clk = '0' else 
           '0' after 10 ns when clk = '1';

    preset : process is 
    begin 
        nReset <= '1';
        wait for 10 ns;
        nReset <= '0';
        wait for 50 ns;
        nReset <= '1';
        wait;
    end process preset;

    process is
    begin
        --loop 
        --    clk <= not clk after half_period;
        --end loop;

        wait for 110 ns;

        address <= "0000000";
        writedata <= "10101010";
        write <= '0', '1' after 20 ns, '0' after 80 ns;

        wait for period;

        address <= "0000101" after 40 ns;
        writedata <= "11110000" after 40 ns;
        
        wait for period;

        read <= '0', '1' after 60 ns, '0' after 80 ns;
        wait;
    end process;
end architecture;