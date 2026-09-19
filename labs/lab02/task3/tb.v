// Self-checking testbench for the 2-bit unsigned comparator.
module tb;
  reg [1:0] t_a, t_b;
  wire t_gt, t_lt, t_eq;
  reg exp_gt, exp_lt, exp_eq;
  integer i, j, errors;

  comp2 DUT (.A(t_a), .B(t_b), .GT(t_gt), .LT(t_lt), .EQ(t_eq));

  initial begin
    errors = 0;
    for (i = 0; i < 4; i = i + 1) begin
      for (j = 0; j < 4; j = j + 1) begin
        t_a = i[1:0];
        t_b = j[1:0];
        exp_gt = (i > j);
        exp_lt = (i < j);
        exp_eq = (i == j);
        #5;
        if ({t_gt, t_lt, t_eq} !== {exp_gt, exp_lt, exp_eq}) begin
          $display("FAIL at %0t: A=%0d B=%0d got=%b%b%b expected=%b%b%b",
                   $time, i, j, t_gt, t_lt, t_eq, exp_gt, exp_lt, exp_eq);
          errors = errors + 1;
        end
      end
    end
    $write("Comparator summary: %0d/%0d passed", 16 - errors, 16);
    if (errors == 0) $display(" (ALL_COMP2_TESTS_PASSED)");
    else             $display(" (%0d failures)", errors);
    $finish;
  end
endmodule
