# fp_mul on Digilent Basys 3 Board

## Description

Test harness which allows user to program a Basys 3 board to use/test the fp_mul module to multiply two 16-bit IEEE 754 encoded values.

Code is explained in the video series [Building an FPU in Verilog](https://www.youtube.com/watch?v=rYkVdJnVJFQ&list=PLlO9sSrh8HrwcDHAtwec1ycV-m50nfUVs).
See the video *Building an FPU in Verilog: Running the hp_mul Module on an FPGA*.

The Basys 3 board can be purchased at [digilentinc.com](https://store.digilentinc.com/basys-3-artix-7-fpga-beginner-board-recommended-for-introductory-users/)

## Manifest

|   Filename   |                        Description                        |
|--------------|-----------------------------------------------------------|
| README.md | This file. |
| fpga_mul.v | The top level module for the test harness. File includes various utility modules needed to support user interaction. This module configures fp_mul to work on data in the 16-bit IEEE binary floating point format. |
| fp_class.sv | Utility module to identify the type of the IEEE 754 value passed in, and extract the exponent & significand fields for use by other modules. |
| fp_mul.v  | Parameterized multiply circuit for the IEEE 754 binary data types. |
| hex2_7seg.v | Utility module to output 4 digit hexadecimal value on 7-segment display. |
| ieee-754-flags.v | Include file which defines the position of each of the individual IEEE type flags within a bit vector and other miscellaneous values defined by the IEEE 754 standard. |
| x7seg.v | Miscellaneous utility routines for formatting data for output to the 7-segment display. |

## Copyright

:copyright: Chris Larsen, 2019-2021
