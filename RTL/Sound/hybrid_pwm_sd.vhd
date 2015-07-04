--// Hybrid PWM / Sigma Delta converter
--//
--// Uses 5-bit PWM, wrapped within a 10-bit Sigma Delta, with the intention of
--// increasing the pulse width, since narrower pulses seem to equate to more
--// noise on the Minimig

entity hybrid_pwm_sd is
port (
	clk : in std_logic;
	n_reset : in std_logic;
	din : in signed(15 downto 0);
	dout : out std_logic
);
end entity;

architecture behavioural of hybrid_pwm_sd is
signal pwmcounter : unsigned(4 downto 0);
signal pwmthreshold : unsigned(4 downto 0);
signal scaledin : signed(33 downto 0);
signal sigma : signed(15 downto 0);

begin

process(clk)
begin

	if n_reset='0' then
		sigma<="0000010000000000";
		pwmthreshold<="10000";
	elsif rising_edge(clk) then
		pwmcounter<=pwmcounter+1;

		if pwmcounter=pwmthreshold then
			out<='0';
		end if;

		if pwmcounter=="11111" then -- Update threshold when pwmcounter reaches zero
			-- Pick a new PWM threshold using a Sigma Delta
			scaledin<=134217728 -- (1<<(16-5))<<16, offset to keep centre aligned.
				+(('0'&din}*61440); -- 30<<(16-5)-1;
			sigma<=scaledin[31:16]+{5'b000000,sigma[10:0]};	// Will use previous iteration's scaledin value
			pwmthreshold<=sigma[15:11]; // Will lag 2 cycles behind, but shouldn't matter.
			out<=1'b1;
		end

		if(dump)
		begin
			sigma[10:0]<=10'b10_0000_0000; // Clear the accumulator to avoid standing tones.
//			sigma[10:0]<={(lfsr_reg[8] ? 4'b10_0 : 4'b011),lfsr_reg[7:0]}; // fill the accumulator with a random value to avoid standing tones.

			// x^25 + x^22 + 1
//			lfsr_reg<={lfsr_reg[23:0],lfsr_reg[24] ^ lfsr_reg[21]};
		end
	end
end

endmodule
