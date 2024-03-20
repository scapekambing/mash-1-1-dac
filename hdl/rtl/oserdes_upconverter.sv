`timescale 1ns / 1ps

module oserdes_upconverter (
    input    iclk, // same as aclk
    input    oclk, // 2x the frequency of aclk
    input    rst_n,
    input    data_i,
    input    data_q,
    output   upconverter_out
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
      .TCE(1'b1),
      .OCE(1'b1),
      .TBYTEIN(1'b0),
      .RST(~rst_n),
      .SHIFTIN1(),
      .SHIFTIN2()
  );

endmodule
