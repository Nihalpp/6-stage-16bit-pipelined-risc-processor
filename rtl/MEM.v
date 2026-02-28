`timescale 1ns / 1ps

module MEM  #(parameter ADDRESS_LINE=16,  parameter DATA_MEM_SIZE=16)
(
    input wire clock,
    input wire reset,
    input wire [1:0]jump_in,
    input wire[15:0] PC_jump_in,
    input wire reg_write_in,
    input wire branch,
    input wire mem_read,
    input wire mem_to_reg_in,
    input wire mem_write,
    input wire eq,
    input wire lt,
    input wire le,
    input wire [15:0] ALU_result_in,
    input wire [15:0] write_data,
    input wire [2:0] write_register_in,
    output reg mem_flag_R0_write, //new
    output reg [2:0] write_register_out,
    //output reg [15:0] write_PC, //new
    output reg [15:0] ALU_result_out,
    output reg [15:0] read_data,
    output reg mem_to_reg_out,
    output wire [1:0] PCScr,
    output wire [15:0]PC_jump_out,
    output reg reg_write_out
);

    wire [15:0] read_data_wire;
    wire mem_flag_R0;
    assign PCScr[0] = (branch & eq)|(branch & lt)|(branch & le)| (branch &jump_in[0]);
    assign PCScr[1] = mem_flag_R0;
    assign PC_jump_out = (jump_in[1]) ? PC_jump_in : ALU_result_in;
    assign mem_flag_R0 = (mem_read & write_register_in==3'b000) ? 1:0;
    
    always@(posedge clock)begin
        if(reset)begin
            mem_to_reg_out <= 0;
            ALU_result_out <= 0;
            reg_write_out <= 0;
            read_data <= 0;
            write_register_out <= 0;
            //write_PC<=0;
            mem_flag_R0_write<=0;
        end else begin
            mem_to_reg_out <= mem_to_reg_in;
            ALU_result_out <= ALU_result_in;
            reg_write_out <= reg_write_in;
            read_data <= read_data_wire;
            write_register_out <= write_register_in;
            mem_flag_R0_write<=mem_flag_R0;
        end
    end

    Data_Memory  #(.ADDRESS_LINE(ADDRESS_LINE),.MEM_SIZE(DATA_MEM_SIZE)) DM(
        .clock(clock),
        .reset(reset),
        .write_data(write_data),
        .address(ALU_result_in),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .read_data(read_data_wire)
    );


endmodule