/* 	spi_if.sv  -  SPI Protocol Interface
*
*	------------------------------
*	Author: Alex Olson
*	Date:	March 2019
*	Class:	ECE 540 - SoC Design
*	------------------------------

*	Description:
*		This file contains SPI protocol transfer interfacing algoritms.
*		The transfer length is parameterized and may be set to any length.
*		The protocol is from the standpoint of the SPI bus master.
*/

interface spi_if
#(
	parameter WORD = 8							// Default to standard 8-bit transfers
)
(
	// System signals
	input  logic refCLK,						// Input reference clock
	input  logic resetN,						// Global Asynchronous Reset (active-low)
	input  logic enableN,						// Enable the spi signal (active-low)
	input  logic [WORD-1:0] din,				// Input data: master into slave (MSB first)
	output logic [WORD-1:0] dout,				// Output data: slave into master (MSB first)

	// SPI signals (master)
	input  logic MISO,							// Master In Slave Out
	output logic MOSI,							// Master Out Slave In
	output logic SCLK,							// SPI clock
	output logic SSN							// SPI chip select (active-low)
);
	
	// State Machine logic
	typedef enum logic {WAIT, DATA} state_t;	// SPI is either active or non-active
	state_t state, nextState=WAIT;				// Initialize nextState to start in WAIT

	logic output_en_N = 1;						// SPI output enable (active-low)
	logic [$clog2(WORD)-1:0] count = WORD-1;	// Start counter at MSB of transfer word
	assign SCLK = output_en_N ? 0 : refCLK;		// Link SPI clock with enable signal
	assign SSN  = output_en_N;					// Link SPI enable with system triggered enable

	// State transition
	always_ff @(posedge refCLK or negedge resetN) begin
		if (!resetN) begin
			state <= WAIT;
		end
		else begin
			state <= nextState;
		end
	end

	// Bit position tracker for word being transfered MSB first
	always_ff @(posedge refCLK) begin
		if (state == WAIT) begin
			count <= WORD-1;
			output_en_N <= 1;
		end
		else begin
			count <= count - 1;
			output_en_N <= 0;
		end
	end

	// Data transfer logic
	always_comb begin
		unique case (state)
			WAIT: begin
				  dout      = 'x;
				  MOSI      = 'z;
				  nextState = enableN ? WAIT : DATA;
		    end
			DATA: begin
			      dout[count] = MISO;
				  MOSI        = din[count];
				  nextState   = count ? DATA : WAIT;
		    end
		endcase
	end

endinterface