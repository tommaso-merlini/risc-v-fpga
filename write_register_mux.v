module write_register_mux (
  input [4:0] Rt,
  input [4:0] Rd,
  input RegDst,

  output reg [4:0] write_register
);

always @(*) begin
  if (RegDst == 1) begin
    write_register <= Rd;
  end else begin
    write_register <= Rt;
  end
end

endmodule
