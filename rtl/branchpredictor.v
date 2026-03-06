`define INST_SIZE 16
module branchPredictor(
    input clk,
    input rst,
    input flush,
    
    input newEntry,

    input [`INST_SIZE-1:0] programCounter,           //Current PC value 
    input [`INST_SIZE-1:0] ActualBranchTarget,       //Coming from Execute stage , this will be a new entry 


    input [2:0] predictionIndex,                    //Index of value to be updated during writeback; the muxin value
    input       PredictionUpdateNeeded,             //Indicates the branch history field needs an update
    input       BranchTarget_Addr_UpdateNeeded,
    input newHistory,                         //This will tell if branch is taken in execute or not; 1 -> T and 0 -> NT

    output [2:0] BTAindex,                           //Comes back as prediction index 
    output [1:0] predictedValue ,                   //need to check by exec stage what was the prediction as to PC select MUX
    output hit,                                     //There was a cache hit , Goes to PC select MUX

    output [`INST_SIZE-1:0] branchTargetAddress      //If there is a cache hit , this address needs to be loaded

);

    reg [15:0] tagRam [7:0];                        //Ram holding PC values
    reg [15:0] addressRam [7:0];                    //Ram holding BTA
    reg [1:0] historyPredictor [7:0];               //Ram holding branch histories
    wire [7:0] hitMap;                              // each line corresponds to whether there was a hit or not (2 lines 
                                                    // should never 1 together)
    wire [2:0]muxIn;

    wire [1:0] new_current_state_predict,new_current_state;
    //Compare Every tag with PC value for hit 

    tagComparator u0(tagRam[0],programCounter,hitMap[0],rst);
    tagComparator u1(tagRam[1],programCounter,hitMap[1],rst);
    tagComparator u2(tagRam[2],programCounter,hitMap[2],rst);
    tagComparator u3(tagRam[3],programCounter,hitMap[3],rst);
    tagComparator u4(tagRam[4],programCounter,hitMap[4],rst);
    tagComparator u5(tagRam[5],programCounter,hitMap[5],rst);
    tagComparator u6(tagRam[6],programCounter,hitMap[6],rst);
    tagComparator u7(tagRam[7],programCounter,hitMap[7],rst);

    //checks if there is a hit
    hitChecker u14(hitMap,hit);
    
    wire [2:0] randomAddress;
    //NMRU implementation
    reg [2:0] recent_tag_index;
    reg count=0; //to keep track of 1st new entry
    always @(posedge clk) begin
    if (rst)
        recent_tag_index <= 3'b001; // Or some default
    else if (hit)
        recent_tag_index <= muxIn;        
    else if (newEntry & (~count)) begin
        recent_tag_index <= 3'b001;
        count <= 1;
    end
    else if (newEntry)
        recent_tag_index <= randomAddress;
    end


    nmru3 u13(
        newEntry,
        clk,
        rst,
        recent_tag_index,
        randomAddress
    );
    
    //encodes the hitMap to a 3 bit value
    encoder8to3 u8(
        hitMap,
        muxIn);

    assign BTAindex = muxIn;

    //Chooses the address to be read out based on encoded value
    mux8to1 u9(
        addressRam[0],
        addressRam[1],
        addressRam[2],
        addressRam[3],
        addressRam[4],
        addressRam[5],
        addressRam[6],
        addressRam[7],
        muxIn, //3 bit selector
        branchTargetAddress);

    wire [1:0] historyMuxOut;
    //Chooses the prediction to be read out based on encoded value
    mux8to1BP u10(
        historyPredictor[0],
        historyPredictor[1],
        historyPredictor[2],
        historyPredictor[3],
        historyPredictor[4],
        historyPredictor[5],
        historyPredictor[6],
        historyPredictor[7],
        muxIn,
        predictedValue
    );

    
/*    lfsr3 u13(
        newEntry,
        clk,
        rst,
        randomAddress
    );*/
    
    

    //To reset all addresses to zero
    integer i=0;
    always @(posedge clk) begin
        if(rst == 1'b1) begin
            for(i = 0 ; i<8 ; i=i+1)begin
                tagRam[i]=0;
                addressRam[i]=0;
                historyPredictor[i]=0;
            end
        end
    end

    //To Update the Prediction after a hit (3 cycles after)
    always @(negedge clk) begin
        if(PredictionUpdateNeeded == 1'b1)
            historyPredictor[predictionIndex] <= new_current_state; 
        if (BranchTarget_Addr_UpdateNeeded == 1'b1)
            addressRam[predictionIndex] <= ActualBranchTarget;
    end

    //In case of a miss , and it happens to be a branch . We need to enter it into the BP.
    //But we will lose the PC information by the time branch status is known .
    //So we always store the last 3 PC values using a shift register and use if needed
    reg [`INST_SIZE-1:0] ProgramCounterMinus4;
    reg [`INST_SIZE-1:0] ProgramCounterMinus3;
    reg [`INST_SIZE-1:0] ProgramCounterMinus2;
    reg [`INST_SIZE-1:0] ProgramCounterMinus1;

    always @(posedge clk) begin
        if(rst | flush)begin
            ProgramCounterMinus4<=0;
            ProgramCounterMinus3<=0;
            ProgramCounterMinus2<=0;
            ProgramCounterMinus1<=0;
        end
        else begin
            ProgramCounterMinus4<=ProgramCounterMinus3;
            ProgramCounterMinus3<=ProgramCounterMinus2;
            ProgramCounterMinus2<=ProgramCounterMinus1;
            ProgramCounterMinus1<=programCounter;
        end
    end

    //If we want to have a new entry , We need the PC from 3 cycles ago , The 
    // actual branch target and the new history
    always @(negedge clk ) begin
        if(newEntry == 1'b1)begin
            tagRam[randomAddress] <= ProgramCounterMinus4;
            addressRam[randomAddress] <= ActualBranchTarget;
            historyPredictor[randomAddress] <= newHistory;
        end
    end
    
   wire [1:0] predictedValue_update;
   
   mux8to1BP u17(
        historyPredictor[0],
        historyPredictor[1],
        historyPredictor[2],
        historyPredictor[3],
        historyPredictor[4],
        historyPredictor[5],
        historyPredictor[6],
        historyPredictor[7],
        predictionIndex,
        predictedValue_update
    );
    
    //updation of the history bit
    predictionUpdate u15(
    PredictionUpdateNeeded,
    predictedValue_update, //input [1:0]previousState,
    newHistory,  //input actualValue,
    new_current_state_predict//output reg [1:0] currentState
    );
    
    FinalPredictionSelect u16(
    PredictionUpdateNeeded,
    new_current_state_predict, //input [1:0] FSMupdate,
    newEntry, //input newEntry,
    newHistory,  //input latestResult,
    new_current_state //output reg [1:0]finalPrediction
    );

endmodule

module FinalPredictionSelect(
    input PredictionUpdateNeeded,
    input [1:0] FSMupdate,
    input newEntry,
    input latestResult,
    output reg [1:0]finalPrediction
);
    always @* begin
    if(PredictionUpdateNeeded) begin
        if(newEntry==1'b1)begin
            finalPrediction = {1'b0,latestResult};//{2{latestResult}};
        end
        else begin
            finalPrediction = FSMupdate;
        end
    end
    else
        finalPrediction = 2'bzz;
    end
endmodule

//history updation
module predictionUpdate(
    input PredictionUpdateNeeded,
    input [1:0]previousState,
    input actualValue,
    output reg [1:0] currentState
);
    always @(*) begin
        if (PredictionUpdateNeeded) begin
        case (previousState)
           2'b00 :begin
            if(actualValue == 0)
                currentState = 2'b00;
            else 
                currentState = 2'b01;
           end 
            2'b01 :begin
            if(actualValue == 1)
                currentState = 2'b11;
            else 
                currentState = 2'b10;
           end 
            2'b10 :begin
            if(actualValue == 0)
                currentState = 2'b00;
            else 
                currentState = 2'b01;
           end 
            2'b11 :begin
            if(actualValue == 0)
                currentState = 2'b10;
            else 
                currentState = 2'b11;
           end 
            default: 
                currentState = 2'b00;
        endcase
        end
        else
            currentState = 2'bzz;
    end
endmodule

module tagComparator(
    input [`INST_SIZE-1:0] In1,
    input [`INST_SIZE-1:0] In2,
    output reg equal,
    input rst
);
    always @(*) begin
        if (rst)
            equal = 1'b0;
        else begin 
        if(In1 == In2)
            equal = 1'b1;
        else 
            equal = 1'b0;
        end
    end
endmodule


module encoder8to3 (
    input [7:0] in,
    output reg [2:0] out
);

always @(*) begin
    case (in)
        8'b00000001: out = 3'b000;
        8'b00000010: out = 3'b001;
        8'b00000100: out = 3'b010;
        8'b00001000: out = 3'b011;
        8'b00010000: out = 3'b100;
        8'b00100000: out = 3'b101;
        8'b01000000: out = 3'b110;
        8'b10000000: out = 3'b111;
        default: out = 3'bzzz; // invalid input
    endcase
end

endmodule

        
module mux8to1 (
    input [15:0] in0,  // 8-bit input 0
    input [15:0] in1,  // 8-bit input 1
    input [15:0] in2,  // 8-bit input 2
    input [15:0] in3,  // 8-bit input 3
    input [15:0] in4,  // 8-bit input 4
    input [15:0] in5,  // 8-bit input 5
    input [15:0] in6,  // 8-bit input 6
    input [15:0] in7,  // 8-bit input 7
    input [2:0] sel,  // 3-bit selector
    output reg [15:0] out // 8-bit output
);

always @(*) begin
    case (sel)
        3'b000: out = in0;
        3'b001: out = in1;
        3'b010: out = in2;
        3'b011: out = in3;
        3'b100: out = in4;
        3'b101: out = in5;
        3'b110: out = in6;
        3'b111: out = in7;
        default: out = 8'b0;
    endcase
end

endmodule

module mux8to1BP (
    input [1:0] in0,  // 8-bit input 0
    input [1:0] in1,  // 8-bit input 1
    input [1:0] in2,  // 8-bit input 2
    input [1:0] in3,  // 8-bit input 3
    input [1:0] in4,  // 8-bit input 4
    input [1:0] in5,  // 8-bit input 5
    input [1:0] in6,  // 8-bit input 6
    input [1:0] in7,  // 8-bit input 7
    input [2:0] sel,  // 3-bit selector
    output reg [1:0] out // 8-bit output
);

always @(*) begin
    case (sel)
        3'b000: out = in0;
        3'b001: out = in1;
        3'b010: out = in2;
        3'b011: out = in3;
        3'b100: out = in4;
        3'b101: out = in5;
        3'b110: out = in6;
        3'b111: out = in7;
        default: out = 8'b0;
    endcase
end

endmodule


module lfsr3 (
    input newEntry,
    input clk,       // Clock input
    input reset,     // Reset input (synchronous)
    output reg [2:0] out // 3-bit LFSR output
);

// Feedback is XOR of bit positions [2] and [1] (can vary depending on taps chosen)
wire feedback = out[2] ^ out[1];

always @(posedge clk) begin
    if (reset)
        out <= 3'b001; // Initial non-zero seed (cannot be 0 for LFSR)
    else 
        out <= {out[1:0], feedback}; // Shift left and insert feedback bit
end

endmodule

module nmru3 (
    input newEntry,
    input clk,       // Clock input
    input reset,     // Reset input (synchronous)
    input [2:0] recent_tag_index,
    output reg [2:0] out // 3-bit LFSR output
);

always @(*) begin
    if (reset) begin
        out = 3'b001;
    end
    else begin
        out = {recent_tag_index[1],recent_tag_index[0],recent_tag_index[2]^recent_tag_index[1]}; // Shift left and insert feedback bit
    end
end

endmodule


module hitChecker(input [7:0] hitMap,output hit);
    wire w[5:0];
    assign w[0] = hitMap[7] | hitMap [6];
    assign w[1] = hitMap[5] | hitMap [4];
    assign w[2] = hitMap[3] | hitMap [2];
    assign w[3] = hitMap[1] | hitMap [0];
    assign w[4] = w[0] | w[1];
    assign w[5] = w[2] | w[3];
    assign hit = w[4] | w[5];
endmodule
