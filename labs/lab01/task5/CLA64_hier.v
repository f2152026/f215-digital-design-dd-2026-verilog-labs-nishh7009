// cla64_hier.v
// BONUS -- open-ended. No detailed scaffold is provided; this is meant to
// be a genuine design exercise. Not required for lab submission.
//
// You will likely need to modify cla4.v (or add signals alongside it) so
// that block-generate/block-propagate summaries of its own Gi, Pi signals
// are exposed as outputs, since the second-level lookahead unit below
// needs them. As with every module in this lab from Task 2 onward, every
// gate/assign you add should carry an explicit delay.
//
// Starting point (from Tutorial 3, Q4(d)):
//   - Reuse 16 four-bit CLA blocks (your cla4.v) -- their internal logic
//     doesn't change.
//   - For each block k, define:
//       Gblk_k = "this block produces a carry regardless of its incoming
//                 carry" -- a Boolean function of that block's own 4
//                 bit-level Gi, Pi signals.
//       Pblk_k = "an incoming carry sails straight through this whole
//                 block" -- likewise a function of its own Gi, Pi.
//   - Build a second-level lookahead unit -- structurally identical to
//     cla4.v, just one level up -- that computes each block's carry-in
//     directly from Gblk_0..Gblk_15, Pblk_0..Pblk_15, and cin, instead of
//     rippling block to block.
//
// To test this, wire it into dut.v as a fourth option (copy the pattern
// used for the other three) and run it through the same tb.v. Compare
// your final delay to cla64_blocked.v from Task 4.

module cla64_hier(
  input  [63:0] a,
  input  [63:0] b,
  input         cin,
  output [63:0] sum,
  output        cout
);

  // TODO: your hierarchical design goes here.

  // --- bit-level propagate/generate for all 64 bits ---
  wire [63:0] p, g;
  genvar i;
  generate
    for (i = 0; i < 64; i = i + 1) begin : gen_pg
      xor #(2) (p[i], a[i], b[i]);
      and #(2) (g[i], a[i], b[i]);
    end
  endgenerate

  // --- first-level block summaries: Pblk_k and Gblk_k for each 4-bit block ---
  wire [15:0] Pblk, Gblk;
  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_blk_pg
      wire tg1, tg2, tg3;
      // Pblk_k = p3 . p2 . p1 . p0   (carry sails straight through)
      and #(2) (Pblk[i], p[4*i+3], p[4*i+2], p[4*i+1], p[4*i]);
      // Gblk_k = g3 + p3.g2 + p3.p2.g1 + p3.p2.p1.g0   (block generates a carry)
      and #(2) (tg1, p[4*i+3], g[4*i+2]);
      and #(2) (tg2, p[4*i+3], p[4*i+2], g[4*i+1]);
      and #(2) (tg3, p[4*i+3], p[4*i+2], p[4*i+1], g[4*i]);
      or  #(2) (Gblk[i], g[4*i+3], tg1, tg2, tg3);
    end
  endgenerate

  // --- second-level lookahead unit: each block's carry-in computed directly ---
  // C[k] is the carry into block k;  C[0] = cin,  cout = C[16].
  wire [16:0] C;
  assign C[0] = cin;
  assign #(2) C[1] = (Gblk[0]) | (Pblk[0] & cin);
  assign #(2) C[2] = (Gblk[1]) | (Gblk[0] & Pblk[1]) | (Pblk[0] & Pblk[1] & cin);
  assign #(2) C[3] = (Gblk[2]) | (Gblk[1] & Pblk[2]) | (Gblk[0] & Pblk[1] & Pblk[2]) | (Pblk[0] & Pblk[1] & Pblk[2] & cin);
  assign #(2) C[4] = (Gblk[3]) | (Gblk[2] & Pblk[3]) | (Gblk[1] & Pblk[2] & Pblk[3]) | (Gblk[0] & Pblk[1] & Pblk[2] & Pblk[3]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & cin);
  assign #(2) C[5] = (Gblk[4]) | (Gblk[3] & Pblk[4]) | (Gblk[2] & Pblk[3] & Pblk[4]) | (Gblk[1] & Pblk[2] & Pblk[3] & Pblk[4]) | (Gblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & cin);
  assign #(2) C[6] = (Gblk[5]) | (Gblk[4] & Pblk[5]) | (Gblk[3] & Pblk[4] & Pblk[5]) | (Gblk[2] & Pblk[3] & Pblk[4] & Pblk[5]) | (Gblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5]) | (Gblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & cin);
  assign #(2) C[7] = (Gblk[6]) | (Gblk[5] & Pblk[6]) | (Gblk[4] & Pblk[5] & Pblk[6]) | (Gblk[3] & Pblk[4] & Pblk[5] & Pblk[6]) | (Gblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6]) | (Gblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6]) | (Gblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & cin);
  assign #(2) C[8] = (Gblk[7]) | (Gblk[6] & Pblk[7]) | (Gblk[5] & Pblk[6] & Pblk[7]) | (Gblk[4] & Pblk[5] & Pblk[6] & Pblk[7]) | (Gblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7]) | (Gblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7]) | (Gblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7]) | (Gblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & cin);
  assign #(2) C[9] = (Gblk[8]) | (Gblk[7] & Pblk[8]) | (Gblk[6] & Pblk[7] & Pblk[8]) | (Gblk[5] & Pblk[6] & Pblk[7] & Pblk[8]) | (Gblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8]) | (Gblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8]) | (Gblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8]) | (Gblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8]) | (Gblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & cin);
  assign #(2) C[10] = (Gblk[9]) | (Gblk[8] & Pblk[9]) | (Gblk[7] & Pblk[8] & Pblk[9]) | (Gblk[6] & Pblk[7] & Pblk[8] & Pblk[9]) | (Gblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9]) | (Gblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9]) | (Gblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9]) | (Gblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9]) | (Gblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9]) | (Gblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & cin);
  assign #(2) C[11] = (Gblk[10]) | (Gblk[9] & Pblk[10]) | (Gblk[8] & Pblk[9] & Pblk[10]) | (Gblk[7] & Pblk[8] & Pblk[9] & Pblk[10]) | (Gblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10]) | (Gblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10]) | (Gblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10]) | (Gblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10]) | (Gblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10]) | (Gblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10]) | (Gblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & cin);
  assign #(2) C[12] = (Gblk[11]) | (Gblk[10] & Pblk[11]) | (Gblk[9] & Pblk[10] & Pblk[11]) | (Gblk[8] & Pblk[9] & Pblk[10] & Pblk[11]) | (Gblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11]) | (Gblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11]) | (Gblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11]) | (Gblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11]) | (Gblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11]) | (Gblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11]) | (Gblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11]) | (Gblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & cin);
  assign #(2) C[13] = (Gblk[12]) | (Gblk[11] & Pblk[12]) | (Gblk[10] & Pblk[11] & Pblk[12]) | (Gblk[9] & Pblk[10] & Pblk[11] & Pblk[12]) | (Gblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12]) | (Gblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12]) | (Gblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12]) | (Gblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12]) | (Gblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12]) | (Gblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12]) | (Gblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12]) | (Gblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12]) | (Gblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & cin);
  assign #(2) C[14] = (Gblk[13]) | (Gblk[12] & Pblk[13]) | (Gblk[11] & Pblk[12] & Pblk[13]) | (Gblk[10] & Pblk[11] & Pblk[12] & Pblk[13]) | (Gblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13]) | (Gblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13]) | (Gblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13]) | (Gblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13]) | (Gblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13]) | (Gblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13]) | (Gblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13]) | (Gblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13]) | (Gblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13]) | (Gblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & cin);
  assign #(2) C[15] = (Gblk[14]) | (Gblk[13] & Pblk[14]) | (Gblk[12] & Pblk[13] & Pblk[14]) | (Gblk[11] & Pblk[12] & Pblk[13] & Pblk[14]) | (Gblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14]) | (Gblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14]) | (Gblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14]) | (Gblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14]) | (Gblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14]) | (Gblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14]) | (Gblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14]) | (Gblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14]) | (Gblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14]) | (Gblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14]) | (Gblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & cin);
  assign #(2) C[16] = (Gblk[15]) | (Gblk[14] & Pblk[15]) | (Gblk[13] & Pblk[14] & Pblk[15]) | (Gblk[12] & Pblk[13] & Pblk[14] & Pblk[15]) | (Gblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15]) | (Gblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15]) | (Gblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15]) | (Gblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15]) | (Gblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15]) | (Gblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15]) | (Gblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15]) | (Gblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15]) | (Gblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15]) | (Gblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15]) | (Gblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15]) | (Gblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15]) | (Pblk[0] & Pblk[1] & Pblk[2] & Pblk[3] & Pblk[4] & Pblk[5] & Pblk[6] & Pblk[7] & Pblk[8] & Pblk[9] & Pblk[10] & Pblk[11] & Pblk[12] & Pblk[13] & Pblk[14] & Pblk[15] & cin);
  assign cout = C[16];

  // --- 16 four-bit CLA blocks, each fed its precomputed carry-in ---
  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_blocks
      cla4 BLK (.a(a[4*i+3 -: 4]), .b(b[4*i+3 -: 4]), .cin(C[i]),
                .sum(sum[4*i+3 -: 4]), .cout());
    end
  endgenerate

endmodule
