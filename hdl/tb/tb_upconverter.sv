/* verilog_format: off */
`resetall
`timescale 1ns / 1ns
`default_nettype none
/* verilog_format: on */

`include "vunit_defines.svh"

module tb_upconverter ();


  integer i;
  integer n_complete_waves = 5;
  integer freq_multiplier = 1;
  real freq = 20e3 * freq_multiplier;
  real t_elapsed = 1 / freq * n_complete_waves * 1e9;


  // clock and reset lines
  logic aclk;
  logic xclk;
  logic arst_n;

  localparam MASH_BW = 5;

  // nco params
  localparam WIDTH = 16;
  localparam LUT_DEPTH = 2 ** 8;
  localparam ACC_FRAC_WIDTH = 24;
  localparam ACC_INT_WIDTH = $clog2(LUT_DEPTH);
  localparam ACC_WIDTH = ACC_INT_WIDTH + ACC_FRAC_WIDTH;

  // clock generation
  localparam real clk_period = 8;
  always begin
    #(clk_period / 2) aclk = ~aclk;
  end
  always begin
    #(clk_period / 8) xclk = ~xclk;
  end

  /*
  * I CHANNEL
  */

  // nco logic
  logic signed [    WIDTH-1:0] tx_data;
  logic                        tx_data_tvalid;

  logic        [ACC_WIDTH-1:0] step;
  logic                        step_enable;


  // dsm logic
  logic signed [  MASH_BW-1:0] mash_data;
  logic                        mash_data_tvalid;

  // dsm2 logic
  logic                        dsm_data;
  logic                        dsm_data_tvalid;

  // nco inst
  axis_nco wave1_gen (
      .aclk  (aclk),
      .arst_n(arst_n),

      .phase_shift(((1 << (6))) << ACC_FRAC_WIDTH),

      .s_axis_data_tdata (step),
      .s_axis_data_tvalid(step_enable),

      .s_axis_data_tready(tx_data_tready),

      .m_axis_data_tdata (tx_data),
      .m_axis_data_tvalid(tx_data_tvalid)
  );

  mod1 #(
      .WIDTH(WIDTH),
      .EXT  (1)
  ) mod1_i (
      .aclk  (aclk),
      .arst_n(arst_n),

      // slave inputs
      .s_axis_data_tdata (tx_data >>> 2),
      .s_axis_data_tvalid(tx_data_tvalid),

      // slave outputs
      .s_axis_data_tready(dsm_data_tready),

      // master outputs
      .m_axis_data_tdata (dsm_data),
      .m_axis_data_tvalid(dsm_data_tvalid)
  );


  /*
  * Q CHANNEL
  */

  // nco logic
  // logic         [WIDTH-1:0]       tx2_data;
  logic signed [  WIDTH-1:0] tx2_data;
  logic                      tx2_data_tvalid;

  // dsm logic
  logic signed [MASH_BW-1:0] mash2_data;
  logic                      mash2_data_tvalid;

  // dsm2 logic
  logic                      dsm2_data;
  logic                      dsm2_data_tvalid;

  // nco inst
  axis_nco wave2_gen (
      .aclk  (aclk),
      .arst_n(arst_n),

      .phase_shift(32'b0),

      .s_axis_data_tdata (step),
      .s_axis_data_tvalid(step_enable),

      .s_axis_data_tready(tx2_data_tready),

      .m_axis_data_tdata (tx2_data),
      .m_axis_data_tvalid(tx2_data_tvalid)
  );


  mod1 #(
      .WIDTH(WIDTH),
      .EXT  (1)
  ) mod1_q (
      .aclk  (aclk),
      .arst_n(arst_n),

      // slave inputs
      .s_axis_data_tdata (tx2_data >>> 2),
      .s_axis_data_tvalid(tx2_data_tvalid),

      // slave outputs
      .s_axis_data_tready(dsm2_data),

      // master outputs
      .m_axis_data_tdata (dsm2_data),
      .m_axis_data_tvalid(dsm2_data_tvalid)
  );


  var logic upconverter_out;
  upconverter upconverter_inst (
      .clk(xclk),
      .rst_n(arst_n),
      .data_i(dsm_data),
      .data_q(dsm2_data),
      .data_out(upconverter_out)
  );


  // /* verilog format: off*/ 
  `TEST_SUITE begin

    `TEST_CASE("plot") begin
      // init vals
      aclk = 0;
      xclk = 0;
      i = 0;
      arst_n = 0;
      step_enable = 0;
      step = 0;

      // reset pulse
      #(clk_period);
      arst_n = 1;
      step_enable = 1;
      step = (1 << 18); //97KHZ
      //step = 24'd85900;
      // step = step * 20; // 1MHz
      // step = 1'b1 << (32-8-1); 

      while(1) begin
        if($time==2*t_elapsed+clk_period) begin
          break;
        end
        else begin
          $display("%d, %d, %b, %b", i, tx_data, upconverter_out, dsm2_data);
          i = i + 1;
          #(clk_period/4);
        end
      end
      // `CHECK_EQUAL($signed(tx_data), -392);
    end
  end

endmodule

`resetall
