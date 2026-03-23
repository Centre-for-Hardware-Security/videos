module adder_6bit_rtl (
    input clk, input [5:0] a, input [5:0] b,
    input c_in, output reg [5:0] sum
);

    always @(posedge clk) begin
        sum <= a + b + c_in;
	// cout version would be like this:
	// {c_out, sum} <= a + b + c_in;
    end
	
endmodule
