library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.ALL;

-- VGA controller
-- a module to handle VGA output

-- Modified for ZPU use, data bus is now 32-bits wide.

-- Self-contained, must generate timings
-- Programmable, must provide hardware registers that will respond to
-- writes.  Registers will include:  (Decode a 4k chunk)

-- 0 Framebuffer Address - hi and low


entity vga_controller is
  generic(
		enable_sprite : boolean := true;
		vga_bits : integer := 4
	);
  port (
		clk : in std_logic;
		reset : in std_logic;

		reg_addr_in : in std_logic_vector(7 downto 0); -- from host CPU
		reg_data_in: in std_logic_vector(31 downto 0);
		reg_data_out: out std_logic_vector(15 downto 0);
		reg_rw : in std_logic;
		reg_req : in std_logic;

		sdr_addrout : buffer std_logic_vector(31 downto 0); -- to SDRAM
		sdr_datain : in std_logic_vector(15 downto 0);	-- from SDRAM
		sdr_fill : in std_logic; -- High when data is being written from SDRAM controller
		sdr_req : buffer std_logic; -- Request service from SDRAM controller
		sdr_reservebank : buffer std_logic; -- Indicate to SDR controller when requests are not critical timewise
		sdr_reserveaddr : buffer std_logic_vector(31 downto 0); -- Indicate to SDR controller when requests are not critical timewise
		sdr_refresh : out std_logic;
		sdr_ack : in std_logic;

		vblank_int : out std_logic;
		hsync : buffer std_logic; -- to monitor
		vsync : buffer std_logic; -- to monitor
		red : out unsigned(vga_bits-1 downto 0);		-- Allow for 8bpp even if we
		green : out unsigned(vga_bits-1 downto 0);	-- only currently support 16-bit
		blue : out unsigned(vga_bits-1 downto 0);		-- 5-6-5 output
		vga_window : buffer std_logic	-- '1' during the display window
	);
end entity;
	
architecture rtl of vga_controller is
	signal vga_pointer : std_logic_vector(31 downto 0);

	signal dma_addr : std_logic_vector(31 downto 0);
	signal setaddr_vga : std_logic;
	signal setaddr_spr0 : std_logic;
	signal dma_len : unsigned(11 downto 0);
	signal setlen_vga : std_logic;
	signal setlen_spr0 : std_logic;
	signal req_vga : std_logic;
	signal req_spr0 : std_logic;
	signal data_from_dma : std_logic_vector(15 downto 0);
	signal valid_vga : std_logic;
	signal valid_spr0 : std_logic;
	
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

	signal tred : unsigned(7 downto 0);
	signal tgreen : unsigned(7 downto 0);
	signal tblue : unsigned(7 downto 0);

begin

	myVgaMaster : entity work.video_vga_master
		generic map (
			clkDivBits => 4
		)
		port map (
			clk => clk,
--			clkDiv => X"3",	-- 100 Mhz / (3+1) = 25 Mhz
			clkDiv => X"4",	-- 125 Mhz / (4+1) = 25 Mhz

			hSync => hsync,
			vSync => vsync,

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


	mydither: entity work.video_vga_dither
		generic map
		(
			outbits => vga_bits
		)
		port map
		(
			clk => clk,
			hsync => hsync,
			vsync => vsync,
			vid_ena => vga_window,
			iRed => tred,
			iGreen => tgreen,
			iBlue => tblue,
			oRed => red,
			oGreen => green,
			oBlue => blue
		);

		
	mydmacache : entity work.DMACache
		port map(
			clk => clk,
			reset_n => reset,

			-- DMA addressing
			addr_in => dma_addr,
			setaddr_vga => setaddr_vga,
			setaddr_sprite0 => setaddr_spr0,
			setaddr_audio0 => '0',
			setaddr_audio1 => '0',

			-- DMA request lengths
			req_length => dma_len,
			setreqlen_vga => setlen_vga,
			setreqlen_sprite0 => setlen_spr0,
			setreqlen_audio0 => '0',
			setreqlen_audio1 => '0',

			-- Read requests
			req_vga => req_vga,
			req_sprite0 => req_spr0,
			req_audio0 => '0',
			req_audio1 => '0',

			-- DMA channel output and valid flags.
			data_out => data_from_dma,
			valid_vga => valid_vga,
			valid_sprite0 => valid_spr0,
			valid_audio0 => open,
			valid_audio1 => open,
			
			-- SDRAM interface
			sdram_addr=> sdr_addrout,
			sdram_reserveaddr(31 downto 0) => sdr_reserveaddr,
			sdram_reserve => sdr_reservebank,
			sdram_req => sdr_req,
			sdram_ack => sdr_ack,
			sdram_fill => sdr_fill,
			sdram_data => sdr_datain
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
			req_spr0<='0';
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
							req_spr0<='1';
							sprite0_counter<="11";
					end case;
				end if;
			else
				sprite_col<="0000";
--				sprite0_counter<="11";
			end if;

--			Prefetch first word.
			if enable_sprite and setaddr_spr0='1' then
				req_spr0<='1';
				sprite0_counter<="11";
			end if;
			
			if enable_sprite and valid_spr0='1' then
				sprite0_data<=data_from_dma;
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
			req_vga<='0';
			vga_newframe<='0';
			setaddr_vga<='0';
			setaddr_spr0<='0';
			setlen_vga<='0';
			setlen_spr0<='0';	

			if(valid_vga='1') then
				vgadata<=data_from_dma;
			end if;

			if end_of_pixel='1' then

				if currentX<640 and currentY<480 then
					vga_window<='1';
					-- Request next pixel from VGA cache
					req_vga<='1';

					if sprite_col(3)='1' then
						tred <= (others => sprite_col(2));
					else
						tred <= unsigned(vgadata(15 downto 11)&"000");
					end if;

					if sprite_col(3)='1' then
						tgreen <= (others=>sprite_col(1));
					else
						tgreen <= unsigned(vgadata(10 downto 5)&"00");
					end if;

					if sprite_col(3)='1' then
						tblue <= (others=>sprite_col(0));
					else
						tblue <= unsigned(vgadata(4 downto 0)&"000");
					end if;

				else
					vga_window<='0';
					
					-- New frame...
					if currentY=vsize and currentX=0 then
						vblank_int<='1';
					end if;

					-- Last line of VBLANK - update DMA pointers
					if currentY=vtotal then
							if currentX=0 then
								dma_addr<=framebuffer_pointer;
								setaddr_vga<='1';
							elsif currentX=1 then
								dma_addr<=sprite0_pointer;
								setaddr_spr0<='1';
							end if;
					end if;
					
					if currentX=(htotal - 20) then	-- Signal to SDRAM controller that we're
						dma_len<=TO_UNSIGNED(640,12);
						setlen_vga<='1';
					elsif enable_sprite and currentX=(htotal - 19) then
						dma_len<=TO_UNSIGNED(4,12);
						setlen_spr0<='1';
					end if;
				end if;
			end if;
		end if;
	end process;
		
end architecture;