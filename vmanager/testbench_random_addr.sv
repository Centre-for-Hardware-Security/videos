`timescale 1ns/1ps
module testbench_random_addr;
  import csr_pkg::*;

  localparam int N = 40;

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

  logic [7:0] regs [3] = '{ADDR_ID, ADDR_BURST_LEN, ADDR_ENC_MODE};

  covergroup cg_addr @(posedge clk);
    cp_addr : coverpoint bus.address iff (bus.rst_n && bus.chip_enable && bus.read_enable) {
      bins        id        = {ADDR_ID};
      bins        burst_len = {ADDR_BURST_LEN};
      bins        enc_mode  = {ADDR_ENC_MODE};
      bins        ro[]      = {[8'h40:8'h53]};
      ignore_bins invalid   = {[8'h01:8'h3F], [8'h54:8'h9F], [8'hA1:8'hBF], [8'hC1:8'hFF]};
    }
  endgroup

  cg_addr cg = new();

  task automatic do_read(input logic [7:0] a);
    bus.drv_cb.chip_enable  <= 1'b1;
    bus.drv_cb.write_enable <= 1'b0;
    bus.drv_cb.read_enable  <= 1'b1;
    bus.drv_cb.address      <= a;
    @(bus.drv_cb);
  endtask

  initial begin
    int unsigned n;

    @(bus.drv_cb);
    bus.drv_cb.rst_n <= 1'b0;
    repeat (3) @(bus.drv_cb);
    bus.drv_cb.rst_n <= 1'b1;
    @(bus.drv_cb);

    // 0-2: ID/BURST_LEN/ENC_MODE, 3-22: read-only region 0x40-0x53
    repeat (N) begin
      n = $urandom_range(0, 22);
      do_read((n < 3) ? regs[n] : 8'(64 + n - 3));
    end

    bus.drv_cb.chip_enable <= 1'b0;
    bus.drv_cb.read_enable <= 1'b0;
    repeat (2) @(bus.drv_cb);
    $display("cg_addr coverage: %0.2f%%", cg.get_coverage());
    $finish;
  end

endmodule : testbench_random_addr
