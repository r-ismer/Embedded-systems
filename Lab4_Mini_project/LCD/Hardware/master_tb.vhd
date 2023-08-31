library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity master_tb is 
end master_tb;

architecture tb of master_tb is

component avalon_master is 
port(
    clk : in std_logic;
    reset_n : in std_logic;

     -- registers
    buf_addr            : in std_logic_vector(31 downto 0);
    buf_length          : in std_logic_vector(31 downto 0);

    -- master 
    am_addr             : out std_logic_vector(31 downto 0);
    am_be               : out std_logic_vector(3 downto 0);
    am_rd               : out std_logic;
    am_rddata           : in std_logic_vector(31 downto 0);
    am_waitrq           : in std_logic;

    -- FIFO
    FIFO_wr             : out std_logic;
    FIFO_wrdata         : out std_logic_vector(15 downto 0);
    FIFO_full           : in std_logic;
    FIFO_almostfull     : in std_logic
);
end component;

signal clk : std_logic := '0';
signal reset_n : std_logic := '0';
signal buf_addr : std_logic_vector(31 downto 0) := (others => '0');
signal buf_length : std_logic_vector(31 downto 0) := (others => '0');
signal am_addr : std_logic_vector(31 downto 0);
signal am_be : std_logic_vector(3 downto 0);
signal am_rd : std_logic;
signal am_rddata : std_logic_vector(31 downto 0) := (others => '0');
signal am_waitrq : std_logic := '0';
signal FIFO_wr : std_logic;
signal FIFO_wrdata : std_logic_vector(15 downto 0);
signal FIFO_full : std_logic := '0';
signal FIFO_almostfull : std_logic := '0';

constant period: time := 20 ns;
constant half_period: time := 10 ns;

begin
    UUT: avalon_master port map (
        clk => clk,
        reset_n => reset_n,
        buf_addr => buf_addr,
        buf_length => buf_length,
        am_addr => am_addr,
        am_be => am_be,
        am_rd => am_rd,
        am_rddata => am_rddata,
        am_waitrq => am_waitrq,
        FIFO_wr => FIFO_wr,
        FIFO_wrdata => FIFO_wrdata,
        FIFO_full => FIFO_full,
        FIFO_almostfull => FIFO_almostfull
    );

    CLOCK:
    clk <= '1' after half_period when clk = '0' else 
           '0' after half_period when clk = '1';

    preset: process is 
    begin
        reset_n <= '1';
        wait for half_period;
        reset_n <= '0';
        wait for 50 ns;
        reset_n <= '1';
        wait;
    end process preset;

    process is 
    begin
        wait for 110 ns;

        buf_addr <= "00000010101010101010101010101010";
        buf_length <= x"00012C00";
        am_rddata <= "11111111111111101111111110000000";
        --FIFO_almostfull <= '1';
        am_waitrq <= '1';

        wait for 200 ns;
        FIFO_almostfull <= '0';
        wait for 70 ns;
        am_waitrq <= '0';

        wait for 3000 us;

        buf_addr <= "00000000101010101010101010101010";
        buf_length <= x"00012C00";
        am_rddata <= "00000001110000000001010100001111";

        wait;

    end process;

end architecture;
