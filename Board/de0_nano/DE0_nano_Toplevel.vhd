library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

library work;
use work.Toplevel_Config.all;

entity DE0_nano_Toplevel is
	port
	(
		CLOCK_50		:	 in STD_LOGIC;
		KEY		:	 in std_logic_vector(1 downto 0);
		SW		:	 in std_logic_vector(3 downto 0);
		LEDG		:	 out std_logic_vector(7 downto 0);
		DRAM_DQ		:	 inout std_logic_vector(15 downto 0);
		DRAM_ADDR		:	 out std_logic_vector(12 downto 0);
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
--		TDI		:	 in STD_LOGIC;
--		TCK		:	 in STD_LOGIC;
--		TCS		:	 in STD_LOGIC;
--		TDO		:	 out STD_LOGIC;
		I2C_SDAT		:	 inout STD_LOGIC;
		I2C_SCLK		:	 out STD_LOGIC;
		GPIO_0		:	 inout std_logic_vector(33 downto 0);
		GPIO_1		:	 inout std_logic_vector(33 downto 0)
	);
END entity;

architecture rtl of DE0_nano_Toplevel is

signal reset : std_logic;
signal sysclk : std_logic;
signal pll_locked : std_logic;

signal audio_l : signed(15 downto 0);
signal audio_r : signed(15 downto 0);


signal ps2m_clk_in : std_logic;
signal ps2m_clk_out : std_logic;
signal ps2m_dat_in : std_logic;
signal ps2m_dat_out : std_logic;

signal ps2k_clk_in : std_logic;
signal ps2k_clk_out : std_logic;
signal ps2k_dat_in : std_logic;
signal ps2k_dat_out : std_logic;

alias PS2_MDAT : std_logic is GPIO_1(19);
alias PS2_MCLK : std_logic is GPIO_1(18);


signal vga_tred : unsigned(7 downto 0);
signal vga_tgreen : unsigned(7 downto 0);
signal vga_tblue : unsigned(7 downto 0);
signal vga_window : std_logic;

COMPONENT audio_top
	PORT
	(
		clk		:	 IN STD_LOGIC;
		rst_n		:	 IN STD_LOGIC;
		rdata		:	 IN SIGNED(15 DOWNTO 0);
		ldata		:	 IN SIGNED(15 DOWNTO 0);
		aud_bclk		:	 OUT STD_LOGIC;
		aud_daclrck		:	 OUT STD_LOGIC;
		aud_dacdat		:	 OUT STD_LOGIC;
		aud_xck		:	 OUT STD_LOGIC;
		i2c_sclk		:	 OUT STD_LOGIC;
		i2c_sdat		:	 INOUT STD_LOGIC
	);
END COMPONENT;

COMPONENT video_vga_dither
	GENERIC ( outbits : INTEGER := 4 );
	PORT
	(
		clk		:	 IN STD_LOGIC;
		hsync		:	 IN STD_LOGIC;
		vsync		:	 IN STD_LOGIC;
		vid_ena		:	 IN STD_LOGIC;
		iRed		:	 IN UNSIGNED(7 DOWNTO 0);
		iGreen		:	 IN UNSIGNED(7 DOWNTO 0);
		iBlue		:	 IN UNSIGNED(7 DOWNTO 0);
		oRed		:	 OUT UNSIGNED(outbits-1 DOWNTO 0);
		oGreen		:	 OUT UNSIGNED(outbits-1 DOWNTO 0);
		oBlue		:	 OUT UNSIGNED(outbits-1 DOWNTO 0)
	);
END COMPONENT;

begin

I2C_SDAT	<= 'Z';
GPIO_0(33 downto 2) <= (others => 'Z');
GPIO_1 <= (others => 'Z');

mypll : entity work.Clock_50to100
port map
(
	inclk0 => CLOCK_50,
	c0 => DRAM_CLK,
	c1 => sysclk,
	locked => pll_locked
);

reset<=(not SW(0) xor KEY(0)) and pll_locked;



myVirtualToplevel : entity work.VirtualToplevel
generic map
(
	sdram_rows => 12,
	sdram_cols => 8,
	sysclk_frequency => 1000
)
port map
(	
	clk => sysclk,
	reset_in => reset,

	-- sdram
	sdr_data => DRAM_DQ,
	sdr_addr => DRAM_ADDR(11 downto 0),
	sdr_dqm(1) => DRAM_UDQM,
	sdr_dqm(0) => DRAM_LDQM,
	sdr_we => DRAM_WE_N,
	sdr_cas => DRAM_CAS_N,
	sdr_ras => DRAM_RAS_N,
	sdr_cs => DRAM_CS_N,
	sdr_ba(1) => DRAM_BA_1,
	sdr_ba(0) => DRAM_BA_0,
--	sdr_clk => DRAM_CLK, defined in mypll
	sdr_cke => DRAM_CKE,

	-- RS232
	rxd => GPIO_0(1),
	txd => GPIO_0(0),

	-- Audio
	audio_l => audio_l,
	audio_r => audio_r
);


end architecture;
