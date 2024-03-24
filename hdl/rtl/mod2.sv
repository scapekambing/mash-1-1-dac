/* verilog_format: off */
`timescale 1ns / 1ns
`default_nettype none
/* verilog_format: on */

module mod2 #(
    parameter integer WIDTH = 16,
    parameter integer EXT_ACC_1 = 2,
    parameter integer EXT_ACC_2 = 4
) (
    input tri aclk,
    input tri arst_n,

    input      tri signed [WIDTH-1:0] s_axis_data_tdata,
    input      tri                    s_axis_data_tvalid,
    output var logic                  s_axis_data_tready,

    output var logic m_axis_data_tdata,
    output var logic m_axis_data_tvalid
);

  localparam DAC_BW = WIDTH + 4;

  var logic signed [DAC_BW-1:0] dsm_in_extended;
  var logic signed [DAC_BW-1:0] error_z1;
  var logic signed [DAC_BW-1:0] error_z2;
  var logic signed [DAC_BW-1:0] quantizer;

  always_ff @(posedge aclk) begin
    if (~arst_n) begin
      error_z1           <= {(DAC_BW) {1'b0}};
      error_z2           <= {(DAC_BW) {1'b0}};
      m_axis_data_tdata  <= 1'b0;
      m_axis_data_tvalid <= 1'b0;
    end else if (s_axis_data_tvalid && s_axis_data_tready) begin
      if (m_axis_data_tdata == 1'b1) begin
        error_z1 <= quantizer + ((-1) <<< DAC_BW - 2);
      end else begin
        error_z1 <= quantizer + (1 <<< DAC_BW - 2);
      end
      error_z2 <= error_z1;
      m_axis_data_tdata <= ~quantizer[DAC_BW-1];
      m_axis_data_tvalid <= 1'b1;
    end
  end

  always_comb begin
    dsm_in_extended = s_axis_data_tdata;
    s_axis_data_tready = 1'b1;

    quantizer = error_z1 * 2 - error_z2 + dsm_in_extended;
  end

endmodule

`resetall
