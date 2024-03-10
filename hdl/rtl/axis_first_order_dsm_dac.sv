`timescale 1ns / 1ps

module axis_first_order_dsm_dac # (
	parameter WIDTH = 16,
	parameter EXT = 1
)

(
  input 																aclk      					,
	input																	arst_n			 				,

  input	signed [WIDTH-1:0]					 		s_axis_data_tdata		,
	input 							 									s_axis_data_tvalid	,
	output logic							 						s_axis_data_tready	,
  
	output logic				          				m_axis_data_tdata		,
	output logic													m_axis_data_tvalid
);

	localparam DAC_BW = WIDTH + EXT;
  logic signed [DAC_BW-1:0] 			sigma;
	logic signed [DAC_BW-1:0] 			dsm_in_extended;
	
	// axis
	logic en;

	// operation
  always_ff @(posedge aclk) begin
		if (~arst_n) begin
			sigma								<= {(DAC_BW){1'b0}};
			m_axis_data_tdata 	<= 1'b0;
			m_axis_data_tvalid	<= 1'b0;
		end
		else if (en) begin
				if(m_axis_data_tdata == 1'b1) begin
						// if the last output was 1, then we outputed a more postiive value 
						// then that means we overshot 
						// the desired val, so subtract the full scale value (exlcude sign)
						sigma <= sigma + dsm_in_extended // sigma
											- (2**(WIDTH-2)); // delta
				end
				else begin
						// if the last output was 0, then that means we undershot
						// the desired val, so add the full scale value (exlcude sign)
						sigma <= sigma + dsm_in_extended // sigma
											+ (2**(WIDTH-2)-1); // delta
				end

				// output ~MSB
				// since we are using signed arithmetic, a 1 MSB corresponds to 0 unsigned
				// and a 0 MSB corresponds to 1 unsigned
				m_axis_data_tdata = ~sigma[DAC_BW-1];

				m_axis_data_tvalid <= 1;
			end 
	end

	always_comb begin
		// axis logic
		s_axis_data_tready = 1;
		en = s_axis_data_tvalid && s_axis_data_tready;
	
		// dsm bit extension
		dsm_in_extended = s_axis_data_tdata;
	end

endmodule