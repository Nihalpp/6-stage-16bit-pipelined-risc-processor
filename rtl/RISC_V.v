`timescale 1ns / 1ps

module RISC_V #(
    parameter PC_SIZE       = 16,
    parameter DATA_MEM_SIZE = 16,
    parameter ADDRESS_LINE  = 16
) (
    input  wire                   clock,
    input  wire                   reset,
    input  wire                   rw,
    input  wire                   reset_IF_memory,
    input  wire [PC_SIZE-1:0]     PC_write,
    input  wire [15:0]            instruction_in,
    output wire [15:0]             write_reg_data
);

    // === IF/ID wires ===
    wire [PC_SIZE-1:0] PC_out_IF;
    wire [PC_SIZE-1:0] PC_next_IF;
    wire [15:0]        instruction_IF;
    wire [1:0]             PCScr;
    wire [PC_SIZE-1:0] PC_jump;

    // === ID outputs ===
    wire               branch_ID;
    wire               mem_read_ID;
    wire               mem_to_reg_ID;
    wire [2:0]         alu_op_ID;
    wire               mem_write_ID;
    wire               alu_src_ID;
    wire [1:0]              jump_ID;
    wire               reg_write_ID;
    wire [2:0]         rs1_ID;
    wire [2:0]         rs2_ID;
    wire [2:0]         write_reg_ID,write_reg_ID_RR;
    wire [15:0]         imm_ID;
    wire [2:0]         funct_ID;
    wire [PC_SIZE-1:0] PC_out_ID;
    wire [PC_SIZE-1:0] PC_next_ID;
    wire load_m_ID;
    wire store_m_ID;

    // === RR wires ===
    wire [PC_SIZE-1:0] PC_out_RR;
    wire [15:0]        read_data1_RR;
    wire [15:0]        read_data2_RR;
    wire [1:0] jump_RR;
    wire  branch_RR;
    wire  mem_read_RR;
    wire  mem_to_reg_RR;
    wire  [2:0] alu_op_RR;
    wire  mem_write_RR;
    wire  alu_src_RR;
    wire [15:0]immediate_RR;
    wire [2:0]funct_RR;
    wire load_m_RR;
    wire store_m_RR;

    // === EXE outputs ===
    
    wire [PC_SIZE-1:0] PC_jump_EXE;
    wire [15:0]        ALU_result_EXE;
    wire [15:0]        write_data_EXE;
    wire               zero_EXE;
    wire               carry_EXE;
    wire               lt_EXE;
    wire               eq_EXE;
    wire               le_EXE;
    wire branch_EXE;
    wire mem_read_EXE;
    wire mem_to_reg_EXE;
    wire mem_write_EXE;
    wire [1:0]jump_EXE;
    wire reg_write_EXE;
    wire stall_l;
    wire sm_reg_select_wire;
    wire finish_wire;

    // === MEM outputs ===
    wire [15:0]         ALU_result_MEM;
    wire [15:0]         mem_read_data;
    wire [2:0]         write_reg_MEM,write_register_EXE;
    wire               mem_to_reg_MEM;
    wire               reg_write_MEM;
    wire               mem_flag_R0_write_MEM;
    //wire [15:0]        write_PC_MEM;

    // === WB output ===
    wire [15:0]         wb_write_data;
    wire [1:0]fwd_A,fwd_B;
    assign write_reg_data = wb_write_data;

    // ---- IF stage ----
    IF #(.PC_SIZE(PC_SIZE)) IF_stage (
        .clock        (clock),
        .reset        (reset),
        .PCScr        (PCScr),
        .rw           (rw),
        .reset_memory(reset_IF_memory),
        .PC_jump      (PC_jump),
        .PC_write     (PC_write),
        .instruction_in(instruction_in),
        .PC_out       (PC_out_IF),
        .PC_next_out  (PC_next_IF),
        .instruction_out(instruction_IF),
        .flush(flush),
        .stall(stall), //input
        .stall_ls(stall_ls),
        .stallPC(stallPC_wire), //input
        .PC_reg_mem(mem_read_data),
        .flag_R0_mem(mem_flag_R0_write_MEM)
    );
wire [2:0] RS2_out,RS1_out;
    // ---- ID stage ----
    ID #(.PC_SIZE(PC_SIZE)) ID_stage (
        .clock       (clock),
        .reset       (reset),
        .PC_out_in   (PC_out_IF),
        .PC_next_in  (PC_next_IF),
        .instruction (instruction_IF),
        .rs1         (rs1_ID),
        .rs2         (rs2_ID),
        .write_register_out(write_reg_ID),
        .reg_write_out(reg_write_ID),
        .branch      (branch_ID),
        .mem_read    (mem_read_ID),
        .mem_to_reg  (mem_to_reg_ID),
        .alu_op      (alu_op_ID),
        .mem_write   (mem_write_ID),
        .alu_src     (alu_src_ID),
        .jump        (jump_ID),
        .immediate   (imm_ID),
        .funct       (funct_ID),
        .PC_out_out(PC_out_ID),
        .PC_next_out(PC_next_ID),
        .stall(stall),  //input
        .stall_ls(stall_ls),
        .stallPC(stallPC_wire),
        .flush(flush),
        .RS2_out(RS2_out),
        .RS1_out(RS1_out),
        .load_m(load_m_ID),
        .store_m(store_m_ID),
        .finish(finish_wire) //input
        
    );
wire reg_write_ID_out;
wire branch_flush;
wire flag_R0_flush;
wire flush;
assign flush = branch_flush | flag_R0_flush;

wire [2:0]  rs2_RR,rs1_RR;
    // ---- ID/EXE pipeline register ----
    RR #(.PC_SIZE(PC_SIZE)) RR_stage (
         .write_reg_ID_in(write_reg_ID),
         .write_reg_ID_out(write_reg_ID_RR),
         .reg_write_ID(reg_write_ID),
         .load_m_ID(load_m_ID),
         .store_m_ID(store_m_ID),
         .reg_write_ID_out(reg_write_ID_out),
         .sm_reg_idx(write_register_EXE),
        .clock             (clock),
        .reset             (reset),
        .PC_out_in         (PC_out_ID),
        .PC_next_in        (PC_next_ID),
        .write_reg_data    (wb_write_data),
        .reg_write_in      (reg_write_MEM),
        .jump_in              (jump_ID),
        .write_register_in (write_reg_MEM),
        .rs1               (rs1_ID),
        .rs2               (rs2_ID),
        .branch_in           (branch_ID),
        .mem_read_in          (mem_read_ID),
        .mem_to_reg_in        (mem_to_reg_ID),
        .alu_op_in           (alu_op_ID),
        .mem_write_in         (mem_write_ID),
        .alu_src_in           (alu_src_ID),
        .PC_out_out        (PC_out_RR),
        .read_data1        (read_data1_RR),
        .read_data2        (read_data2_RR),
        .immediate_in         (imm_ID),
        .jump_out          (jump_RR),
        .funct_in            (funct_ID),
        .branch_out(branch_RR),
        .mem_read_out(mem_read_RR),
        .mem_to_reg_out(mem_to_reg_RR),
        .alu_op_out(alu_op_RR),
        .load_m_RR(load_m_RR),
        .store_m_RR(store_m_RR),
        .mem_write_out(mem_write_RR),
        .alu_src_out(alu_src_RR),
        .immediate_out(immediate_RR),
        .funct_out(funct_RR),
        .rs2_RR(rs2_RR),
        .rs1_RR(rs1_RR),
        . mem_read_EXE(mem_read_ID),          // <- comes from EX stage  comes from MEM stage
        .branch_EXE (PCScr),           // <- comes from EX stage
        .stall(stall),  //output stall
        .branch_flush(branch_flush),
        .flag_R0_flush(flag_R0_flush),
        .rs1_select(sm_reg_select_wire),
       // .zero_EXE (zero)              // <- comes from EX stage
       .RS1_out(RS1_out),
       .RS2_out(RS2_out),
       .flag_R0(mem_flag_R0_write_MEM)
    );
//assign   
//assign
//assign
    // ---- EXE stage ----
    EXE #(.PC_SIZE(PC_SIZE)) EXE_stage (
        .clock            (clock),
        .reset            (reset),
        .jump_in          (jump_RR),
        .CurrentPC         (PC_out_RR),
        .data1            (read_data1_RR),
        .data2            (read_data2_RR),
        .immediate        (immediate_RR),
        .funct            (funct_RR),
        .alu_op           (alu_op_RR),
        .alu_src          (alu_src_RR),
        .branch_in        (branch_RR),
        .mem_read_in      (mem_read_RR),
        .mem_to_reg_in    (mem_to_reg_RR),
        .mem_write_in     (mem_write_RR),
        
        .load_m_RR        (load_m_RR),
        .store_m_RR       (store_m_RR),
        .reg_write_in     (reg_write_ID_out),
        .fwd_A            (fwd_A),
        .fwd_B            (fwd_B),
        .write_register_in(write_reg_ID_RR),
        .wb_write_data    (mem_read_data),  //Changed
        .ex_mem_alu_result(ALU_result_EXE),//Changed
        .PC_jump          (PC_jump_EXE),
        .zero             (zero_EXE),
        .carry            (carry_EXE),
        .lt               (lt_EXE),
        .eq               (eq_EXE),
        .le               (le_EXE),
        .ALU_result       (ALU_result_EXE),
        .write_register_out(write_register_EXE),
        .branch_out(branch_EXE),
        .mem_read_out(mem_read_EXE),
        .mem_to_reg_out(mem_to_reg_EXE),
        .mem_write_out(mem_write_EXE),
        .write_data(write_data_EXE),
        .jump_out(jump_EXE),
        .reg_write_out(reg_write_EXE),
           .flush(flush),
           .stall_ls(stall_ls), //output
        .sm_reg_select(sm_reg_select_wire),
        .finish(finish_wire) //output
    );

    // ---- MEM stage ----
    MEM #(.ADDRESS_LINE(ADDRESS_LINE), .DATA_MEM_SIZE(DATA_MEM_SIZE)) MEM_stage (
        .clock             (clock),
        .reset             (reset),
        .jump_in           (jump_EXE),
        .PC_jump_in        (PC_jump_EXE),
        .reg_write_in      (reg_write_EXE),
        .branch            (branch_EXE),
        .mem_read          (mem_read_EXE),
        .mem_to_reg_in     (mem_to_reg_EXE),
        .mem_write         (mem_write_EXE),
        .eq                (eq_EXE),
        .lt                (lt_EXE),
        .le                (le_EXE),
        .ALU_result_in     (ALU_result_EXE),
        .write_data        (write_data_EXE),
        .write_register_in (write_register_EXE),
        .write_register_out(write_reg_MEM),
        .ALU_result_out    (ALU_result_MEM),
        .read_data         (mem_read_data),
        .mem_to_reg_out    (mem_to_reg_MEM),
        .PCScr             (PCScr),
        .PC_jump_out       (PC_jump),
        .reg_write_out     (reg_write_MEM),
        .mem_flag_R0_write(mem_flag_R0_write_MEM)
        //.write_PC(write_PC_MEM)
    );

    // ---- WB stage ----
    WB WB_stage (
        .read_data  (mem_read_data),
        .ALU_result (ALU_result_MEM),
        .mem_to_reg (mem_to_reg_MEM),
        .write_data (wb_write_data)
    );

    // ---- Forwarding Unit ----
    Forwarding_Unit FU (
        .reg_RS1         (rs1_RR),
        .reg_RS2         (rs2_RR),
        .ex_mem_reg_RD   (write_register_EXE),
        .mem_wb_reg_RD   (write_reg_MEM),
        .ex_mem_regwrite (reg_write_EXE),
        .mem_wb_regwrite (reg_write_MEM),
        .fwd_A           (fwd_A),
        .fwd_B           (fwd_B)
    );

endmodule
