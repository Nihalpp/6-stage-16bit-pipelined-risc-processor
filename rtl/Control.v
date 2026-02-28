`timescale 1ns / 1ps

module Control
(
    input wire [3:0] opcode,
    output reg branch,
    output reg mem_read,
    output reg mem_to_reg,
    output reg [2:0] alu_op,
    output reg mem_write,
    output reg alu_src,
    output reg [1:0]jump,
    output reg reg_write,
    output reg load_m,
    output reg store_m
);
//ALUOp signals 000:load and stores;001:beq,100:blt,101:ble;010:add;011:nand;110:add0; 111 incr
//| Instruction | ALUSrc | Memto-Reg | Reg-Write | Mem-Read | Mem-Write | Branch | ALUOp1 | ALUOp0 |
//|-------------|--------|-----------|-----------|----------|-----------|--------|--------|--------|
//| R-format    |    0   |     0     |     1     |     0    |     0     |    0   |    1   |    0   |
//| ADI         |    1   |     0     |     1     |     0    |     0     |    0   |    1   |    0   |
//| ld          |    1   |     1     |     1     |     1    |     0     |    0   |    0   |    0   |
//| sd          |    1   |     X     |     0     |     0    |     1     |    0   |    0   |    0   |
//| beq         |    0   |     X     |     0     |     0    |     0     |    1   |    0   |    1   |
//| jal         |    1   |     0     |     1     |     0    |     0     |    1   |    1   |    1   |


    always @* begin
        case(opcode)
            4'b0000: begin // ADA to ACW
                branch = 0;
                mem_read = 0;
                mem_to_reg = 0;
                alu_op = 3'b010;
                mem_write = 0;
                alu_src = 0;
                jump=0;
                reg_write = 1;
                load_m = 0;
                store_m=0;
            end
            4'b0001: begin // ADI
                branch = 0;
                mem_read =0;
                mem_to_reg = 0;
                alu_op = 3'b000;
                mem_write = 0;
                alu_src = 1;
                jump=0;
                reg_write = 1;
                load_m = 0;
                store_m=0;
            end
            4'b0010: begin // nand
                branch = 0;
                mem_read = 0;
                mem_to_reg = 0;
                alu_op = 3'b011;
                mem_write = 0;
                alu_src = 0;
                jump=0;
                reg_write = 1;
                load_m = 0;
                store_m=0;
            end
            4'b0011: begin // lli
                branch = 0;
                mem_read = 0;
                mem_to_reg = 0;
                alu_op = 3'b110;
                mem_write = 0;
                alu_src = 1;
                jump=0;
                reg_write = 1;
                load_m = 0;
                store_m=0;
            end
            4'b0100: begin // lw
                branch = 0;
                mem_read = 1;
                mem_to_reg = 1;
                alu_op = 3'b000;
                mem_write = 0;
                alu_src = 1;
                jump=0;
                reg_write = 1;
                load_m = 0;
                store_m=0;
            end
            4'b0101: begin //sw
                branch = 0;
                mem_read = 0;
                mem_to_reg = 1'b0;
                alu_op = 3'b000;
                mem_write = 1;
                alu_src = 1;
                jump=0;
                reg_write = 0;
                load_m = 0;
                store_m=0;
            end
            4'b0110: begin  //lm
                branch = 0;
                mem_read = 0;
                mem_to_reg = 0;
                alu_op = 3'b111;
                mem_write = 0;
                alu_src = 1;
                jump=0;
                reg_write = 0;
                load_m = 1;
                store_m=0;
            end
            4'b0111: begin //sm
                branch = 0;
                mem_read = 0;
                mem_to_reg = 0;
                alu_op = 3'b111;
                mem_write = 0;
                alu_src = 1;
                jump=0;
                reg_write = 0;
                load_m = 0;
                store_m=1;
            end
            4'b1000: begin   //beq
                branch = 1;
                mem_read = 0;
                mem_to_reg = 1'b0;
                alu_op = 3'b001;
                mem_write = 0;
                alu_src = 0;
                jump=0;
                reg_write = 0;
                load_m = 0;
                store_m=0;
            end
            4'b1010: begin //ble
                branch = 1;
                mem_read = 0;
                mem_to_reg = 1'b0;
                alu_op = 3'b101;
                mem_write = 0;
                alu_src = 0;
                jump=0;
                reg_write = 0;
                load_m = 0;
                store_m=0;
            end
            4'b1001: begin //blt
                branch = 1;
                mem_read = 0;
                mem_to_reg = 1'bx;
                alu_op = 3'b100;
                mem_write = 0;
                alu_src = 0;
                jump=0;
                reg_write = 0;
                load_m = 0;
                store_m=0;
            end
            4'b1011: begin //jal
                branch = 1;
                mem_read = 0;
                mem_to_reg = 0;
                alu_op = 3'b000;
                mem_write = 0;
                alu_src = 0;
                jump=2'b11;
                reg_write = 1;
                load_m = 0;
                store_m=0;
            end
            4'b1100: begin ////jlr 
                branch = 1;
                mem_read = 0;
                mem_to_reg = 0;
                alu_op = 3'b110;
                mem_write = 0;
                alu_src = 1;
                jump=2'b01;
                reg_write = 1;
                load_m = 0;
                store_m=0;
            end
            4'b1101: begin ////jri
                branch = 1;
                mem_read = 0;
                mem_to_reg = 0;
                alu_op = 3'b000;
                mem_write = 0;
                alu_src = 1;
                jump=2'b01;
                reg_write = 0;
                load_m = 0;
                store_m=0;
            end
            default: begin
                branch = 0;
                mem_read = 0;
                mem_to_reg = 0;
                alu_op = 3'b000;
                mem_write = 0;
                alu_src = 0;
                jump=0;
                reg_write = 0;
                load_m = 0;
                store_m=0;
            end
        endcase
    end
    
endmodule