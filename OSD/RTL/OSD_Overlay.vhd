library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity OSD_Overlay is
port (
	clk : in std_logic;
	red_in : in unsigned(7 downto 0);
	green_in : in unsigned(7 downto 0);
	blue_in : in unsigned(7 downto 0);
	window_in : in std_logic;
	osd_winow_in : in std_logic;
	osd_pixel_in : in std_logic;
	red_out : in unsigned(7 downto 0);
	green_out : in unsigned(7 downto 0);
	blue_out : in unsigned(7 downto 0);
	window_out : out std_logic
);
end entity;

architecture RTL of OSD_Overlay is
begin


end architecture;
