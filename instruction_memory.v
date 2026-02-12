module instruction_memory (
    input  [31:0] read_address,
    output [31:0] instruction
);

  reg [31:0] instructions[32];

  initial begin
    $readmemb("data.bin", instructions);
  end

  assign instruction = instructions[read_address];

endmodule
