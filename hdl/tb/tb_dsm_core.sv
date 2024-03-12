`timescale 1ns/1ns

`include "vunit_defines.svh"

module tb_dsm_core();

  
  integer i;
  integer n_complete_waves = 5;
  integer freq_multiplier = 1;
  real freq = 80e3*freq_multiplier;
  real t_elapsed = 1/freq*n_complete_waves*1e9;
 

  // clock and reset lines
  logic aclk;
  logic xclk;
  logic rst_n;

  localparam MASH_BW = 3;

  // nco params
  localparam WIDTH = 16;
  localparam LUT_DEPTH = 2**8;
  localparam ACC_FRAC_WIDTH = 24;
  localparam ACC_INT_WIDTH = $clog2(LUT_DEPTH);
  localparam ACC_WIDTH = ACC_INT_WIDTH + ACC_FRAC_WIDTH;


  // dsm logic
  logic dsm_i_data;
  logic dsm_q_data;
  
  logic [WIDTH-1:0] tx_i_data;
  logic [WIDTH-1:0] tx_q_data;

  logic signed [MASH_BW-1:0]  mash_i_data;
  logic signed [MASH_BW-1:0]  mash_q_data;

  logic upconverter_out;
  
  logic         [ACC_WIDTH-1:0]   step;
  logic                           step_enable;

  // clock generation
  localparam clk_period = 8;
  always begin
    #(clk_period/2) aclk = ~aclk;
  end

  always begin
    #(clk_period/8) xclk = ~xclk;
  end

  // dsm core
  dsm_core dsm_core_inst (
    .aclk(aclk),
    .xclk(xclk),
    .rst_n(rst_n),
    .nco_step(step),
    .nco_step_enable(1),
    .tx_i_data(tx_i_data),
    .tx_q_data(tx_q_data),
    .mash_i_data(mash_i_data),
    .mash_q_data(mash_q_data),
    .dsm_i_data(dsm_i_data),
    .dsm_q_data(dsm_q_data),
    .upconverter_out(upconverter_out)
  );


`TEST_SUITE begin

  `TEST_CASE("plot") begin
    // init vals
    aclk = 0;
    xclk = 0;
    i = 0;
    rst_n = 0;
    step_enable = 0;
    step = 0;

    // reset pulse
    #(clk_period);
    rst_n = 1;
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
        $display("%d, %d, %b, %d, %b", i, tx_q_data, upconverter_out, mash_q_data, dsm_q_data);
        i = i + 1;
        #(clk_period/4);
      end
    end
    // `CHECK_EQUAL($signed(tx_data), -392);
  end

end
endmodule
