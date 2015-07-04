// Two Way Cache, supporting 128 meg address space.
// Would be easy enough to extend to wider address spaces, just need
// to increase the width of the "tag" blockram.

// If we're targetting Cyclone 3, then we have 9kbit blockrams to play with.
// Each burst, assuming we stick with 4-word bursts, is 64 bits, so a single M9K
// can hold 128 cachelines.  Since we're building a 2-way cache, this will end
// up being 2 overlapping sets of 64 cachelines.

// The address is broken down as follows:
//   bits 0 & 1 are irrelevant because we're working in 32-bit words.
//   bits 3:2 specify which word of a burst we're interested in.
//   Bits 10:4 specify the seven bit address of the cachelines;
//     this will map to {1'b0,addr[8:3]} and {1;b1,addr[8:3]} respectively.
//   Bits 25:11 have to be stored in the tag, which, it turns out is no problem,
//     since we can use have 18-bit wide words.  The highest bit will be used as
//     a "most recently used" flag, leaving one bit spare, so we can support 64 meg
//     without changing bit widths.
// (Storing the MRU flag in both tags in a 2-way cache is redundant, so we'll only 
// store it in the first tag.)

// Modified for 32 bit CPU bus width.
// We're using 8 word bursts, 16-bit channel to the SDRAM.
// One burst accounts for 2 address bits in the Data RAM
// and 4 address bits CPU side.
// We're using 10 address bits for the data RAM.
// {way, addr[10:4], word[burst[1:0]/addr[3:2]]}


module TwoWayCache
(
	input clk,
	input reset, // active low
	output ready,
	input [31:0] cpu_addr,
	input cpu_req,	// 1 to request attention
	output reg cpu_ack,	// 1 to signal that data is ready.
	output cpu_cachevalid, // 1 to indicate that data is already cached and valid
	input cpu_rw, // 1 for read cycles, 0 for write cycles
	input cpu_rwl,
	input cpu_rwu,
	input cpu_rwu2, // Upper word
	input [31:0] data_from_cpu,
	output [31:0] data_to_cpu,
//	output reg [31:0] sdram_addr, // The SDRAM controller uses the CPU address directly
	input [15:0] data_from_sdram,
	output reg [15:0] data_to_sdram,
	output reg sdram_req,
	input sdram_fill,
	output reg sdram_rw,	// 1 for read cycles, 0 for write cycles
	output reg busy,
	output [2:0] debug
);

// Debugging
reg cache_error;
assign debug[0]=cache_error;
assign debug[1]=tag_hit1;
assign debug[2]=tag_hit2;
reg debug_hit1;
reg debug_hit2;


// States for state machine
localparam	INIT1=0, INIT2=1, WAITING=2, WAITRD=3, PAUSE1=4;
localparam	WRITE1=5, WRITE2=6, WAITFILL=7, FILL2=8, FILL3=9;
localparam 	FILL4=10, FILL5=11, FILL6=12, FILL7=13, FILL8=14, FILL9=15;

reg [15:0] state = INIT1;
reg init;
reg [9:0] initctr;
assign ready=~init;

// BlockRAM and related signals for data

wire [10:0] data_port1_addr;
wire [10:0] data_port2_addr;
wire [17:0] data_port1_r;
wire [17:0] data_port2_r;
reg[17:0] data_ports_w;
wire [17:0] data_port1_r_hi;
wire [17:0] data_port2_r_hi;
reg[17:0] data_ports_w_hi;
reg data_wren1;
reg data_wren2;

defparam dataram.addrbits = 10;
defparam dataram.databits = 18;
defparam dataram_high.addrbits = 10;
defparam dataram_high.databits = 18;

DualPortRAM dataram(
	.clock(clk),
	.address_a(data_port1_addr),
	.address_b(data_port2_addr),
	.data_a(data_ports_w),
	.data_b(data_ports_w),
	.q_a(data_port1_r),
	.q_b(data_port2_r),
	.wren_a(data_wren1),
	.wren_b(data_wren2)
);


DualPortRAM dataram_high(
	.clock(clk),
	.address_a(data_port1_addr),
	.address_b(data_port2_addr),
	.data_a(data_ports_w_hi),
	.data_b(data_ports_w_hi),
	.q_a(data_port1_r_hi),
	.q_b(data_port2_r_hi),
	.wren_a(data_wren1),
	.wren_b(data_wren2)
);


wire data_valid1;
wire data_valid2;

assign data_valid1 = data_port1_r[17] & data_port1_r[16] & data_port1_r_hi[17] & data_port1_r_hi[16];
assign data_valid2 = data_port2_r[17] & data_port2_r[16] & data_port2_r_hi[17] & data_port2_r_hi[16];

// BlockRAM and related signals for tags.

wire [7:0] tag_port1_addr;
wire [7:0] tag_port2_addr;
wire [17:0] tag_port1_r;
wire [17:0] tag_port2_r;
wire [17:0] tag_port1_w;
wire [17:0] tag_port2_w;

reg tag_wren1;
reg tag_wren2;
reg tag_mru1;

defparam tagram.addrbits = 8;
defparam tagram.databits = 18;

DualPortRAM tagram(
	.clock(clk),
	.address_a(tag_port1_addr),
	.address_b(tag_port2_addr),
	.data_a(tag_port1_w),
	.data_b(tag_port2_w),
	.q_a(tag_port1_r),
	.q_b(tag_port2_r),
	.wren_a(tag_wren1),
	.wren_b(tag_wren2)
);

//   bits 3:2 specify which words of a burst we're interested in.
//   Bits 10:4 specify the seven bit address of the cachelines;
//   Since we're building a 2-way cache, we'll map this to 
//   {1'b0,addr[10:4]} and {1;b1,addr[10:4]} respectively.

wire [9:0] cacheline1;
wire [9:0] cacheline2;

reg [10:4] latched_cpuaddr;
reg [31:0] firstword;

assign data_to_cpu = (readword_burst ? firstword :
									((tag_hit1 && data_valid1) ?
										{data_port1_r_hi[15:0],data_port1_r[15:0]}
											: { data_port2_r_hi[15:0],data_port2_r[15:0]}));

assign cpu_cachevalid = ((tag_hit1 && data_valid1) || (tag_hit2 && data_valid2)) && !readword_burst;
								
reg readword_burst; // Set to 1 when the lsb of the cache address should
							// track the SDRAM controller.
reg [1:0] readword;

assign cacheline1 = {1'b0,cpu_addr[10:4],(readword_burst ? readword : cpu_addr[3:2])};
assign cacheline2 = {1'b1,cpu_addr[10:4],(readword_burst ? readword : cpu_addr[3:2])};

// We share each tag between all four 32-bit word of a cacheline.  We therefore only need
// one M9K tag RAM for four M9Ks of data RAM.

assign tag_port1_addr = cacheline1[9:2];
assign tag_port2_addr = cacheline2[9:2];

// The first port contains the mru flag, so we have to write to it on every
// access.  The second tag only needs writing when a cacheline in the second
// block is updated, so we tie the write port of the second tag to part of the
// CPU address.
// The first port has to be toggled between old and new data, depending upon
// the state of the mru flag.
// (Writing both ports on every access for troubleshooting)

assign tag_port1_w = {tag_mru1,(tag_mru1 ? cpu_addr[27:11] : tag_port1_r[16:0])};
assign tag_port2_w = {1'b0,(!tag_mru1 ? cpu_addr[27:11] : tag_port2_r[16:0])};
//assign tag_port2_w = {1'b0,cpu_addr[25:9]};


// Boolean signals to indicate cache hits.

wire tag_hit1;
wire tag_hit2;

assign tag_hit1 = tag_port1_r[16:0]==cpu_addr[27:11];
assign tag_hit2 = tag_port2_r[16:0]==cpu_addr[27:11];


// In the data blockram the lower two bits of the address determine
// which word of the burst we're reading.  When reading from the cache, this comes
// from the CPU address; when writing to the cache it's determined by the state
// machine.


assign data_port1_addr = init ? {1'b0,initctr} :
			readword_burst ? {1'b0,latched_cpuaddr,readword} : cacheline1;
assign data_port2_addr = init ? {1'b1,initctr} :
			readword_burst ? {1'b1,latched_cpuaddr,readword} : cacheline2;

always @(posedge clk)
begin

	// Defaults
	tag_wren1<=1'b0;
	tag_wren2<=1'b0;
	data_wren1<=1'b0;
	data_wren2<=1'b0;
	cpu_ack<=1'b0;
	init<=1'b0;
	readword_burst<=1'b0;
	cache_error<=1'b0;

	busy <=1'b1;
	
	case(state)

		// We use an init state here to loop through the data, clearing
		// the valid flag - for which we'll use bit 17 of the data entry.
	
		INIT1:
		begin
			init<=1'b1;	// need to mark the entire cache as invalid before starting.
			initctr<=10'b00_0000_0000;
			data_ports_w<=18'b0; // Mark entire cache as invalid
			data_ports_w_hi<=18'b0; // Mark entire cache as invalid
			data_wren1<=1'b1;
			data_wren2<=1'b1;
			state<=INIT2;
		end
		
		INIT2:
		begin
			init<=1'b1;
			initctr<=initctr+1;
			data_wren1<=1'b1;
			data_wren2<=1'b1;
			if(initctr==10'b11_1111_1111)
				state<=WAITING;
		end

		WAITING:
		begin
			state<=WAITING;
			busy <= 1'b0;
			if(cpu_req==1'b1)
			begin
				if(cpu_rw==1'b1)	// Read cycle
					state<=WAITRD;
				else	// Write cycle
					state<=WRITE1;
			end
		end
		WRITE1:
			begin
				busy <= 1'b0;
				// If the current address is in cache,
				// we must update the appropriate cacheline

				// FIXME - this won't work for byte accesses!
				
				// We mark the two halves of the word separately.
				// If this is a byte write, the byte not being written
				// will be marked as invalid, triggering a re-read if
				// the other byte or whole word is read.
				
				// FIXME - this gets more complicated for a 32-bit cache.
				// For now, we simply invalidate the cacheline if the write
				// is anything other than 32 bit.
				data_ports_w_hi<={~cpu_rwu2,~cpu_rwu2,data_from_cpu[31:16]};
				data_ports_w<={~cpu_rwu2,~cpu_rwu2,data_from_cpu[15:0]};

 				if(tag_hit1)
				begin
					// Write the data to the first cache way
					data_wren1<=1'b1;
					// Mark tag1 as most recently used.
					tag_mru1<=1'b1;
					tag_wren1<=1'b1;
				end
				// Note: it's possible that both ways of the cache will end up caching
				// the same address; if so, we must write to both ways, or at least
				// invalidate them both, otherwise we'll have problems with stale data.
				if(tag_hit2)
				begin
					// Write the data to the second cache way
					data_wren2<=1'b1;
					// Mark tag2 as most recently used.
					tag_mru1<=1'b0;
					tag_wren1<=1'b1;
				end
				
				// FIXME - ultimately we should clear a cacheline here and cache
				// the data for future use.

				// FIXME - we also need to check at this point whether the write cache
				// can merge this data into the current write, and if so send an ack.

				state<=WRITE2;
			end

		WRITE2:
			begin
				busy <= 1'b0;
				if(cpu_req==1'b0)	// Wait for the write cycle to finish
					state<=WAITING;
			end

		WAITRD:
			begin
				state<=PAUSE1;
				// Check both tags for a match...
				if(tag_hit1 && data_valid1)
				begin
					// Copy data to output
					cpu_ack<=1'b1;

					// Mark tag1 as most recently used.
					tag_mru1<=1'b1;
					tag_wren1<=1'b1;
				end
				else if(tag_hit2 && data_valid2)
				begin
					// Copy data to output
					cpu_ack<=1'b1;
					
					// Mark tag2 as most recently used.
					tag_mru1<=1'b0;
					tag_wren1<=1'b1;
				end
				else	// No matches?  How do we decide which one to use?
				begin
					// invert most recently used flags on both tags.
					// (Whichever one was least recently used will be overwritten, so
					// is now the most recently used.)
					// If either tag matches, but the corresponding data is stale,
					// we re-use the stale cacheline.

					latched_cpuaddr[10:4]<=cpu_addr[10:4];

					debug_hit1=tag_hit1;			
					debug_hit2=tag_hit2;

					if(tag_hit1)
						tag_mru1<=1'b1;	// Way 1 contains stale data
					else if(tag_hit2)
						tag_mru1<=1'b0;	// Way 2 contains stale data
					else
						tag_mru1<=!tag_port1_r[17];

					tag_wren1<=1'b1;
					tag_wren2<=1'b1;
					// If r[17] is 1, tag_mru1 is 0, so we need to write to the second tag.
					// FIXME - might be simpler to just write every cycle and switch between new and old data.

					sdram_req<=1'b1;
					sdram_rw<=1'b1;	// Read cycle
					state<=WAITFILL;
				end
			end

		PAUSE1:
		begin
			cpu_ack<=cpu_req;
			if(cpu_req==1'b0)
				state<=WAITING;
		end
		
		WAITFILL:
		begin
			readword_burst<=1'b1;
			// In the interests of performance, read the word we're waiting for first.
			readword<=cpu_addr[3:2];

			if (sdram_fill==1'b1)
			begin
				sdram_req<=1'b0;
				// Forward data to CPU
				firstword[31:16] <= data_from_sdram;

				// write first word to Cache...
				data_ports_w_hi<={2'b11,data_from_sdram};
				state<=FILL2;
			end
		end

		FILL2:
		begin
			cpu_ack<=1'b1; // Maintain ack signal if necessary
			// Forward data to CPU
			firstword[15:0] <= data_from_sdram;
			// write second word to Cache...
			readword_burst<=1'b1;
			data_ports_w<={2'b11,data_from_sdram};
			data_wren1<=tag_mru1;
			data_wren2<=!tag_mru1;
			state<=FILL3;

			if(debug_hit1 && data_valid1)
			begin
				if (data_port1_r_hi[15:0]!=data_ports_w_hi[15:0])
					cache_error<=1'b1;
				if (data_port1_r[15:0]!=data_from_sdram)
					cache_error<=1'b1;
			end
			
			if(debug_hit2 && data_valid2)
			begin
				if (data_port2_r_hi[15:0]!=data_ports_w_hi[15:0])
					cache_error<=1'b1;
				if (data_port2_r[15:0]!=data_from_sdram)
					cache_error<=1'b1;
			end

//			end
		end

		FILL3:
		begin
			cpu_ack<=cpu_req; // Maintain ack signal if necessary
			// write third word to Cache...
			readword_burst<=1'b1;
			data_ports_w_hi<={2'b11,data_from_sdram};
			state<=FILL4;
		end

		FILL4:
		begin
			cpu_ack<=cpu_req; // Maintain ack signal if necessary - that's four cycles, should be plenty
			readword_burst<=1'b1;
			readword<=readword+1;
			data_ports_w<={2'b11,data_from_sdram};
			data_wren1<=tag_mru1;
			data_wren2<=!tag_mru1;
			state<=FILL5;
		end

		FILL5:
		begin
			readword_burst<=1'b1;
			data_ports_w_hi<={2'b11,data_from_sdram};
			state<=FILL6;
		end

		FILL6:
		begin
			readword_burst<=1'b1;
			readword<=readword+1;
			data_ports_w<={2'b11,data_from_sdram};
			data_wren1<=tag_mru1;
			data_wren2<=!tag_mru1;
			state<=FILL7;
		end

		FILL7:
		begin
			readword_burst<=1'b1;
			data_ports_w_hi<={2'b11,data_from_sdram};
			state<=FILL8;
		end
		
		FILL8:
		begin
			readword_burst<=1'b1;
			readword<=readword+1;
			data_ports_w<={2'b11,data_from_sdram};
			data_wren1<=tag_mru1;
			data_wren2<=!tag_mru1;
			state<=FILL9;
		end
		
		FILL9:
		begin
//			readword_burst<=1'b1;
			readword<=cpu_addr[3:2];
			state<=WAITING;
		end

		default:
			state<=WAITING;
	endcase

	if(reset==1'b0)
		state<=INIT1;
end


endmodule
