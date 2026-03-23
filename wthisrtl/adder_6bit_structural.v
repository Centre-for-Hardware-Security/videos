module adder_6bit_structural(
    input clk, input [5:0] a, input [5:0] b,
    input c_in, output [5:0] sum_flopped
);

    wire [4:0] car;
    wire [5:0] sum;
    
    fadd fa0 (.a(a[0]), .b(b[0]), .c_in(c_in), .sum(sum[0]), .c_out(car[0]));
    fadd fa1 (.a(a[1]), .b(b[1]), .c_in(car[0]), .sum(sum[1]), .c_out(car[1]));
    fadd fa2 (.a(a[2]), .b(b[2]), .c_in(car[1]), .sum(sum[2]), .c_out(car[2]));
    fadd fa3 (.a(a[3]), .b(b[3]), .c_in(car[2]), .sum(sum[3]), .c_out(car[3]));
    fadd fa4 (.a(a[4]), .b(b[4]), .c_in(car[3]), .sum(sum[4]), .c_out(car[4]));
    fadd fa5 (.a(a[5]), .b(b[5]), .c_in(car[4]), .sum(sum[5]), .c_out());
    dff dff0 (.clk(clk), .d(sum[0]), .q(sum_flopped[0]));
    dff dff1 (.clk(clk), .d(sum[1]), .q(sum_flopped[1]));
    dff dff2 (.clk(clk), .d(sum[2]), .q(sum_flopped[2]));
    dff dff3 (.clk(clk), .d(sum[3]), .q(sum_flopped[3]));
    dff dff4 (.clk(clk), .d(sum[4]), .q(sum_flopped[4]));
    dff dff5 (.clk(clk), .d(sum[5]), .q(sum_flopped[5]));
endmodule

module dff (
    input clk, input d,
    output reg q
);

always @(posedge clk) begin
    q <= d;
end
endmodule

module fadd(
    input  a, input  b,
    input  c_in, output sum,
    output c_out
);
    // Boolean equations for a full adder
    assign sum = a ^ b ^ c_in;
    assign c_out = (a & b) | (c_in & (a ^ b));
endmodule
