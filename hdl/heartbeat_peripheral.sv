/* 	heartbeat_peripheral.sv  -  Heartbeat AHB Interface
*
*	------------------------------
*	Author: Alex Olson
*	Date:	March 2019
*	Class:	ECE 540 - SoC Design
*	------------------------------

*	Description:
*		This file contains AHB protocol facing logic for the heartbeat module.
*       When the proper signals are applied to the inputs, the module either reads
*       or writes data from the heartbeat module onto the AHB.
*/

`include "mfp_ahb_const.vh"

module heartbeat_peripheral
(
	input  logic		HCLK, HRESETn, HSEL, HWRITE,
	input  logic [ 1:0] HTRANS, 
    input  logic [ 3:0] HADDR,
    input  logic [31:0] HWDATA, IO_HEARTBEAT,
    input  logic        IO_READ_RDY,
    output logic [31:0] HRDATA,
    output logic		IO_READ_ACK
);

	// Heartbeat module I/O decoded address selection bits
	enum logic [3:0] {HEARTBEAT=0, READRDY=4, READACK=8} HeartIO;

	logic 	wr_en;	// Write enable

	// Delay signals to align with the data write address
	logic  [3:0]    HADDR_d;
	logic           HWRITE_d;
	logic           HSEL_d;
	logic  [1:0]    HTRANS_d;
	logic [31:0]	IO_HEARTBEAT_d;
	logic			IO_READ_RDY_d;

	// Delay HADDR, HWRITE, HSEL, HTRANS, and Heartbeat IO to align with HWDATA for writing
	always_ff @(posedge HCLK) begin
		HADDR_d  		<= HADDR;
		HWRITE_d 		<= HWRITE;
		HSEL_d   		<= HSEL;
		HTRANS_d 		<= HTRANS;
		IO_HEARTBEAT_d  <= IO_HEARTBEAT;
		IO_READ_RDY_d   <= IO_READ_RDY;
	end

	// Determine if the write enable for the controller
	assign wr_en = (HTRANS_d != `HTRANS_IDLE) & HSEL_d & HWRITE_d;

	// HWDATA (bus write -- write control data to the bus for the heartbeat module to read)
	always_ff @(posedge HCLK or negedge HRESETn) begin
		
		// Global Asynchronous Reset
		if (~HRESETn) begin
			IO_READ_ACK <= '0;
		end

		// Data transfer
		else if (wr_en) begin 
			unique case (HADDR_d)
				HEARTBEAT: ;
				READRDY:   ;
				READACK:   IO_READ_ACK <= HWDATA[0];
			endcase
		end
		
		// Maintain state if not enabled
		else begin
			IO_READ_ACK <= IO_READ_ACK;
		end
	end

	// HRDATA (bus read -- write to the bus for the application processor to read)
	always_ff @(posedge HCLK or negedge HRESETn) begin
		
		// Global Asynchronous Reset
		if (~HRESETn) begin
			HRDATA <= '0;
		end

		// Data transfer
		else if (HSEL) begin 
			unique case (HADDR)
				HEARTBEAT: HRDATA <= IO_HEARTBEAT;
				READRDY:   HRDATA <= {31'b0, IO_READ_RDY};
				READACK:   ;
			endcase
		end
		
		// Maintain state if not enabled
		else begin
			HRDATA <= HRDATA;
		end
	end

endmodule: heartbeat_peripheral