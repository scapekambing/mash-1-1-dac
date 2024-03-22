/* verilog_format: off */
`resetall
`timescale 1ns / 1ns
`default_nettype none
/* verilog_format: on */

`include "vunit_defines.svh"

module tb_mash11();

  
  integer i;
  integer n_complete_waves = 5;
  integer freq_multiplier = 1;
  real freq = 20e3*freq_multiplier;
  real t_elapsed = 1/freq*n_complete_waves*1e9;
 

  // clock and reset lines
  logic aclk;
  logic arst_n;


  // nco params
  localparam WIDTH = 16;
  localparam LUT_DEPTH = 2**8;
  localparam ACC_FRAC_WIDTH = 24;
  localparam ACC_INT_WIDTH = $clog2(LUT_DEPTH);
  localparam ACC_WIDTH = ACC_INT_WIDTH + ACC_FRAC_WIDTH;

  // nco logic
  logic         [WIDTH-1:0]       tx_data; 
  logic                           tx_data_tvalid;
  logic                           tx_data_tready;
  
  logic         [ACC_WIDTH-1:0]   step;
  logic                           step_enable;

  localparam MASH_BW = 4;
 
  // dsm logic
  logic signed [MASH_BW-1:0] mash_data;
  logic mash_data_tvalid;
  logic mash_data_tready;

  // dsm2 logic
  logic dsm2_data;
  logic dsm2_data_tvalid;
  logic dsm2_data_tready;


  // clock generation
  localparam clk_period = 10;
  always begin
    #(clk_period/2) aclk = ~aclk;
  end

  // nco inst
  unco wave1_gen ( 
    .aclk(aclk),    
    .arst_n(arst_n),

    .phase_shift(32'd0),

    .s_axis_data_tdata(step),    
    .s_axis_data_tvalid(step_enable),
    .dither_enable(1'b0),
   
    .s_axis_data_tready(tx_data_tready),

    .m_axis_data_tdata(tx_data),    
    .m_axis_data_tvalid(tx_data_tvalid)    
  ); 

  // mash inst
  mash11 #(
    .WIDTH(WIDTH),
    .DAC_BW(MASH_BW)
  ) mash11_inst (
    .aclk(aclk),
    .arst_n(arst_n),

    // slave inputs
    .s_axis_data_tdata  (tx_data),
    .s_axis_data_tvalid (tx_data_tvalid),
    
    // slave outputs
    .s_axis_data_tready(mash_data_tready),
    
    // master outputs
    .m_axis_data_tdata(mash_data),
    .m_axis_data_tvalid(mash_data_tvalid)
  );

  mod2 # (
		.WIDTH(MASH_BW)
  ) mod2_inst (
		.aclk(aclk),
		.arst_n(arst_n),
		.s_axis_data_tdata(mash_data),
		.s_axis_data_tvalid(mash_data_tvalid),
		.s_axis_data_tready(dsm2_data_tready),
		.m_axis_data_tdata(dsm2_data),
		.m_axis_data_tvalid(dsm2_data_tvalid)
	);


`TEST_SUITE begin

  // `TEST_CASE("op") begin
  //   // init vals
  //   aclk = 0;
  //   i = 0;
  //   arst_n = 0;
  //   step_enable = 0;
  //   step = 0;

  //   // reset pulse
  //   #(clk_period);
  //   arst_n = 1;
  //   step_enable = 1;
  //   step = 24'd85900;
  //   step = step*freq_multiplier;

  //   // 2khz
  //   while(1) begin
  //     if($time==t_elapsed+clk_period) begin
  //       break;
  //     end
  //     else begin
  //       i = i + 1;
  //       #(clk_period);
  //     end
  //   end

  //   // 8khz
  //   step = step*4;
  //   while(1) begin
  //     if($time==2*t_elapsed+clk_period) begin
  //       break;
  //     end
  //     else begin
  //       i = i + 1;
  //       #(clk_period);
  //     end
  //   end

  // end

  `TEST_CASE("plot") begin
    // init vals
    aclk = 0;
    i = 0;
    arst_n = 0;
    step_enable = 0;
    step = 0;

    // reset pulse
    #(clk_period);
    arst_n = 1;
    step_enable = 1;
    step = (1 << 22); //97KHZ
    // step = 24'd85900;
    // step = step * 20; // 1MHz
    // step = 1'b1 << (32-8-1); 


    while(1) begin
      if($time==2*t_elapsed+clk_period) begin
        break;
      end
      else begin
        $display("%d, %d, %d, %b ", i, tx_data, mash_data, dsm2_data);
        i = i + 1;
        #(clk_period);
      end
    end
  end
    // `CHECK_EQUAL($signed(tx_data), -392);
  end

endmodule

`resetall
