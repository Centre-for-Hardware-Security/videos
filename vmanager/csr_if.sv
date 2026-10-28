`timescale 1ns/1ps
interface csr_if #(
  parameter int ADDRW = 8,
  parameter int DATAW = 8
) (
  input logic clk
);

  logic             rst_n        = 1'b1;
  logic             chip_enable  = 1'b0;
  logic             write_enable = 1'b0;
  logic             read_enable  = 1'b0;
  logic [ADDRW-1:0] address      = '0;
  logic [DATAW-1:0] data_in      = '0;
  logic [DATAW-1:0] data_out;

  clocking drv_cb @(posedge clk);
    output rst_n, chip_enable, write_enable, read_enable, address, data_in;
  endclocking

  clocking mon_cb @(posedge clk);
    input rst_n, chip_enable, write_enable, read_enable, address, data_in, data_out;
  endclocking

  a_we_re_exclusive: assert property (@(posedge clk)
    !(write_enable && read_enable))
    else $error("write_enable and read_enable assserted!");

endinterface : csr_if
