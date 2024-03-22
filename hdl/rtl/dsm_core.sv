/* verilog_format: off */
`timescale 1ns / 1ns
`default_nettype none
/* verilog_format: on */

module dsm_core #(
    parameter integer MASH_BW = 5,
    parameter integer WIDTH = 16,
    parameter integer ACC_FRAC_WIDTH = 24,
    parameter integer ACC_INT_WIDTH = 8

) (
    input  tri                                    aclk,
    input  tri                                    xclk,
    input  tri                                    rst_n,
    input  tri [ACC_FRAC_WIDTH+ACC_INT_WIDTH-1:0] nco_step,
    input  tri                                    nco_step_enable,
    input  tri                                    dither_enable,
    output tri [                       WIDTH-1:0] tx_i_data,
    output tri [                       WIDTH-1:0] tx_q_data,
    output tri [                     MASH_BW-1:0] mash_i_data,
    output tri [                     MASH_BW-1:0] mash_q_data,
    output tri                                    dsm_i_data,
    output tri                                    dsm_q_data,
    output tri                                    upconverter_out
);

  // nco logic
  logic tx_i_data_tvalid;
  logic tx_i_data_tready;
  logic tx_q_data_tvalid;
  logic tx_q_data_tready;

  // dsm logic
  logic mash_i_data_tvalid;
  logic mash_i_data_tready;
  logic mash_q_data_tvalid;
  logic mash_q_data_tready;

  // dsm logic
  logic dsm_i_data_tvalid;
  logic dsm_i_data_tready;
  logic dsm_q_data_tvalid;
  logic dsm_q_data_tready;


  // frequency control
  jtag_axil_adapter #(
      .WIDTH(ACC_FRAC_WIDTH + ACC_INT_WIDTH)
  ) fctrl (
      .aclk(aclk),
      .arst_n(rst_n),
      .m_axil_data(nco_step),
      .m_axil_addr()
  );


  // unsigned nco inst
  unco wave_i_gen (
      .aclk(aclk),
      .arst_n(rst_n),
      .phase_shift((32'd64) << ACC_FRAC_WIDTH),
      .dither_enable(dither_enable),
      .s_axis_data_tdata(nco_step),
      .s_axis_data_tvalid(nco_step_enable),
      .s_axis_data_tready(tx_i_data_tready),
      .m_axis_data_tdata(tx_i_data),
      .m_axis_data_tvalid(tx_i_data_tvalid)
  );

  // unsigned nco inst
  unco wave_q_gen (
      .aclk  (aclk),
      .arst_n(rst_n),

      .phase_shift(32'd0),
      .dither_enable(dither_enable),
      .s_axis_data_tdata(nco_step),
      .s_axis_data_tvalid(nco_step_enable),
      .s_axis_data_tready(tx_q_data_tready),
      .m_axis_data_tdata(tx_q_data),
      .m_axis_data_tvalid(tx_q_data_tvalid)
  );

  // mash inst
  mash11 #(
      .WIDTH (WIDTH),
      .DAC_BW(MASH_BW)
  ) dac_i (
      .aclk(aclk),
      .arst_n(rst_n),
      .s_axis_data_tdata(tx_i_data),
      .s_axis_data_tvalid(tx_i_data_tvalid),
      .s_axis_data_tready(mash_i_data_tready),
      .m_axis_data_tdata(mash_i_data),
      .m_axis_data_tvalid(mash_i_data_tvalid)
  );

  // mash inst
  mash11 #(
      .WIDTH (WIDTH),
      .DAC_BW(MASH_BW)
  ) dac_q (
      .aclk(aclk),
      .arst_n(rst_n),
      .s_axis_data_tdata(tx_q_data),
      .s_axis_data_tvalid(tx_q_data_tvalid),
      .s_axis_data_tready(mash_q_data_tready),
      .m_axis_data_tdata(mash_q_data),
      .m_axis_data_tvalid(mash_q_data_tvalid)
  );


  // dsm inst
  mod2 #(
      .WIDTH(MASH_BW)
  ) dsm_i (
      .aclk(aclk),
      .arst_n(rst_n),
      .s_axis_data_tdata(mash_i_data),
      .s_axis_data_tvalid(mash_i_data_tvalid),
      .s_axis_data_tready(dsm_i_data_tready),
      .m_axis_data_tdata(dsm_i_data),
      .m_axis_data_tvalid(dsm_i_data_tvalid)
  );

  mod2 #(
      .WIDTH(MASH_BW)
  ) dsm_q (
      .aclk(aclk),
      .arst_n(rst_n),
      .s_axis_data_tdata(mash_q_data),
      .s_axis_data_tvalid(mash_q_data_tvalid),
      .s_axis_data_tready(dsm_q_data_tready),
      .m_axis_data_tdata(dsm_q_data),
      .m_axis_data_tvalid(dsm_q_data_tvalid)
  );


  // upconverter inst
  upconverter_oserdes upconverter_inst (
      .iclk(aclk),
      .oclk(xclk),
      .rst_n(rst_n),
      .data_i(dsm_i_data),
      .data_q(dsm_q_data),
      .upconverter_out(upconverter_out)
  );

endmodule

`resetall
