`timescale 1ns/1ns

`include "vunit_defines.svh"

module tb_axis_second_order_dsm_dac();

  integer i;
  integer n_complete_waves = 5;
  integer freq_multiplier = 1;
  real freq = 2e3*freq_multiplier;
  real t_elapsed = 1/freq*n_complete_waves*1e9;
 

  // clock and reset lines
  logic aclk;
  logic arst_n;


  // nco params
  localparam SIGN = 1;
  localparam WIDTH = 15 + SIGN;
  localparam ACC_FRAC_WIDTH = 24;
  localparam LUT_DEPTH = 2**8;
  localparam ACC_INT_WIDTH = $clog2(LUT_DEPTH);
  localparam ACC_WIDTH = ACC_INT_WIDTH + ACC_FRAC_WIDTH;

  // nco logic
  logic signed  [WIDTH-1:0]       tx_data; 
  logic                           tx_data_tvalid;

  logic signed  [WIDTH-1:0]       cic_data; 
  logic                           cic_data_tvalid;
  
  logic         [ACC_WIDTH-1:0]   step;
  logic                           step_enable;

  // dsm logic
  logic dsm2_data;
  logic dsm2_data_tvalid;

  // clock generation
  localparam clk_period = 10;
  always begin
    #(clk_period/2) aclk = ~aclk;
  end


  // nco inst
  axis_nco wave1_gen ( 
    .aclk(aclk),    
    .arst_n(arst_n),

    .phase_shift(0),

    .s_axis_data_tdata(step),    
    .s_axis_data_tvalid(step_enable),
   
    .s_axis_data_tready(),

    .m_axis_data_tdata(tx_data),    
    .m_axis_data_tvalid(tx_data_tvalid)    
  ); 

  // first order dsm
  axis_first_order_dsm_dac # (
    .WIDTH(WIDTH),
    .EXT(1)
  )
  axis_first_order_dsm (
    .aclk(aclk),
    .arst_n(arst_n),

    // slave inputs
    .s_axis_data_tdata(tx_data >>> 2),
    .s_axis_data_tvalid(tx_data_tvalid),
    
    // slave outputs
    .s_axis_data_tready(),
    
    // master outputs
    .m_axis_data_tdata(dsm2_data),
    .m_axis_data_tvalid(dsm2_data_tvalid)
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
    // step = 24'd85900;
    step = 1 << 22;
    step = step*freq_multiplier;

    
    while(1) begin
      if($time==2*t_elapsed+clk_period) begin
        break;
      end
      else begin
        $display("%d, %d, %b", i, $signed(tx_data), dsm2_data);
        i = i + 1;
        #(clk_period);
      end
    end
    `CHECK_EQUAL($signed(tx_data), -392);
  end

end
endmodule
