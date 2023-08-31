library ieee;
use ieee.std_logic_1164.all;

entity lt24_top_level is
    port(
        clk         : in std_logic;
        reset_n     : in std_logic;

        -- slave
        as_addr     : in std_logic_vector(2 downto 0);
        as_cs       : in std_logic;
        as_wr       : in std_logic;
        as_wrdata   : in std_logic_vector(31 downto 0);
        as_rd       : in std_logic;
        as_rddata   : out std_logic_vector(31 downto 0);
        as_irq      : out std_logic;

        -- master
        am_addr     : out std_logic_vector(31 downto 0);
        am_be       : out std_logic_vector(3 downto 0);
        am_rd       : out std_logic;
        am_rddata   : in std_logic_vector(31 downto 0);
        am_waitrq   : in std_logic;

        -- lcd
        lcd_reset_n : out std_logic;
        lcd_on      : out std_logic;
        lcd_cs      : out std_logic;
        lcd_dcx     : out std_logic;
        lcd_wr_n    : out std_logic;
        lcd_rd_n    : out std_logic;
        lcd_data    : out std_logic_vector(15 downto 0)
    );
end entity lt24_top_level;

architecture lt24 of lt24_top_level is

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
            FIFO_Empty          : in std_logic;
            FIFO_Almost_Empty   : in std_logic;

            -- Internal interface masterCTRL
            buf_addr            : out std_logic_vector(31 downto 0) := (others => '0');
            buf_length          : out std_logic_vector(31 downto 0) := (others => '0');

            -- External interface
            Data                : out std_logic_vector(15 downto 0);
            LCD_ON              : out std_logic := '1';
            CSx                 : out std_logic := '1';
            DCx                 : out std_logic;
            WRx                 : out std_logic;
            RDx                 : out std_logic
        );
    end component slaveCTRL;

    component LCD_Master is
        port(
        clk                 : in std_logic;
        reset_n             : in std_logic;

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
    end component LCD_Master;

    component fifo_lt_24 is
	    port(
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		almost_empty		: OUT STD_LOGIC ;
		almost_full		: OUT STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
    end component fifo_lt_24;

    signal s_buf_addr: std_logic_vector(31 downto 0);
    signal s_buf_len: std_logic_vector(31 downto 0);

    signal s_data: std_logic_vector(15 downto 0);
    signal s_rdreq: std_logic;
    signal s_wrreq: std_logic;
    signal s_almost_empty: std_logic;
    signal s_almost_full: std_logic;
    signal s_empty: std_logic;
    signal s_full: std_logic;
    signal s_q: std_logic_vector(15 downto 0);



begin

    u0 : component slaveCTRL
        port map (
            clk                 => clk,
            nReset              => reset_n,
            AS_addr             => as_addr,
            AS_CS               => as_cs,
            AS_Wr               => as_wr,
            AS_WData            => as_wrdata,
            AS_Rd               => as_rd,
            AS_RData            => as_rddata,
            AS_IRQ              => as_irq,
            RdFIFO              => s_rdreq,
            RdData              => s_q,
            FIFO_Empty          => s_empty,
            FIFO_Almost_Empty   => s_almost_empty,
            buf_addr            => s_buf_addr,
            buf_length          => s_buf_len,
            Data                => lcd_data,
            LCD_ON              => lcd_on,
            CSx                 => lcd_cs,
            DCx                 => lcd_dcx,
            WRx                 => lcd_wr_n,
            RDx                 => lcd_rd_n
        );

    u1 : component LCD_Master
        port map (
            clk                 => clk,
            reset_n             => reset_n,
            buf_addr            => s_buf_addr,
            buf_length          => s_buf_len,
            am_addr             => am_addr,
            am_be               => am_be,
            am_rd               => am_rd,
            am_rddata           => am_rddata,
            am_waitrq           => am_waitrq,
            FIFO_wr             => s_wrreq,
            FIFO_wrdata         => s_data,
            FIFO_full           => s_full,
            FIFO_almostfull     => s_almost_full
        );

    fifo_inst : fifo_lt_24
    port map (
		clock	 => clk,
		data	 => s_data,
		rdreq	 => s_rdreq,
		wrreq	 => s_wrreq,
		almost_empty	 => s_almost_empty,
		almost_full	 => s_almost_full,
		empty	 => s_empty,
		full	 => s_full,
		q	 => s_q
	);

    lcd_reset_n <= reset_n;

end;
