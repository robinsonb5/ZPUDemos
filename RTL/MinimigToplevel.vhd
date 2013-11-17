-- Minimig toplevel file
-- 
-- This file is part of Minimig
-- 
-- Minimig is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 3 of the License, or
-- (at your option) any later version.
-- 
-- Minimig is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http:-- www.gnu.org/licenses/>.
--
-- Toplevel converted to VHDL by Alastair M. Robinson

library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity MinimigToplevel is
port (
	-- m68k pins
	cpu_data : inout std_logic_vector(15 downto 0);	-- m68k data bus
	cpu_address : in std_logic_vector(23 downto 1);	-- m68k address bus
	n_cpu_ipl  : out std_logic_vector(2 downto 0);		-- m68k interrupt request
	n_cpu_as : in std_logic;			-- m68k address strobe
	n_cpu_uds : in std_logic;			-- m68k upper data strobe
	n_cpu_lds : in std_logic;			-- m68k lower data strobe
	cpu_r_w : in std_logic;			-- m68k read / write
	n_cpu_dtack : out std_logic;			-- m68k data acknowledge
	n_cpu_reset : inout std_logic;			-- m68k reset
	cpu_clk : out std_logic;			-- m68k clock
	-- sram pins
	ram_data : inout std_logic_vector(15 downto 0);	-- sram data bus
	ram_address : out std_logic_vector(19 downto 1);	-- sram address bus
	n_ram_ce : out std_logic_vector(3 downto 0);		-- sram chip enable
	n_ram_bhe : out std_logic;			-- sram upper byte select
	n_ram_ble : out std_logic;			-- sram lower byte select
	n_ram_we : out std_logic;			-- sram write enable
	n_ram_oe : out std_logic;			-- sram  enable
	-- system	pins
	mclk  : in std_logic;				-- master system clock (4.433619MHz)
	-- rs232 pins
	rxd : in std_logic;				-- rs232 receive
	txd : out std_logic;			-- rs232 send
	cts : in std_logic;				-- rs232 clear to send
	rts : out std_logic;				-- rs232 request to send
	-- I/O
	n_joy1 : in std_logic_vector(5 downto 0);			-- joystick 1 [fire1,fire,up,down,left,right] (default mouse port)
	n_joy2 : in std_logic_vector(5 downto 0);			-- joystick 2 [fire1,fire,up,down,left,right] (default joystick port)
	n_15khz : in std_logic;				-- scandoubler disable
	pwrled : out std_logic;				-- power led
	msdat : inout std_logic;				-- PS2 mouse data
	msclk : inout std_logic;				-- PS2 mouse clk
	kbddat : inout std_logic;				-- PS2 keyboard data
	kbdclk : inout std_logic;				-- PS2 keyboard clk
	-- host controller interface (SPI)
	n_scs : in std_logic_vector(2 downto 0);			-- SPI chip select
	sdi : in std_logic;				-- SPI data input
	sdo : inout std_logic;				-- SPI data 
	sck : in std_logic;				-- SPI clock
	-- video
	n_hsync : out std_logic;				-- horizontal sync
	n_vsync : out std_logic;				-- vertical sync
	red : out unsigned(3 downto 0);			-- red
	green : out unsigned(3 downto 0);		-- green
	blue : out unsigned(3 downto 0);			-- blue
	-- audio
	left : out std_logic;				-- audio bitstream left
	right : out std_logic;				-- audio bitstream right
	-- user i/o
	drv_snd : out std_logic;
	-- unused pins
	init_b : out std_logic				-- vertical sync for MCU (sync OSD update)
);
end entity;

architecture RTL of MinimigToplevel is

signal sysclk : std_logic;
signal clklocked : std_logic;

begin

n_ram_oe<='1';
cpu_data<=(others=>'Z');
n_cpu_ipl<=(others=>'1');
n_cpu_dtack<='1';
cpu_clk<='0';
ram_address<=(others => '0');
n_ram_ce<=(others => '1');
n_ram_bhe<='1';
n_ram_ble<='1';
n_ram_we<='1';
n_ram_oe<='1';
--txd<='1';
rts<='1';
pwrled<='1';
msdat<='Z';
msclk<='Z';
kbddat<='Z';
kbdclk<='Z';
sdo<='Z';
--n_hsync<='1';
--n_vsync<='1';
--red<=(others => '0');
--green<=(others => '0');
--blue<=(others => '0');
left<='0';
right<='0';
drv_snd<='0';
init_b<='0';


myclock : entity work.minimig_sysclock
port map(
	CLKIN_IN => mclk,
	RST_IN => '0',
	CLKFX_OUT => sysclk,
	LOCKED_OUT => clklocked
);

project: entity work.VirtualToplevel
	generic map (
		sysclk_frequency => 1250, -- Sysclk frequency * 10
		vga_bits => 4
	)
	port map (
		clk => sysclk,
		reset_in => '1',

		-- VGA
		vga_red => red,
		vga_green => green,
		vga_blue => blue,
		vga_hsync 	=> n_hsync,
		vga_vsync 	=> n_vsync,
--		vga_window	: out std_logic;

		-- SDRAM
--		sdr_data		: inout std_logic_vector(15 downto 0);
--		sdr_addr		: out std_logic_vector((sdram_rows-1) downto 0);
--		sdr_dqm 		: out std_logic_vector(1 downto 0);
--		sdr_we 		: out std_logic;
--		sdr_cas 		: out std_logic;
--		sdr_ras 		: out std_logic;
--		sdr_cs		: out std_logic;
--		sdr_ba		: out std_logic_vector(1 downto 0);
--		sdr_clk		: out std_logic;
--		sdr_cke		: out std_logic;

		-- SPI signals
--		spi_miso		: in std_logic := '1'; -- Allow the SPI interface not to be plumbed in.
--		spi_mosi		: out std_logic;
--		spi_clk		: out std_logic;
--		spi_cs 		: out std_logic;
		
		-- UART
		rxd => rxd,
		txd => txd
		
		-- Audio
--		audio_l => left,
--		audio_r => right
);

end architecture;