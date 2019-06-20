/*	ECE-540 Winter 2019
	
	AHB-Lite Peripheral Module for Communicating with ESP8266

	The file implements the AHB-Lite Peripheral for the application program
	to write data to the interface that sends data to the ESP8266.
	
	By: Alex Olson, Andrew Capatina, Ryan Bentz, and Ryan Bornhorst
*/


`include "mfp_ahb_const.vh"

module mfp_ahb_spi(
	input 			HCLK,
	input 			HRESETn,
	input			HWRITE,
	input  [1:0]	HTRANS,
	input  [3:0] 	HADDR,
	input  [31:0]	HWDATA,
	input 			HSEL,
	output [31:0]	HRDATA,

	output			SCLK,     // output clock
	output          IO_SPI
);

logic HSEL_d;
logic HWRITE_d;
logic HTRANS_d;

logic [3:0]		HADDR_d;
logic [15:0]	data_in;
logic [31:0]    data_out;

logic wr_en, start, stop;


// Instantiation of the module that handles the 2-wire interface that 
// transmits data to the ESP8266
spi_master spi_master(    
    .data_out(IO_SPI),
    .sclk(SCLK),
    .stop(stop),
    .clk(SLOWCLOCK),
    .reset_n(HRESETn),
    .start(start),
    .data_in(data_in)
);

// Delay the signals for the bus write
always_ff @(posedge HCLK) begin
	HADDR_d 	<= HADDR;
	HWRITE_d 	<= HWRITE;
	HSEL_d		<= HSEL;
	HTRANS_d	<= HTRANS;
end

// Handle the Write Enable
assign wr_en = (HTRANS_d != `HTRANS_IDLE) & HSEL_d & HWRITE_d;


// Register for the application program to write data to
always_ff @(posedge HCLK or negedge HRESETn) begin
	if(!HRESETn)
		data_out <= 0;
	else if(wr_en) begin
	    start   <= 1'b1;
		data_in <= HWDATA[15:0];
    end else if(stop) 
        start   <= 0;
	else
	    data_out <= data_out;
end

endmodule

