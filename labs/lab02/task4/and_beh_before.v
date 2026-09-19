// Behavioral AND gate: inputs are sampled after the delay has elapsed.
// For the manual's #1, #2, and #3 experiments, replace 5 with that delay.
// `#5 y = a & b` waits first, then samples a and b.  While the always block
// is waiting it cannot respond to additional input changes, so fast changes
// can be missed.  Its result can consequently reflect a later input state,
// rather than the state that triggered this evaluation.
module and_beh_before (input a, input b, output reg y);
  always @(*) begin
    #5 y = a & b;
  end
endmodule
