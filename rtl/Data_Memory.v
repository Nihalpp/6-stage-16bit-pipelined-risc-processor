`timescale 1ns / 1ps

module Data_Memory #(parameter ADDRESS_LINE=16,  parameter MEM_SIZE=16)
(
    input wire clock,
    input wire reset,
    input wire [15:0] write_data,
    input wire [ADDRESS_LINE-1:0] address,
    input wire mem_write,
    input wire mem_read,
    output wire [15:0] read_data
);

    reg [15:0] memory[MEM_SIZE-1:0];

    assign read_data = mem_read ? memory[address] : 16'b0;
    integer i = 0;
    always@(posedge clock) begin
        if(reset)begin
            for( i=0; i<MEM_SIZE; i=i+1)begin
                memory[i] <= 0;
            end
            memory[0] <= 1;
            memory[1] <= 3;
            memory[2] <= 20;
            memory[3] <= 4;
            memory[4] <= 5;
            memory[5] <= 6;
            memory[6] <= 7;
            memory[7] <= 8;
            memory[8] <= 9;
            memory[9] <= 10;
            memory[10] <= 11;
        end
        else begin
            if(mem_write)begin
                memory[address] <= write_data;
            end
        end
    end
    

endmodule