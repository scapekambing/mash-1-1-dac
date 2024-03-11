module jtag_axil_slave #(

    /////////////////////////////////////
    // ADDR MASK ////////////////////////
    /////////////////////////////////////
    parameter ADDR_MASK = 32'h0

) (
    input               s_axi_aclk,
    input               s_axi_aresetn,
    input        [31:0] s_axi_awaddr,
    input               s_axi_awvalid,
    output logic        s_axi_awready,
    input        [31:0] s_axi_wdata,
    input               s_axi_wvalid,
    output logic        s_axi_wready,
    output       [ 1:0] s_axi_bresp,
    output logic        s_axi_bvalid,
    input               s_axi_bready,
    input        [31:0] s_axi_araddr,
    input               s_axi_arvalid,
    output logic        s_axi_arready,
    output logic [31:0] s_axi_rdata,
    output       [ 1:0] s_axi_rresp,
    output logic        s_axi_rvalid,
    input               s_axi_rready,
    output       [31:0] data_out,
    output       [31:0] addr_out
);

  /////////////////////////////////////
  // WRITE DATA ///////////////////////
  /////////////////////////////////////

  logic addr_done;
  logic data_done;

  // Flip-flops for latching data
  logic [31:0] data_latch;
  logic [31:0] addr_latch;

  /////////////////////////////////////
  // BACKEND //////////////////////////
  /////////////////////////////////////
  assign data_out   = data_latch;
  assign addr_out   = addr_latch;
  assign data_valid = data_done && addr_done;

  // master will assert awvalid
  // so slave must assert awready
  // we deassert if awvalid and awready were previously high
  always @(posedge s_axi_aclk) begin
    if (~s_axi_aresetn || (s_axi_awvalid && s_axi_awready)) begin
      s_axi_awready <= 0;  // should be high 
    end else begin
      if (~s_axi_awready && s_axi_awvalid) begin
        s_axi_awready <= 1;
      end
    end
  end

  // master will assert wvalid 
  // so slave must assert wready
  // we deassert if wvalid and wready were previously high
  always @(posedge s_axi_aclk) begin
    if (~s_axi_aresetn || (s_axi_wvalid && s_axi_wready)) begin
      s_axi_wready <= 0;  // should be high
    end else begin
      if (~s_axi_wready && s_axi_wvalid) begin
        s_axi_wready <= 1;
      end
    end
  end

  // begin handshake
  // ready and valid signals are now on the
  // aw and w channels
  // after the handshake, now slave has
  // awaddr and wdata
  always @(posedge s_axi_aclk) begin
    if (~s_axi_aresetn) begin
      data_latch <= 32'd0;
      addr_latch <= 32'd0;
    end else begin
      if (s_axi_awvalid && s_axi_awready) begin
        addr_latch <= s_axi_awaddr;
      end
      if (s_axi_wvalid && s_axi_wready && (s_axi_awaddr == ADDR_MASK)) begin
        data_latch <= s_axi_wdata;
      end
    end
  end

  // when handshake is complete
  // the valid and ready signals are deasserted above
  // we will also deassert the done signals in the next cycle
  always @(posedge s_axi_aclk) begin
    if (~s_axi_aresetn || (addr_done && data_done)) begin
      addr_done <= 0;
      data_done <= 0;
    end else begin
      if (s_axi_awvalid && s_axi_awready) begin  // Look for addr handshake
        addr_done <= 1;
      end
      if (s_axi_wvalid && s_axi_wready) begin  // Look for data handshake
        data_done <= 1;
      end
    end
  end

  // slave asserts bvalid on the bresp channel 
  // when handshaking is done
  assign s_axi_bresp = 2'd0;  // OKAY
  always @(posedge s_axi_aclk) begin
    if (~s_axi_aresetn || (s_axi_bvalid && s_axi_bready)) begin
      s_axi_bvalid <= 0;
    end else begin
      if (~s_axi_bvalid && (data_done && addr_done)) begin
        s_axi_bvalid <= 1;
      end
    end
  end

  /////////////////////////////////////
  // READ DATA ///////////////////////
  /////////////////////////////////////

  logic [3:0] addr_latch_read;
  always @(posedge s_axi_aclk) begin
    if (~s_axi_aresetn || (s_axi_rvalid && s_axi_rready)) begin
      s_axi_arready <= 0;
      s_axi_rdata   <= 32'd0;
      s_axi_rvalid  <= 0;
    end else begin
      // master wil assert arvalid
      if (s_axi_arvalid) begin
        s_axi_arready <= 1; // slave will assert arready to indicate it can receive address to read from
        addr_latch_read <= s_axi_araddr;
      end else begin
        // deassert s_axi_arready when handshake is complete
        // at the same time, the master will deassert arvalid
        if (s_axi_arready && ~s_axi_arvalid) begin
          s_axi_arready <= 0;
          s_axi_rvalid  <= 1;
          case (addr_latch_read == ADDR_MASK)
            default: s_axi_rdata <= data_latch;
            1'b0: s_axi_rdata <= 32'd0;
          endcase
        end
      end
    end
  end

  // rresp signal
  assign s_axi_rresp = 2'b00;  // OKAY

endmodule
