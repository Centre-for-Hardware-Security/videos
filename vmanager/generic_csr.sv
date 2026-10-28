`timescale 1ns/1ps
// generic_csr

module generic_csr
  import csr_pkg::*;
#(
  parameter int ADDRW = 8,
  parameter int DATAW = 8
) (
  input  logic             clk,
  input  logic             rst_n,
  input  logic             chip_enable,
  input  logic             write_enable,
  input  logic             read_enable,
  input  logic [ADDRW-1:0] address,
  input  logic [DATAW-1:0] data_in,
  output logic [DATAW-1:0] data_out
);

  localparam logic [ADDRW-1:0] A_ID        = ADDRW'(ADDR_ID);
  localparam logic [ADDRW-1:0] A_BURST_LEN = ADDRW'(ADDR_BURST_LEN);
  localparam logic [ADDRW-1:0] A_ENC_MODE  = ADDRW'(ADDR_ENC_MODE);

  localparam int               RO_DEPTH    = 20;
  localparam logic [ADDRW-1:0] A_RO_BASE   = ADDRW'(64);
  localparam logic [ADDRW-1:0] A_RO_END    = ADDRW'(64 + RO_DEPTH);

  logic wr_req, rd_req;
  assign wr_req = chip_enable && write_enable;
  assign rd_req = chip_enable && read_enable;

  burst_len_e       burst_len_q;
  enc_mode_e        enc_mode_q;
  logic [DATAW-1:0] rdata;

  logic [DATAW-1:0] ro_mem [RO_DEPTH];
  logic             ro_hit;
  assign ro_hit = (address >= A_RO_BASE) && (address < A_RO_END);

  // read only "memory"
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) ro_mem <= '{default: '0};
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      burst_len_q <= BURST_SHORT;
      enc_mode_q  <= ENC_PLAIN;
    end else if (wr_req) begin
      if (address == A_BURST_LEN &&
          data_in[1:0] inside {BURST_SHORT, BURST_AVERAGE, BURST_LONG})
        burst_len_q <= burst_len_e'(data_in[1:0]);
      if (address == A_ENC_MODE &&
          data_in[1:0] inside {ENC_PLAIN, ENC_HASH, ENC_ECC})
        enc_mode_q <= enc_mode_e'(data_in[1:0]);
    end
  end

  always_comb begin
    rdata = '0;
    if (address == A_ID)             rdata = DATAW'(ID_VALUE);
    else if (address == A_BURST_LEN) rdata = DATAW'(burst_len_q);
    else if (address == A_ENC_MODE)  rdata = DATAW'(enc_mode_q);
    else if (ro_hit)                 rdata = ro_mem[address - A_RO_BASE];
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)      data_out <= '0;
    else if (rd_req) data_out <= rdata;
  end

endmodule : generic_csr
