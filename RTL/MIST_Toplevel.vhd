library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

library work;
use work.Toplevel_Config.ALL;

entity MIST_Toplevel is
	port
	(
		CLOCK_27		:	 in std_logic_vector(1 downto 0);

		UART_TX		:	 out STD_LOGIC;
		UART_RX		:	 in STD_LOGIC;

		SDRAM_DQ		:	 inout std_logic_vector(15 downto 0);
		SDRAM_A	:	 out std_logic_vector(12 downto 0);
		SDRAM_DQMH	:	 out STD_LOGIC;
		SDRAM_DQML	:	 out STD_LOGIC;
		SDRAM_nWE	:	 out STD_LOGIC;
		SDRAM_nCAS	:	 out STD_LOGIC;
		SDRAM_nRAS	:	 out STD_LOGIC;
		SDRAM_nCS	:	 out STD_LOGIC;
		SDRAM_BA		:	 out std_logic_vector(1 downto 0);
		SDRAM_CLK	:	 out STD_LOGIC;
		SDRAM_CKE	:	 out STD_LOGIC;

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

signal audiol : signed(15 downto 0);
signal audior : signed(15 downto 0);

-- Sigma Delta audio
COMPONENT hybrid_pwm_sd
	PORT
	(
		clk		:	 IN STD_LOGIC;
		n_reset		:	 IN STD_LOGIC;
		din		:	 IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		dout		:	 OUT STD_LOGIC
	);
END COMPONENT;

begin

--	All bidir ports tri-stated
SPI_DO <= 'Z';

mypll : entity work.PLL
port map
(
	inclk0 => CLOCK_27(0),
	c0 => SDRAM_CLK,
	c1 => sysclk,
	locked => pll_locked
);

reset<='1';

myVirtualToplevel : entity work.VirtualToplevel
generic map
(
	sdram_rows => 13,
	sdram_cols => 9,
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
	sdr_data => SDRAM_DQ,
	sdr_addr => SDRAM_A,
	sdr_dqm(1) => SDRAM_DQMH,
	sdr_dqm(0) => SDRAM_DQML,
	sdr_we => SDRAM_nWE,
	sdr_cas => SDRAM_nCAS,
	sdr_ras => SDRAM_nRAS,
	sdr_cs => SDRAM_nCS,
	sdr_ba => SDRAM_BA,
--	sdr_clk => DRAM_CLK,
	sdr_cke => SDRAM_CKE,

	-- RS232
	rxd => UART_RX,
	txd => UART_TX,

	-- SD Card
--	spi_cs => SD_DAT3,
--	spi_miso => SD_DAT,
--	spi_mosi => SD_CMD,
--	spi_clk => SD_CLK

	-- Audio
	audio_l => audiol,
	audio_r => audior
);

-- Do we have audio?  If so, instantiate a two DAC channels.
audio2: if Toplevel_UseAudio = true generate
leftsd: component hybrid_pwm_sd
	port map
	(
		clk => sysclk,
		n_reset => reset,
		din => std_logic_vector(audiol),
		dout => AUDIO_L
	);
	
rightsd: component hybrid_pwm_sd
	port map
	(
		clk => sysclk,
		n_reset => reset,
		din => std_logic_vector(audior),
		dout => AUDIO_R
	);
end generate;

-- No audio?  Make the audio pins high Z.

audio3: if Toplevel_UseAudio = false generate
	AUDIO_L<='Z';
	AUDIO_R<='Z';
end generate;


end architecture;
