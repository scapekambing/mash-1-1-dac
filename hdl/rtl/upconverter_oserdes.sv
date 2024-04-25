/* verilog_format: off */
`timescale 1ns / 1ns
`default_nettype none
/* verilog_format: on */

module upconverter_oserdes (
    input tri iclk,  // same as aclk
    input tri oclk,  // 2x the frequency of aclk
    input tri rst_n,
    input tri data_i,
    input tri data_q,
    output tri upconverter_out
);

  // OSERDES inst
  OSERDESE2 #(
      .DATA_RATE_OQ("DDR"), // double data rate, so to achieve 4x sampling of aclk, xclk must be 2x aclk
      .DATA_RATE_TQ("DDR"),
      .DATA_WIDTH(4),
      .SERDES_MODE("MASTER"),
      .TRISTATE_WIDTH(4),
      .TBYTE_CTL("FALSE"),
      .TBYTE_SRC("FALSE")
  ) upconverter (
      .OQ(upconverter_out),
      .OFB(),
      .TQ(),
      .TFB(),
      .SHIFTOUT1(),
      .SHIFTOUT2(),
      .TBYTEOUT(),
      .CLK(oclk),
      .CLKDIV(iclk),
      .D1(data_i),
      .D2(~data_q),
      .D3(~data_i),
      .D4(data_q),
      .TCE(1'b0),
      .OCE(1'b1),
      .TBYTEIN(1'b0),
      .RST(~rst_n),
      .SHIFTIN1(),
      .SHIFTIN2()
  );

endmodule

`resetall
