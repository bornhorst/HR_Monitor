// SPI Testbench

module spi_test ();

logic refclk, resetN, start;
logic miso, mosi, sclk;
logic [15:0] din;

spi_master spi (	.clk(refclk), .reset_n(resetN),
					.start(start), .data_in(din),
					.MOSI(mosi), .SCLK(sclk));
	
	initial begin
		refclk = 1'b0;
		resetN = 1'b0;		// put in reset mode
		start = 1'b0;   	// ready to enable
		#3;
		resetN = 1'b1;
		#3;
		
		// toggle start signal
		din = 8'h0404;
		start = 1'b1;
		#2;
		start = 1'b0;
		// wait for transfer to complete
		#40;
		
		// new data and toggle start signal
		din = 8'h00FF;
		start = 1'b1;
        #2;
        start = 1'b0;
        // wait for transfer to complete
        #40;
                
        // new data and toggle start signal
        din = 8'hAA55;
        start = 1'b1;
        #2;
        start = 1'b0;
        // wait for transfer to complete
        #40;
        

                
	end
	
	
	
	always #1 refclk = ~refclk;

endmodule

