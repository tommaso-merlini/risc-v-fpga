module instruction_control(
  input  [5:0] instr_ctrl,
  output [7:0] control
);

assign control[0] = instr_ctrl[0];

endmodule
