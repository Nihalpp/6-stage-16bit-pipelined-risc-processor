IITB-RISC-25
6-Stage 16-bit Pipelined RISC Processor (Verilog RTL)
🔹 Overview

Designed and implemented a fully functional 16-bit, 6-stage pipelined RISC processor in Verilog with a custom ISA (R, I, J types).

Pipeline Stages:
IF → ID → RR → EX → MEM → WB

The additional RR stage separates decoding from register access, reducing critical path delay.

🔹 Key Features

16-bit datapath

Complete pipeline implementation

Data Forwarding (EX/MEM & MEM/WB)

Load-use hazard detection (1-cycle stall)

8-entry fully associative BTB

2-bit saturating branch prediction

Pipeline stall and flush logic

Carry & Zero flag support

🔹 Instruction Support

Arithmetic: ADA, ADC, ADZ, AWC, ADI
Logical: NDU, NDC, NDZ
Memory: LLI, LW, SW
Control: BEQ, BLE, BLT, JAL, JLR, JRI

🔹 Hazard Handling

Forwarding Unit eliminates most ALU RAW hazards (zero-cycle penalty)

Hazard Detection Unit inserts bubble for load-use hazards

Branch predictor + flush mechanism reduces control penalties

🔹 Tools Used

Verilog RTL • ModelSim/Vivado Simulation • Custom Testbench
