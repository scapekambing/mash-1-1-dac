/* verilog_format: off */
`timescale 1ns / 1ns
`default_nettype none
/* verilog_format: on */

module jtag_axil_adapter #(
    parameter integer ADDR_MASK = 32'hC,
    parameter integer WIDTH = 32
) (
    input  tri               aclk,
    input  tri               arst_n,
    output tri [WIDTH-1:0] m_axil_data,
    output tri [WIDTH-1:0] m_axil_addr
);

  //Parameters of Axi Slave Bus Interface
  localparam C_S_AXI_DATA_WIDTH = 32;
  localparam C_S_AXI_ADDR_WIDTH = 32;

  tri [    C_S_AXI_ADDR_WIDTH-1 : 0] awaddr;
  tri [                       2 : 0] awprot;
  tri                                awvalid;
  tri                                awready;
  tri [    C_S_AXI_DATA_WIDTH-1 : 0] wdata;
  tri [(C_S_AXI_DATA_WIDTH/8)-1 : 0] wstrb;
  tri                                wvalid;
  tri                                wready;
  tri [                       1 : 0] bresp;
  tri                                bvalid;
  tri                                bready;
  tri [    C_S_AXI_ADDR_WIDTH-1 : 0] araddr;
  tri [                       2 : 0] arprot;
  tri                                arvalid;
  tri                                arready;
  tri [    C_S_AXI_DATA_WIDTH-1 : 0] rdata;
  tri [                       1 : 0] rresp;
  tri                                rvalid;
  tri                                rready;


  jtag_axi_0 jtag_axil_master_inst (
      .aclk         (aclk),
      .aresetn      (arst_n),
      .m_axi_awaddr (awaddr),
      .m_axi_awprot (awprot),
      .m_axi_awvalid(awvalid),
      .m_axi_awready(awready),
      .m_axi_wdata  (wdata),
      .m_axi_wstrb  (wstrb),
      .m_axi_wvalid (wvalid),
      .m_axi_wready (wready),
      .m_axi_bresp  (bresp),
      .m_axi_bvalid (bvalid),
      .m_axi_bready (bready),
      .m_axi_araddr (araddr),
      .m_axi_arprot (arprot),
      .m_axi_arvalid(arvalid),
      .m_axi_arready(arready),
      .m_axi_rdata  (rdata),
      .m_axi_rresp  (rresp),
      .m_axi_rvalid (rvalid),
      .m_axi_rready (rready)
  );

  jtag_axil_slave #(
      .ADDR_MASK(ADDR_MASK),
      .WIDTH(WIDTH)
  ) jtag_axil_slave_inst (
      .s_axi_aclk   (aclk),
      .s_axi_aresetn(arst_n),
      .s_axi_awaddr (awaddr),
      .s_axi_awvalid(awvalid),
      .s_axi_awready(awready),
      .s_axi_wdata  (wdata),
      .s_axi_wvalid (wvalid),
      .s_axi_wready (wready),
      .s_axi_bresp  (bresp),
      .s_axi_bready (bready),
      .s_axi_bvalid (bvalid),
      .s_axi_araddr (araddr),
      .s_axi_arvalid(arvalid),
      .s_axi_arready(arready),
      .s_axi_rdata  (rdata),
      .s_axi_rresp  (rresp),
      .s_axi_rvalid (rvalid),
      .s_axi_rready (rready),
      .data_out     (m_axil_data),
      .addr_out     (m_axil_addr)
  );

endmodule

`resetall
