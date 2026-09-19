// Self-checking testbench for both ALU operations.
module tb;
  reg [3:0] t_a, t_b;
  reg t_op;
  wire [3:0] t_result;
  reg [3:0] expected;
  integer a_value, b_value, op_value, errors;

  alu DUT (.a(t_a), .b(t_b), .op(t_op), .result(t_result));

  initial begin
    errors = 0;
    for (a_value = 0; a_value < 16; a_value = a_value + 1) begin
      for (b_value = 0; b_value < 16; b_value = b_value + 1) begin
        for (op_value = 0; op_value < 2; op_value = op_value + 1) begin
          t_a = a_value[3:0];
          t_b = b_value[3:0];
          t_op = op_value[0];
          expected = t_op ? (t_a - t_b) : (t_a + t_b);
          #1;
          if (t_result !== expected) begin
            $display("FAIL: op=%b a=%0d b=%0d got=%0d expected=%0d",
                     t_op, t_a, t_b, t_result, expected);
            errors = errors + 1;
          end
        end
      end
    end
    if (errors == 0) $display("ALL_ALU_TESTS_PASSED (512/512)");
    else             $display("ALU failures: %0d", errors);
    $finish;
  end
endmodule
