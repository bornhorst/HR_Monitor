// mfp_ahb.v
// 
// January 1, 2017
//
// AHB-lite bus module with 3 slaves: boot RAM, program RAM, and
// GPIO (memory-mapped I/O: switches and LEDs from the FPGA board).
// The module includes an address decoder and multiplexer (for 
// selecting which slave module produces HRDATA).

`include "mfp_ahb_const.vh"


module mfp_ahb
(
    input                       HCLK,
    input                       HRESETn,
    input      [ 31         :0] HADDR,
    input      [  2         :0] HBURST,
    input                       HMASTLOCK,
    input      [  3         :0] HPROT,
    input      [  2         :0] HSIZE,
    input      [  1         :0] HTRANS,
    input      [ 31         :0] HWDATA,
    input                       HWRITE,
    output     [ 31         :0] HRDATA,
    output                      HREADY,
    output                      HRESP,
    input                       SI_Endian,

// memory-mapped I/O
    input      [`MFP_N_SW-1 :0] IO_Switch,
    input      [`MFP_N_PB-1 :0] IO_PB,
    output     [`MFP_N_LED-1:0] IO_LED,
    output     [7 : 0]			IO_7SEGEN_N,
    output     [7 : 0]          IO_7SEG_N,
	
	// Heartbeat Peripheral
    input      [31: 0]          IO_HEARTBEAT,
	input 			   			IO_READ_RDY,
    output 		       			IO_READ_ACK,
	
	// ESP8266 Signals
	output          			SCLK,     // output clock
    output                      IO_SPI,
	
	// Timer Signals
    output                      cpu_cnt_reset,
    input      [31:0]           time_is_up
);


  wire [31:0] HRDATA6, HRDATA5, HRDATA4, HRDATA3, HRDATA2, HRDATA1, HRDATA0;
  wire [ 6:0] HSEL;
  reg  [ 6:0] HSEL_d;

  assign HREADY = 1;
  assign HRESP = 0;
	
  // Delay select signal to align for reading data
  always @(posedge HCLK)
    HSEL_d <= HSEL;

  // Module 0 - boot ram
  mfp_ahb_b_ram mfp_ahb_b_ram(HCLK, HRESETn, HADDR, HBURST, HMASTLOCK, HPROT, HSIZE,
                              HTRANS, HWDATA, HWRITE, HRDATA0, HSEL[0]);
  // Module 1 - program ram
  mfp_ahb_p_ram mfp_ahb_p_ram(HCLK, HRESETn, HADDR, HBURST, HMASTLOCK, HPROT, HSIZE,
                              HTRANS, HWDATA, HWRITE, HRDATA1, HSEL[1]);
  // Module 2 - GPIO
  mfp_ahb_gpio mfp_ahb_gpio(HCLK, HRESETn, HADDR[5:2], HTRANS, HWDATA, HWRITE, HSEL[2], 
                            HRDATA2, IO_Switch, IO_PB, IO_LED);
  
  // Module 3 - 7 Segment Display Controller
  sevenseg sevenseg(.HCLK(HCLK), .HRESETn(HRESETn), .IO_7SEG_N(IO_7SEG_N), .IO_7SEGEN_N(IO_7SEGEN_N),
                    .HADDR(HADDR[3:0]), .HTRANS(HTRANS), .HWDATA(HWDATA), .HWRITE(HWRITE),
                    .HSEL(HSEL[3]), .HRDATA(HRDATA3));

  // Module 4 - Heartbeat Collector Interface
  heartbeat_peripheral heartbeat_peripheral(.HCLK(HCLK), .HRESETn(HRESETn), .HSEL(HSEL[4]), .HTRANS(HTRANS), 
                                            .HADDR(HADDR[3:0]), .HRDATA(HRDATA4), 
                                            .IO_HEARTBEAT(IO_HEARTBEAT));
                                            
  // Module 5 - Timer Counter                        
  mfp_ahb_counter counter(.HCLK(HCLK), .HRESETn(HRESETn), .HSEL(HSEL[5]), .HTRANS(HTRANS), .HADDR(HADDR[3:0]), 
                          .HWDATA(HWDATA), .time_is_up(time_is_up), .cpu_cnt_reset(cpu_cnt_reset), .HRDATA(HRDATA5));

  // Module 6 - SPI -> nodeMCU Interface
  mfp_ahb_spi mfp_ahb_spi(.HCLK(HCLK), .HRESETn(HRESETn), .HSEL(HSEL[6]), .HTRANS(HTRANS), .HWRITE(HWRITE), 
                          .HADDR(HADDR[3:0]), .HRDATA(HRDATA6), .HWDATA(HWDATA), .SCLK(SCLK), .IO_SPI(IO_SPI));


  ahb_decoder ahb_decoder(HADDR, HSEL);
  ahb_mux ahb_mux(HCLK, HSEL_d, HRDATA6, HRDATA5, HRDATA4, HRDATA3, HRDATA2, HRDATA1, HRDATA0, HRDATA);

endmodule


module ahb_decoder
(
    input  [31:0] HADDR,
    output [ 6:0] HSEL
);

  // Decode based on most significant bits of the address
  assign HSEL[0] = (HADDR[28:20] == `H_RAM_RESET_ADDR_Match); // 128 KB RAM  at 0xbfc00000 (physical: 0x1fc00000)
  assign HSEL[1] = (HADDR[28]    == `H_RAM_ADDR_Match);       // 256 KB RAM at 0x80000000 (physical: 0x00000000)
  assign HSEL[2] = (HADDR[28:20] == `H_LED_ADDR_Match);       // GPIO at 0xbf800000 (physical: 0x1f800000)
  assign HSEL[3] = (HADDR[28:20] == `H_SEVENSEG_ADDR_Match);  // SEVEN-SEGMENT DISPLAY at 0x1F70_0000
  assign HSEL[4] = (HADDR[28:20] == `H_HEARTBEAT_ADDR_Match); // Heartbeats at 0xbf900000 (physical:0x1f900000)
  assign HSEL[5] = (HADDR[28:20] == `H_TIMER_COUNT_ADDR_Match); // Timer at 0xbfa00000 (physical: 0x1fa00000)
  assign HSEL[6] = (HADDR[28:20] == `H_SPI_MASTER_ADDR_Match);
endmodule


module ahb_mux
(
    input             HCLK,
    input      [ 6:0] HSEL_d,
    input      [31:0] HRDATA6, HRDATA5, HRDATA4, HRDATA3, HRDATA2, HRDATA1, HRDATA0,
    output reg [31:0] HRDATA
);

    always @(*)
      casez (HSEL_d)
        7'b??????1:    HRDATA = HRDATA0;
        7'b?????10:    HRDATA = HRDATA1;
        7'b????100:    HRDATA = HRDATA2;
        7'b???1000:    HRDATA = HRDATA3;
        7'b??10000:    HRDATA = HRDATA4;
        7'b?100000:    HRDATA = HRDATA5;
        7'b1000000:    HRDATA = HRDATA6;
        
        default:     HRDATA = HRDATA1;
      endcase
endmodule