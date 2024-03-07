`timescale 1ns/1ns

`include "vunit_defines.svh"
`include "../rtl/axis_nco.sv"
`include "../rtl/axis_efms.sv"
`include "../rtl/axis_mash11s.sv"
`include "../rtl/axis_second_order_dsm_dac.sv"

module tb_mash11s();

  integer i;
  integer n_complete_waves = 10;
  integer freq_multiplier = 1;
  real freq = 20e3*freq_multiplier;
  real t_elapsed = 1/freq*n_complete_waves*1e9;
 

  // clock and reset lines
  logic aclk;
  logic arst_n;

  // clock generation
  localparam clk_period = 10;
  always begin
    #(clk_period/2) aclk = ~aclk;
  end



  // nco params
  localparam WIDTH = 16;
  localparam LUT_DEPTH = 2**8;
  localparam ACC_FRAC_WIDTH = 24;
  localparam ACC_INT_WIDTH = $clog2(LUT_DEPTH);
  localparam ACC_WIDTH = ACC_INT_WIDTH + ACC_FRAC_WIDTH;

  // nco logic
  logic signed  [WIDTH-1:0]       tx_data; 
  logic                           tx_data_tvalid;
  
  logic         [ACC_WIDTH-1:0]   step;
  logic                           step_enable;

  // nco inst
  axis_nco wave1_gen ( 
    .aclk(aclk),    
    .arst_n(arst_n),

    .phase_shift(32'd0),

    .s_axis_data_tdata(step),    
    .s_axis_data_tvalid(step_enable),
   
    .s_axis_data_tready(),

    .m_axis_data_tdata(tx_data),    
    .m_axis_data_tvalid(tx_data_tvalid)    
  ); 

  // mash
  localparam MASH_BW = 6;
  logic dsm1_data;
  logic signed [MASH_BW-1:0] mash_data;
  logic mash_data_tvalid;
  axis_mash11s #(
    .WIDTH(WIDTH),
    .DAC_BW(MASH_BW)
  )
  mash ( 
    .aclk(aclk),    
    .arst_n(arst_n),

    .s_axis_data_tdata(tx_data),    
    .s_axis_data_tvalid(tx_data_tvalid),
   
    .s_axis_data_tready(),

    .m_axis_data_tdata( mash_data),    
    .m_axis_data_tvalid(mash_data_tvalid),
    .dsm_data()
  );

      // first order dsm
  axis_efms # (
    .WIDTH(WIDTH)
  )
  dac (
    .aclk(aclk),
    .arst_n(arst_n),

    // slave inputs
    .s_axis_data_tdata  (tx_data),
    .s_axis_data_tvalid (tx_data_tvalid),
    
    // slave outputs
    .s_axis_data_tready(),
    
    // master outputs
    .m_axis_data_tdata(dsm1_data),
    .m_axis_data_tvalid(dsm1_data_tvalid)
  );


  // bit reduction
  logic reduction_data;
  logic reduction_data_tvalid;
  axis_second_order_dsm_dac #(
    .WIDTH(MASH_BW),
    .EXT_ACC_1(2),
    .EXT_ACC_2(8)
  ) dsm (
    .aclk(aclk),
    .arst_n(arst_n),

    // slave inputs
    .s_axis_data_tdata  (mash_data),
    .s_axis_data_tvalid (mash_data_tvalid),
    
    // slave outputs
    .s_axis_data_tready(),
    
    // master outputs
    .m_axis_data_tdata  (reduction_data),
    .m_axis_data_tvalid (reduction_data_tvalid)
  );



`TEST_SUITE begin

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
    step = 24'd85900;
    // step = step * 20; // 1MHz
    // step = 1'b1 << (32-8-1); 

    while(1) begin
      if($time==2*t_elapsed+clk_period) begin
        break;
      end
      else begin
        $display("%d, %d, %b, %d, %b ", i, tx_data, dsm1_data, mash_data, reduction_data);
        i = i + 1;
        #(clk_period);
      end
    end
    // `CHECK_EQUAL($signed(tx_data), -392);
  end

end
endmodule
