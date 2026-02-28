`timescale 1ns / 1ps

module ID #(parameter PC_SIZE=16)
(
    input wire clock,
    input wire reset,
    input wire stall,flush,
    input wire [PC_SIZE-1:0] PC_out_in,
    input wire [PC_SIZE-1:0] PC_next_in,
    input wire [15:0] instruction,
    input wire stall_ls,
    input finish,

    output reg [2:0] rs1 ,
    output reg [2:0] rs2 ,
    output reg [2:0] write_register_out, //This is Rd
    output reg reg_write_out,           // This is W en for RF
    
    output reg [15:0] immediate,
    
    /*Control Signals*/
    output reg branch,
    output reg mem_read,
    output reg mem_to_reg,
    output reg [2:0] alu_op,
    output reg mem_write,
    output reg alu_src,
    output reg [1:0]jump,
    output reg [2:0] funct,
    output reg load_m,
    output reg store_m,
    /*Bypass*/
    output reg [PC_SIZE-1:0] PC_out_out,
    output reg [PC_SIZE-1:0] PC_next_out,
    output [2:0]  RS1_out,RS2_out,
    output reg stallPC
);
    wire [3:0] OPCODE ;
    wire [1:0] FUNCT3 ;
    wire  COMPL ;
    wire [2:0] RD ;
    wire [2:0] RS1 ;
    wire [2:0] RS2 ;
    wire branch_wire;
    wire mem_read_wire;
    wire mem_to_reg_wire;
    wire [2:0] alu_op_wire;
    wire mem_write_wire;
    wire alu_src_wire;
    wire [1:0]jump_wire;
    wire reg_write_wire;
    wire [15:0] immediate_wire;
    wire [2:0] funct_wire;
    wire load_m_wire;
    wire store_m_wire;


    assign OPCODE = instruction[15:12];
    assign FUNCT3 =  instruction[1:0];
    assign COMPL = instruction[2];
    assign funct_wire = {instruction[2],FUNCT3};

assign RS1 =((OPCODE == 4'b1000|OPCODE == 4'b1001|OPCODE == 4'b1010|OPCODE==4'b1011|OPCODE==4'b1100|OPCODE==4'b1101 ))?instruction[11:9] :instruction[8:6];
assign RS2 =((OPCODE == 4'b1000|OPCODE == 4'b1001|OPCODE == 4'b1010|OPCODE==4'b1011|OPCODE==4'b1100|OPCODE==4'b1101))?instruction[8:6] :((OPCODE == 4'b0101)?instruction[11:9]:instruction[5:3]);
  assign RS1_out = RS1;
    assign RS2_out = RS2;

always @* begin
    if( stallPC ==1'b1 &  finish==1)
                  stallPC <=1'b0; 
end


    always@(posedge clock or posedge reset)begin
        if(reset)begin
            PC_out_out <= 0;
            stallPC <=1'b0;
            PC_next_out <= 0;
            branch <= 0;
            mem_read <= 0;
            mem_to_reg <= 0;
            alu_op <= 0;
            mem_write <= 0;         //These might actually be valid
            alu_src <= 0;
            jump<=0;
            immediate <= 0;
            funct <= 0;
            reg_write_out <=1'b0;
            write_register_out <= 0;
            rs1 <= 0;   //We are not allowed to use RO
            rs2 <= 0;
            load_m <= 0;
            store_m <=0;
            //finish<=0;
        end 
        else if (flush ) begin
        //stallPC <=1'b0;
          PC_out_out <= 0;
            PC_next_out <= 0;
            branch <= 0;
            mem_read <= 0;
            mem_to_reg <= 0;
            alu_op <= 0;
            mem_write <= 0;         //These might actually be valid
            alu_src <= 0;
            jump<=0;
            immediate <= 0;
            funct <= 0;
            reg_write_out <=0;
            write_register_out <= 0;
            rs1 <= 0;   //We are not allowed to use RO
            rs2 <= 0;
            load_m <= 0;     
            store_m <=0;
        
           end
         else  if(stall | stall_ls)begin
         //stallPC <=1'b0;
            PC_out_out <= 0;
            PC_next_out <= 0;
            branch <= 0;
            mem_read <= 0;
            mem_to_reg <= 0;
            alu_op <= 0;
            mem_write <= 0;         //These might actually be valid
            alu_src <= 0;
            jump<=0;
            immediate <= 0;
            funct <= 0;
            reg_write_out <=reg_write_out;
            write_register_out <= instruction[11:9];
            rs1 <= rs1;   //We are not allowed to use RO
            rs2 <= rs2;
            load_m <= load_m_wire;
            store_m <= store_m_wire;
        end 
        else if(OPCODE == 4'b0101)
        begin
        
            rs1 <= instruction[8:6];        //For store Rs1 = Rb(Address)
            rs2 <= instruction[11:9];       //For store Rs2 = Ra(Actual data)
            write_register_out <= 0;        //No rd for Store
            PC_out_out <= PC_out_in;
            PC_next_out <= PC_next_in;
            branch <= branch_wire;
            mem_read <= mem_read_wire;
            mem_to_reg <= mem_to_reg_wire;
            alu_op <= alu_op_wire;
            mem_write <= mem_write_wire;
            alu_src <= alu_src_wire;
            jump<=jump_wire;
            immediate <= immediate_wire;
            funct <= funct_wire;
            reg_write_out <= reg_write_wire;
            load_m <= load_m_wire;
            store_m <= store_m_wire;
        end
        
        else if(OPCODE == 4'b0110)
        begin
            rs1 <= instruction[11:9];        //For store Rs1 = Rb(Address)
            stallPC <=1'b1;
                             //no rs2
            write_register_out <= 0;        //No rd for Store
            PC_out_out <= PC_out_in;
            PC_next_out <= PC_next_in;
            branch <= branch_wire;
            mem_read <= mem_read_wire;
            mem_to_reg <= mem_to_reg_wire;
            alu_op <= alu_op_wire;
            mem_write <= mem_write_wire;
            alu_src <= alu_src_wire;
            jump<=jump_wire;
            immediate <= immediate_wire;
            funct <= funct_wire;
            reg_write_out <= reg_write_wire;
            load_m <= load_m_wire;
            store_m<=store_m_wire;
        end
        
        else if(OPCODE == 4'b0111)
        begin
            rs1 <= instruction[11:9];        //For store Rs1 = Rb(Address)
                                            //no rs2
            write_register_out <= 0;        //No rd for Store
                        stallPC <=1'b1;
            //if( stallPC ==1'b1 &  finish==1)
                  //stallPC <=1'b0;
            PC_out_out <= PC_out_in;
            PC_next_out <= PC_next_in;
            branch <= branch_wire;
            mem_read <= mem_read_wire;
            mem_to_reg <= mem_to_reg_wire;
            alu_op <= alu_op_wire;
            mem_write <= mem_write_wire;
            alu_src <= alu_src_wire;
            jump<=jump_wire;
            immediate <= immediate_wire;
            funct <= funct_wire;
            reg_write_out <= reg_write_wire;
            load_m <= load_m_wire;
            store_m<=store_m_wire;
        end
        
         else if(OPCODE == 4'b1000|OPCODE == 4'b1001|OPCODE == 4'b1010|OPCODE==4'b1011|OPCODE==4'b1101)
        begin
        //stallPC <=1'b0;
            rs1 <= instruction[11:9];           //For Beq rs1 = RA
            rs2 <= instruction[8:6];            //For Beq rs2 = RB
            write_register_out <= 0;            //Rd = 0
            PC_out_out <= PC_out_in;
            PC_next_out <= PC_next_in;
            branch <= branch_wire;
            mem_read <= mem_read_wire;
            mem_to_reg <= mem_to_reg_wire;
            alu_op <= alu_op_wire;
            mem_write <= mem_write_wire;
            alu_src <= alu_src_wire;
            jump<=jump_wire;
            immediate <= immediate_wire;
            funct <= funct_wire;
            reg_write_out <= reg_write_wire;
            load_m <= load_m_wire;
            store_m<=store_m_wire;
        end 
        else if(OPCODE == 4'b1100)
        begin
        //stallPC <=1'b0;
            rs1 <= instruction[8:6];           //For Beq rs1 = RA
            rs2 <= instruction[5:3];            //For Beq rs2 = RB
            write_register_out <= instruction[11:9];            //Rd = 0
            PC_out_out <= PC_out_in;
            PC_next_out <= PC_next_in;
            branch <= branch_wire;
            mem_read <= mem_read_wire;
            mem_to_reg <= mem_to_reg_wire;
            alu_op <= alu_op_wire;
            mem_write <= mem_write_wire;
            alu_src <= alu_src_wire;
            jump<=jump_wire;
            immediate <= immediate_wire;
            funct <= funct_wire;
            reg_write_out <= reg_write_wire;
            load_m <= load_m_wire;
            store_m<=store_m_wire;
        end 
        else
        begin
        //stallPC <=1'b0;
            PC_out_out <= PC_out_in;
            PC_next_out <= PC_next_in;
            branch <= branch_wire;
            mem_read <= mem_read_wire;
            mem_to_reg <= mem_to_reg_wire;
            alu_op <= alu_op_wire;
            mem_write <= mem_write_wire;
            alu_src <= alu_src_wire;
            jump<=jump_wire;
            immediate <= immediate_wire;
            funct <= funct_wire;
            reg_write_out <= reg_write_wire;
            write_register_out <= instruction[11:9];
            rs1 <= instruction[8:6];
            rs2 <= instruction[5:3];
            load_m <= load_m_wire;
            store_m<=store_m_wire;
        end
    end

    Control CU(
        .opcode(OPCODE),
        .branch(branch_wire),
        .mem_read(mem_read_wire),
        .mem_to_reg(mem_to_reg_wire),
        .alu_op(alu_op_wire),
        .mem_write(mem_write_wire),
        .alu_src(alu_src_wire),
        .jump(jump_wire),
        .reg_write(reg_write_wire),
        .load_m(load_m_wire),
        .store_m(store_m_wire)
    );

    Imm_Gen Immediate_Generator(
        .instruction(instruction),
        .immediate(immediate_wire)
    );


endmodule