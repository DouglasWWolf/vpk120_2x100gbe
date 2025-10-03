// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// -------------------------------------------------------------------------------

`timescale 1 ps / 1 ps

(* BLOCK_STUB = "true" *)
module top_level (
  UART_rxd,
  UART_txd,
  qsfp1_gt_grx_n,
  qsfp1_gt_grx_p,
  qsfp1_gt_gtx_n,
  qsfp1_gt_gtx_p,
  qsfp0_gt_grx_n,
  qsfp0_gt_grx_p,
  qsfp0_gt_gtx_n,
  qsfp0_gt_gtx_p,
  qsfp0_clk_clk_n,
  qsfp0_clk_clk_p,
  qsfp1_clk_clk_n,
  qsfp1_clk_clk_p,
  rx0_aligned,
  rx1_aligned,
  qsfp_lpmode
);

  (* X_INTERFACE_INFO = "xilinx.com:interface:uart:1.0 UART RxD" *)
  (* X_INTERFACE_MODE = "master UART" *)
  input UART_rxd;
  (* X_INTERFACE_INFO = "xilinx.com:interface:uart:1.0 UART TxD" *)
  output UART_txd;
  (* X_INTERFACE_INFO = "xilinx.com:interface:gt:1.0 qsfp1_gt GRX_N" *)
  (* X_INTERFACE_MODE = "master qsfp1_gt" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME qsfp1_gt, CAN_DEBUG false" *)
  input [3:0]qsfp1_gt_grx_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:gt:1.0 qsfp1_gt GRX_P" *)
  input [3:0]qsfp1_gt_grx_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:gt:1.0 qsfp1_gt GTX_N" *)
  output [3:0]qsfp1_gt_gtx_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:gt:1.0 qsfp1_gt GTX_P" *)
  output [3:0]qsfp1_gt_gtx_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:gt:1.0 qsfp0_gt GRX_N" *)
  (* X_INTERFACE_MODE = "master qsfp0_gt" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME qsfp0_gt, CAN_DEBUG false" *)
  input [3:0]qsfp0_gt_grx_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:gt:1.0 qsfp0_gt GRX_P" *)
  input [3:0]qsfp0_gt_grx_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:gt:1.0 qsfp0_gt GTX_N" *)
  output [3:0]qsfp0_gt_gtx_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:gt:1.0 qsfp0_gt GTX_P" *)
  output [3:0]qsfp0_gt_gtx_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 qsfp0_clk CLK_N" *)
  (* X_INTERFACE_MODE = "slave qsfp0_clk" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME qsfp0_clk, CAN_DEBUG false, FREQ_HZ 156250000" *)
  input [0:0]qsfp0_clk_clk_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 qsfp0_clk CLK_P" *)
  input [0:0]qsfp0_clk_clk_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 qsfp1_clk CLK_N" *)
  (* X_INTERFACE_MODE = "slave qsfp1_clk" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME qsfp1_clk, CAN_DEBUG false, FREQ_HZ 156250000" *)
  input [0:0]qsfp1_clk_clk_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 qsfp1_clk CLK_P" *)
  input [0:0]qsfp1_clk_clk_p;
  (* X_INTERFACE_IGNORE = "true" *)
  output rx0_aligned;
  (* X_INTERFACE_IGNORE = "true" *)
  output rx1_aligned;
  (* X_INTERFACE_IGNORE = "true" *)
  output qsfp_lpmode;

  // stub module has no contents

endmodule
