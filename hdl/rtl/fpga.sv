module fpga (
  input                 CLK100MHZ,
  input                 RST,
  output                jc[6],  
);

  top top_inst (
    .clk(CLK100MHZ),
    .rst(RST),
    .dac_out(jc[6])
  );

endmodule
