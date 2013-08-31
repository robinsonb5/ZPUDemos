library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity MIST_Toplevel is
	port
	(
		CLOCK_27		:	 in std_logic_vector(1 downto 0);

		UART_TX		:	 out STD_LOGIC;
		UART_RX		:	 in STD_LOGIC;

		DRAM_DQ		:	 inout std_logic_vector(15 downto 0);
		DRAM_ADDR		:	 out std_logic_vector(11 downto 0);
		DRAM_LDQM		:	 out STD_LOGIC;
		DRAM_UDQM		:	 out STD_LOGIC;
		DRAM_WE_N		:	 out STD_LOGIC;
		DRAM_CAS_N		:	 out STD_LOGIC;
		DRAM_RAS_N		:	 out STD_LOGIC;
		DRAM_CS_N		:	 out STD_LOGIC;
		DRAM_BA_0		:	 out STD_LOGIC;
		DRAM_BA_1		:	 out STD_LOGIC;
		DRAM_CLK		:	 out STD_LOGIC;
		DRAM_CKE		:	 out STD_LOGIC;

		SPI_DO	: inout std_logic;
		SPI_DI	: in std_logic;
		SPI_SCK		:	 in STD_LOGIC;
		SPI_SS2		:	 in STD_LOGIC; -- FPGA
		SPI_SS3		:	 in STD_LOGIC; -- OSD
		SPI_SS4		:	 in STD_LOGIC; -- "sniff" mode
		CONF_DATA0  : in std_logic; -- SPI_SS for user_io

		VGA_HS		:	 out STD_LOGIC;
		VGA_VS		:	 out STD_LOGIC;
		VGA_R		:	 out unsigned(5 downto 0);
		VGA_G		:	 out unsigned(5 downto 0);
		VGA_B		:	 out unsigned(5 downto 0);

		AUDIO_L : out std_logic;
		AUDIO_R : out std_logic
	);
END entity;

architecture rtl of MIST_Toplevel is

signal reset : std_logic;
signal sysclk : std_logic;
signal pll_locked : std_logic;

begin

--	All bidir ports tri-stated
SPI_DO <= 'Z';

mypll : entity work.PLL
port map
(
	inclk0 => CLOCK_27(0),
	c0 => DRAM_CLK,
	c1 => sysclk,
	locked => pll_locked
);

reset<='1';

myVirtualToplevel : entity work.VirtualToplevel
generic map
(
	sdram_rows => 12,
	sdram_cols => 8,
	sysclk_frequency => 1250,
	vga_bits => 6
)
port map
(	
	clk => sysclk,
	reset_in => reset,

	-- video
	vga_hsync => VGA_HS,
	vga_vsync => VGA_VS,
	vga_red => VGA_R,
	vga_green => VGA_G,
	vga_blue => VGA_B,
--	vga_window => vga_window,
	
	-- sdram
	sdr_data => DRAM_DQ,
	sdr_addr => DRAM_ADDR,
	sdr_dqm(1) => DRAM_UDQM,
	sdr_dqm(0) => DRAM_LDQM,
	sdr_we => DRAM_WE_N,
	sdr_cas => DRAM_CAS_N,
	sdr_ras => DRAM_RAS_N,
	sdr_cs => DRAM_CS_N,
	sdr_ba(1) => DRAM_BA_1,
	sdr_ba(0) => DRAM_BA_0,
--	sdr_clk => DRAM_CLK,
	sdr_cke => DRAM_CKE,

	-- RS232
	rxd => UART_RX,
	txd => UART_TX

	-- SD Card
--	spi_cs => SD_DAT3,
--	spi_miso => SD_DAT,
--	spi_mosi => SD_CMD,
--	spi_clk => SD_CLK
);


end architecture;
