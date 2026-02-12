module tb_register_file;
  reg clk, rst_n, reg_write;
  reg [4:0] read_reg_1, read_reg_2, write_reg;
  reg [31:0] write_data;
  wire [31:0] read_data_1, read_data_2;

  register_file uut (.*);

  always #5 clk = ~clk;

  initial begin
    clk = 0;
    rst_n = 0;
    reg_write = 0;

    #10 rst_n = 1;

    write_reg  = 5'd1;
    write_data = 32'hDEADBEEF;
    reg_write  = 1;
    #10 reg_write = 0;
    read_reg_1 = 5'd1;
    #10 $display("Reg1 = %h (expected DEADBEEF)", read_data_1);

    write_reg  = 5'd0;
    write_data = 32'hFFFFFFFF;
    reg_write  = 1;
    #10 reg_write = 0;
    read_reg_1 = 5'd0;
    #10 $display("Reg0 = %h (expected 00000000)", read_data_1);

    $finish;
  end
endmodule
