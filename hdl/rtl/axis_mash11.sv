`timescale 1ns / 1ps

module axis_mash11 # (
	parameter WIDTH = 16,
	parameter DAC_BW = 3
)

(
  input 																aclk      					,
	input																	arst_n			 				,

  input	[WIDTH-1:0]					 						s_axis_data_tdata		,
	input 							 									s_axis_data_tvalid	,
	output logic							 						s_axis_data_tready	,
  
	output logic signed [DAC_BW-1:0] 			m_axis_data_tdata		,
	output logic													m_axis_data_tvalid
);

  // dsm1 signals
	logic  								dsm1_data;
	logic  [WIDTH-1: 0] 	dsm1_error;
	logic 								dsm1_data_tvalid;

	// dsm2 signals
	logic  								dsm2_data;
	logic  [WIDTH-1: 0] 	dsm2_error;
	logic 								dsm2_data_tvalid;

	// mash signals
	logic signed [DAC_BW-1:0] mash11;
	logic signed [DAC_BW-1:0] dsm2_data_signed_delayed,  dsm1_data_signed, dsm2_data_signed;
	
	logic en;

	axis_efm # (
    .WIDTH(WIDTH)
  )
  dsm1 (
    .aclk(aclk),
    .arst_n(arst_n),

    // slave inputs
    .s_axis_data_tdata  (s_axis_data_tdata),
    .s_axis_data_tvalid (s_axis_data_tvalid),
    
    // slave outputs
    .s_axis_data_tready(),
    
    // master outputs
    .m_axis_data_tdata(dsm1_data),
		.m_axis_data_terror(dsm1_error),
    .m_axis_data_tvalid(dsm1_data_tvalid)
  );

	axis_efm # (
    .WIDTH(WIDTH)
  )
  dsm2 (
    .aclk(aclk),
    .arst_n(arst_n),

    // slave inputs
    .s_axis_data_tdata  (dsm1_error),
    .s_axis_data_tvalid (dsm1_data_tvalid),
    
    // slave outputs
    .s_axis_data_tready(),
    
    // master outputs
    .m_axis_data_tdata(dsm2_data),
		.m_axis_data_terror(dsm2_error),
    .m_axis_data_tvalid(dsm2_data_tvalid)
  );

  always_ff @(posedge aclk) begin
		if (~arst_n) begin
			mash11 <= 0;
			dsm2_data_signed_delayed 	<= 0;
			m_axis_data_tvalid	<= 1'b0;	
		end
		else if (en) begin
			dsm2_data_signed_delayed 	<= dsm2_data_signed;
			mash11 <= dsm1_data + dsm2_data - dsm2_data_signed_delayed;
			m_axis_data_tvalid <= 1;
		end
	end

	always_comb begin
		// axis logic
		s_axis_data_tready = 1;
		en = s_axis_data_tvalid && s_axis_data_tready;

		// sign extension logic
		dsm1_data_signed = dsm1_data;
		dsm2_data_signed = dsm2_data;

		// hookup to output
		m_axis_data_tdata = mash11;
	end

endmodule