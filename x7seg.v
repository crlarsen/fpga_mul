`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/12/2020 11:44:23 AM
// Design Name: 
// Module Name: prob4_8_2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// Add 3 to any digit which is 5 or greater
// Utility module needed by bin2dec
module add3(a, s);
    input [3:0] a;
    output [3:0] s;
    reg [3:0] s;

    always @(a)
        case (a)
            4'h0: s = 4'h0;
            4'h1: s = 4'h1;
            4'h2: s = 4'h2;
            4'h3: s = 4'h3;
            4'h4: s = 4'h4;
            4'h5: s = 4'h8;
            4'h6: s = 4'h9;
            4'h7: s = 4'hA;
            4'h8: s = 4'hB;
            4'h9: s = 4'hC;
            default: s = 4'bxxxx;
        endcase
endmodule

// Convert 14-bit binary number into four decimal digits
// for display on the 7-segment LEDs.
module bin2dec(b, segdig);
    input [13:0] b;
    output [15:0] segdig;
    wire [3:0] s[0:25];

    add3({1'b0, b[13:11]}, s[0]); // shift 3

    add3({s[0][2:0], b[10]}, s[1]); // shift 1; 4 so far

    add3({s[1][2:0], b[9]}, s[2]); // shift 1; 5 so far

    add3({1'b0, s[0][3], s[1][3], s[2][3]}, s[3]); // shift 1; 6 so far
        add3({s[2][2:0], b[8]}, s[4]);

    add3({s[3][2:0], s[4][3]}, s[5]); // shift 1; 7 so far
        add3({s[4][2:0], b[7]}, s[6]);

    add3({s[5][2:0], s[6][3]}, s[7]); // shift 1; 8 so far
        add3({s[6][2:0], b[6]}, s[8]);

    add3({1'b0, s[3][3], s[5][3], s[7][3]}, s[9]); // shift 1; 9 so far
        add3({s[7][2:0], s[8][3]}, s[10]);
            add3({s[8][2:0], b[5]}, s[11]);

    add3({s[9][2:0], s[10][3]}, s[12]); // shift 1; 10 so far
        add3({s[10][2:0], s[11][3]}, s[13]);
            add3({s[11][2:0], b[4]}, s[14]);

    add3({s[12][2:0], s[13][3]}, s[15]); // shift 1; 11 so far
        add3({s[13][2:0], s[14][3]}, s[16]);
            add3({s[14][2:0], b[3]}, s[17]);

    add3({1'b0, s[9][3], s[12][3], s[15][3]}, s[18]); // shift 1; 12 so far
        add3({s[15][2:0], s[16][3]}, s[19]);
            add3({s[16][2:0], s[17][3]}, s[20]);
                add3({s[17][2:0], b[2]}, s[21]);

    add3({s[18][2:0], s[19][3]}, s[22]); // shift 1; 13 so far
        add3({s[19][2:0], s[20][3]}, s[23]);
            add3({s[20][2:0], s[21][3]}, s[24]);
                add3({s[21][2:0], b[1]}, s[25]);

    assign segdig = {s[22][2:0], s[23], s[24], s[25], b[0]}; // shift; 14 total
endmodule

// Select the digit currently being displayed
module mux44(sw, s, hexdig);
    input [15:0] sw;
    input [1:0] s;
    output [3:0] hexdig;
    reg [3:0] hexdig;

    always @(*)
        case (s)
            2'b00: hexdig = sw[3:0];
            2'b01: hexdig = sw[7:4];
            2'b10: hexdig = sw[11:8];
            default: hexdig = sw[15:12];
        endcase
endmodule

// Extra logic to disable zero leading digits.
module ancode(s, aen, an);
    input [1:0] s;
    input [3:0] aen;
    output [3:0] an;
    reg [3:0] an;

    always @(*)
        begin
            an = 4'b1111;
            if (aen[s] == 1'b1)
                an[s] = 1'b0;
        end
endmodule

// Counter to control strobing the four digits on the
// 7-segment LEDs
module ctr2bit(clk, clr, s);
    input clk;
    input clr;
    output [1:0] s;

    reg [20:0] clkdiv;

    // At the slower refresh rate I can see flicker
    assign s = clkdiv[19:18];

    always @(posedge clk or posedge clr)
        begin
            if (clr == 1'b1)
                clkdiv = 0;
            else if (clk == 1'b1)
                clkdiv = clkdiv + 1;
        end
endmodule

// Display up to 4 hexadecimal digits on the 4 7-segment LEDs
// Disable leading zeroes
module x7seg(x, clk, clr, g_to_a, an);
    input [15:0] x;
    input clk;
    input clr;
    output [6:0] g_to_a;
    output [3:0] an;

    wire [1:0] s;
    wire [3:0] digit;
    wire [3:0] aen;

    // Enable all digits.
    assign aen = 4'b1111;

    mux44 U0(x, s, digit);

    ancode U1(s, aen, an);

    ctr2bit U2(clk, clr, s);

    hex2_7seg U3(digit, g_to_a);

endmodule

// Display up to 4 hexadecimal digits on the 4 7-segment LEDs
// Disable leading zeroes
module x7segb(x, clk, clr, g_to_a, an);
    input [15:0] x;
    input clk;
    input clr;
    output [6:0] g_to_a;
    output [3:0] an;

    wire [1:0] s;
    wire [3:0] digit;
    wire [3:0] aen;

    // Extra logic to disable zero leading digits.
    assign aen = {|x[15:12], |x[15:8], |x[15:4], 1'b1};

    mux44 U0(x, s, digit);

    ancode U1(s, aen, an);

    ctr2bit U2(clk, clr, s);

    hex2_7seg U3(digit, g_to_a);

endmodule
