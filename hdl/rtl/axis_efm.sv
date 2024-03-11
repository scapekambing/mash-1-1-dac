`timescale 1ns / 1ps

module axis_efm #(
    parameter WIDTH = 16,
    parameter EXT   = 1
) (
    input aclk,
    input arst_n,

    input        [WIDTH-1:0] s_axis_data_tdata,
    input                    s_axis_data_tvalid,
    output logic             s_axis_data_tready,

    output logic             m_axis_data_tdata,
    output logic [WIDTH-1:0] m_axis_data_terror,
    output logic             m_axis_data_tvalid
);

  localparam DAC_BW = WIDTH + EXT;

  // dsm signals
  var  logic [DAC_BW-1:0]    sigma;
  logic en;

  // operation
  always_ff @(posedge aclk) begin
    if (~arst_n) begin
      sigma <= 0;
      m_axis_data_tvalid <= 1'b0;
    end else if (en) begin
      // feedback truncation error
      sigma <= s_axis_data_tdata + sigma[DAC_BW-2:0];
      m_axis_data_tvalid <= 1;
    end
  end

  always_comb begin
    // axis logic
    s_axis_data_tready = 1;
    en = s_axis_data_tvalid && s_axis_data_tready;
  end

  always_comb begin
    m_axis_data_tdata  = sigma[DAC_BW-1];
    m_axis_data_terror = sigma[DAC_BW-2:0];
  end

endmodule
