`timescale 1ns/1ps
module testbench_illegal;
  import csr_pkg::*;

  logic clk = 1'b0;
  always #5 clk = ~clk;

  csr_if bus (.clk(clk));

  generic_csr dut (
    .clk          (clk),
    .rst_n        (bus.rst_n),
    .chip_enable  (bus.chip_enable),
    .write_enable (bus.write_enable),
    .read_enable  (bus.read_enable),
    .address      (bus.address),
    .data_in      (bus.data_in),
    .data_out     (bus.data_out)
  );

  initial begin
    @(bus.drv_cb);
    bus.drv_cb.rst_n <= 1'b0;
    repeat (3) @(bus.drv_cb);
    bus.drv_cb.rst_n <= 1'b1;
    @(bus.drv_cb);

    // simultaneous read and write...
    bus.drv_cb.chip_enable  <= 1'b1;
    bus.drv_cb.write_enable <= 1'b1;
    bus.drv_cb.read_enable  <= 1'b1;
    bus.drv_cb.address      <= ADDR_BURST_LEN;
    bus.drv_cb.data_in      <= 8'(BURST_LONG);
    @(bus.drv_cb);

    bus.drv_cb.chip_enable  <= 1'b0;
    bus.drv_cb.write_enable <= 1'b0;
    bus.drv_cb.read_enable  <= 1'b0;
    repeat (2) @(bus.drv_cb);
    $finish;
  end

endmodule : testbench_illegal
