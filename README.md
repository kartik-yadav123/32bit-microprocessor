# 32bit-microprocessor

📌 Overview

This project implements a 32-bit MIPS Processor using Verilog HDL, designed based on the classical MIPS architecture. The processor supports basic instruction execution, including arithmetic, logical, memory, and control operations.

The design follows a modular approach, making it easy to understand, simulate, and extend for advanced features like pipelining or hazard handling.

🚀 Features
32-bit RISC architecture
Supports key MIPS instruction types:
R-type (ADD, SUB, AND, OR, SLT)
I-type (LW, SW, BEQ)
J-type (JUMP)
ALU with multiple operations
Register File (32 registers)
Instruction Memory & Data Memory
Control Unit for instruction decoding
Program Counter (PC) logic
Modular and scalable design
🏗️ Architecture

The processor consists of the following main blocks:

Program Counter (PC) – Holds address of next instruction
Instruction Memory – Stores program instructions
Control Unit – Generates control signals
Register File – 32 general-purpose registers
ALU (Arithmetic Logic Unit) – Performs operations
Data Memory – Used for load/store instructions
MUXes & Adders – Control data flow
🔄 Data Flow
PC fetches instruction from Instruction Memory
Instruction is decoded by Control Unit
Register File provides operands
ALU performs operation
Memory access (if required)
Result written back to register
