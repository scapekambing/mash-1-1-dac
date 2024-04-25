/* verilog_format: off */
`timescale 1ns / 1ns
`default_nettype none
/* verilog_format: on */

module efm2 #(
    parameter integer WIDTH = 3,
    parameter integer EXT   = 0
) (
    input tri aclk,
    input tri arst_n,

    input      tri signed [WIDTH-1:0] s_axis_data_tdata,
    input      tri                    s_axis_data_tvalid,
    output var logic                  s_axis_data_tready,

    output var logic m_axis_data_tdata,
    output var logic m_axis_data_tvalid
);

  var logic signed [WIDTH+EXT-1:0] dsm_in_extended;
  var logic signed [WIDTH+EXT-1:0] dsm_hold_1, next_dsm_hold_1;
  var logic signed [WIDTH+EXT-1:0] dsm_hold_2;
  var logic signed [WIDTH+EXT-1:0] dsm_path;


  // operation
  always_ff @(posedge aclk) begin
    if (~arst_n) begin
      dsm_hold_1         <= {(WIDTH + EXT) {1'b0}};
      dsm_hold_2         <= {(WIDTH + EXT) {1'b0}};
      m_axis_data_tvalid <= 1'b0;
      m_axis_data_tdata  <= 1'b0;

    end else if (s_axis_data_tvalid && s_axis_data_tready) begin

      if (dsm_path > 0) begin
        dsm_hold_1 <= dsm_path - 1;
        m_axis_data_tdata <= 1'b1;
      end else begin
        dsm_hold_1 <= dsm_path;
        m_axis_data_tdata <= 1'b0;
      end
      dsm_hold_2 <= dsm_hold_1;
      m_axis_data_tvalid <= 1'b1;
    end
  end

  always_comb begin
    // axis logic
    s_axis_data_tready = 1;

    // dsm bit extension
    dsm_in_extended = s_axis_data_tdata;
    dsm_path = dsm_in_extended + (dsm_hold_1 * 2) - dsm_hold_2;

  end

endmodule

`resetall
