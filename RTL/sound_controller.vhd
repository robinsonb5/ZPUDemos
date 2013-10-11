library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.ALL;

library work;
use work.DMACache_pkg.ALL;
use work.DMACache_config.ALL;

-- Sound controller
-- a module to handle a single channel of DMA-driven 8-bit audio, with
-- six bit volume control, giving 14-bit output.
-- (These specifications might sound familiar to ex-Amiga users!)

-- To achieve Amiga-accurate pitches we need a clock of
-- 3546895 Hz (PAL) or 3579545 (NTSC)


entity sound_controller is
  port (
		clk : in std_logic;
		reset : in std_logic;

		reg_addr_in : in std_logic_vector(7 downto 0); -- from host CPU
		reg_data_in: in std_logic_vector(31 downto 0);
		reg_data_out: out std_logic_vector(15 downto 0);
		reg_rw : in std_logic;
		reg_req : in std_logic;

		dma_data : in std_logic_vector(15 downto 0);
		channel_fromhost : out DMAChannel_FromHost;
		channel_tohost : in DMAChannel_ToHost;
		
		audio_out : out signed(13 downto 0);
		audio_int : out std_logic
	);
end entity;
	
architecture rtl of sound_controller is

	-- Sound channel state
	signal datapointer : std_logic_vector(31 downto 0);
	signal datalen : std_logic_vector(15 downto 0);
	signal repeatpointer : std_logic_vector(31 downto 0);
	signal repeatlen : std_logic_vector(15 downto 0);
	signal period : std_logic_vector(15 downto 0);
	signal volume : signed(6 downto 0);

	-- Sound data
	signal sampleword : std_logic_vector(15 downto 0);
	signal sample : signed(7 downto 0);
	signal sampleout : signed(14 downto 0);
begin

	channel_fromhost.reqlen <= reg_data_in;
	volume(6)<='0';

	sampleout <= sample * volume;
	audio_out<=sampleout(14 downto 0);

	-- Handle CPU access to hardware registers
	
	process(clk,reset)
	begin
		if reset='0' then

		elsif rising_edge(clk) then

			channel_fromhost.setaddr <='0';
			channel_fromhost.setreqlen <='0';
			reg_data_out<=(others => '0');

			if reg_req='1' and reg_rw='0' then
				case reg_addr_in is
					when X"00" =>
						datapointer <= reg_data_in;
						channel_fromhost.addr <= reg_data_in;
						channel_fromhost.setaddr <='1';
					when X"04" =>
						datalen <= reg_data_in;
--						channel_fromhost.reqlen <= reg_data_in;
						channel_fromhost.setreqlen <='1';
					when X"08" =>
						repeatpointer <= reg_data_in;
					when X"0c" =>
						repeatlen <= reg_data_in;
					when X"10" =>
						period <= reg_data_in;
					when X"14" =>
						volume <= reg_data_in;
					when others =>
				end case;
			end if;

		-- Channel fetch
			channel_fromhost.req<='0';

			spr0channel_fromhost.req<='1';

			if channel_tohost.valid='1' then
				sound_data<=dma_data;
			end if;

		end if;
	end process;

	elsif enable_sprite and currentX=(htotal - 19) then
		spr0channel_fromhost.reqlen<=TO_UNSIGNED(4,16);
		spr0channel_fromhost.setreqlen<='1';
	end if;
		
end architecture;
