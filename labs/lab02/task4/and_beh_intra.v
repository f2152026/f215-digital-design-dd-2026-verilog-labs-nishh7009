// Behavioral AND gate: inputs are sampled before the delayed assignment.
// For the manual's #1, #2, and #3 experiments, replace 5 with that delay.
// `y = #5 a & b` samples a and b immediately and delays only the write.
// The delayed output is therefore a faithful record of the old input state,
// which can look stale when inputs change faster than the delay.
// Lesson: delayed behavioral combinational code is not interchangeable with
// hardware timing; avoid such delays in functional RTL unless modeling a
// specific simulation effect.
module and_beh_intra (input a, input b, output reg y);
  always @(*) begin
    y = #5 a & b;
  end
endmodule
