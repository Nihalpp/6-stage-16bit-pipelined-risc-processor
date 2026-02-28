
`timescale 1ns / 1ps

module TOP_tb();

reg clock;
reg reset;
reg rw;
reg reset_IF_memory;
reg [15:0] instruction_in;
reg [15:0] PC_write;
wire [15:0] write_reg_data;

TOP top(
    .clock(clock),
    .reset(reset),
    .reset_IF_memory(reset_IF_memory),
    .instruction_in(instruction_in),
    .rw(rw),
    .PC_write(PC_write),
    .write_reg_data(write_reg_data)
);

always #100 clock = ~clock;

initial begin
    clock = 0;
    reset = 1; reset_IF_memory = 1;
    #26 reset_IF_memory = 0;
    PC_write = 0;
    instruction_in = 16'h0000;

    // writing instructions to instruction memory
    rw = 0; 
    
    #80 reset = 0; 
     @(posedge clock);
    PC_write = 16'd1; instruction_in = 16'b0100_000_001_000_001 ; //LW R0,R1,1
     @(posedge clock);
    PC_write = 16'd2; instruction_in = 16'b0010_100_001_010_000; //  NDU R4, R1, R2
     @(posedge clock);
    PC_write = 16'd3; instruction_in = 16'b0000_110_001_010_000; // ADA R6, R1, R4
    @(posedge clock);
     PC_write = 16'd4; instruction_in = 16'b0000_101_001_010_100; // ADA R5, R1, R4
     @(posedge clock);
    PC_write = 16'd5; instruction_in = 16'b0000_011_001_010_000; // ADA R3, R1, R4
    @(posedge clock);
    PC_write = 16'd6; instruction_in = 16'b0000_111_001_010_000; // ADA R7, R1, R4
//    @(posedge clock);
//    PC_write = 10'd1; instruction_in = 16'b0011101000000000; // lli r5,0 :  r5 =0
//    @(posedge clock);
//  @(posedge clock);
//PC_write = 16'd1; instruction_in = 16'b10_00_100_011_000_111; // beq r4,r3,2
//    @(posedge clock);
//    PC_write = 16'd2; instruction_in = 16'b0100001101000001; // lw  r1,r5,1:  r1 = MEM[1+r5]


//    PC_write = 10'd2; instruction_in = 16'b0011110000000000; // lli r6,0 :  r6 =0
//    @(posedge clock);
//    PC_write = 16'd1; instruction_in = 16'b0010_101_011_100_000; // jal  r1,1:  jump to PC+2
//    @(posedge clock);
//   PC_write = 16'd2; instruction_in = 16'b0000_010_101_110_000; // ada r2=r5+r6
//     @(posedge clock);
//    PC_write = 16'd3; instruction_in = 16'b0000_111_010_011_000; // ada r7=r2+r3
//     @(posedge clock);
//    PC_write = 16'd1; instruction_in = 16'b0101_111_010_000_001; // sw r7,r6,1 r7=M[r6+1]
    
//    @(posedge clock);
//    PC_write = 16'd8; instruction_in = 16'b0000_111_010_001_000; // lw r2,r6,2: r2 = MEM[2+r6]
// @(posedge clock);
//    PC_write = 16'd9; instruction_in = 16'b0100_001_101_000010; // lw  r1,r5,1:  r1 = MEM[2+r5]
    
//      @(posedge clock);
//      PC_write = 16'd9; instruction_in = 16'b0111_001_011_110110; // sm  r1,r5,1:  r1 = MEM[2+r5]
      
//           @(posedge clock);
//    PC_write = 16'd10; instruction_in = 16'b0000_111_010_011_000; // ada r7=r2+r3
      
//         @(posedge clock);
//        PC_write = 16'd1; instruction_in = 16'b0110_001_011_110110; // lm  r1,r5,1:  r6=M[r5]
//                   @(posedge clock);
//    PC_write = 16'd12; instruction_in = 16'b0000_111_010_011_000; // ada r7=r2+r3
//               @(posedge clock);
//    PC_write = 16'd13; instruction_in = 16'b0000_111_010_011_000; // ada r7=r2+r3

// @(posedge clock);
//    PC_write = 16'd10; instruction_in = 16'b0100_101_101_000001; // lw  r1,r5,1:  r1 = MEM[1+r5]



//    @(posedge clock);
//    PC_write = 16'd3; instruction_in = 16'b10_00_100_011_000_001; // beq r4,r3,2
//    @(posedge clock);
//    PC_write = 16'd2; instruction_in = 16'b00_00_101_010_010_000; // awc r5, r2, r2
//     @(posedge clock);
//    PC_write = 16'd3; instruction_in = 16'b00_00_011_011_011_000; // awc r3, r3, r3
//     @(posedge clock);
//    PC_write = 16'd4; instruction_in = 16'b00_00_111_111_111_000; // awc r7, r7, r7
//    @(posedge clock);
//     PC_write = 16'd4; instruction_in = 16'b00_00_111_011_001_100; //aca r5,r4,r3   //0B1C
//    @(posedge clock);
//    PC_write = 16'd6; instruction_in = 16'b00_00_101_010_001_001; //adz r5,r2,r1   //0B1A
// @(posedge clock);
//    PC_write = 16'd7; instruction_in = 16'b00_00_101_010_001_001; //adz r5,r2,r1   //0B1A
// @(posedge clock);
//    PC_write = 16'd7; instruction_in = 16'b01_01_111_101_000_001; //sw

    //0101_RA_RB_6-bit Immediate
    
    
    /*#26 PC_write = 10'd12; instruction_in = 32'b0100000_00010_00011_000_00011_0110011; // sub r3, r2, r3 : r3 = r2 - r3
    #26 PC_write = 10'd13; instruction_in = 32'b0000000_00011_00001_000_00000_0100011; // sd r3, 0, r1 : MEM[0+r1] = r3 
    #26 PC_write = 10'd14; instruction_in = 32'b000000000110_00000_000_00000_1101111;  // jal 4 : PC = PC + 5

    #26 PC_write = 10'd18; instruction_in = 32'b0000000_00010_00011_000_00011_0110011; // add r3, r2, r3 : r3 = r2 + r3
    #26 PC_write = 10'd19; instruction_in = 32'b0000000_00011_00001_000_00000_0100011; // sd r3, 0, r1 : MEM[0+r1] = r3 
    
    #26 PC_write = 10'd20; instruction_in = 32'b0000000_00010_00001_000_00001_0110011; // add r1, r2, r1 : r1 = r2 + r1
    #26 PC_write = 10'd21; instruction_in = 32'b001111101110_00000_000_00000_1101111;  // jal 4 : PC = PC + 238
*/


    #500 reset = 1;
    #500 reset = 0; rw = 1; // reading instructions from instruction memory


end
endmodule
