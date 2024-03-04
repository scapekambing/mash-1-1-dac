module jtag_axil_adapter # (
    ADDR_MASK = 32'hC
)(
    input                  aclk,
    input                arst_n,
    output [3:0]    m_axil_data,
    output [3:0]    m_axil_addr
);

  logic [3:0] jtag_axil_data;
  assign m_axil_data = jtag_axil_data[3:0];

  logic [3:0] jtag_axil_addr;
  assign m_axil_addr = jtag_axil_addr[3:0];

  
  //Parameters of Axi Slave Bus Interface
  localparam integer C_S_AXI_DATA_WIDTH  = 31    ;
  localparam integer C_S_AXI_ADDR_WIDTH  = 31    ;
  
  wire [C_S_AXI_ADDR_WIDTH-1 : 0]     awaddr    ;
  wire [2 : 0]                        awprot    ;
  wire                                awvalid   ;
  wire                                awready   ;
  wire [C_S_AXI_DATA_WIDTH-1 : 0]     wdata     ;
  wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] wstrb     ;
  wire                                wvalid    ;
  wire                                wready    ;
  wire [1 : 0]                        bresp     ;
  wire                                bvalid    ;
  wire                                bready    ;
  wire [C_S_AXI_ADDR_WIDTH-1 : 0]     araddr    ;
  wire [2 : 0]                        arprot    ; 
  wire                                arvalid   ;
  wire                                arready   ;
  wire [C_S_AXI_DATA_WIDTH-1 : 0]     rdata     ;
  wire [1 : 0]                        rresp     ;
  wire                                rvalid    ;
  wire                                rready    ;
  

  jtag_axi_0 jtag_axil_master_inst (
    .aclk           ( aclk          ),
    .aresetn        ( arst_n        ),
    .m_axi_awaddr   ( awaddr        ),
    .m_axi_awprot   ( awprot        ),
    .m_axi_awvalid  ( awvalid       ),
    .m_axi_awready  ( awready       ),
    .m_axi_wdata    ( wdata         ),
    .m_axi_wstrb    ( wstrb         ),
    .m_axi_wvalid   ( wvalid        ),
    .m_axi_wready   ( wready        ),
    .m_axi_bresp    ( bresp         ),
    .m_axi_bvalid   ( bvalid        ),
    .m_axi_bready   ( bready        ),
    .m_axi_araddr   ( araddr        ),
    .m_axi_arprot   ( arprot        ),
    .m_axi_arvalid  ( arvalid       ),
    .m_axi_arready  ( arready       ),
    .m_axi_rdata    ( rdata         ),
    .m_axi_rresp    ( rresp         ),
    .m_axi_rvalid   ( rvalid        ),
    .m_axi_rready   ( rready        )
  );
  
  jtag_axil_slave #(
    .ADDR_MASK(ADDR_MASK)
  )
  jtag_axil_slave_inst (
    .s_axi_aclk    ( aclk             ),
    .s_axi_aresetn ( arst_n           ),
    .s_axi_awaddr  ( awaddr           ),
    .s_axi_awvalid ( awvalid          ),
    .s_axi_awready ( awready          ),
    .s_axi_wdata   ( wdata            ),
    .s_axi_wvalid  ( wvalid           ),
    .s_axi_wready  ( wready           ),
    .s_axi_bresp   ( bresp            ),
    .s_axi_bready  ( bready           ),
    .s_axi_bvalid  ( bvalid           ),
    .s_axi_araddr  ( araddr           ),
    .s_axi_arvalid ( arvalid          ),
    .s_axi_arready ( arready          ),
    .s_axi_rdata   ( rdata            ),
    .s_axi_rresp   ( rresp            ),
    .s_axi_rvalid  ( rvalid           ),
    .s_axi_rready  ( rready           ),
    .data_out      ( jtag_axil_data   ),
    .addr_out      ( jtag_axil_addr   )
  );

endmodule