`timescale 1ns/1ps

module microprocessor_tb;

    // Clock signals
    reg clk1, clk2;
    
    // Instantiate the processor
    microprocessor_32bits uut(
        .clk1(clk1),
        .clk2(clk2)
    );
    
    // Clock generation
    initial begin
        clk1 = 0;
        clk2 = 0;
        forever begin
            #5 clk1 = ~clk1;
            #5 clk2 = ~clk2;
        end
    end
    
    // Test sequence
    initial begin
        // Display header
        $display("\n32-bit Microprocessor Testbench");
        $display("=============================");
        
        // Initialize registers with test values
        initialize_registers();
        
        // Load test program into memory
        load_program();
        
        // Run simulation
        $display("\nStarting simulation...");
        #1000;  // Allow time for execution
        
        // Display results
        display_results();
        
        $finish;
    end
    
    // Task to initialize registers
    task initialize_registers;
        begin
            $display("\nInitializing registers...");
            // Arithmetic test values
            uut.Reg[2] = 10;   // ADD operand 1
            uut.Reg[3] = 20;   // ADD operand 2
            uut.Reg[5] = 50;   // SUB operand 1
            uut.Reg[6] = 15;   // SUB operand 2
            uut.Reg[8] = 4;    // MUL operand 1
            uut.Reg[9] = 5;    // MUL operand 2
            
            // Logical test values
            uut.Reg[11] = 8'b1100_1100;  // AND operand 1
            uut.Reg[12] = 8'b1010_1010;  // AND operand 2
            uut.Reg[14] = 8'b1100_1100;  // OR operand 1
            uut.Reg[15] = 8'b1010_1010;  // OR operand 2
        end
    endtask
    
    // Task to load program into memory
    task load_program;
        begin
            $display("\nLoading test program...");
            // Instruction format: {opcode(6), rs(5), rt(5), rd(5), shamt(5), funct(6)}
            
            // ADD R1 = R2 + R3
            uut.Mem[0] = {6'b000000, 5'd2, 5'd3, 5'd1, 5'd0, 6'b100000};
            
            // SUB R4 = R5 - R6
            uut.Mem[1] = {6'b000000, 5'd5, 5'd6, 5'd4, 5'd0, 6'b100010};
            
            // MUL R7 = R8 * R9
            uut.Mem[2] = {6'b000000, 5'd8, 5'd9, 5'd7, 5'd0, 6'b011000};
            
            // AND R10 = R11 & R12
            uut.Mem[3] = {6'b000000, 5'd11, 5'd12, 5'd10, 5'd0, 6'b100100};
            
            // OR R13 = R14 | R15
            uut.Mem[4] = {6'b000000, 5'd14, 5'd15, 5'd13, 5'd0, 6'b100101};
            
            // HLT (custom opcode)
            uut.Mem[5] = {6'b111111, 26'd0};
            
            $display("Program loaded with 6 instructions");
        end
    endtask
    
    // Task to display results
    task display_results;
        begin
            $display("\nExecution Results:");
            $display("-----------------");
            $display("ADD: R1 = R2 + R3 = %d + %d = %d", 
                    uut.Reg[2], uut.Reg[3], uut.Reg[1]);
            $display("SUB: R4 = R5 - R6 = %d - %d = %d", 
                    uut.Reg[5], uut.Reg[6], uut.Reg[4]);
            $display("MUL: R7 = R8 * R9 = %d * %d = %d", 
                    uut.Reg[8], uut.Reg[9], uut.Reg[7]);
            $display("AND: R10 = R11 & R12 = %b & %b = %b", 
                    uut.Reg[11], uut.Reg[12], uut.Reg[10]);
            $display("OR:  R13 = R14 | R15 = %b | %b = %b", 
                    uut.Reg[14], uut.Reg[15], uut.Reg[13]);
            
            $display("\nStatus Flags:");
            $display("Zero Flag:    %b", uut.ZF);
            $display("Sign Flag:    %b", uut.SF);
            $display("Carry Flag:   %b", uut.CF);
            $display("Overflow Flag: %b", uut.OF);
        end
    endtask
    
endmodule