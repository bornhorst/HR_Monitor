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
//      Module used for incrementing a counter. Processor receives and sends information
//  to this module.
// 
//////////////////////////////////////////////////////////////////////////////////

module timer_count(
      input                    clk,
      input                    resetn,
      input                    cpu_is_ready,
      output reg        [31:0] time_is_up
      );
      
      reg[31:0] count;
      
initial 
begin
    time_is_up  = 0;    // Flag for indicating time has reached threshold.
    count       = 0;
end

always@(posedge clk or negedge resetn)
begin
    if(~resetn) // Reset variables on reset.
    begin
        count       <= 0;
        time_is_up  <= 8'h00000000;
    end
    
    else if(cpu_is_ready == 1)  // Processor requests reset on timer.
    begin 
        count        <= 0;
        time_is_up   <= 8'h00000000;
    end
    // Check if counter is above 6 seconds. 
    else if(count >= 300000000) 
    begin
        time_is_up <= 8'h00000001;  // Data for processor.    
    end
    else
    begin
        count <= count + 1;     // Increment counter.
        time_is_up <= 8'h00000000;  // Time isn't up yet.
    end
end
endmodule