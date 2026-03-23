module add_acc_split (
    input clk, input rst_n,
    input [5:0] a, input [5:0] b,
    input c_in, input enable_sum, enable_acc,
    output reg [5:0] sum, output reg [12:0] acc
);

    reg [5:0] next_sum; reg [12:0] next_acc;

    always @(*) begin
        next_sum = sum;
	next_acc = acc;
	if (enable_sum) next_sum = a + b + c_in;
        if (enable_acc) next_acc = acc + sum;
    end

    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            sum <= 6'd0;
	    acc <= 13'd0;
        end		
	else begin
	    sum <= next_sum;
	    acc <= next_acc;
        end
    end
endmodule
