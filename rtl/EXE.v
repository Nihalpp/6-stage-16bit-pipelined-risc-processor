`timescale 1ns / 1ps

module EXE #(parameter PC_SIZE=16)
(
    input wire clock,
    input wire reset,
    input wire flush,
    input wire [1:0]jump_in,                 
    input wire [PC_SIZE-1:0] CurrentPC,
    input wire [15:0] data1,
    input wire [15:0] data2,
    input wire [15:0] immediate,
    
    /*Control Signals*/
    input wire [2:0] funct, // {COMPL, funct3}
    input wire load_m_RR, //load_m = 1 then is a load multiple instr
    input wire store_m_RR,
    input wire [2:0] alu_op,
    input wire alu_src,
    input wire branch_in,
    input wire mem_read_in,
    input wire mem_to_reg_in,
    input wire mem_write_in,
    input wire reg_write_in, 
    input wire [1:0] fwd_A,
    input wire [1:0] fwd_B,
    input wire [2:0] write_register_in,//tells which register to write data
    
    //Forwarded inputs
    input wire [15:0] wb_write_data,
    input wire [15:0] ex_mem_alu_result,
    
    
    output reg [2:0] write_register_out, //tells which register to write data
    output reg [PC_SIZE-1:0] PC_jump,
    output reg zero,
    output reg carry,
    output reg lt,
    output reg eq,
    output reg le,
    output reg [15:0] ALU_result,
    output reg branch_out,      //Not needed to forward
    output reg mem_read_out,    
    output reg mem_to_reg_out,
    output reg mem_write_out,
    output reg load_m_EXE,
    output reg [15:0] write_data,
    output reg [1:0]jump_out,
    output reg reg_write_out,
    //output reg stall_l, 
    output reg stall_ls, //this will stall ID and IF stage when LM or SM instr comes
    output reg sm_reg_select,
    output reg finish
);

    wire [3:0] alu_control;
    wire [15:0] intermediate_data2;
    reg [15:0] selected_data2;
    wire [15:0] selected_data2_final;
    wire [15:0] data2_final;
    reg [15:0] selected_data1;
    reg [PC_SIZE-1:0] PC_jump_wire;
    wire [15:0] ALU_result_wire;
    wire zero_wire;
    wire carry_wire;
    wire lt_wire;
    wire eq_wire;
    wire le_wire;
    reg stall_l;
    
    
    
    //load multiple instruction
    // Define states using localparam
    localparam [2:0]IDLE = 3'b000;  // IDLE state
    localparam [2:0]SHIFT_ADDR = 3'b001; //where the bit of imm data will be checked
    localparam [2:0]STALL1 = 3'b010; //2 stall cycles
    localparam [2:0]STALL2 = 3'b011;
    localparam [2:0]STALL3 = 3'b100;
    localparam [2:0]FINISH = 3'b111;
    // Initialize state to IDLE
   reg [2:0] current_state=IDLE, next_state;
   
    reg [8:0] imm_reg_r=0;
    reg [15:0] ra_base_addr_reg=0;
    reg [15:0] ra_base_addr=0;
    //wire [15:0] computed_base_addr;
    reg [15:0]alu_a=0;
    
    reg [3:0]shift_idx=0;
    reg [2:0]reg_idx=7;
    //reg stall_l=0;
    reg [1:0]stall_count=0;
    //reg finish=0; // tells when the computaion is completed
    reg first_1=0;
    //shifting the register at every clk cycle
   reg active;
   reg reg_idx_out;
   wire [3:0] alu_op_wire;
   reg store_check=0;
    assign alu_op_wire = stall_l ? 4'b0111 : alu_op;
    
always @(posedge clock) begin
    if (reset) begin
        stall_ls <= 1'b0;
        active <= 1'b0;
        finish <=0;
    end
    else if (load_m_RR | store_m_RR) begin
        if (store_m_RR)
            store_check<=1;
        stall_ls <= 1'b1;
        active <= 1'b1;              // Start when load_m is high
        finish <=0;
    end
    else if (finish) begin
        store_check<=0;
        stall_ls <= 1'b0;
        active <= 1'b0;              // Stop when finish is high
        finish <= 1'b0;
    end
end
   
   always @ (posedge clock) begin
  if (reset) begin
    current_state <= IDLE;
  end 
  else if (active) begin
    current_state <= next_state;
  end
  end

    // Always block for combinational logic (next state logic)
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (reset | finish == 1'b1)
                   next_state = IDLE;
                else
                    next_state = SHIFT_ADDR;
            end

            SHIFT_ADDR: begin //READING ADDRESS
                next_state = SHIFT_ADDR;
                if (imm_reg_r[reg_idx]==1'b1)begin
                    next_state = STALL1;
                end
                else if (reg_idx == 0)
                    next_state = FINISH;                
            end
            
            STALL1: begin
                if (store_check)
                    next_state = STALL2;
                else
                    next_state = STALL3;
            end
            
            STALL2: begin
                    next_state = STALL3;
            end
            
            STALL3: begin
                if(reg_idx == 0 )
                    next_state = FINISH;
                else  begin
                    next_state = SHIFT_ADDR;
                end
            end
            
            FINISH: begin
                    next_state = IDLE ;  // Transition to IDLE if start is low
            end
            
            default: next_state = IDLE;  
        endcase
    end
    
//output sequential logic
    always @(posedge clock) begin
        case (current_state)
            IDLE: begin                
                //ra_base_addr <= data1;
                write_register_out <= 1'b0; 
                if (reset | finish == 1'b1)begin
                   imm_reg_r <= 0;
                end
                else if(load_m_RR | store_m_RR) begin
                    imm_reg_r <= immediate;
                    ra_base_addr_reg <= data1-1; 
               
                end
            end

            SHIFT_ADDR: begin //READING ADDRESS
                if (imm_reg_r[reg_idx]==1'b1)begin //reg_idx update is sequential
                    if (first_1 == 0)begin
                           first_1 <= 1;
                           //write_register_out <= reg_idx;
                    end
                    write_register_out <= reg_idx;         
                    //alu_a <= ra_base_addr_reg;
                end
                reg_idx <= (imm_reg_r[reg_idx] == 1'b1) ? reg_idx : reg_idx - 1; //reg_idx will be decreased here if the imm index value is 0
                ALU_result <= ALU_result_wire;   
                                                                               //otherwise it will get decreased after stalls 
            end
            
            STALL1: begin
                    ra_base_addr_reg <= ALU_result_wire;
                    
                    
            end
            
            STALL2: begin
                    
                    
            end
            
            STALL3: begin
                //stall_l <= 0;
                reg_idx <= reg_idx - 1;
                write_data <= selected_data1; //store instr
            end
            FINISH: begin
                finish <= 1'b1; //to indicate completion of operation
            end
            
            default: begin
                //stall_l <= 0;
                finish <= 1'b0;
                alu_a <= 0;
                reg_idx <= reg_idx;
                write_register_out <= 1'b0; 
            end
        endcase
    end
    
//output combinational logic
    always @(*) begin
        mem_read_out=0;
        mem_to_reg_out=0;
        mem_write_out=0;
        reg_write_out=0;
        stall_l=0;
        sm_reg_select=0;
        case (current_state)
            IDLE: begin
                
                stall_l = 0; 
            end

            SHIFT_ADDR: begin //READING ADDRESS  
                sm_reg_select=1;
                if (imm_reg_r[reg_idx]==1'b1) begin //reg_idx update is sequential
                    stall_l = 1;  
                end
            end
            
            STALL1: begin
                stall_l = 1;
                sm_reg_select=1;
                //to update the value to alu_a
            end
            
            STALL2: begin
                sm_reg_select=1;
                stall_l = 1;
            end
            
            STALL3: begin
                if (~store_check) begin
                mem_read_out=1;    
                mem_to_reg_out=1;
                mem_write_out=0;
                reg_write_out=1;  
                
                end
                
                 if(store_check)begin
                mem_read_out=0;    
                mem_to_reg_out=0;
                mem_write_out=1;
                reg_write_out=0;  
          
                sm_reg_select=1;
                end
                stall_l = 0;
            end
            
            FINISH: begin
                sm_reg_select=0;
            end
            
            default: begin
                stall_l = 0;
                alu_a = 0;
                sm_reg_select=0;
                //reg_idx = reg_idx;
            end
        endcase
    end


//alu u1 (rst,stall_l,alu_a,computed_base_addr); //computes if stall is high
//assign addr_load = computed_base_addr; //this is the address to be loaded for the next cycles
    
    //signals for load instr
 
    assign selected_data2_final = (alu_src) ? intermediate_data2 : selected_data2;
    assign data2_final = (  (funct[2]) & ((alu_op == 3'b010 )|( alu_op == 3'b011)) )? ~(selected_data2_final):(selected_data2_final); //does complement if required
    always@(posedge clock)begin
        if (reset | flush )begin
            PC_jump <= 0;
            branch_out <= 0;
            mem_read_out <= 0;
            mem_to_reg_out <= 0;
            mem_write_out <= 0;
            reg_write_out <= 0;
            write_data <= 0;
            ALU_result <= 0;
            zero <= 0;
            carry <= 0;
            lt <= 0;
            eq <= 0;
            le <= 0;
            write_register_out <= 0;
            jump_out<=0;
        end else if (~load_m_RR&~stall_ls&~store_m_RR) begin
            PC_jump <= CurrentPC + immediate;
            branch_out <= branch_in;
            mem_read_out <= mem_read_in;
            mem_to_reg_out <= mem_to_reg_in;
            mem_write_out <= mem_write_in;
            reg_write_out <= reg_write_in;
            write_data <= data2;     /// changed selected_data2
            ALU_result <= ALU_result_wire;
            zero <= zero_wire;
            carry <= carry_wire;
            lt <= lt_wire;
            eq <= eq_wire;
            le <= le_wire;
            write_register_out <= write_register_in;
            jump_out<=jump_in;
         end
    end

    MUX_2to1 #(.N(16)) MUX_Data2(
        .D0(data2),
        .D1(immediate[15:0]),
        .S0(alu_src),
        .Y(intermediate_data2)
    );

    always@(*)begin
        case(fwd_A)                                     // Source
            2'b00: begin
            selected_data1 = data1;              // ID/EX
            if (stall_ls==1)
                selected_data1 = ra_base_addr_reg;
            end
            2'b01: selected_data1 = wb_write_data;      // MEM/WB
            2'b10: selected_data1 = ex_mem_alu_result;  // EX/MEM
            default: selected_data1 = 16'b0;
        endcase

        casex(fwd_B)                                     // Source    
            2'b00: selected_data2 = intermediate_data2; // ID/EXE
            2'b01: selected_data2 = wb_write_data;      //  MEM/WB
            2'b10: selected_data2 = ex_mem_alu_result;  //  EX/MEM
            default: selected_data2 = 16'b0;
        endcase
    end
  

    ALU_Control ALU_Control(
        .funct(funct),
        .alu_op(alu_op_wire),
        .alu_control(alu_control)
    );

    //assign alu_control = stall_l ? 4'b111: alu_control;
    
    ALU ALU(
        .stall_l(stall_l),
        .data1(selected_data1),
        .data2(data2_final),
        .ALU_control(alu_control),
        .ALU_result(ALU_result_wire),
        .zero(zero_wire),
        .carry(carry_wire),
        .lt(lt_wire),
        .le(le_wire),
        .eq(eq_wire)
    );

endmodule