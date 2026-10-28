package csr_pkg;

  localparam logic [7:0] ADDR_ID        = 8'h00;  // RO
  localparam logic [7:0] ADDR_BURST_LEN = 8'hA0;  // RW
  localparam logic [7:0] ADDR_ENC_MODE  = 8'hC0;  // RW

  localparam logic [7:0] ID_VALUE = 8'hBE;

  typedef enum logic [1:0] {
    BURST_SHORT   = 2'd0,
    BURST_AVERAGE = 2'd1,
    BURST_LONG    = 2'd2
  } burst_len_e;

  typedef enum logic [1:0] {
    ENC_PLAIN = 2'd0,
    ENC_HASH  = 2'd1,
    ENC_ECC   = 2'd2
  } enc_mode_e;

endpackage : csr_pkg
