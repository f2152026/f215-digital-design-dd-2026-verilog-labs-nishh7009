// Dataflow AND gate with a five-time-unit continuous-assignment delay.
// For the manual's #1, #2, and #3 experiments, replace 5 with that delay.
// A continuous assignment is an inertial delay: an input change must persist
// for the entire delay to appear at y.  It therefore rejects short pulses,
// but never evaluates a stale input value.
module and_df (input a, input b, output y);
  assign #5 y = a & b;
endmodule
