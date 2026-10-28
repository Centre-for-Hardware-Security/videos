`timescale 1ns/1ps
module testbench_valid;
  import csr_pkg::*;

  localparam int N = 1000;

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

  logic [7:0] rw_addrs  [2] = '{ADDR_BURST_LEN, ADDR_ENC_MODE};
  logic [7:0] all_addrs [3] = '{ADDR_ID, ADDR_BURST_LEN, ADDR_ENC_MODE};
  logic [1:0] burst = BURST_SHORT;
  logic [1:0] enc   = ENC_PLAIN;

  // last values written on the interface
  logic [1:0] obs_burst, obs_enc;

  always @(bus.mon_cb)
    if (bus.mon_cb.chip_enable && bus.mon_cb.write_enable) begin
      if (bus.mon_cb.address == ADDR_BURST_LEN) obs_burst <= bus.mon_cb.data_in[1:0];
      if (bus.mon_cb.address == ADDR_ENC_MODE)  obs_enc   <= bus.mon_cb.data_in[1:0];
    end

  covergroup cg_modes @(posedge clk);
    cp_burst : coverpoint obs_burst iff (bus.rst_n) {
      bins valid[] = {BURST_SHORT, BURST_AVERAGE, BURST_LONG};
    }
    cp_enc : coverpoint obs_enc iff (bus.rst_n) {
      bins valid[] = {ENC_PLAIN, ENC_HASH, ENC_ECC};
    }
    x_modes : cross cp_burst, cp_enc;
  endgroup

  cg_modes cg = new();

  task automatic do_write(input logic [7:0] a, input logic [1:0] v);
    bus.drv_cb.chip_enable  <= 1'b1;
    bus.drv_cb.write_enable <= 1'b1;
    bus.drv_cb.read_enable  <= 1'b0;
    bus.drv_cb.address      <= a;
    bus.drv_cb.data_in      <= 8'(v);
    @(bus.drv_cb);
    if (a == ADDR_BURST_LEN) burst = v;
    else                     enc   = v;
  endtask

  task automatic do_read(input logic [7:0] a);
    logic [7:0] exp;
    exp = (a == ADDR_ID)        ? ID_VALUE :
          (a == ADDR_BURST_LEN) ? 8'(burst) : 8'(enc);
    bus.drv_cb.chip_enable  <= 1'b1;
    bus.drv_cb.write_enable <= 1'b0;
    bus.drv_cb.read_enable  <= 1'b1;
    bus.drv_cb.address      <= a;
    @(bus.drv_cb);

    fork
      begin
        @(bus.mon_cb);
        if (bus.mon_cb.data_out !== exp)
          $error("read 0x%h: got 0x%h, expected 0x%h", a, bus.mon_cb.data_out, exp);
      end
    join_none
  endtask

  initial begin
    @(bus.drv_cb);
    bus.drv_cb.rst_n <= 1'b0;
    repeat (3) @(bus.drv_cb);
    bus.drv_cb.rst_n <= 1'b1;
    @(bus.drv_cb);

    repeat (N) begin
      do_write(rw_addrs[$urandom_range(0, 1)], 2'($urandom_range(0, 2)));
      do_read(all_addrs[$urandom_range(0, 2)]);
    end

    bus.drv_cb.chip_enable <= 1'b0;
    bus.drv_cb.read_enable <= 1'b0;
    repeat (2) @(bus.drv_cb);
    $display("cg_modes coverage: %0.2f%%", cg.get_coverage());
    $finish;
  end

endmodule : testbench_valid
