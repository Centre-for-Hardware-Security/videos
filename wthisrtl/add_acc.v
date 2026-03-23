
module add_acc(
    input clk, input rst_n,
    input [5:0] a, input [5:0] b,
    input c_in, input enable_sum, enable_acc,
    output reg [5:0] sum, output reg [12:0] acc
);

    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            sum <= 6'd0;
	    acc <= 13'd0;
        end		
	else begin
            if (enable_sum)
                sum <= a + b + c_in;
            if (enable_acc)
                acc <= acc + sum;
        end
    end
endmodule
