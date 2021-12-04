module VerilogVirtualToplevel 
#(
	parameter sdram_rows=13,
	parameter sdram_cols=0,
	parameter sysclk_frequency=1000
)
(
	input clk,
	input reset_in,
	
	output [7:0] vga_red,
	output [7:0] vga_green,
	output [7:0] vga_blue,

	output vga_hsync,
	output vga_vsync,
	output vga_window,

	// SDRAM wires
	
	inout [15:0] sdr_data,
	output [12:0] sdr_addr,
	output [1:0] sdr_dqm,
	output sdr_we,
	output sdr_cas,
	output sdr_ras,
	output sdr_cs,
	output [1:0] sdr_ba,
// output sdr_clk,
	output sdr_cke,

	// SPI wires
	input spi_miso,
	output spi_mosi,
	output spi_clk,
	output spi_cs,
	
	// PS/2 wires
	input ps2k_clk_in,
	input ps2k_dat_in,
	output ps2k_clk_out,
	output ps2k_dat_out,
	input ps2m_clk_in,
	input ps2m_dat_in,
	output ps2m_clk_out,
	output ps2m_dat_out,

	// UART
	input rxd,
	output txd,
	
	// Audio
	output [15:0] audio_l,
	output [15:0] audio_r
);

localparam sysclk_hz = sysclk_frequency*1000;
localparam uart_divisor = sysclk_hz/1152;
localparam maxAddrBit = 31;

reg reset;
reg [15:0] reset_counter;

// UART wires

reg [7:0] ser_txdata;
wire ser_txready;
wire [7:0] ser_rxdata;
reg ser_rxrecv;
reg ser_txgo;
wire ser_rxint;

reg mem_busy;
reg [31:0] mem_read;
wire [31:0] mem_write;
wire [maxAddrBit:0] mem_addr;
wire mem_writeEnable;
wire mem_writeEnableh;
wire mem_writeEnableb;
wire mem_readEnable;

assign ps2k_dat_out=1'b1;
assign ps2k_clk_out=1'b1;
assign ps2m_dat_out=1'b1;
assign ps2m_clk_out=1'b1;

assign audio_l = 16'h0000;
assign audio_r = 16'h0000;

assign sdr_cke =1'b0; // Disable SDRAM for now
assign sdr_cs =1'b1; // Disable SDRAM for now

assign sdr_data = 16'bzzzzzzzzzzzzzzzz;
assign sdr_addr = 13'b0;
assign sdr_dqm = 2'b11;
assign sdr_we = 1'b1;
assign sdr_cas =1'b1;
assign sdr_ras =1'b1;
assign sdr_ba = 2'b11;

assign spi_mosi = 1'b1;
assign spi_clk = 1'b1;
assign spi_cs = 1'b1;


// Reset counter.

always @(posedge clk or negedge reset_in)
begin
	if(!reset_in) begin
		reset_counter<=16'hFFFF;
		reset<=1'b0;		
	end else begin
		reset_counter<=reset_counter-1'b1;
		if (!reset_counter)
			reset<=1'b1;
	end
end


// UART

simple_uart #(.enable_tx("true"),.enable_rx("true"))
(
	.clk(clk),
	.reset(reset), // active low
	.txdata(ser_txdata),
	.txready(ser_txready),
	.txgo(ser_txgo),
	.rxdata(ser_rxdata),
	.rxint(ser_rxint),
	.txint(),
	.clock_divisor(uart_divisor),
	.rxd(rxd),
	.txd(txd)
);


// Main CPU

ZPU_ROM_Wrapper #(.maxAddrBit(maxAddrBit)) zpu
(
	.clk             (clk),
	.reset           (!reset),
	.mem_busy        (mem_busy),
	.mem_read        (mem_read),
	.mem_write       (mem_write),
	.mem_addr        (mem_addr),
	.mem_writeEnable (mem_writeEnable),
	.mem_writeEnableh(mem_writeEnableh),
	.mem_writeEnableb(mem_writeEnableb),
	.mem_readEnable  (mem_readEnable)
);

always @(posedge clk) begin
	mem_busy<=1'b1;
	ser_txgo<=1'b0;
		
	// Write from CPU?
	if (mem_writeEnable) begin
		case(mem_addr[31:28])
			4'hF: begin
				case (mem_addr[7:0])
					8'hc0: begin
							ser_txdata<=mem_write[7:0];
							ser_txgo<=1'b1;
							mem_busy<=1'b0;
						end
					default: mem_busy<=1'b0;
				endcase;
			end
			default:
				mem_busy<=1'b0;
		endcase;
	end
	else if (mem_readEnable) begin // Read from CPU?
		case(mem_addr[31:28])
			4'hF: begin
				case (mem_addr[7:0])
					8'hc0: begin
							mem_read[9:0]<={ser_rxrecv,ser_txready,ser_rxdata};
							ser_rxrecv<=1'b0;	// Clear rx flag.
							mem_busy<=1'b0;
						end
					default: mem_busy<=1'b0;
				endcase;
			end
			default:
				mem_busy<=1'b0;
		endcase;
	end

	// Set this after the read operation has potentially cleared it.
	if(ser_rxint)
		ser_rxrecv<=1'b1;
end

endmodule
