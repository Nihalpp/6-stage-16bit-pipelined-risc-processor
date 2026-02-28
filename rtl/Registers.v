`timescale 1ns / 1ps

module Registers
(   
    input wire clock,
    input wire reset,
    input wire [15:0]PC_next_in,
    input wire [15:0]Current_PC,
    input wire [1:0] jump,
    input wire [2:0] read_reg1, // Read resister 1
    input wire [2:0] read_reg2, // Read resister 2
    input wire [2:0] write_reg,write_reg_ID_in, // Write resister 
    input wire [15:0] write_reg_data, // Write resister data
    input wire reg_write,reg_write_ID,   // Control signal for writing to register
    output reg [15:0] read_data1, // Read data 1
    output reg [15:0] read_data2, // Read data 2
    output reg [15:0] PC_out
);

    reg [15:0] registers[7:0]; // 8 registers, each 16-bit wide
    integer i=0;
    always@(negedge clock) begin
        if(reset)begin
            for( i=0; i<8; i=i+1)begin
                registers[i] <= 0;
            end
            registers[1]<=16'h0001;
            registers[2]<=14'h0001;
            registers[4]<=16'hFFFF;
            registers[3]<=16'hFFF0;
//            read_data1 <= 0;
//            read_data2 <= 0;
        end
        else begin
            if(reg_write_ID)begin
                if(jump[0]==1)begin
                    registers[write_reg_ID_in] <= PC_next_in;
                end
             end
             if(reg_write)begin
                if(write_reg==3'b000)begin
                    PC_out<=write_reg_data;
                    registers[0]<=write_reg_data;
                 end
                 else begin
                    registers[write_reg] <= write_reg_data;
                 end
                end
             else begin
                PC_out<=Current_PC;
                registers[0]<=Current_PC;
             end
            end
//            read_data1 <= registers[read_reg1];
//            read_data2 <= registers[read_reg2];
        
    end
    
// Reading on positive edge
always @(posedge clock) begin
    if (reset) begin
        read_data1 <= 0;
        read_data2 <= 0;
    end
    else begin
        read_data1 <= (read_reg1==3'b0)? PC_out:registers[read_reg1];
        read_data2 <= (read_reg2==3'b0)? PC_out:registers[read_reg2];
    end
end

endmodule