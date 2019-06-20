/*	ECE-540 Winter 2019
	
	SPI Master file for ESP8266 Connection

	This file contains the state machine that drives the CLK and DATA lines 
	connected to the ESP8266 to	transmit data one bit at a time.
	
	By: Alex Olson, Andrew Capatina, Ryan Bentz, and Ryan Bornhorst
*/

module spi_master #(parameter DATA_WIDTH = 16)(
	output logic				data_out,
	output logic				sclk,
	output                      stop,
	input 						clk,
	input						reset_n,
	input						start,
	input  [DATA_WIDTH-1:0]		data_in
);

// states for sending out serial data
typedef enum logic[1:0] {IDLE, START, STOP} spi_state;

integer i;

// hold onto new data
logic [DATA_WIDTH-1:0] data_in_d;

// state/ next state
spi_state state, n_state;

// grab the data as it comes in
assign data_in_d = data_in;

// stop sending data when last bit is reached
assign stop = (i == 15) ? 1'b1:1'b0;

// send out a clock signal while sending out data
assign sclk = (state == START) ? clk:1'b0;

// state transition on clock edge
always_ff @(posedge clk or negedge reset_n) begin
	if(!reset_n)
        state <= IDLE;
    else
        state <= n_state;
end

// state transition logic
always_comb begin
    case(state)
        IDLE: if(start) n_state = START;
        START: if(stop) n_state = STOP; else n_state = START;
        STOP: n_state = IDLE;
        default: n_state = IDLE;
    endcase
end

// send data out on clock edge while in START state
always_ff @(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
            i           <= 0;
            data_out    <= 0;
    end else if(state == START) begin
        for(i = 0; i < DATA_WIDTH; i = i + 1) begin
            data_out <= data_in_d[i];
        end
    end else begin
            i           <= 0;
            data_out    <= 0;
    end
end

endmodule
