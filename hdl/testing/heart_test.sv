module heart_test();

logic        	ahbCLK;				// Clock for interfacing buffer with AHB
logic			sysCLK;				// System input clock (8.4 MHz in this example)
logic			resetN;				// Global Asynchronous Reset
logic 			IO_READ_ACK;		// Signal that the buffer was read
wire [ 4:1]	IO_JA;					// SPI data
logic 			IO_READ_RDY;		// Buffer is ready after collecting a parameterized read size
logic [31:0] 	IO_HEARTBEAT;		// Heartbeat data

logic		    HCLK, HRESETn, HSEL, HWRITE;
logic [ 1:0]    HTRANS;
logic [ 3:0]    HADDR;
logic [31:0]    HWDATA;
logic [31:0]    HRDATA;




heartbeat hb (	.ahbCLK(ahbCLK),
				.sysCLK(sysCLK),
				.resetN(resetN),
				.IO_READ_RDY(IO_READ_RDY),
				.IO_READ_ACK(IO_READ_ACK),
				.IO_JA(IO_JA));

heartbeat_peripheral hbp (  .HCLK(HCLK),
                            .HRESETn(HRESETn),
                            .HSEL(HSEL),
                            .HWRITE(HWRITE),
                            .HTRANS(HTRANS),
                            .HADDR(HADDR),
                            .HWDATA(HWDATA),
                            .IO_HEARTBEAT(IO_HEARTBEAT),
                            .IO_READ_RDY(IO_READ_RDY),
                            .HRDATA(HRDATA),
                            .IO_READ_ACK(IO_READ_ACK)
);



	initial begin
		// init signals
		ahbCLK = '0;
		sysCLK = '0;
		resetN = '0;
		#4;
		// let go of reset
		resetN = '1;
		
		
		$stop();
	end
	
	assign HCLK = ahbCLK;

	always #1 ahbCLK = ~ahbCLK;
	always #8 sysCLK = ~sysCLK;
endmodule