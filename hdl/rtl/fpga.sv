module fpga (
    input  CLK100MHZ,
    input  RST,
    output dac_out
);

  top top_inst (
      .clk(CLK100MHZ),
      .rst(RST),
      .dac_out(dac_out)
  );

endmodule
