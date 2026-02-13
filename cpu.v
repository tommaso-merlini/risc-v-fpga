module cpu();
reg [31:0] pc = 0;
wire [31:0] instr;

wire [31:0] r_1;
wire [31:0] r_2;

reg clk = 0;
reg rst_n = 0;

//INSTRUCTION CONTROL SIGNALS
wire RegWrite;
wire ALUSrc;
wire [1:0] ALUOp;

always #5 clk = ~clk;

instruction_memory im (
    .read_address(pc),
    .instruction(instr)
);

instruction_control ic (
    .Opcode(instr[6:0]),
    .Funct3(instr[14:12]),
    .RegWrite(RegWrite),
    .ALUSrc(ALUSrc),
    .ALUOp(ALUOp)
);

register_file rf (
    .clk(clk),
    .rst_n(rst_n),
    .read_reg_1(instr[19:15]),
    .read_reg_2(instr[24:20]),
    .write_reg(instr[11:7]),
    .write_data(pc), // TODO: connect ALU result
    .enable_write(RegWrite),
    .read_data_1(r_1),
    .read_data_2(r_2)
);

// Expected instruction values for assertions
reg [31:0] expected_instr [0:4];
initial begin
    expected_instr[0] = 32'h00500093; // ADDI x1, x0, 5
    expected_instr[1] = 32'h00300113; // ADDI x2, x0, 3
    expected_instr[2] = 32'h002081b3; // ADD x3, x1, x2
    expected_instr[3] = 32'h00a00213; // ADDI x4, x0, 10
    expected_instr[4] = 32'h004182b3; // ADD x5, x3, x4
end

initial begin
    #10 rst_n = 1;

    repeat (5) begin
        @(posedge clk);

        // ASSERTION: Check instruction matches expected
        if (instr !== expected_instr[pc]) begin
            $display("ERROR: PC=%0d, instr=0x%08x, expected=0x%08x", pc, instr, expected_instr[pc]);
            $display("FAILED: Instruction mismatch at PC %0d", pc);
        end else begin
            $display("PASS: PC=%0d, instr=0x%08x matches expected", pc, instr);
        end

        // ASSERTION: Check opcode for I-type (0010011) or R-type (0110011)
        if (instr[6:0] !== 7'b0010011 && instr[6:0] !== 7'b0110011) begin
            $display("ERROR: Invalid opcode %07b at PC %0d", instr[6:0], pc);
        end

        // ASSERTION: Check RegWrite is high for these ALU instructions
        if (RegWrite !== 1'b1) begin
            $display("ERROR: RegWrite should be 1 for ALU instructions at PC %0d", pc);
        end

        // ASSERTION: Check ALUSrc based on instruction type
        if (instr[6:0] == 7'b0010011 && ALUSrc !== 1'b1) begin  // I-type should use immediate
            $display("ERROR: ALUSrc should be 1 for I-type at PC %0d", pc);
        end
        if (instr[6:0] == 7'b0110011 && ALUSrc !== 1'b0) begin  // R-type should use register
            $display("ERROR: ALUSrc should be 0 for R-type at PC %0d", pc);
        end

        // ASSERTION: Check ALUOp for ALU operations
        if (ALUOp !== 2'b10) begin
            $display("ERROR: ALUOp should be 10 for ALU operations at PC %0d", pc);
        end

        $display("  opcode: %07b, funct3: %03b, rd=x%0d, rs1=x%0d, rs2=x%0d",
                 instr[6:0], instr[14:12], instr[11:7], instr[19:15], instr[24:20]);
        $display("  RegWrite: %b, ALUSrc: %b, ALUOp: %02b", RegWrite, ALUSrc, ALUOp);
        $display("  r1: %h, r2: %h", r_1, r_2);
        $display("========================");
        pc = pc + 1;
    end

    $display("\n=== ALL ASSERTIONS COMPLETED ===");
    $finish;
end

endmodule
