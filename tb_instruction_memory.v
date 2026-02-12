`timescale 1ns / 1ps

module tb_instruction_memory;

  // Testbench signals
  reg  [31:0] read_address;
  wire [31:0] instruction;

  // Instantiate the DUT (Device Under Test)
  instruction_memory dut (
    .read_address(read_address),
    .instruction(instruction)
  );

  initial begin
    // Display header
    $display("==========================================");
    $display("   Instruction Memory Testbench");
    $display("==========================================");
    $display("Address    | Instruction");
    $display("------------------------------------------");

    // Test read from address 0
    read_address = 32'd0;
    #10;
    $display("0x%08h | 0x%08h", read_address, instruction);

    // Test read from address 1
    read_address = 32'd1;
    #10;
    $display("0x%08h | 0x%08h", read_address, instruction);

    // Test read from address 2
    read_address = 32'd2;
    #10;
    $display("0x%08h | 0x%08h", read_address, instruction);

    // Test read from address 3
    read_address = 32'd3;
    #10;
    $display("0x%08h | 0x%08h", read_address, instruction);

    // Test read from address 31 (last valid address)
    read_address = 32'd31;
    #10;
    $display("0x%08h | 0x%08h", read_address, instruction);

    // Test read from address 32 (out of bounds - returns X)
    read_address = 32'd32;
    #10;
    $display("0x%08h | 0x%08h (out of bounds)", read_address, instruction);

    $display("==========================================");
    $display("Testbench Complete");
    $display("==========================================");
    $finish;
  end

endmodule
