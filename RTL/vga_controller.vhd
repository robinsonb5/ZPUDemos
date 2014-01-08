library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.ALL;

library work;
use work.DMACache_pkg.ALL;
use work.DMACache_config.ALL;

-- VGA controller
-- a module to handle VGA output

-- Modified for ZPU use, data bus is now 32-bits wide.

-- Self-contained, must generate timings
-- Programmable, must provide hardware registers that will respond to
-- writes.  Registers will include:  (Decode a 4k chunk)

-- 0 Framebuffer Address - hi and low


entity vga_controller is
  generic(
		enable_sprite : boolean := true
	);
  port (
		clk : in std_logic;
		reset : in std_logic;

		reg_addr_in : in std_logic_vector(7 downto 0); -- from host CPU
		reg_data_in: in std_logic_vector(31 downto 0);
		reg_data_out: out std_logic_vector(15 downto 0);
		reg_rw : in std_logic;
		reg_req : in std_logic;

		dma_data : in std_logic_vector(15 downto 0);
		vgachannel_fromhost : out DMAChannel_FromHost;
		vgachannel_tohost : in DMAChannel_ToHost;
		spr0channel_fromhost : out DMAChannel_FromHost;
		spr0channel_tohost : in DMAChannel_ToHost;
		
		sdr_refresh : out std_logic;

		vblank_int : out std_logic;
		hsync : out std_logic; -- to monitor
		vsync : out std_logic; -- to monitor
		red : out unsigned(7 downto 0);		-- Allow for 8bpp even if we
		green : out unsigned(7 downto 0);	-- only currently support 16-bit
		blue : out unsigned(7 downto 0);		-- 5-6-5 output
		vga_window : out std_logic	-- '1' during the display window
	);
end entity;
	
architecture rtl of vga_controller is
	signal vga_pointer : std_logic_vector(31 downto 0);

	signal vgasetaddr : std_logic;
	signal spr0setaddr : std_logic;
	
	signal framebuffer_pointer : std_logic_vector(31 downto 0) := X"00100000";
	constant hsize : unsigned(11 downto 0) := TO_UNSIGNED(640,12);
	constant htotal : unsigned(11 downto 0) := TO_UNSIGNED(800,12);
	constant hbstart : unsigned(11 downto 0) := TO_UNSIGNED(656,12);
	constant hbstop : unsigned(11 downto 0) := TO_UNSIGNED(752,12);
	constant vsize : unsigned(11 downto 0) := TO_UNSIGNED(480,12);
	constant vtotal : unsigned(11 downto 0) := TO_UNSIGNED(525,12);
	constant vbstart : unsigned(11 downto 0) := TO_UNSIGNED(500,12);
	constant vbstop : unsigned(11 downto 0) := TO_UNSIGNED(502,12);

	signal sprite0_pointer : std_logic_vector(31 downto 0) := X"00000000";
	signal sprite0_xpos : unsigned(11 downto 0);
	signal sprite0_ypos : unsigned(11 downto 0);
	signal sprite0_data : std_logic_vector(15 downto 0);
	signal sprite0_counter : unsigned(1 downto 0);

	signal sprite_col : std_logic_vector(3 downto 0);
	
	signal currentX : unsigned(11 downto 0);
	signal currentY : unsigned(11 downto 0);
	signal end_of_pixel : std_logic;
	signal vga_newframe : std_logic;
	signal vgadata : std_logic_vector(15 downto 0);

	signal vsync_r : std_logic;
	signal hsync_r : std_logic;
	signal vga_window_r : std_logic;

begin

	vsync<=vsync_r;
	hsync<=hsync_r;
	vga_window<=vga_window_r;

	vgachannel_fromhost.setaddr<=vgasetaddr;
	spr0channel_fromhost.setaddr<=spr0setaddr;

	myVgaMaster : entity work.video_vga_master
		generic map (
			clkDivBits => 4
		)
		port map (
			clk => clk,
			clkDiv => X"3",	-- 100 Mhz / (3+1) = 25 Mhz
--			clkDiv => X"4",	-- 125 Mhz / (4+1) = 25 Mhz

			hSync => hsync_r,
			vSync => vsync_r,

			endOfPixel => end_of_pixel,
			endOfLine => open,
			endOfFrame => open,
			currentX => currentX,
			currentY => currentY,

			-- Setup 640x480@60hz needs ~25 Mhz
			hSyncPol => '0',
			vSyncPol => '0',
			xSize => htotal,
			ySize => vtotal,
			xSyncFr => hbstart,
			xSyncTo => hbstop,
			ySyncFr => vbstart, -- Sync pulse 2
			ySyncTo => vbstop
		);		

	-- Handle CPU access to hardware registers
	
	process(clk,reset)
	begin
		if reset='0' then
			reg_data_out<=X"0000";
			if enable_sprite then
				sprite0_xpos<=X"000";
				sprite0_ypos<=X"000";
			end if;
		elsif rising_edge(clk) then
			if reg_req='1' then
				case reg_addr_in is
					when X"00" =>
						if reg_rw='0' then
							framebuffer_pointer(31 downto 0) <= reg_data_in;
						end if;
					when X"10" =>
						if reg_rw='0' and enable_sprite then
							sprite0_pointer(31 downto 0) <= reg_data_in;
						end if;
					when X"14" =>
						if reg_rw='0' and enable_sprite then
							sprite0_xpos <= unsigned(reg_data_in(11 downto 0));
						end if;
					when X"18" =>
						if reg_rw='0' and enable_sprite then
							sprite0_ypos <= unsigned(reg_data_in(11 downto 0));
						end if;
					when others =>
						reg_data_out<=X"0000";
				end case;
			end if;
		end if;
	end process;

	
	-- Sprite positions
	process(clk, reset, currentX, currentY)
	begin
		if rising_edge(clk) then
			spr0channel_fromhost.req<='0';
			if enable_sprite and currentX>=sprite0_xpos and currentX-sprite0_xpos<16
						and currentY>=sprite0_ypos and currentY-sprite0_ypos<16 then	
				if end_of_pixel='1' then
					case sprite0_counter is
						when "11" =>
							sprite_col<=sprite0_data(15 downto 12);
							sprite0_counter<="10";
						when "10" =>
							sprite_col<=sprite0_data(11 downto 8);
							sprite0_counter<="01";
						when "01" =>
							sprite_col<=sprite0_data(7 downto 4);
							sprite0_counter<="00";
						when "00" =>
							sprite_col<=sprite0_data(3 downto 0);
							spr0channel_fromhost.req<='1';
							sprite0_counter<="11";
					end case;
				end if;
			else
				sprite_col<="0000";
--				sprite0_counter<="11";
			end if;

--			Prefetch first word.
			if enable_sprite and spr0setaddr='1' then
				spr0channel_fromhost.req<='1';
				sprite0_counter<="11";
			end if;
			
			if enable_sprite and spr0channel_tohost.valid='1' then
				sprite0_data<=dma_data;
			end if;

		end if;
	end process;
	
	
	process(clk, reset,currentX, currentY)
	begin
		if rising_edge(clk) then
			sdr_refresh <='0';
			if end_of_pixel='1' and currentX=hsize then
				sdr_refresh<='1';
			end if;
		end if;
		
		if rising_edge(clk) then
			vblank_int<='0';
			vga_newframe<='0';
			vgachannel_fromhost.req<='0';
			vgasetaddr<='0';
			vgachannel_fromhost.setreqlen<='0';
			spr0setaddr<='0';
			spr0channel_fromhost.setreqlen<='0';	

			if(vgachannel_tohost.valid='1') then
				vgadata<=dma_data;
			end if;

			if end_of_pixel='1' then

				if currentX<640 and currentY<480 then
					vga_window_r<='1';
					-- Request next pixel from VGA cache
					vgachannel_fromhost.req<='1';

					if sprite_col(3)='1' then
						red <= (others => sprite_col(2));
					else
						red <= unsigned(vgadata(15 downto 11)&"000");
					end if;

					if sprite_col(3)='1' then
						green <= (others=>sprite_col(1));
					else
						green <= unsigned(vgadata(10 downto 5)&"00");
					end if;

					if sprite_col(3)='1' then
						blue <= (others=>sprite_col(0));
					else
						blue <= unsigned(vgadata(4 downto 0)&"000");
					end if;

				else
					vga_window_r<='0';
					
					-- New frame...
					if currentY=vsize and currentX=0 then
						vblank_int<='1';
					end if;

					-- Last line of VBLANK - update DMA pointers
					if currentY=vtotal then
							if currentX=0 then
								vgachannel_fromhost.addr<=framebuffer_pointer;
								vgasetaddr<='1';
							elsif currentX=1 then
								spr0channel_fromhost.addr<=sprite0_pointer;
								spr0setaddr<='1';
							end if;
					end if;
					
					if currentX=(htotal - 20) then	-- Signal to SDRAM controller that we're about to start displaying
						vgachannel_fromhost.reqlen<=TO_UNSIGNED(640,16);
						vgachannel_fromhost.setreqlen<='1';
					elsif enable_sprite and currentX=(htotal - 19) then
						spr0channel_fromhost.reqlen<=TO_UNSIGNED(4,16);
						spr0channel_fromhost.setreqlen<='1';
					end if;
				end if;
			end if;
		end if;
	end process;
		
end architecture;