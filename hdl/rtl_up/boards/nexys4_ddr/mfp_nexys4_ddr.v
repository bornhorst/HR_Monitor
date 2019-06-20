// mfp_nexys4_ddr.v
// January 1, 2017
//
// Instantiate the mipsfpga system and rename signals to
// match the GPIO, LEDs and switches on Digilent's (Xilinx)
// Nexys4 DDR board

// Outputs:
// 16 LEDs (IO_LED) 
// Inputs:
// 16 Slide switches (IO_Switch),
// 5 Pushbuttons (IO_PB): {BTNU, BTND, BTNL, BTNC, BTNR}
//

`include "mfp_ahb_const.vh"

module mfp_nexys4_ddr( 
                        input                   CLK100MHZ,
                        input                   CPU_RESETN,
                        // push buttons
                        input                   BTNU, BTND, BTNL, BTNC, BTNR, 
                        input  [`MFP_N_SW-1 :0] SW,
                        output [`MFP_N_LED-1:0] LED,
                        inout  [ 8          :1] JA, JB,
                        inout  [4:1]            JC, JD,
                        input                   UART_TXD_IN,
                        
                        // 7 segment display
                        output [7 : 0]          AN,
                        output                  CA,CB,CC,CD,CE,CF,CG,DP
);
    // Press btnCpuReset to reset the processor. 
        
    wire clk_out_50MHz, clk_out_8pt4MHz; 
    wire tck_in, tck;
    wire [7:0] IO_7SEGEN_N;
    wire [7:0] IO_7SEG_N;
    wire [31:0] IO_HEARTBEAT;   
    wire SCLK, IO_SPI;
  
    clk_wiz_0 clk_wiz_0(.clk_in1(CLK100MHZ), .clk_out1(clk_out_50MHz), .clk_out2(clk_out_8MHz));

    IBUF IBUF1(.O(tck_in),.I(JB[4]));
    BUFG BUFG1(.O(tck), .I(tck_in));
    
    // map the peripheral signals to the ports/pins on the Nexys4
    assign AN = IO_7SEGEN_N;
    assign {DP,CA,CB,CC,CD,CE,CF,CG} = IO_7SEG_N;
    
    reg count = 0;
    
    always @ (posedge clk_out_8MHz) begin
        count = ~count;
    end
    

    assign JC[1] = count;
    assign JC[2] = count;
    assign JC[3] = count;
    assign JC[4] = count;
   
    assign JD[1] = count;
    assign JD[2] = count;
    assign JD[3] = count;
    assign JD[4] = count;

       
    // debounce the button and switch inputs
    wire [`MFP_N_SW-1 : 0] SW_DB;
    wire CPU_RESETN_DB;
    wire BTNU_DB, BTND_DB, BTNL_DB, BTNC_DB, BTNR_DB;
    
    debounce debouncer
    (
        .clk		( clk_out_50MHz ),
        .pbtn_in	( {BTNU, BTND, BTNL, BTNC, BTNR, CPU_RESETN} ),
        .switch_in	( SW ),
        .pbtn_db	( {BTNU_DB, BTND_DB, BTNL_DB, BTNC_DB, BTNR_DB, CPU_RESETN_DB} ),
        .swtch_db	( SW_DB )
    );

    mfp_sys mfp_sys
    (
        .SI_Reset_N(CPU_RESETN_DB),
        .SI_ClkIn(clk_out_50MHz),
        .HADDR(),
        .HRDATA(),
        .HWDATA(),
        .HWRITE(),
		.HSIZE(),
        .EJ_TRST_N_probe(JB[7]),
        .EJ_TDI(JB[2]),
        .EJ_TDO(JB[3]),
        .EJ_TMS(JB[1]),
        .EJ_TCK(tck),
        .SI_ColdReset_N(JB[8]),
        .EJ_DINT(1'b0),
        .IO_Switch(SW_DB),
        .IO_PB({BTNU_DB, BTND_DB, BTNL_DB, BTNC_DB, BTNR_DB}),
        .IO_LED(LED),
        .UART_RX(UART_TXD_IN),
        .IO_7SEGEN_N(IO_7SEGEN_N),
        .IO_7SEG_N(IO_7SEG_N),
        .IO_HEARTBEAT(IO_HEARTBEAT),
        .IO_READ_ACK(IO_READ_ACK),
        .IO_READ_RDY(IO_READ_RDY),
        .SLOWCLOCK(clk_out_8MHz),
        .SCLK(JC[1]),
        .IO_SPI(JC[2])
    );

    heartbeat heartbeat
    (
        .ahbCLK(clk_out_50MHz),
        .sysCLK(clk_out_8pt4MHz),
        .resetN(CPU_RESETN_DB),
        .IO_JA (JA[4:1]),
        .IO_READ_ACK(IO_READ_ACK),
        .IO_READ_RDY(IO_READ_RDY),
        .IO_HEARTBEAT(IO_HEARTBEAT)
    );

endmodule