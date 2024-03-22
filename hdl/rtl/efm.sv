/* verilog_format: off */
`timescale 1ns / 1ns
`default_nettype none
/* verilog_format: on */

module efm #(
    parameter integer WIDTH = 16,
    parameter integer EXT = 1,
    parameter integer DAC_BW = WIDTH + EXT
) (
    input tri aclk,
    input tri arst_n,

    input      tri   [WIDTH-1:0] s_axis_data_tdata,
    input      tri               s_axis_data_tvalid,
    output var logic             s_axis_data_tready,

    output var logic             m_axis_data_tdata,
    output var logic [WIDTH-1:0] m_axis_data_terror,
    output var logic             m_axis_data_tvalid
);

  // dsm signals
  var logic [DAC_BW-1:0] sigma;

  // feedback truncation error
  always_ff @(posedge aclk) begin
    if (~arst_n) begin
      sigma <= 32'd0;
      m_axis_data_tvalid <= 1'b0;
    end else if (s_axis_data_tvalid && s_axis_data_tready) begin
      sigma <= s_axis_data_tdata + sigma[DAC_BW-2:0];
      m_axis_data_tvalid <= 1;
    end
  end

  always_comb begin
    s_axis_data_tready = 1;
  end

  always_comb begin
    m_axis_data_tdata  = sigma[DAC_BW-1];
    m_axis_data_terror = sigma[DAC_BW-2:0];
  end

endmodule

`resetall
