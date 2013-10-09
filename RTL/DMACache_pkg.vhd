library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.DMACache_config.all;

package DMACache_pkg is

	type DMAChannel_FromHost is record
		setaddr : std_logic;
		setreqlen : std_logic;
		req : std_logic;
	end record;

	type DMAChannel_ToHost is record
		valid : std_logic;
	end record;

	type DMAChannels_FromHost is array (DMACache_MaxChannel downto 0) of DMAChannel_FromHost;
	type DMAChannels_ToHost is array (DMACache_MaxChannel downto 0) of DMAChannel_ToHost;

end package;
