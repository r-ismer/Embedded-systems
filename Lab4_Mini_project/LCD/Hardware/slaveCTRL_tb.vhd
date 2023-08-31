library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity slaveCTRL_tb is 
end slaveCTRL_tb;

architecture tb of slaveCTRL_tb is 

component slaveCTRL is 
port(
    clk                 : in std_logic;
	nReset              : in std_logic;

	-- Internal interface Avalon slave
	AS_addr             : in std_logic_vector(2 downto 0); -- 2 to 0 for address register
    AS_CS               : in std_logic;
    AS_Wr               : in std_logic;
    AS_WData            : in std_logic_vector(31 downto 0);
    AS_Rd               : in std_logic;
    AS_RData            : out std_logic_vector(31 downto 0);
    AS_IRQ              : out std_logic;
    
    -- Internal interface FIFO
    RdFIFO              : out std_logic;
    RdData              : in std_logic_vector(15 downto 0);
    FIFO_Empty          : in std_logic; -- not needed ??
    FIFO_Almost_Empty   : in std_logic;

    -- Internal interface masterCTRL
    buf_addr            : out std_logic_vector(31 downto 0) := (others => '0');
    buf_length          : out std_logic_vector(31 downto 0) := (others => '0');

	-- External interface
	Data                : out std_logic_vector(15 downto 0);
    LCD_ON              : out std_logic := '1';
    CSx                 : out std_logic := '1';
    DCx                 : out std_logic;
    WRx                 : out std_logic
);
end component;

    signal clk         : std_logic := '0';
	signal nReset      : std_logic := '1';

	-- Internal interface Avalon slave
	signal AS_addr             : std_logic_vector(2 downto 0) := (others => '0');
    signal AS_CS               : std_logic := '1';
    signal AS_Wr               : std_logic := '0';
    signal AS_WData            : std_logic_vector(31 downto 0) := (others => '0');
    signal AS_Rd               : std_logic := '0';
    signal AS_RData            : std_logic_vector(31 downto 0);
    signal AS_IRQ              : std_logic;
    
    -- Internal interface FIFO
    signal RdFIFO              : std_logic;
    signal RdData              : std_logic_vector(15 downto 0) := x"A0A0";
    signal FIFO_Empty          : std_logic := '0';
    signal FIFO_Almost_Empty   : std_logic := '0';

    -- Internal interface masterCTRL
    signal buf_addr            : std_logic_vector(31 downto 0) := (others => '0');
    signal buf_length          : std_logic_vector(31 downto 0) := (others => '0');

	-- External interface
	signal Data                : std_logic_vector(15 downto 0);
    signal LCD_ON              : std_logic;
    signal CSx                 : std_logic;
    signal DCx                 : std_logic;
    signal WRx                 : std_logic;

    constant period             : time := 20 ns;
    constant half_period        : time := 10 ns;

begin

    UUT: slaveCTRL port map (
    clk                 => clk,
	nReset              => nReset,
	AS_addr             =>   AS_addr,
    AS_CS               =>  AS_CS,
    AS_Wr               => AS_Wr,
    AS_WData            => AS_WData,
    AS_Rd               => AS_Rd,
    AS_RData            => AS_RData,
    AS_IRQ              => AS_IRQ ,
    RdFIFO              => RdFIFO,
    RdData              => RdData,
    FIFO_Empty          =>  FIFO_Empty,
    FIFO_Almost_Empty   => FIFO_Almost_Empty,
    buf_addr            => buf_addr,
    buf_length          => buf_length,
	Data                => Data,
    LCD_ON              => LCD_ON,
    CSx                 =>  CSx,
    DCx                 => DCx,
    WRx                 =>  WRx
    );

    CLOCK:
    clk <= '1' after 10 ns when clk = '0' else 
           '0' after 10 ns when clk = '1';

    RdData <= x"A0A0" after 80 ns when RdData = x"D3D3" else 
            x"D3D3" after 80 ns when RdData = x"A0A0";

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

        -- Trying to send a command
        wait for 110 ns;
        AS_Wr <= '1';
        AS_addr <= "010";
        AS_WData <= x"0F0F0F0F";

        wait for 20 ns;
        AS_addr <= "011";
        AS_WData <= x"00000002";

        wait for 20 ns;
        AS_addr <= "101";
        AS_WData <= x"00001234";

        wait for 20 ns;
        AS_addr <= "101";
        AS_WData <= x"00004321";

        -- write command to lcd
        wait for 20 ns;
        AS_addr <= "100";
        AS_WData <= x"00000001";

        wait for 20 ns;
        AS_Wr <= '0';

        wait for 40 ns;
        AS_Rd <= '1';
        AS_addr <= "010";

        wait for 40 ns;
        AS_addr <= "011";

        wait for 40 ns;
        AS_Rd <= '0';

        -- Trying to send a frame
        wait for 40 ns;
        AS_Wr <= '1';
        AS_addr <= "001";
        AS_WData <= x"00012C00";
        wait for 40 ns;
        AS_addr <= "000"; -- change buff
        AS_WData <= x"01010101"; -- address buff

        wait for 7 ms;

        FIFO_empty <= '1';
        AS_WData <= x"11010101"; -- address buff
        
        wait for 200 ns;
        FIFO_empty <= '0';

       wait;


    end process;
end architecture;