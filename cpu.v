module cpu();
  reg  [31:0] pc = 0;
  wire [31:0] instr;

  wire [31:0] r_1;
  wire [31:0] r_2;
  wire [7:0]  ctrl;
  wire [4:0] w_reg;

  reg clk = 0;
  reg rst_n = 0;

  always #5 clk = ~clk;

  instruction_memory im (
    .read_address(pc),
    .instruction(instr)
  );

  instruction_control ic (
    .instr_ctrl(instr[31:26]),
    .control(ctrl)
  );

  write_register_mux wrm (.Rt(instr[20:16]), .Rd(instr[15:11]), .RegDst(ctrl[7]), .write_register(w_reg));

  register_file rf (
    .clk(clk),
    .rst_n(rst_n),
    .read_reg_1(instr[25:21]),
    .read_reg_2(instr[20:16]),
    .write_reg(w_reg),
    .write_data(pc),      // TODO: connect ALU result
    .enable_write(ctrl[0]),
    .read_data_1(r_1),
    .read_data_2(r_2)
  );

  initial begin
    #10 rst_n = 1;

    repeat (3) begin
      @(posedge clk);
      $display("pc:  %0d", pc);
      $display("instr: %b", instr);
      $display("ctrl: %b", ctrl);
      $display("write_register: %b", w_reg);
      $display("enable write: %b", ctrl[0]);
      $display("RegDst: %b", ctrl[7]);
      $display("r1: %h", r_1);
      $display("r2: %h", r_2);
      $display("========================");
      pc = pc + 1;
    end

    $finish;
  end

endmodule
