`timescale 1ns / 1ps

module axis_efms # (
	parameter WIDTH = 16,
	parameter EXT = 2
)

(
  input 																aclk      					,
	input																	arst_n			 				,

  input	       [WIDTH-1:0]					 		s_axis_data_tdata		,
	output logic [WIDTH-1:0]				m_axis_data_terror	,
	input 							 									s_axis_data_tvalid	,
	output logic							 						s_axis_data_tready	,
  
	output logic				          				m_axis_data_tdata		,
	output logic													m_axis_data_tvalid
);

	localparam DAC_BW = WIDTH + EXT;
  logic  [DAC_BW-1:0] 			sigma;
	logic  [DAC_BW-1:0] 			error;
	logic  [DAC_BW-1:0] 			dsm_in_extended;
	
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
			

		    sigma <= sigma + error;

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
		dsm_in_extended =  {s_axis_data_tdata[WIDTH-1], s_axis_data_tdata[WIDTH-1], s_axis_data_tdata};
	
		case(m_axis_data_tdata)
			1'b0: begin
				// if the last output was 0, then that means we undershot
				// the desired val, so add the full scale value (exlcude sign)
				error = dsm_in_extended // sigma
									+ (2**(WIDTH-1)); // delta
			end
			1'b1: begin
				// if the last output was 1, then we outputed a more postiive value 
				// then that means we overshot 
				// the desired val, so subtract the full scale value (exlcude sign)
				error = dsm_in_extended // sigma
									- (2**(WIDTH-1)); // delta
			end
		endcase

		m_axis_data_terror = error[WIDTH-1:0];

	end

endmodule
