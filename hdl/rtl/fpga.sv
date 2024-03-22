/* verilog_format: off */
`timescale 1ns / 1ns
`default_nettype none
/* verilog_format: on */

module fpga (
    input  tri CLK100MHZ,
    input  tri RST,
    input  tri SW_0,
    output tri upconverter_out
);

  localparam integer MASH_BW = 3;
  localparam integer WIDTH = 16;
  localparam integer LUT_DEPTH = 2 ** 8;
  localparam integer ACC_FRAC_WIDTH = 24;
  localparam integer ACC_INT_WIDTH = $clog2(LUT_DEPTH);
  localparam integer ACC_WIDTH = ACC_INT_WIDTH + ACC_FRAC_WIDTH;

  // frequency control
  var logic    [ACC_WIDTH-1:0] step;
  var logic    [ACC_WIDTH-1:0] step_addr;


  // dsm core
  logic        [    WIDTH-1:0] tx_i_data;
  logic        [    WIDTH-1:0] tx_q_data;

  logic signed [  MASH_BW-1:0] mash_i_data;
  logic signed [  MASH_BW-1:0] mash_q_data;

  logic                        dsm_i_data;
  logic                        dsm_q_data;


  /* 
  * clock generation
  */
  logic                        clk_200mhz_mmcm_out;
  logic                        mmcm_rst = ~RST;
  logic                        mmcm_locked;
  logic                        mmcm_clkfb;
  logic                        clk_100mhz_mmcm_out;
  logic                        rst_100mhz;

  // MMCM instance
  // 100 MHz in, 200 and 100 MHz out
  // PFD range: 10 MHz to 550 MHz
  // VCO range: 600 MHz to 1200 MHz
  // M = 8, D = 1 sets Fvco = 800 MHz (in range)
  // Divide by 4 to get output frequency of 200 MHz
  // Divide by 8 to get output frequency of 100 MHz
  MMCME2_BASE #(
      .BANDWIDTH("OPTIMIZED"),
      .CLKOUT0_DIVIDE_F(4),
      .CLKOUT0_DUTY_CYCLE(0.5),
      .CLKOUT0_PHASE(0),
      .CLKOUT1_DIVIDE(8),
      .CLKOUT1_DUTY_CYCLE(0.5),
      .CLKOUT1_PHASE(0),
      .CLKOUT2_DIVIDE(1),
      .CLKOUT2_DUTY_CYCLE(0.5),
      .CLKOUT2_PHASE(0),
      .CLKOUT3_DIVIDE(1),
      .CLKOUT3_DUTY_CYCLE(0.5),
      .CLKOUT3_PHASE(0),
      .CLKOUT4_DIVIDE(1),
      .CLKOUT4_DUTY_CYCLE(0.5),
      .CLKOUT4_PHASE(0),
      .CLKOUT5_DIVIDE(1),
      .CLKOUT5_DUTY_CYCLE(0.5),
      .CLKOUT5_PHASE(0),
      .CLKOUT6_DIVIDE(1),
      .CLKOUT6_DUTY_CYCLE(0.5),
      .CLKOUT6_PHASE(0),
      .CLKFBOUT_MULT_F(8),
      .CLKFBOUT_PHASE(0),
      .DIVCLK_DIVIDE(1),
      .REF_JITTER1(0.010),
      .CLKIN1_PERIOD(10.0),
      .STARTUP_WAIT("FALSE"),
      .CLKOUT4_CASCADE("FALSE")
  ) clk_mmcm_inst (
      .CLKIN1(CLK100MHZ),
      .CLKFBIN(mmcm_clkfb),
      .RST(mmcm_rst),
      .PWRDWN(1'b0),
      .CLKOUT0(clk_200mhz_mmcm_out),
      .CLKOUT0B(),
      .CLKOUT1(clk_100mhz_mmcm_out),
      .CLKOUT1B(),
      .CLKOUT2(),
      .CLKOUT2B(),
      .CLKOUT3(),
      .CLKOUT3B(),
      .CLKOUT4(),
      .CLKOUT5(),
      .CLKOUT6(),
      .CLKFBOUT(mmcm_clkfb),
      .CLKFBOUTB(),
      .LOCKED(mmcm_locked)
  );

  // LOCKED is dessarted if the input clock stop sor phase alignment is violated
  always_ff @(posedge clk_100mhz_mmcm_out) begin
    if (RST) begin
      rst_100mhz <= 1'b0;
    end else begin
      rst_100mhz <= !mmcm_locked;
    end
  end

  // frequency control
  jtag_axil_adapter #(
      .WIDTH(ACC_WIDTH)
  ) fctrl (
      .aclk(CLK100MHZ),
      .arst_n(RST),
      .m_axil_data(step),
      .m_axil_addr(step_addr)
  );


  // dsm core
  dsm_core #(
      .MASH_BW(MASH_BW),
      .WIDTH(WIDTH),
      .ACC_FRAC_WIDTH(ACC_FRAC_WIDTH),
      .ACC_INT_WIDTH(ACC_INT_WIDTH)
  ) rf_dac (
      .aclk(clk_100mhz_mmcm_out),
      .xclk(clk_200mhz_mmcm_out),
      .rst_n(rst_100mhz),
      .nco_step(step),
      .nco_step_enable(1'b1),
      .dither_enable(SW_0),
      .tx_i_data(tx_i_data),
      .tx_q_data(tx_q_data),
      .mash_i_data(mash_i_data),
      .mash_q_data(mash_q_data),
      .dsm_i_data(dsm_i_data),
      .dsm_q_data(dsm_q_data),
      .upconverter_out(upconverter_out)
  );

endmodule

`resetall
