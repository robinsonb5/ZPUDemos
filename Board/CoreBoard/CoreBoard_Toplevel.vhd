library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

library work;
use work.Toplevel_Config.ALL;


entity CoreBoard_Toplevel is
port(
	CLK50M : in std_logic;
	KEY0 : in std_logic;
	KEY1 : in std_logic;
	LED : out std_logic_vector(1 downto 0);
	CK : in std_logic_vector(3 downto 0); -- Alias SW(3 downto 0)
	-- SDRAM interface
	SDRAM_Addr : out std_logic_vector(12 downto 0);
	SDRAM_BA : out std_logic_vector(1 downto 0);
	SDRAM_CAS_N : out std_logic;
	SDRAM_CKE : out std_logic;
	SDRAM_CLK : out std_logic;
	SDRAM_CS_N : out std_logic;
	SDRAM_DQ : inout std_logic_vector(15 downto 0);
	SDRAM_DQM : out std_logic_vector(1 downto 0);
	SDRAM_RAS_N : out std_logic;
	SDRAM_WE_N : out std_logic;
	-- GPIO
	IO_D : inout std_logic_vector(40 downto 1)
);
end entity;

architecture rtl of CoreBoard_Toplevel is

signal sysclk : std_logic;
signal reset : std_logic;
signal UART_TXD : std_logic;
signal UART_RXD : std_logic;

signal spi_miso : std_logic;
signal spi_mosi : std_logic;
signal spi_clk : std_logic;
signal spi_cs : std_logic;

signal audio_l : signed(15 downto 0);
signal audio_r : signed(15 downto 0);
signal sd_left : std_logic;
signal sd_right : std_logic;

signal tft_miso : std_logic;
signal tft_mosi : std_logic;
signal tft_cs : std_logic;
signal tft_sck : std_logic;
signal tft_d_c : std_logic;
signal tft_led : std_logic;
signal tft_reset : std_logic;

signal ts_miso : std_logic;
signal ts_mosi : std_logic;
signal ts_cs : std_logic;
signal ts_sck : std_logic;
signal ts_irq : std_logic;

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

process(sysclk)
begin
	IO_D <= (others => 'Z');

	-- UART mapping
	IO_D(40) <= UART_TXD;
	UART_RXD <= IO_D(39);

	-- SPI mapping
	IO_D(9) <= spi_cs;
	IO_D(7) <= spi_mosi;
	IO_D(11) <= spi_clk;
	spi_miso <= IO_D(13);

	-- TFT mapping
	IO_D(15) <= tft_cs;
	IO_D(17) <= tft_reset;
	IO_D(19) <= tft_d_c;
	IO_D(21) <= tft_mosi;
	IO_D(23) <= tft_sck;
	IO_D(25) <= tft_led;
	tft_miso <= IO_D(27);

	-- Touchscreen mapping
	IO_D(30) <= ts_cs;
	IO_D(32) <= ts_mosi;
	IO_D(28) <= ts_sck;
	ts_miso <= IO_D(34);
	ts_irq <= IO_D(36);
	
	-- Sound mapping
	IO_D(37) <= sd_left; -- J1 pin 37
	IO_D(38) <= sd_right; -- J1 pin 38
	
	-- Other IO mappings

end process;


process(sysclk)
begin
	if rising_edge(sysclk) then
		reset <= KEY0;
	end if;
end process;


-- PLL

MyPLL : entity work.PLL
port map(
	inclk0 => CLK50M,
	c0 => SDRAM_CLK,
	c1 => sysclk
);

-- Main project instance.

myproject : entity work.VirtualToplevel
		generic map(
			sdram_rows => 13,
			sdram_cols => 9,
			sysclk_frequency => 1000
	)
		port map(
			clk => sysclk,
			reset_in => reset,

			-- SDRAM - presenting a single interface to both chips.
			sdr_addr => SDRAM_Addr,
			sdr_data => SDRAM_DQ,
			sdr_ba => SDRAM_BA,
			sdr_cke => SDRAM_CKE,
			sdr_dqm => SDRAM_DQM,
			sdr_cs => SDRAM_CS_N,
			sdr_we => SDRAM_WE_N,
			sdr_cas => SDRAM_CAS_N,
			sdr_ras => SDRAM_RAS_N,
			
			-- UART
			rxd => UART_RXD,
			txd => UART_TXD,

			-- SD card
			spi_miso => spi_miso,
			spi_mosi => spi_mosi,
			spi_clk => spi_clk,
			spi_cs => spi_cs,

			-- audio
			audio_l => audio_l,
			audio_r => audio_r
		);

-- Do we have audio?  If so, instantiate a two DAC channels.
audio2: if Toplevel_UseAudio = true generate
leftsd: component hybrid_pwm_sd
	port map
	(
		clk => sysclk,
		n_reset => reset,
		din => std_logic_vector(audio_l),
		dout => sd_left
	);
	
rightsd: component hybrid_pwm_sd
	port map
	(
		clk => sysclk,
		n_reset => reset,
		din => std_logic_vector(audio_r),
		dout => sd_right
	);
end generate;

-- No audio?  Make the audio pins high Z.

audio3: if Toplevel_UseAudio = false generate
	sd_left<='Z';
	sd_right<='Z';
end generate;

end architecture;
