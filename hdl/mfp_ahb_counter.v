//////////////////////////////////////////////////////////////////////////////////
// 
//   Authors: 	  Andrew Capatina
//   Class:       ECE 540
//   Date:        Winter 2019
//   Assignment:  Final Project\
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//		Module for receiving and sending data from processor.
// 
//////////////////////////////////////////////////////////////////////////////////

`include "mfp_ahb_const.vh"

module mfp_ahb_counter(
    input               HCLK,
    input               HRESETn,
    input               HSEL,
    input         [1:0] HTRANS,
    input         [3:0] HADDR,
    input         [31:0]HWDATA,
    input         [31:0]time_is_up,
    output reg          cpu_cnt_reset,
    output reg   [31:0] HRDATA      
    );
    
    reg [3:0] HADDR_d;
    reg       HWRITE_d;
    reg       HSEL_d;
    reg [1:0] HTRANS_d;
    wire      we;
    
    always@(posedge HCLK)	
    begin
        HADDR_d <= HADDR;
        HTRANS_d <= HTRANS;
        HSEL_d <= HSEL;
    end
    
	// Set write enable.
    assign we = (HTRANS_d != `HTRANS_IDLE) & HSEL_d;
    
    always@(posedge HCLK or negedge HRESETn)
    if(~HRESETn)
    begin
        HRDATA <= 32'h00000000;	// Reset data.
        cpu_cnt_reset <= 0;
    end
    else if(we)
        case(HADDR_d)
            `H_CNT_TIME_RDY_IONUM: cpu_cnt_reset <= HWDATA[0]; 	// Set acknowledge signal for timer overflow.           
            `H_CNT_TIME_ACK_IONUM: HRDATA <= time_is_up;		// Send value for 6 second timer elapsing.
            default:               ;
        endcase
        
endmodule
