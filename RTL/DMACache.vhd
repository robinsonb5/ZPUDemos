library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

library work;
use work.DMACache_pkg.ALL;
use work.DMACache_config.ALL;


entity DMACache is
	port(
		clk : in std_logic;
		reset_n : in std_logic;
		-- DMA channel address strobes

		vga_channel_from_host : in DMAChannel_FromHost;
		vga_channel_to_host : out DMAChannel_ToHost;
		spr0_channel_from_host : in DMAChannel_FromHost;
		spr0_channel_to_host : out DMAChannel_ToHost;

--		channels_from_host : in DMAChannels_FromHost;
--		channels_to_host : out DMAChannels_FromHost;
		data_out : out std_logic_vector(15 downto 0);

		-- SDRAM interface
		sdram_addr : out std_logic_vector(31 downto 0);
		sdram_reserveaddr : out std_logic_vector(31 downto 0);
		sdram_reserve : out std_logic;
		sdram_req : out std_logic;
		sdram_ack : in std_logic; -- Set when the request has been acknowledged.
		sdram_fill : in std_logic;
		sdram_data : in std_logic_vector(15 downto 0)
	);
end entity;

architecture rtl of dmacache is

type DMAChannel_Internal is record
	valid_d : std_logic; -- Used to delay the valid flag
	wrptr : unsigned(DMACache_MaxCacheBit downto 0);
	wrptr_next : unsigned(DMACache_MaxCacheBit downto 0);
	rdptr : unsigned(DMACache_MaxCacheBit downto 0);
	addr : std_logic_vector(31 downto 0); -- Current RAM address
	count : unsigned(15 downto 0); -- Number of words to transfer.
	pending : std_logic;
end record;

type inputstate_t is (rd1,rcv1,rcv2,rcv3,rcv4);
signal inputstate : inputstate_t := rd1;

type updatestate_t is (upd_vga,upd_spr0,upd_aud0,apd_aud1);
signal update : updatestate_t := upd_vga;

constant vga_base : std_logic_vector(2 downto 0) := "000";
constant spr0_base : std_logic_vector(2 downto 0) := "001";
constant spr1_base : std_logic_vector(2 downto 0) := "010";
constant aud0_base : std_logic_vector(2 downto 0) := "011";
constant aud1_base : std_logic_vector(2 downto 0) := "100";
constant aud2_base : std_logic_vector(2 downto 0) := "101";
constant aud3_base : std_logic_vector(2 downto 0) := "110";
-- constant aud1_base : std_logic_vector(2 downto 0) := "100";

-- DMA channel state information

signal vga : DMAChannel_Internal;
signal spr0 : DMAChannel_Internal;
signal aud0 : DMAChannel_Internal;
signal aud1 : DMAChannel_Internal;
signal aud2 : DMAChannel_Internal;
signal aud3 : DMAChannel_Internal;

-- interface to the blockram

signal cache_wraddr : std_logic_vector(7 downto 0);
signal cache_rdaddr : std_logic_vector(7 downto 0);
signal cache_wren : std_logic;
signal data_from_ram : std_logic_vector(15 downto 0);

begin

myDMACacheRAM : entity work.DMACacheRAM
	port map
	(
		clock => clk,
		data => data_from_ram,
		rdaddress => cache_rdaddr,
		wraddress => cache_wraddr,
		wren => cache_wren,
		q => data_out
	);

-- Employ bank reserve for SDRAM.
-- FIXME - use pointer comparison to turn off reserve when not needed.
sdram_reserve<='1' when vga.count/=X"000" else '0';

process(clk)
begin
	if rising_edge(clk) then
		if reset_n='0' then
			inputstate<=rd1;
			vga.count<=(others => '0');
			vga.wrptr<=(others => '0');
			vga.wrptr_next<=(2=>'1', others =>'0');
			spr0.count<=(others => '0');
			spr0.wrptr<=(others => '0');
			spr0.wrptr_next<=(2=>'1', others =>'0');
		end if;

		cache_wren<='0';
		
		if sdram_ack='1' then
			sdram_reserveaddr<=vga.addr;
			sdram_req<='0';
		end if;

		-- Request and receive data from SDRAM:
		case inputstate is
			-- First state: Read.  Check the channels in priority order.
			-- VGA has absolutel priority, and the others won't do anything until the VGA buffer is
			-- full.
			when rd1 =>
				if vga.rdptr( DMACache_MaxCacheBit downto 2)/=vga.wrptr_next( DMACache_MaxCacheBit downto 2) and vga.count/=X"000" then
					cache_wraddr<=vga_base&std_logic_vector(vga.wrptr);
					sdram_req<='1';
					sdram_addr<=vga.addr;
					vga.addr<=std_logic_vector(unsigned(vga.addr)+8);
					inputstate<=rcv1;
					update<=upd_vga;
					vga.count<=vga.count-4;
				elsif spr0.rdptr( DMACache_MaxCacheBit downto 2)/=spr0.wrptr_next( DMACache_MaxCacheBit downto 2) and spr0.count/=X"000" then
					cache_wraddr<=spr0_base&std_logic_vector(spr0.wrptr);
					sdram_req<='1';
					sdram_addr<=spr0.addr;
					spr0.addr<=std_logic_vector(unsigned(spr0.addr)+8);
					inputstate<=rcv1;
					update<=upd_spr0;
					spr0.count<=spr0.count-4;
				end if;
				-- FIXME - other channels here
			-- Wait for SDRAM, fill first word.
			when rcv1 =>
				if sdram_fill='1' then
					data_from_ram<=sdram_data;
					cache_wren<='1';
					inputstate<=rcv2;
				end if;
			when rcv2 =>
				data_from_ram<=sdram_data;
				cache_wren<='1';
				cache_wraddr<=std_logic_vector(unsigned(cache_wraddr)+1);
				inputstate<=rcv3;
			when rcv3 =>
				data_from_ram<=sdram_data;
				cache_wren<='1';
				cache_wraddr<=std_logic_vector(unsigned(cache_wraddr)+1);
				inputstate<=rcv4;
			when rcv4 =>
				data_from_ram<=sdram_data;
				cache_wren<='1';
				cache_wraddr<=std_logic_vector(unsigned(cache_wraddr)+1);
				inputstate<=rd1;
				case update is
					when upd_vga =>
						vga.wrptr<=vga.wrptr_next;
						vga.wrptr_next<=vga.wrptr_next+4;
					when upd_spr0 =>
						spr0.wrptr<=spr0.wrptr_next;
						spr0.wrptr_next<=spr0.wrptr_next+4;
				-- FIXME - other channels here
					when others =>
						null;
				end case;
			when others =>
				null;
		end case;
		
		if vga_channel_from_host.setaddr='1' then
			vga.addr<=vga_channel_from_host.addr;
			vga.wrptr<=(others =>'0');
			vga.wrptr_next<=(2=>'1', others =>'0');
		end if;
		if spr0_channel_from_host.setaddr='1' then
			spr0.addr<=spr0_channel_from_host.addr;
			spr0.wrptr<=(others =>'0');
			spr0.wrptr_next<=(2=>'1', others =>'0');
		end if;

		if vga_channel_from_host.setreqlen='1' then
			vga.count<=vga_channel_from_host.reqlen;
		end if;
		if spr0_channel_from_host.setreqlen='1' then
			spr0.count<=spr0_channel_from_host.reqlen;
		end if;

	end if;
end process;


process(clk)
begin
	if rising_edge(clk) then
		if reset_n='0' then
			vga.rdptr<=(others => '0');
			spr0.rdptr<=(others => '0');
		end if;

	-- Reset read pointers when a new address is set
		if vga_channel_from_host.setaddr='1' then
			vga.rdptr<=(others => '0');
		end if;
		if spr0_channel_from_host.setaddr='1' then
			spr0.rdptr<=(others => '0');
		end if;
		
	-- Handle timeslicing of output registers
	-- We prioritise simply by testing in order of priority.
	-- req signals should always be a single pulse; need to latch all but VGA, since it may be several
	-- cycles since they're serviced.

		if spr0_channel_from_host.req='1' then
			spr0.pending<='1';
		end if;
--		if req_audio0='1' then
--			aud0_pending<='1';
--		end if;

		vga_channel_to_host.valid<=vga.valid_d;
		spr0_channel_to_host.valid<=spr0.valid_d;

		vga.valid_d<='0';
		spr0.valid_d<='0';
		
		if vga_channel_from_host.req='1' then -- and vga_rdptr/=vga_wrptr then -- This test should never fail.
			cache_rdaddr<=vga_base&std_logic_vector(vga.rdptr);
			vga.rdptr<=vga.rdptr+1;
			vga.valid_d<='1';
		elsif spr0.pending='1' and spr0.rdptr/=spr0.wrptr then
			cache_rdaddr<=spr0_base&std_logic_vector(spr0.rdptr);
			spr0.rdptr<=spr0.rdptr+1;
			spr0.valid_d<='1';
			spr0.pending<='0';
--		elsif aud0_pending='1' and aud0_rdptr/=aud0_wrptr then
--			cache_rdaddr<=aud0_base&std_logic_vector(aud0_rdptr);
--			aud0_rdptr<=aud0_rdptr+1;
--			valid_audio0_d<='1';
--			aud0_pending<='0';
		end if;
	end if;
end process;
		
end rtl;

