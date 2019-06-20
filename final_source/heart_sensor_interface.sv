/* 	heartbeat.sv  -  Heartbeat sensor storage
*
*	------------------------------
*	Author: Alex Olson
*	Date:	March 2019
*	Class:	ECE 540 - SoC Design
*	------------------------------
*
*	Description:
*		This file contains the ADC protocol facing logic for the heartbeat module.
*       Data is read MSB first from the SPI interface, reversed, and stored into a buffer that holds 4 converted numbers.
*       There are three types of I/O: heartbeat data, read ready, and read acknowledged.
*       The read rdy/ack signals are for handshaking with the MIPSfpga.
*       When a ready signal is asserted, the processor must assert ack, read the heartbeat data, then de-assert ack.
*		A reference clock of 8.4MHz is dicided to capture 1.05MHz and 128Hz signals for data collection.
*/

`include "mfp_ahb_const.vh"

module heartbeat 
(
	input  logic        ahbCLK,						// Clock for interfacing buffer with AHB
	input  logic		sysCLK,						// System input clock (8.4 MHz in this example)
	input  logic		resetN,						// Global Asynchronous Reset
	input  logic 		IO_READ_ACK,				// Signal that the buffer was read
	inout  logic [ 4:1]	IO_JA,						// SPI data
	output logic 		IO_READ_RDY,				// Buffer is ready after collecting a parameterized read size
	output logic [31:0] IO_HEARTBEAT				// Heartbeat data
);

	localparam TRANSFER_SIZE = 14;					// 13 bit transfers -> 2 bits for conversion, 1 null, then 10 bits of data
	localparam BUFSIZE = 4;  						// 4 entries
	localparam BUFBITS = $clog2(BUFSIZE);			// Buffer size
	localparam TOPCOUNT = 16'h8068;					// For tracking 13 clocks (D) after enable is triggered (refCLK[15]) 800D?

	logic enableN = 1;								// SPI enable signal
	logic [15:0] refCLK = '0;						// Reference clk, SCLK is bit 2 --> 1.05 MHz if sysCLK is 8.4 MHz
	logic [BUFBITS-1:0] wr_loc = '0;				// Buffer location count	logic [7:0] bus_interface;

	logic [TRANSFER_SIZE-1:0] din, dout, doutLE;	// SPI input/output --> MSB First as per the standard
	logic [7:0] buffer [BUFSIZE];					// Circular buffer to hold MISO data
	logic MISO, MOSI, SSN, SCLK;					// SPI signals

	// Data is only read from the sensor, not written
	assign din = 'z;

	// Reverse MSB first data into little endian format for buffer
	assign doutLE[ 0] = dout[13]; 
	assign doutLE[ 1] = dout[12]; 
	assign doutLE[ 2] = dout[11];
	assign doutLE[ 3] = dout[10];  
	assign doutLE[ 4] = dout[ 9]; 
	assign doutLE[ 5] = dout[ 8]; 
	assign doutLE[ 6] = dout[ 7]; 
	assign doutLE[ 7] = dout[ 6]; 
	assign doutLE[ 8] = dout[ 5];
	assign doutLE[ 9] = dout[ 4]; 
	assign doutLE[10] = dout[ 3]; 
	assign doutLE[11] = dout[ 2];
	assign doutLE[12] = dout[ 1]; 
	assign doutLE[13] = dout[ 0]; 

	// Route SPI signals to PMOD JA
	assign MISO = IO_JA[1];
	assign IO_JA[2] = MOSI;
	assign IO_JA[3] = SSN;
	assign IO_JA[4] = SCLK;

	// Heart sensor ADC SPI interface
	spi_if #(TRANSFER_SIZE) heart_sensor_master (
		.refCLK(refCLK[3]),		// 1.05MHz
		.resetN(resetN),
		.enableN(enableN),
		.din(din),
		.dout(dout),
		.SCLK(SCLK),
		.SSN(SSN),
		.MISO(MISO),
		.MOSI(MOSI)
	);

	// Drive the reference clock to the ADC. Reference clock is 8.4 MHz source clock
	// divided down for the ADC To use
	always_ff @(posedge sysCLK) begin
		if (refCLK == TOPCOUNT+1)
			refCLK <= '0;
		else
			refCLK <= refCLK + 1;
	end

	// Logic tied to the 8.4 MHz clock domain
	always_ff @(posedge sysCLK) begin
		if (refCLK == TOPCOUNT)	begin				// Turn off enable after 13 cycles
			enableN <= 1;
			wr_loc <= wr_loc + 1;					// Increment write pointer after a transfer is over
		end
		else if (refCLK[15]) begin					// Sample at 128 samples per second
			enableN <= 0;
			wr_loc <= wr_loc;
		end
		else if (wr_loc == BUFSIZE) begin			// Reset buffer pointer when th buffer is full
			enableN <= 1;
			wr_loc <= '0;
		end
		else begin									// Else maintain state
			enableN <= 1;
			wr_loc <= wr_loc;
		end
	end

	// Data ready logic
	always_comb begin
		if (IO_READ_ACK) begin						// If the cpu acknowledged the signal
			IO_READ_RDY = 0;						// Reset data ready signal to 0 for next 
		end
		else if (wr_loc == BUFSIZE-1) begin			// Else if the buffer is full
			IO_READ_RDY = 1;						// Signal to the cpu that data is ready to be read
		end
		else begin
			IO_READ_RDY = IO_READ_RDY;				// Else maintain the state
		end
	end

	// Fill buffer with output data
	always_comb begin
		if (!enableN && (refCLK == TOPCOUNT)) begin
			buffer[wr_loc] = doutLE[7:0];			// Truncate from 10-bits down to 8-bits
		end
	end

	// Output the data to the processor
	always_comb begin
		if (IO_READ_ACK) begin
			IO_HEARTBEAT = {buffer[0], buffer[1], buffer[2], buffer[3]};
		end
	end

endmodule: heartbeat