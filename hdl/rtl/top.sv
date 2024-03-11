module top (
    input  clk,
    input  rst,
    output dac_out
);

  logic arst_n;
  assign arst_n = rst;

  logic aclk;
  assign aclk = clk;

  //////////////////////////////////////////////////////////////////////
  // JTAG AXIL SLAVE to NCO ////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////

  // nco params
  localparam WIDTH = 16;
  localparam LUT_DEPTH = 2 ** 8;
  localparam ACC_FRAC_WIDTH = 24;
  localparam ACC_INT_WIDTH = $clog2(LUT_DEPTH);
  localparam ACC_WIDTH = ACC_INT_WIDTH + ACC_FRAC_WIDTH;

  // nco logic
  logic [    WIDTH-1:0] tx_data;
  logic                 tx_data_tvalid;

  logic [ACC_WIDTH-1:0] var_step;
  logic [ACC_WIDTH-1:0] new_var_step;
  logic [ACC_WIDTH-1:0] ref_step;
  logic                 step_enable;
  assign step_enable = 1'b1;

  // jtag_axil_adapter
  logic [3:0] frequency_selection;
  jtag_axil_adapter #(
      .ADDR_MASK(32'h0)
  ) frequency_selector (
      .aclk       (aclk),
      .arst_n     (arst_n),
      .m_axil_data(frequency_selection),
      .m_axil_addr()
  );

  // jtag_axil_adapter output will be shown through leds 
  // which is related to the frequency of the nco
  // assign LED = SW;
  always_comb begin
    // since these are multiples of 4kHz, we can just use the same cic filter
    case (frequency_selection)
      default: begin
        new_var_step = ref_step * 0;  // 4kHz
      end
      4'b0001: begin
        new_var_step = ref_step * 1;  // 4kHz
      end
      4'b0010: begin
        new_var_step = ref_step * 2;  // 8kHz
      end
      4'b0011: begin
        new_var_step = ref_step * 3;  // 12kHz
      end
      4'b0100: begin
        new_var_step = ref_step * 4;  // 16kHz
      end
      4'b0101: begin
        new_var_step = ref_step * 5;  // 20kHz
      end
      4'b0110: begin
        new_var_step = ref_step * 6;  // 24kHz
      end
      4'b0111: begin
        new_var_step = ref_step * 7;  // 28kHz
      end
      4'b1000: begin
        new_var_step = ref_step * 8;  // 32kHz
      end
      4'b1001: begin
        new_var_step = ref_step * 9;  // 36kHz
      end
      4'b1010: begin
        new_var_step = ref_step * 10;  // 40kHz
      end
      4'b1011: begin
        new_var_step = ref_step * 11;  // 44kHz
      end
      4'b1100: begin
        new_var_step = ref_step * 12;  // 48kHz
      end
      4'b1101: begin
        new_var_step = ref_step * 13;  // 52kHz
      end
      4'b1110: begin
        new_var_step = ref_step * 14;  // 56kHz
      end
      4'b1111: begin
        new_var_step = ref_step * 15;  // 60kHz
      end
    endcase
  end

  // seq logic for NCO phase accumulator
  always_ff @(posedge aclk) begin
    if (~arst_n) begin
      var_step <= 0;
      ref_step <= 0;
    end else begin
      // phase acc steps
      var_step <= new_var_step;
      ref_step <= 32'd85900 * 32;  // 2khz * 10
    end
  end

  // nco inst which will show a variable frequency
  axis_unco wave1_gen (
      .aclk  (aclk),
      .arst_n(arst_n),

      .s_axis_data_tdata (var_step),
      .s_axis_data_tvalid(step_enable),

      .s_axis_data_tready(),

      .m_axis_data_tdata (tx_data),
      .m_axis_data_tvalid(tx_data_tvalid)
  );

  //////////////////////////////////////////////////////////////////////
  // DSM ///////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////


  // MASH DSM
  logic signed [2:0] mash_data;
  logic mash_data_tvalid;

  // dsm2 logic
  logic dsm2_data;
  logic dsm2_data_tvalid;

  // mash inst
  axis_mash11 dac (
      .aclk  (aclk),
      .arst_n(arst_n),

      // slave inputs
      .s_axis_data_tdata (tx_data >> 1),   // to prevent snr overflow
      .s_axis_data_tvalid(tx_data_tvalid),

      // slave outputs
      .s_axis_data_tready(),

      // master outputs
      .m_axis_data_tdata (mash_data),
      .m_axis_data_tvalid(mash_data_tvalid)
  );

  axis_second_order_dsm_dac #(
      .WIDTH(3)
  ) dsm2 (
      .aclk(aclk),
      .arst_n(arst_n),
      .s_axis_data_tdata(mash_data),
      .s_axis_data_tvalid(mash_data_tvalid),
      .s_axis_data_tready(),
      .m_axis_data_tdata(dsm2_data),
      .m_axis_data_tvalid(dsm2_data_tvalid)
  );

  // output of dsm to pmod
  assign dac_out = dsm2_data;

endmodule
