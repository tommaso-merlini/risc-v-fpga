module instruction_control (
    input wire [6:0] Opcode,
    input wire [2:0] Funct3,

    output reg Jalr,
    output reg Jump,
    output reg BranchZero,
    output reg BranchNotZero,
    output reg MemRead,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite,
    output reg [1:0] ALUOp
);

    // RISC-V Opcodes
    localparam OP_RTYPE    = 7'b0110011;  // Register-register ALU
    localparam OP_ITYPE    = 7'b0010011;  // Immediate ALU
    localparam OP_LOAD     = 7'b0000011;  // Load
    localparam OP_STORE    = 7'b0100011;  // Store
    localparam OP_BRANCH   = 7'b1100011;  // Branch
    localparam OP_JAL      = 7'b1101111;  // Jump and Link
    localparam OP_JALR     = 7'b1100111;  // Jump and Link Register
    localparam OP_LUI      = 7'b0110111;  // Load Upper Immediate
    localparam OP_AUIPC    = 7'b0010111;  // Add Upper Immediate to PC

    always @(*) begin
        // Default values
        Jalr         = 1'b0;
        Jump         = 1'b0;
        BranchZero   = 1'b0;
        BranchNotZero= 1'b0;
        MemRead      = 1'b0;
        MemWrite     = 1'b0;
        ALUSrc       = 1'b0;
        RegWrite     = 1'b0;
        ALUOp        = 2'b00;

        case (Opcode)
            // R-type: register-register ALU operations
            // Format: add, sub, and, or, xor, slt, sltu, sll, srl, sra
            OP_RTYPE: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b0;  // Use register value
                ALUOp    = 2'b10; // ALU operation determined by funct3/funct7
            end

            // I-type ALU: immediate ALU operations
            // Format: addi, andi, ori, xori, slti, sltiu, slli, srli, srai
            OP_ITYPE: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;  // Use immediate
                ALUOp    = 2'b10; // ALU operation
            end

            // Load instructions: lb, lh, lw, lbu, lhu
            // Format: lw rd, offset(rs1)
            OP_LOAD: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;  // Use immediate for address calculation
                MemRead  = 1'b1;
                ALUOp    = 2'b00; // Addition for address calculation
            end

            // Store instructions: sb, sh, sw
            // Format: sw rs2, offset(rs1)
            OP_STORE: begin
                ALUSrc   = 1'b1;  // Use immediate for address calculation
                MemWrite = 1'b1;
                ALUOp    = 2'b00; // Addition for address calculation
            end

            // Branch instructions: beq, bne, blt, bge, bltu, bgeu
            OP_BRANCH: begin
                ALUSrc   = 1'b0;  // Use register values for comparison
                ALUOp    = 2'b01; // Subtraction for comparison
                case (Funct3)
                    3'b000:  BranchZero    = 1'b1; // beq
                    3'b001:  BranchNotZero = 1'b1; // bne
                    3'b100:  BranchZero    = 1'b1; // blt (ALU does slt, check if result < 0)
                    3'b101:  BranchNotZero = 1'b1; // bge (check if result >= 0)
                    3'b110:  BranchZero    = 1'b1; // bltu
                    3'b111:  BranchNotZero = 1'b1; // bgeu
                    default: begin
                        BranchZero    = 1'b0;
                        BranchNotZero = 1'b0;
                    end
                endcase
            end

            // Jump and Link: jal
            // Stores PC+4 to rd, jumps to PC + immediate
            OP_JAL: begin
                RegWrite = 1'b1;
                Jump     = 1'b1;
                ALUOp    = 2'b00; // Don't care for ALU
            end

            // Jump and Link Register: jalr
            // Stores PC+4 to rd, jumps to rs1 + immediate
            OP_JALR: begin
                RegWrite = 1'b1;
                Jalr     = 1'b1;
                ALUSrc   = 1'b1;  // Use immediate
                ALUOp    = 2'b00; // Addition for target address
            end

            // Load Upper Immediate: lui
            // Loads immediate into upper 20 bits of rd
            OP_LUI: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 2'b11; // Special: pass immediate through
            end

            // Add Upper Immediate to PC: auipc
            // Adds PC + (immediate << 12) to rd
            OP_AUIPC: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 2'b11; // Special: use PC + immediate
            end

            default: begin
                // NOP or illegal instruction - all control signals remain 0
            end
        endcase
    end

endmodule
