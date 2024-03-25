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
  var logic signed [DAC_BW-1:0] quantizer_in;

  always_ff @(posedge aclk) begin
    if (~arst_n) begin
      error_z1           <= {(DAC_BW) {1'b0}};
      error_z2           <= {(DAC_BW) {1'b0}};
      m_axis_data_tdata  <= 1'b0;
      m_axis_data_tvalid <= 1'b0;
    end else if (s_axis_data_tvalid && s_axis_data_tready) begin

      // this meant that the quantizer outputted a 1
      if (m_axis_data_tdata == 1'b1) begin
        // subtract 1 since this is the difference between the quantizer output and the input
        error_z1 <= quantizer_in - 1;

        // this meant that the quantizer outputted a 0
        // we subtract 0 since this is the difference beteween the quantizer output and the input
      end else begin
        error_z1 <= quantizer_in - 0;
      end
      error_z2 <= error_z1;

      // we are outpting the sign bit
      // if quantizer_in's MSB is 1 that means we have a negative number, so quantizer outputted a 0
      // if quantizer_in's MSB is 0 that means we have a positive number, so quantizer outputted a 1
      m_axis_data_tdata <= ~quantizer_in[WIDTH-1];
    end
  end

  always_comb begin
    dsm_in_extended = s_axis_data_tdata;
    s_axis_data_tready = 1'b1;
    quantizer_in = dsm_in_extended + 2 * error_z1 - error_z2;
  end

endmodule

`resetall
