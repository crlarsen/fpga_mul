`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/14/2020 03:41:50 AM
// Design Name: 
// Module Name: fpga_mul
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Multiply 2 16-bit IEEE floating point numbers.
//              Inputs:
//              - btnC: Control whether the number displayed on
//                      the 7-segment display is the value set in
//                      the dip switches (button released) or the
//                      output of the 16-bit floating point unit
//                      (butten pressed & held).
//              - btnR: Reset the internal register to be zero.
//              - btnL: Latch the value displayed on the 7-segment
//                      display into the internal register.
//              - sw[15:0]: 'a' input value for 16-bit floating
//                      point multiply unit.
//              Outputs:
//              - 7-segment display: When btnC is pressed this
//                      is the output of the floating point
//                      multiply unit. When btnC is released this
//                      is the value set in DIP switches sw[15:0].
//              - led[15:0]: Contents of the internal register.
//                      The internal register is input value 'b' for
//                      the floating point multiply unit.
//              Internal State:
//              - 16-bit internal FP register: This is the 'b' value
//                      input to the floating point multiplication
//                      unit. This value can be updated by pressing
//                      btnL. When btnL is pressed the value
//                      shown on the 7-segment display is the value
//                      which gets latched into this register.
//                      Normally, the value shown on the 7-segment
//                      display comes from the DIP switch settings
//                      but when btnC is pressed & held the value
//                      shown on the 7-segment display and latched
//                      into this register (by pressing btnL) is the
//                      output of the floating point multiply unit.
//               Note: There is other internal state information but
//               it's not directly visible to the user. It's there
//               to improve the user experience in various ways
//               (debouncing buttons, generating a single pulse to
//               latch data, holding data so the user can compare
//               the values shown in the 7-segment display and the
//               LEDs, etc.).
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module debounce(clk, btnin, btnout);
  input clk, btnin;
  output btnout;
  
  reg [2:0] delay;
  
  initial
    begin
      delay = 3'b000;
    end
  
  always @(posedge clk)
    begin
      if (clk)
        begin
          delay = {btnin, delay[2:1]};
        end
    end
    
  assign btnout = &delay;
    
endmodule

module pulse(clk, btn, we);
  input clk, btn;
  output we;
  
  reg [2:0] delay;
  
  initial
    begin
      delay = 3'b000;
    end
  
  always @(posedge clk)
    begin
      if (clk)
        begin
          delay = {btn, delay[2], ~delay[1]};
        end
    end
    
  assign we = &delay;
    
endmodule

module register(clk, clr, we, d, q);
  parameter N = 8;
  input clk, clr, we;
  input [N-1:0] d;
  output [N-1:0] q;
  reg [N-1:0] q;
  
  always @(posedge clk or posedge clr)
    begin
      if (clr)
        q = {N{1'b0}};
      else if (clk)
        if (we)
          q = d;
    end
endmodule

module latch(clk, pass, d, q);
  parameter N = 8;
  input clk, pass;
  input [N-1:0] d;
  output [N-1:0] q;
  reg [N-1:0] q;
  
  always @(posedge clk)
    begin
      if (clk)
        if (pass)
          q = d;
    end
endmodule

module fpga_mul(clk, btnL, btnC, btnR, sw, led, seg, an, dp);
  parameter NEXP = 5;
  parameter NSIG = 10;
  input clk, btnL, btnC, btnR;
  input [NEXP+NSIG:0] sw;
  output [NEXP+NSIG:0] led;
  output [0:6] seg;
  output [3:0] an;
  output dp;
  
  wire [15:0] hexdigits;
  wire [15:0] b, bHold, p;
  `include "ieee-754-flags.v"
  wire [LAST_FLAG-1:0] flags;
  wire clr, we, pass, clk190;
  reg [30:0] counter;
  
  // Debounce btnC to generate "pass" signal
  debounce U0(clk190, btnC, pass);
  
  assign hexdigits = pass ? p : sw;
  
  // Generate 190 Hz clock signal
  always @(posedge clk)
    begin
      if (clk)
        counter = counter + 1;
    end
  assign clk190 = counter[18];
  
  // Debounce btnR to generate "clear" signal
  debounce U1(clk190, btnR, clr);
    
  // Generate a single clock pulse to latch data into register
  pulse U2(clk190, btnL, we);
    
  register #(16) U3(clk190, clr, we, hexdigits, b);

  // Don't allow data to pass from the internal register to the
  // multiply circuit while btnC is pressed. This maintains the
  // floating point product shown on the 7-segment display so
  // the user can verify that when latching th product into the
  // internal register that the latch happened successfully by
  // comparing the 7-segment display to the 16 LEDs.
  latch #(16) U4(clk190, ~pass, b, bHold);

  fp_mul #(5,10) U5(sw, bHold, p, flags);
  
  x7seg U6(hexdigits, clk, clr, seg, an);
  
  assign led = b;
  
  assign dp = ~0;
  
endmodule
