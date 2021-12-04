library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use work.zpupkg.ALL;

use work.Toplevel_Config.all;

entity VirtualToplevel is
	generic (
		sdram_rows : integer := 12;
		sdram_cols : integer := 8;
		sysclk_frequency : integer := 1000 -- Sysclk frequency * 10
	);
	port (
		clk 			: in std_logic;
		reset_in 	: in std_logic;

		-- VGA
		vga_red 		: out unsigned(7 downto 0);
		vga_green 	: out unsigned(7 downto 0);
		vga_blue 	: out unsigned(7 downto 0);
		vga_hsync 	: out std_logic;
		vga_vsync 	: buffer std_logic;
		vga_window	: out std_logic;

		-- SDRAM
		sdr_data		: inout std_logic_vector(15 downto 0);
		sdr_addr		: out std_logic_vector((sdram_rows-1) downto 0);
		sdr_dqm 		: out std_logic_vector(1 downto 0);
		sdr_we 		: out std_logic;
		sdr_cas 		: out std_logic;
		sdr_ras 		: out std_logic;
		sdr_cs		: out std_logic;
		sdr_ba		: out std_logic_vector(1 downto 0);
--		sdr_clk		: out std_logic;
		sdr_cke		: out std_logic;

		-- SPI signals
		spi_miso		: in std_logic := '1'; -- Allow the SPI interface not to be plumbed in.
		spi_mosi		: out std_logic;
		spi_clk		: out std_logic;
		spi_cs 		: out std_logic;
		
		-- PS/2 signals
		ps2k_clk_in : in std_logic := '1';
		ps2k_dat_in : in std_logic := '1';
		ps2k_clk_out : out std_logic;
		ps2k_dat_out : out std_logic;
		ps2m_clk_in : in std_logic := '1';
		ps2m_dat_in : in std_logic := '1';
		ps2m_clk_out : out std_logic;
		ps2m_dat_out : out std_logic;

		-- UART
		rxd	: in std_logic;
		txd	: out std_logic;
		
		-- Audio
		audio_l : out signed(15 downto 0);
		audio_r : out signed(15 downto 0)
);
end entity;

architecture rtl of VirtualToplevel is

begin

vt: component VerilogVirtualToplevel
generic map (
	sdram_rows => sdram_rows,
	sdram_cols => sdram_cols,
	sysclk_frequency => sysclk_frequency
)
port map (
	clk => clk,
	reset_in => reset_in,

	-- VGA
	vga_red => vga_red,
	vga_green => vga_green,
	vga_blue => vga_blue,
	vga_hsync => vga_hsync,
	vga_vsync => vga_vsync,
	vga_window => vga_window,

	-- SDRAM
	sdr_data => sdr_data,
	sdr_addr => sdr_addr,
	sdr_dqm => sdr_dqm,
	sdr_we => sdr_we,
	sdr_cas => sdr_cas,
	sdr_ras => sdr_ras,
	sdr_cs => sdr_cs,
	sdr_ba => sdr_ba,
--		sdr_clk		: out std_logic;
	sdr_cke => sdr_cke,

	-- SPI signals
	spi_miso => spi_miso,
	spi_mosi	=> spi_mosi,
	spi_clk => spi_clk,
	spi_cs => spi_cs,
	
--	-- PS/2 signals
	ps2k_clk_in => ps2k_clk_in,
	ps2k_dat_in => ps2k_dat_in,
	ps2k_clk_out => ps2k_clk_out,
	ps2k_dat_out => ps2k_dat_out,
--	ps2m_clk_in : in std_logic := '1';
--	ps2m_dat_in : in std_logic := '1';
--	ps2m_clk_out : out std_logic;
--	ps2m_dat_out : out std_logic;

	-- UART
	rxd => rxd,
	txd => txd,
	
--	-- Audio
	audio_l => audio_l,
	audio_r => audio_r
);


end architecture;
