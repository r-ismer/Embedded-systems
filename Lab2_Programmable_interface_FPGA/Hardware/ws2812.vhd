library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ws2812 is 
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
end ws2812;

architecture comp of ws2812 is

    -- clk is 50 MHz (20 ns)
    constant num_leds : natural := 24;
    constant color_size : natural := 24;
    type table is array(num_leds - 1 downto 0) of std_logic_vector(color_size - 1 downto 0);
    type Tstate is (RESET, CODE_0, CODE_1);

    constant T0H : natural := 17;       -- .35 us (350 ns / 17-18 clk cycle)
    constant T1H : natural := 35;       -- .7  us (700 ns / 35 clk cycle)
    constant T0L : natural := 40;       -- .8  us (800 ns / 40 clk cycle)
    constant T1L : natural := 30;       -- .6  us (600 ns / 30 clk cycle)
    constant RES : natural := 2500;     -- above 50 us (50 000 ns / 2500 clk cycle)

    signal counter : natural;
    signal next_counter : natural;
    signal bit_counter : natural;
    signal next_bit_counter: natural;
    signal led_counter : natural;
    signal next_led_counter : natural;

    signal state : Tstate;
    signal next_state : Tstate;
    signal leds : table;

begin 

dff : process(clk, nReset)
begin 
    if nReset = '0' then
        state <= RESET;
        counter <= 0;
        bit_counter <= 0;
        led_counter <= 0;
    elsif rising_edge(clk) then
        state <= next_state;
        counter <= next_counter;
        bit_counter <= next_bit_counter;
        led_counter <= next_led_counter;
    end if;
end process dff;

main: process(counter)
begin
    next_state <= state;
    next_counter <= counter + 1;
    next_bit_counter <= bit_counter;
    next_led_counter <= led_counter;
    do <= '0';
    case state is 
    when RESET => 
        --next_counter <= 0;
        next_bit_counter <= 0;
        next_led_counter <= 0;
        if counter = RES then
            next_counter <= 0;
            next_bit_counter <= 0;
            next_led_counter <= 0;
            if leds(0)(0) = '1' then
                next_state <= CODE_1;
            else 
                next_state <= CODE_0;
            end if;
        end if;
    when CODE_0 =>
        if counter = T0H + T0L then
            next_counter <= 0;
            next_bit_counter <= bit_counter + 1;
            if bit_counter + 1 = color_size then
                next_led_counter <= led_counter + 1;
                next_bit_counter <= 0;
                if led_counter + 1 = num_leds then
                    next_state <= RESET;
                    next_led_counter <= 0;
                elsif leds(led_counter + 1)(0) = '1' then
                    next_state <= CODE_1;
                else 
                    next_state <= CODE_0;
                end if;
            elsif leds(led_counter)(bit_counter + 1) = '1' then
                next_state <= CODE_1;
            else 
                next_state <= CODE_0;
            end if;
        end if;
        if counter < T0H then
            do <= '1';
        else 
            do <= '0';
        end if;
    when CODE_1 =>
        if counter = T1H + T1L then
            next_counter <= 0;
            next_bit_counter <= bit_counter + 1;
            if bit_counter + 1 = color_size then
                next_led_counter <= led_counter + 1;
                next_bit_counter <= 0;
                if led_counter + 1 = num_leds then
                    next_state <= RESET;
                    next_led_counter <= 0;
                elsif leds(led_counter + 1)(0) = '1' then
                    next_state <= CODE_1;
                else 
                    next_state <= CODE_0;
                end if;
            elsif leds(led_counter)(bit_counter + 1) = '1' then
                next_state <= CODE_1;
            else 
                next_state <= CODE_0;
            end if;
        end if;
        if counter < T1H then
            do <= '1';
        else 
            do <= '0';
        end if;
    end case;
end process main;

process(clk, nReset)
-- addr 0 => B
-- addr 1 => R
-- addr 2 => G
begin
    if nReset = '0' then
        for i in 0 to num_leds - 1 loop
            leds(i) <= (others => '0');
        end loop;
        
    elsif rising_edge(clk) then
        if write = '1' then
            case address(1 downto 0) is 
            when "00" => leds(to_integer(unsigned(address(6 downto 2))))(7 downto 0) <= writedata;
            when "01" => leds(to_integer(unsigned(address(6 downto 2))))(15 downto 8) <= writedata;
            when "10" => leds(to_integer(unsigned(address(6 downto 2))))(23 downto 16) <= writedata;
            when others => null;
            end case;
        end if;
    end if;
end process;

process(clk, nReset)
begin
    if nReset = '0' then
        readdata <= (others => '0');
    elsif rising_edge(clk) then
        readdata <= (others => '0');
        if read = '1' then
            case address(1 downto 0) is 
            when "00" => readdata <= leds(to_integer(unsigned(address(6 downto 2))))(7 downto 0);
            when "01" => readdata <= leds(to_integer(unsigned(address(6 downto 2))))(15 downto 8);
            when "10" => readdata <= leds(to_integer(unsigned(address(6 downto 2))))(23 downto 16);
            when others => null;
            end case;
        end if;
    end if;
end process;

end comp;
