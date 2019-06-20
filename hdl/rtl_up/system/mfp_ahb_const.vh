// 
// mfp_ahb_const.vh
//
// Verilog include file with AHB definitions
// 

//---------------------------------------------------
// Physical bit-width of memory-mapped I/O interfaces
//---------------------------------------------------
`define MFP_N_LED             16
`define MFP_N_SW              16
`define MFP_N_PB              5

//---------------------------------------------------
// Memory-mapped I/O addresses
//---------------------------------------------------
`define H_SEVENSEG_ADDR_Match   (9'h1f7)
`define H_SSEG_DIGEN            (32'h1f700000)
`define H_SSEGLO_DATA			(32'h1f700004)
`define H_SSEGHI_DATA			(32'h1f700008)
`define H_SSEG_DPEN             (32'h1f70000C)

`define H_LED_ADDR_Match		(9'h1f8)
`define H_LED_ADDR    			(32'h1f800000)
`define H_SW_ADDR   			(32'h1f800004)
`define H_PB_ADDR   			(32'h1f800008)

`define H_HEARTBEAT_ADDR_Match	(9'h1f9)
`define H_HEARTBEAT_READ 		(32'h1f900000)
`define H_HEARTBEAT_RDY			(32'h1f900004)
`define H_HEARTBEAT_ACK			(32'h1f900008)

`define H_SPI_MASTER_ADDR_Match (9'h1fa)

`define H_LED_IONUM   			(4'h0)
`define H_SW_IONUM  			(4'h1)
`define H_PB_IONUM  			(4'h2)
`define H_HEARTBEAT_IONUM		(4'd3)
`define H_SSEGLO_IONUM			(4'd6)
`define H_SSEGHI_IONUM			(4'd7)

//---------------------------------------------------
// RAM addresses
//---------------------------------------------------
`define H_RAM_RESET_ADDR 		(32'h1fc?????)
`define H_RAM_ADDR	 		    (32'h0???????)
`define H_RAM_RESET_ADDR_WIDTH  (8) 
`define H_RAM_ADDR_WIDTH		(16) 
`define H_RAM_RESET_ADDR_Match  (9'h1fc)
`define H_RAM_ADDR_Match 		(1'b0)

//---------------------------------------------------
// AHB-Lite values used by MIPSfpga core
//---------------------------------------------------

`define HTRANS_IDLE    2'b00
`define HTRANS_NONSEQ  2'b10
`define HTRANS_SEQ     2'b11

`define HBURST_SINGLE  3'b000
`define HBURST_WRAP4   3'b010

`define HSIZE_1        3'b000
`define HSIZE_2        3'b001
`define HSIZE_4        3'b010
