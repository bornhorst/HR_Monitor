/*
 *	Seven segment array driver
 *
 *	Authors: 	Ryan Bentz, Alex Olson
 *	Class:		ECE 540
 *	Date:		Winter 2019
 *	Assignment:	Project 1\
 *
 *	This module uses data from the processor (HADDR, HWDATA) to control the seven segment LED array
 * 	on the Nexys A7 devolopment board (IO_7SEGEN_N and IO_7SEG_N).
 */

`include "mfp_ahb_const.vh"


// Seven segment decoder module
module sevenseg
(
    input logic 		HCLK,			// Bus clock
    input logic 		HRESETn,		// Active low registers
    input logic [3:0]	HADDR,			// Bus address
    input logic [1:0]	HTRANS,			// Transfer type (unused)
    input logic [31:0]	HWDATA,			// Bus data lines
    input logic 		HWRITE,			// Bus write signal (unused)
    input logic			HSEL,			// Chip select line
    output logic [31:0]	HRDATA,			// Bus read (unused)
	
	output logic [7:0]	IO_7SEG_N,		// the specific LEDs of an individual segment to turn on
	output logic [7:0]	IO_7SEGEN_N		// the specific 7-segment display to access
);
    
    // delay signals to align with the data write address
    logic  [3:0]    HADDR_d;
    logic           HWRITE_d;
    logic           HSEL_d;
    logic  [1:0]    HTRANS_d;
    
	// write enable
    logic           we;            
    
	// Peripheral registers to store the memory mapped data
    logic [7:0]     seg_enable;     // Segment enable pins (IO_7SEGEN_N)
    logic [31:0]    dig_low;        // digit led pins for lower 4 segments
    logic [31:0]    dig_high;       // digit led pins for upper 4 segments
    logic [7:0]     dp_enable;      // decimal point enable pins
    
    // delay HADDR, HWRITE, HSEL, and HTRANS to align with HWDATA for writing
    always @ (posedge HCLK) begin
		HADDR_d  <= HADDR;
		HWRITE_d <= HWRITE;
		HSEL_d   <= HSEL;
		HTRANS_d <= HTRANS;
    end
     
    // determine the write enable for the controller
    assign we = (HTRANS_d != `HTRANS_IDLE) & HSEL_d;
   
    // registers store data on clock edge and latch data based on address
    always @ (posedge HCLK or negedge HRESETn) begin
        // Reset the displays to the 'off' state
		if (~HRESETn) begin
            seg_enable <= 8'b0;
            dig_low <= 32'b0;
            dig_high <= 32'b0;
            dp_enable <= 8'b0;
        end
		
		// Write data out to the displays
        else if (we) begin
            case (HADDR_d)
                4'b0000:    seg_enable <= HWDATA[7:0];
                4'b0100:    dig_low <= HWDATA;
                4'b1000:    dig_high <= HWDATA;
                4'b1100:    dp_enable <= HWDATA[7:0];
                default:    ;
            endcase
        end
		
		// Hold the data until the next clock cycle
        else begin
            seg_enable <= seg_enable;
            dig_low <= dig_low;
            dig_high <= dig_high;
            dp_enable <= dp_enable;
        end
    end
    
    // instantiate the seven segment timer that cycles through each multiplexed digit
    mfp_ahb_sevensegtimer mpf_ahb_sevensegtimer (
                .clk(HCLK),
                .resetn(HRESETn),
                .EN(seg_enable),
                .DIGITS({dig_low, dig_high}),
                .dp(dp_enable),
                .DISPENOUT(IO_7SEGEN_N),
                .DISPOUT(IO_7SEG_N));
                
                
endmodule

