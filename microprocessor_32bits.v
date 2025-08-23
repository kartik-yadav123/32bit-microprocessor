module microprocessor_32bits(clk1, clk2);

input clk1, clk2; 
reg ZF;
reg SF;
reg CF;
reg OF; 


reg [31:0] PC, IF_ID_IR, IF_ID_NPC;
reg [31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm;
reg [2:0]  ID_EX_type, EX_MEM_type, MEM_WB_type;
reg [31:0] EX_MEM_IR, EX_MEM_ALUOut, EX_MEM_B;
reg        EX_MEM_cond;
reg [31:0] MEM_WB_IR, MEM_WB_ALUOut, MEM_WB_LMD;

reg [31:0] Reg [0:31];   
reg [31:0] Mem [0:1023]; 

// Opcodes
parameter ADD   = 6'b000000, SUB   = 6'b000001, AND   = 6'b000010, OR    = 6'b000011,
          SLT   = 6'b000100, MUL   = 6'b000101, HLT   = 6'b111111,
          LW    = 6'b100000, SW    = 6'b100001, ADDI  = 6'b100010,
          SUBI  = 6'b100011, SLTI  = 6'b100100, BNEQZ = 6'b100101,
          BEQZ  = 6'b100110, SLL   = 6'b000111, SRL   = 6'b001000,
          SRA   = 6'b001001, ANDI  = 6'b001010, ORI   = 6'b001011,
          XORI  = 6'b001100, XOR   = 6'b001101, SEQ   = 6'b001110,
          SNE   = 6'b001111;

// Instruction Types
parameter RR_ALU=3'b000, RM_ALU=3'b001, LOAD=3'b010, STORE=3'b011, 
          BRANCH=3'b100, HALT=3'b101;

reg HALTED;        
reg TAKEN_BRANCH;  



// IF Stage
always @(posedge clk1)
begin
    if (HALTED == 0)
    begin
        
        TAKEN_BRANCH <= #2 1'b0;

        if (((EX_MEM_IR[31:26] == BEQZ) && (EX_MEM_cond == 1)) ||
            ((EX_MEM_IR[31:26] == BNEQZ) && (EX_MEM_cond == 0)))
        begin
            IF_ID_IR   <= #2 Mem[EX_MEM_ALUOut];
            IF_ID_NPC  <= #2 EX_MEM_ALUOut + 1;
            PC         <= #2 EX_MEM_ALUOut + 1;
            TAKEN_BRANCH <= #2 1'b1; 
        end
        else
        begin
            IF_ID_IR   <= #2 Mem[PC];
            IF_ID_NPC  <= #2 PC + 1;
            PC         <= #2 PC + 1;
        end
    end
end


// ID Stage
always @(posedge clk2)
begin
    if (HALTED == 0)
    begin
        if (IF_ID_IR[25:21] == 5'b00000)
            ID_EX_A <= 0;
        else
            ID_EX_A <= #2 Reg[IF_ID_IR[25:21]];

        if (IF_ID_IR[20:16] == 5'b00000)
            ID_EX_B <= 0;
        else
            ID_EX_B <= #2 Reg[IF_ID_IR[20:16]];

        ID_EX_NPC  <= #2 IF_ID_NPC;
        ID_EX_IR   <= #2 IF_ID_IR;
        ID_EX_Imm  <= #2 {{16{IF_ID_IR[15]}}, IF_ID_IR[15:0]};

        case (IF_ID_IR[31:26])
            ADD, SUB, AND, OR, SLT, MUL, XOR, SEQ, SNE, SLL, SRL, SRA:
                ID_EX_type <= #2 RR_ALU;

            ADDI, SUBI, SLTI, ANDI, ORI, XORI:
                ID_EX_type <= #2 RM_ALU;

            LW:    ID_EX_type <= #2 LOAD;
            SW:    ID_EX_type <= #2 STORE;
            BNEQZ, BEQZ: ID_EX_type <= #2 BRANCH;
            HLT:   ID_EX_type <= #2 HALT;
            default: ID_EX_type <= #2 HALT;
        endcase
    end
end


// EX Stage
always @(posedge clk1)
begin
    if (HALTED == 0)
    begin
        EX_MEM_type <= #2 ID_EX_type;
        EX_MEM_IR   <= #2 ID_EX_IR;

        

        case (ID_EX_type)
            RR_ALU: begin
                case (ID_EX_IR[31:26])
                    ADD:  EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_B;
                    SUB:  EX_MEM_ALUOut <= #2 ID_EX_A - ID_EX_B;
                    AND:  EX_MEM_ALUOut <= #2 ID_EX_A & ID_EX_B;
                    OR:   EX_MEM_ALUOut <= #2 ID_EX_A | ID_EX_B;
                    XOR:  EX_MEM_ALUOut <= #2 ID_EX_A ^ ID_EX_B;
                    SLT:  EX_MEM_ALUOut <= #2 ID_EX_A < ID_EX_B;
                    MUL:  EX_MEM_ALUOut <= #2 ID_EX_A * ID_EX_B;
                    SEQ:  EX_MEM_ALUOut <= #2 (ID_EX_A == ID_EX_B);
                    SNE:  EX_MEM_ALUOut <= #2 (ID_EX_A != ID_EX_B);
                    SLL:  EX_MEM_ALUOut <= #2 ID_EX_B << ID_EX_IR[10:6];
                    SRL:  EX_MEM_ALUOut <= #2 ID_EX_B >> ID_EX_IR[10:6];
                    SRA:  EX_MEM_ALUOut <= #2 $signed(ID_EX_B) >>> ID_EX_IR[10:6];
                    default: EX_MEM_ALUOut <= #2 32'hxxxxxxxx;
                endcase
            end

            RM_ALU: begin
                case (ID_EX_IR[31:26])
                    ADDI: EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_Imm;
                    SUBI: EX_MEM_ALUOut <= #2 ID_EX_A - ID_EX_Imm;
                    SLTI: EX_MEM_ALUOut <= #2 ID_EX_A < ID_EX_Imm;
                    ANDI: EX_MEM_ALUOut <= #2 ID_EX_A & ID_EX_Imm;
                    ORI:  EX_MEM_ALUOut <= #2 ID_EX_A | ID_EX_Imm;
                    XORI: EX_MEM_ALUOut <= #2 ID_EX_A ^ ID_EX_Imm;
                    default: EX_MEM_ALUOut <= #2 32'hxxxxxxxx;
                endcase
            end

            LOAD, STORE: begin
                EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_Imm;
                EX_MEM_B      <= #2 ID_EX_B;
            end

            BRANCH: begin
                EX_MEM_ALUOut <= #2 ID_EX_NPC + ID_EX_Imm;
                EX_MEM_cond   <= #2 (ID_EX_A == 0);
            end
        endcase
    end
end

// MEM Stage
always @(posedge clk2)
begin
    if (HALTED == 0)
    begin
        MEM_WB_type <= #2 EX_MEM_type;
        MEM_WB_IR   <= #2 EX_MEM_IR;

        case (EX_MEM_type)
            RR_ALU, RM_ALU: MEM_WB_ALUOut <= #2 EX_MEM_ALUOut;
            LOAD:           MEM_WB_LMD    <= #2 Mem[EX_MEM_ALUOut];
            STORE: if (TAKEN_BRANCH == 0)
                        Mem[EX_MEM_ALUOut] <= #2 EX_MEM_B;
        endcase
    end
end



// WB Stage
// WB Stage
always @(posedge clk1)
begin
    // Default flag values to prevent latch warnings
    ZF <= #2 ZF; 
    SF <= #2 SF;
    CF <= #2 CF;
    OF <= #2 OF;

    if (TAKEN_BRANCH == 0)
    begin
        case (MEM_WB_type)
            RR_ALU: begin
                Reg[MEM_WB_IR[15:11]] <= #2 MEM_WB_ALUOut;

                ZF <= #2 (MEM_WB_ALUOut == 0);
                SF <= #2 MEM_WB_ALUOut[31];

                case (MEM_WB_IR[31:26])
                    ADD: begin
                        CF <= #2 (MEM_WB_ALUOut < ID_EX_A); 
                        OF <= #2 ((ID_EX_A[31] == ID_EX_B[31]) && (MEM_WB_ALUOut[31] != ID_EX_A[31]));
                    end
                    SUB: begin
                        CF <= #2 (ID_EX_A < ID_EX_B); 
                        OF <= #2 ((ID_EX_A[31] != ID_EX_B[31]) && (MEM_WB_ALUOut[31] != ID_EX_A[31]));
                    end
                    default: begin
                        CF <= #2 0;
                        OF <= #2 0;
                    end
                endcase
            end

            RM_ALU: begin
                Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_ALUOut;

                ZF <= #2 (MEM_WB_ALUOut == 0);
                SF <= #2 MEM_WB_ALUOut[31];
                CF <= #2 0; 
                OF <= #2 0;
            end

            LOAD: begin
                Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_LMD;

                ZF <= #2 (MEM_WB_LMD == 0);
                SF <= #2 MEM_WB_LMD[31];
                CF <= #2 0;
                OF <= #2 0;
            end

            HALT: HALTED <= #2 1'b1;
        endcase
    end
end


endmodule
