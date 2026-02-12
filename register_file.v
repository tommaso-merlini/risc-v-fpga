module register_file (
    input clk, // TODO: implement clock logic
    input rst_n, //TODO: implement reset logic

    input [4:0] read_reg_1,
    input [4:0] read_reg_2,

    input [4:0] write_reg,
    input [31:0] write_data,
    input reg_write,

    output [31:0] read_data_1,
    output [31:0] read_data_2
);


  reg [31:0] registers[32];

  always @(*) begin
    if (reg_write && write_reg != 5'b0) begin
      registers[write_reg] <= write_data;
    end
  end

  assign read_data_1 = (read_reg_1 == 5'b0) ? 32'h0 : registers[read_reg_1];
  assign read_data_2 = (read_reg_2 == 5'b0) ? 32'h0 : registers[read_reg_2];

endmodule
