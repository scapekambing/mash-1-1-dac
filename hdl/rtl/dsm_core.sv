`timescale 1ns / 1ns

module dsm_core #(
    parameter integer MASH_BW = 5,
    parameter integer WIDTH = 16,
    parameter integer ACC_FRAC_WIDTH = 24,
    parameter integer ACC_INT_WIDTH = 8

) (
    input aclk,
    input xclk,
    input rst_n,

    input [ACC_FRAC_WIDTH+ACC_INT_WIDTH-1:0] nco_step,
    input                                    nco_step_enable,

    output [WIDTH-1:0] tx_i_data,
    output [WIDTH-1:0] tx_q_data,

    output [MASH_BW-1:0] mash_i_data,
    output [MASH_BW-1:0] mash_q_data,

    output dsm_i_data,
    output dsm_q_data,

    output upconverter_out
);

  // nco logic
  logic tx_i_data_tvalid;
  logic tx_q_data_tvalid;

  // dsm logic
  logic mash_i_data_tvalid;
  logic mash_q_data_tvalid;

  // dsm logic
  logic dsm_i_data_tvalid;
  logic dsm_q_data_tvalid;


  // nco inst
  axis_unco wave_i_gen (
      .aclk  (aclk),
      .arst_n(rst_n),

      .phase_shift((32'd64) << ACC_FRAC_WIDTH),

      .s_axis_data_tdata (nco_step),
      .s_axis_data_tvalid(nco_step_enable),

      .s_axis_data_tready(),

      .m_axis_data_tdata (tx_i_data),
      .m_axis_data_tvalid(tx_i_data_tvalid)
  );

  // nco inst
  axis_unco wave_q_gen (
      .aclk  (aclk),
      .arst_n(rst_n),

      .phase_shift(32'd0),

      .s_axis_data_tdata (nco_step),
      .s_axis_data_tvalid(nco_step_enable),

      .s_axis_data_tready(),

      .m_axis_data_tdata (tx_q_data),
      .m_axis_data_tvalid(tx_q_data_tvalid)
  );

  // mash inst
  axis_mash11 #(
      .WIDTH (WIDTH),
      .DAC_BW(MASH_BW)
  ) dac_i (
      .aclk  (aclk),
      .arst_n(rst_n),

      // slave inputs
      .s_axis_data_tdata (tx_i_data),
      .s_axis_data_tvalid(tx_i_data_tvalid),

      // slave outputs
      .s_axis_data_tready(),

      // master outputs
      .m_axis_data_tdata (mash_i_data),
      .m_axis_data_tvalid(mash_i_data_tvalid)
  );

  // mash inst
  axis_mash11 #(
      .WIDTH (WIDTH),
      .DAC_BW(MASH_BW)
  ) dac_q (
      .aclk  (aclk),
      .arst_n(rst_n),

      // slave inputs
      .s_axis_data_tdata (tx_q_data),
      .s_axis_data_tvalid(tx_q_data_tvalid),

      // slave outputs
      .s_axis_data_tready(),

      // master outputs
      .m_axis_data_tdata (mash_q_data),
      .m_axis_data_tvalid(mash_q_data_tvalid)
  );


  // dsm inst
  axis_second_order_dsm_dac #(
      .WIDTH(MASH_BW)
  ) dsm_i (
      .aclk(aclk),
      .arst_n(rst_n),
      .s_axis_data_tdata(mash_i_data),
      .s_axis_data_tvalid(mash_i_data_tvalid),
      .s_axis_data_tready(),
      .m_axis_data_tdata(dsm_i_data),
      .m_axis_data_tvalid(dsm_i_data_tvalid)
  );

  axis_second_order_dsm_dac #(
      .WIDTH(MASH_BW)
  ) dsm_q (
      .aclk(aclk),
      .arst_n(rst_n),
      .s_axis_data_tdata(mash_q_data),
      .s_axis_data_tvalid(mash_q_data_tvalid),
      .s_axis_data_tready(),
      .m_axis_data_tdata(dsm_q_data),
      .m_axis_data_tvalid(dsm_q_data_tvalid)
  );

  upconverter upconverter_inst (
      .clk(xclk),
      .rst_n(rst_n),
      .data_i(dsm_i_data),
      .data_q(dsm_q_data),
      .data_out(upconverter_out)
  );


endmodule
