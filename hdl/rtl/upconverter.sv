`timescale 1ns / 1ps

module upconverter (
  input    clk,
  input    rst_n,
  input    data_i,
  input    data_q,
  output logic data_out
);

  var logic [1:0] xcvr_out;

  always_ff @(posedge clk) begin
    if (~rst_n) begin
      xcvr_out <= 0;
			data_out <= 0; 
    end
    else begin
      case (xcvr_out)
        default: begin
          data_out <= data_i;
          xcvr_out <= 1;
        end
        1: begin
          data_out <= ~data_q;
          xcvr_out <= 2;
        end
        2: begin 
          data_out <= ~data_i;
          xcvr_out <= 3;
        end
        3: begin 
          data_out <= data_q;
          xcvr_out <= 0;
        end
      endcase
    end
  end

endmodule
