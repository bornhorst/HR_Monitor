// AHB SPI Testbench

module ahb_spi_test ();

	logic [5:0] HSEL;
	logic HCLK;
	logic HRESETn;
	logic [31:0] HWDATA, HRDATA;
	logic [31:0] HADDR;
	logic [1:0] HTRANS;
	logic HWRITE;
	
	logic MISO, MOSI, SCLK, CS;
	
	
	ahb_decoder ahb_decoder(HADDR, HSEL);

	mfp_ahb_spi ahb_spi ( 	.HCLK(HCLK), .HRESETn(HRESETn), .HADDR(HADDR[3:0]), .HTRANS(HTRANS), .HWDATA(HWDATA), .HWRITE(HWRITE),
							.HSEL(HSEL), .HRDATA(HRDATA), .MISO(MISO), .MOSI(MOSI), .SCLK(SCLK), .CS(CS));

	
	initial begin
		// initial setup
		HCLK = '0;
		HADDR = '0;
		HWDATA = '0;
		HRDATA = '0;
		HWRITE = '0;
		HRESETn = '0;
		#3;
		
		// take out of reset
		HRESETn = 1'b1;
		#2;
		
		// Simulate a write to the bus to the SPI peripheral
		HADDR = 32'h1FA00000;
		#2; 
		HWDATA = 32'h000F;
	
	end
	
	
	
	
	always #1 HCLK = ~HCLK;

endmodule

