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

entity ESM_BB10Toplevel is
port (
	clk : in std_logic;

	-- sram pins
	sram_bw0: out std_logic;
	sram_bw1: out std_logic;
	sram_bw2: out std_logic;
	sram_bw3: out std_logic;
	sram_clk: out std_logic;
--	SR-CLKEN: out std_logic;
	sram_adv_ld_n: out std_logic;
	sram_cen: out std_logic;
	sram_oe_n: out std_logic;
	sram_we_n: out std_logic;

	sram_addr : out std_logic_vector(22 downto 0);
	sram_data : inout std_logic_vector(31 downto 0);

	-- rs232 pins
	TXD1_TO_FPGA : in std_logic;
	RXD1_FROM_FPGA : out std_logic;
	RTS1_TO_FPGA : in std_logic;
	CTS1_FROM_FPGA : out std_logic

	-- I/O
--	msdat : inout std_logic;				-- PS2 mouse data
--	msclk : inout std_logic;				-- PS2 mouse clk
--	kbddat : inout std_logic;				-- PS2 keyboard data
--	kbdclk : inout std_logic;				-- PS2 keyboard clk

	-- host controller interface (SPI)
--	n_scs : in std_logic_vector(2 downto 0);			-- SPI chip select
--	sdi : in std_logic;				-- SPI data input
--	sdo : inout std_logic;				-- SPI data 
--	sck : in std_logic;				-- SPI clock

	-- video
--	n_hsync : out std_logic;				-- horizontal sync
--	n_vsync : out std_logic;				-- vertical sync
--	red : out unsigned(1 downto 0);			-- red
--	green : out unsigned(1 downto 0);		-- green
--	blue : out unsigned(1 downto 0);			-- blue
	
	-- audio
--	left : out std_logic;				-- audio bitstream left
--	right : out std_logic				-- audio bitstream right
);
end entity;

architecture RTL of ESM_BB10Toplevel is

signal sysclk : std_logic;
signal clklocked : std_logic;

signal counter : unsigned(31 downto 0);

begin

sram_bw0<='1';
sram_bw1<='1';
sram_bw2<='1';
sram_bw3<='1';
sram_clk<='1';
sram_adv_ld_n<='1';
sram_cen<='1';
sram_oe_n<='1';
sram_we_n<='1';

sram_addr<=(others => '0');
sram_data<=(others => 'Z');

--txd<='1';
CTS1_FROM_FPGA<='1';

myclock : entity work.ESM_BB10_sysclock
port map(
	CLK_IN1 => clk,
	RESET => '0',
	CLK_OUT1 => sysclk,
	LOCKED => clklocked
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
--		vga_red => red,
--		vga_green => green,
--		vga_blue => blue,
--		vga_hsync 	=> n_hsync,
--		vga_vsync 	=> n_vsync,
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
		rxd => TXD1_TO_FPGA,
		txd => RXD1_FROM_FPGA
		
		-- Audio
--		audio_l => left,
--		audio_r => right
);

end architecture;