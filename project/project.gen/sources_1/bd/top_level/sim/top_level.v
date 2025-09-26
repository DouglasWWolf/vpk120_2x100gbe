//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.2 (lin64) Build 5239630 Fri Nov 08 22:34:34 MST 2024
//Date        : Fri Sep 26 10:02:42 2025
//Host        : wolf-super-server running 64-bit Ubuntu 20.04.6 LTS
//Command     : generate_target top_level.bd
//Design      : top_level
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module axi_uart_bridge_imp_1OII57Q
   (M_AXI_araddr,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    UART_rxd,
    UART_txd,
    aclk,
    aresetn);
  output [63:0]M_AXI_araddr;
  input M_AXI_arready;
  output M_AXI_arvalid;
  output [63:0]M_AXI_awaddr;
  input M_AXI_awready;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [0:0]M_AXI_rdata;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input UART_rxd;
  output UART_txd;
  input aclk;
  input aresetn;

  wire [63:0]M_AXI_araddr;
  wire M_AXI_arready;
  wire M_AXI_arvalid;
  wire [63:0]M_AXI_awaddr;
  wire M_AXI_awready;
  wire M_AXI_awvalid;
  wire M_AXI_bready;
  wire [1:0]M_AXI_bresp;
  wire M_AXI_bvalid;
  wire [0:0]M_AXI_rdata;
  wire M_AXI_rready;
  wire [1:0]M_AXI_rresp;
  wire M_AXI_rvalid;
  wire [31:0]M_AXI_wdata;
  wire M_AXI_wready;
  wire [3:0]M_AXI_wstrb;
  wire M_AXI_wvalid;
  wire UART_rxd;
  wire UART_txd;
  wire aclk;
  wire aresetn;
  wire [31:0]axi_uart_bridge_M_UART_ARADDR;
  wire axi_uart_bridge_M_UART_ARREADY;
  wire axi_uart_bridge_M_UART_ARVALID;
  wire [31:0]axi_uart_bridge_M_UART_AWADDR;
  wire axi_uart_bridge_M_UART_AWREADY;
  wire axi_uart_bridge_M_UART_AWVALID;
  wire axi_uart_bridge_M_UART_BREADY;
  wire [1:0]axi_uart_bridge_M_UART_BRESP;
  wire axi_uart_bridge_M_UART_BVALID;
  wire [31:0]axi_uart_bridge_M_UART_RDATA;
  wire axi_uart_bridge_M_UART_RREADY;
  wire [1:0]axi_uart_bridge_M_UART_RRESP;
  wire axi_uart_bridge_M_UART_RVALID;
  wire [31:0]axi_uart_bridge_M_UART_WDATA;
  wire axi_uart_bridge_M_UART_WREADY;
  wire [3:0]axi_uart_bridge_M_UART_WSTRB;
  wire axi_uart_bridge_M_UART_WVALID;
  wire axi_uartlite_interrupt;

  top_level_axi_uart_bridge_0_0 axi_uart_bridge
       (.M_AXI_ARADDR(M_AXI_araddr),
        .M_AXI_ARREADY(M_AXI_arready),
        .M_AXI_ARVALID(M_AXI_arvalid),
        .M_AXI_AWADDR(M_AXI_awaddr),
        .M_AXI_AWREADY(M_AXI_awready),
        .M_AXI_AWVALID(M_AXI_awvalid),
        .M_AXI_BREADY(M_AXI_bready),
        .M_AXI_BRESP(M_AXI_bresp),
        .M_AXI_BVALID(M_AXI_bvalid),
        .M_AXI_RDATA({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,M_AXI_rdata}),
        .M_AXI_RREADY(M_AXI_rready),
        .M_AXI_RRESP(M_AXI_rresp),
        .M_AXI_RVALID(M_AXI_rvalid),
        .M_AXI_WDATA(M_AXI_wdata),
        .M_AXI_WREADY(M_AXI_wready),
        .M_AXI_WSTRB(M_AXI_wstrb),
        .M_AXI_WVALID(M_AXI_wvalid),
        .M_UART_ARADDR(axi_uart_bridge_M_UART_ARADDR),
        .M_UART_ARREADY(axi_uart_bridge_M_UART_ARREADY),
        .M_UART_ARVALID(axi_uart_bridge_M_UART_ARVALID),
        .M_UART_AWADDR(axi_uart_bridge_M_UART_AWADDR),
        .M_UART_AWREADY(axi_uart_bridge_M_UART_AWREADY),
        .M_UART_AWVALID(axi_uart_bridge_M_UART_AWVALID),
        .M_UART_BREADY(axi_uart_bridge_M_UART_BREADY),
        .M_UART_BRESP(axi_uart_bridge_M_UART_BRESP),
        .M_UART_BVALID(axi_uart_bridge_M_UART_BVALID),
        .M_UART_RDATA(axi_uart_bridge_M_UART_RDATA),
        .M_UART_RREADY(axi_uart_bridge_M_UART_RREADY),
        .M_UART_RRESP(axi_uart_bridge_M_UART_RRESP),
        .M_UART_RVALID(axi_uart_bridge_M_UART_RVALID),
        .M_UART_WDATA(axi_uart_bridge_M_UART_WDATA),
        .M_UART_WREADY(axi_uart_bridge_M_UART_WREADY),
        .M_UART_WSTRB(axi_uart_bridge_M_UART_WSTRB),
        .M_UART_WVALID(axi_uart_bridge_M_UART_WVALID),
        .UART_INT(axi_uartlite_interrupt),
        .aclk(aclk),
        .aresetn(aresetn));
  top_level_axi_uartlite_0_0 axi_uartlite
       (.interrupt(axi_uartlite_interrupt),
        .rx(UART_rxd),
        .s_axi_aclk(aclk),
        .s_axi_araddr(axi_uart_bridge_M_UART_ARADDR[3:0]),
        .s_axi_aresetn(aresetn),
        .s_axi_arready(axi_uart_bridge_M_UART_ARREADY),
        .s_axi_arvalid(axi_uart_bridge_M_UART_ARVALID),
        .s_axi_awaddr(axi_uart_bridge_M_UART_AWADDR[3:0]),
        .s_axi_awready(axi_uart_bridge_M_UART_AWREADY),
        .s_axi_awvalid(axi_uart_bridge_M_UART_AWVALID),
        .s_axi_bready(axi_uart_bridge_M_UART_BREADY),
        .s_axi_bresp(axi_uart_bridge_M_UART_BRESP),
        .s_axi_bvalid(axi_uart_bridge_M_UART_BVALID),
        .s_axi_rdata(axi_uart_bridge_M_UART_RDATA),
        .s_axi_rready(axi_uart_bridge_M_UART_RREADY),
        .s_axi_rresp(axi_uart_bridge_M_UART_RRESP),
        .s_axi_rvalid(axi_uart_bridge_M_UART_RVALID),
        .s_axi_wdata(axi_uart_bridge_M_UART_WDATA),
        .s_axi_wready(axi_uart_bridge_M_UART_WREADY),
        .s_axi_wstrb(axi_uart_bridge_M_UART_WSTRB),
        .s_axi_wvalid(axi_uart_bridge_M_UART_WVALID),
        .tx(UART_txd));
endmodule

module clk_and_reset_imp_OK11XN
   (peripheral_aresetn,
    sys_clk);
  output [0:0]peripheral_aresetn;
  output sys_clk;

  wire clk_wizard_locked;
  wire [0:0]peripheral_aresetn;
  wire sys_clk;
  wire versal_cips_pl0_ref_clk;
  wire versal_cips_pl0_resetn;

  top_level_clk_wizard_0_0 clk_wizard
       (.clk_in1(versal_cips_pl0_ref_clk),
        .clk_out1(sys_clk),
        .locked(clk_wizard_locked),
        .resetn(versal_cips_pl0_resetn));
  top_level_proc_sys_reset_0_1 proc_sys_reset
       (.aux_reset_in(1'b1),
        .dcm_locked(clk_wizard_locked),
        .ext_reset_in(versal_cips_pl0_resetn),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(peripheral_aresetn),
        .slowest_sync_clk(sys_clk));
  top_level_versal_cips_0_0 versal_cips
       (.pl0_ref_clk(versal_cips_pl0_ref_clk),
        .pl0_resetn(versal_cips_pl0_resetn));
endmodule

module packet_gen_0_imp_WS1ECX
   (S_AXI_araddr,
    S_AXI_arprot,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awprot,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid,
    axis_out_tdata,
    axis_out_tkeep,
    axis_out_tlast,
    axis_out_tready,
    axis_out_tvalid,
    clk,
    resetn);
  input [0:0]S_AXI_araddr;
  input [2:0]S_AXI_arprot;
  output S_AXI_arready;
  input S_AXI_arvalid;
  input [0:0]S_AXI_awaddr;
  input [2:0]S_AXI_awprot;
  output S_AXI_awready;
  input S_AXI_awvalid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [0:0]S_AXI_wdata;
  output S_AXI_wready;
  input [0:0]S_AXI_wstrb;
  input S_AXI_wvalid;
  output [511:0]axis_out_tdata;
  output [63:0]axis_out_tkeep;
  output axis_out_tlast;
  input axis_out_tready;
  output axis_out_tvalid;
  input clk;
  input resetn;

  wire [0:0]S_AXI_araddr;
  wire [2:0]S_AXI_arprot;
  wire S_AXI_arready;
  wire S_AXI_arvalid;
  wire [0:0]S_AXI_awaddr;
  wire [2:0]S_AXI_awprot;
  wire S_AXI_awready;
  wire S_AXI_awvalid;
  wire S_AXI_bready;
  wire [1:0]S_AXI_bresp;
  wire S_AXI_bvalid;
  wire [31:0]S_AXI_rdata;
  wire S_AXI_rready;
  wire [1:0]S_AXI_rresp;
  wire S_AXI_rvalid;
  wire [0:0]S_AXI_wdata;
  wire S_AXI_wready;
  wire [0:0]S_AXI_wstrb;
  wire S_AXI_wvalid;
  wire [511:0]axis_out_tdata;
  wire [63:0]axis_out_tkeep;
  wire axis_out_tlast;
  wire axis_out_tready;
  wire axis_out_tvalid;
  wire clk;
  wire [15:0]packet_config_idle_cycles;
  wire [15:0]packet_config_initial_value;
  wire [31:0]packet_config_packet_count;
  wire [15:0]packet_config_packet_len;
  wire packet_config_start;
  wire packet_gen_busy;
  wire resetn;

  top_level_packet_config_0_0 packet_config
       (.S_AXI_ARADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,S_AXI_araddr}),
        .S_AXI_ARPROT(S_AXI_arprot),
        .S_AXI_ARREADY(S_AXI_arready),
        .S_AXI_ARVALID(S_AXI_arvalid),
        .S_AXI_AWADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,S_AXI_awaddr}),
        .S_AXI_AWPROT(S_AXI_awprot),
        .S_AXI_AWREADY(S_AXI_awready),
        .S_AXI_AWVALID(S_AXI_awvalid),
        .S_AXI_BREADY(S_AXI_bready),
        .S_AXI_BRESP(S_AXI_bresp),
        .S_AXI_BVALID(S_AXI_bvalid),
        .S_AXI_RDATA(S_AXI_rdata),
        .S_AXI_RREADY(S_AXI_rready),
        .S_AXI_RRESP(S_AXI_rresp),
        .S_AXI_RVALID(S_AXI_rvalid),
        .S_AXI_WDATA({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,S_AXI_wdata}),
        .S_AXI_WREADY(S_AXI_wready),
        .S_AXI_WSTRB({1'b1,1'b1,1'b1,S_AXI_wstrb}),
        .S_AXI_WVALID(S_AXI_wvalid),
        .clk(clk),
        .idle_cycles(packet_config_idle_cycles),
        .initial_value(packet_config_initial_value),
        .packet_count(packet_config_packet_count),
        .packet_gen_busy(packet_gen_busy),
        .packet_len(packet_config_packet_len),
        .resetn(resetn),
        .start(packet_config_start));
  top_level_packet_gen_0_0 packet_gen
       (.axis_out_tdata(axis_out_tdata),
        .axis_out_tkeep(axis_out_tkeep),
        .axis_out_tlast(axis_out_tlast),
        .axis_out_tready(axis_out_tready),
        .axis_out_tvalid(axis_out_tvalid),
        .busy(packet_gen_busy),
        .clk(clk),
        .idle_cycles(packet_config_idle_cycles),
        .initial_value(packet_config_initial_value),
        .packet_count(packet_config_packet_count),
        .packet_length(packet_config_packet_len),
        .resetn(resetn),
        .start(packet_config_start));
endmodule

module packet_gen_1_imp_16P2JTB
   (S_AXI_araddr,
    S_AXI_arprot,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awprot,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid,
    axis_out_tdata,
    axis_out_tkeep,
    axis_out_tlast,
    axis_out_tready,
    axis_out_tvalid,
    clk,
    resetn);
  input [0:0]S_AXI_araddr;
  input [2:0]S_AXI_arprot;
  output S_AXI_arready;
  input S_AXI_arvalid;
  input [0:0]S_AXI_awaddr;
  input [2:0]S_AXI_awprot;
  output S_AXI_awready;
  input S_AXI_awvalid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [0:0]S_AXI_wdata;
  output S_AXI_wready;
  input [0:0]S_AXI_wstrb;
  input S_AXI_wvalid;
  output [511:0]axis_out_tdata;
  output [63:0]axis_out_tkeep;
  output axis_out_tlast;
  input axis_out_tready;
  output axis_out_tvalid;
  input clk;
  input resetn;

  wire [0:0]S_AXI_araddr;
  wire [2:0]S_AXI_arprot;
  wire S_AXI_arready;
  wire S_AXI_arvalid;
  wire [0:0]S_AXI_awaddr;
  wire [2:0]S_AXI_awprot;
  wire S_AXI_awready;
  wire S_AXI_awvalid;
  wire S_AXI_bready;
  wire [1:0]S_AXI_bresp;
  wire S_AXI_bvalid;
  wire [31:0]S_AXI_rdata;
  wire S_AXI_rready;
  wire [1:0]S_AXI_rresp;
  wire S_AXI_rvalid;
  wire [0:0]S_AXI_wdata;
  wire S_AXI_wready;
  wire [0:0]S_AXI_wstrb;
  wire S_AXI_wvalid;
  wire [511:0]axis_out_tdata;
  wire [63:0]axis_out_tkeep;
  wire axis_out_tlast;
  wire axis_out_tready;
  wire axis_out_tvalid;
  wire clk;
  wire [15:0]packet_config_idle_cycles;
  wire [15:0]packet_config_initial_value;
  wire [31:0]packet_config_packet_count;
  wire [15:0]packet_config_packet_len;
  wire packet_config_start;
  wire packet_gen_busy;
  wire resetn;

  top_level_packet_config_1 packet_config
       (.S_AXI_ARADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,S_AXI_araddr}),
        .S_AXI_ARPROT(S_AXI_arprot),
        .S_AXI_ARREADY(S_AXI_arready),
        .S_AXI_ARVALID(S_AXI_arvalid),
        .S_AXI_AWADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,S_AXI_awaddr}),
        .S_AXI_AWPROT(S_AXI_awprot),
        .S_AXI_AWREADY(S_AXI_awready),
        .S_AXI_AWVALID(S_AXI_awvalid),
        .S_AXI_BREADY(S_AXI_bready),
        .S_AXI_BRESP(S_AXI_bresp),
        .S_AXI_BVALID(S_AXI_bvalid),
        .S_AXI_RDATA(S_AXI_rdata),
        .S_AXI_RREADY(S_AXI_rready),
        .S_AXI_RRESP(S_AXI_rresp),
        .S_AXI_RVALID(S_AXI_rvalid),
        .S_AXI_WDATA({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,S_AXI_wdata}),
        .S_AXI_WREADY(S_AXI_wready),
        .S_AXI_WSTRB({1'b1,1'b1,1'b1,S_AXI_wstrb}),
        .S_AXI_WVALID(S_AXI_wvalid),
        .clk(clk),
        .idle_cycles(packet_config_idle_cycles),
        .initial_value(packet_config_initial_value),
        .packet_count(packet_config_packet_count),
        .packet_gen_busy(packet_gen_busy),
        .packet_len(packet_config_packet_len),
        .resetn(resetn),
        .start(packet_config_start));
  top_level_packet_gen_1 packet_gen
       (.axis_out_tdata(axis_out_tdata),
        .axis_out_tkeep(axis_out_tkeep),
        .axis_out_tlast(axis_out_tlast),
        .axis_out_tready(axis_out_tready),
        .axis_out_tvalid(axis_out_tvalid),
        .busy(packet_gen_busy),
        .clk(clk),
        .idle_cycles(packet_config_idle_cycles),
        .initial_value(packet_config_initial_value),
        .packet_count(packet_config_packet_count),
        .packet_length(packet_config_packet_len),
        .resetn(resetn),
        .start(packet_config_start));
endmodule

module pl_rtl_imp_QFYSB7
   (S00_AXI_araddr,
    S00_AXI_arready,
    S00_AXI_arvalid,
    S00_AXI_awaddr,
    S00_AXI_awready,
    S00_AXI_awvalid,
    S00_AXI_bready,
    S00_AXI_bresp,
    S00_AXI_bvalid,
    S00_AXI_rdata,
    S00_AXI_rready,
    S00_AXI_rresp,
    S00_AXI_rvalid,
    S00_AXI_wdata,
    S00_AXI_wready,
    S00_AXI_wstrb,
    S00_AXI_wvalid,
    aclk,
    aresetn,
    qsfp0_clk_clk_n,
    qsfp0_clk_clk_p,
    qsfp0_gt_grx_n,
    qsfp0_gt_grx_p,
    qsfp0_gt_gtx_n,
    qsfp0_gt_gtx_p,
    qsfp1_clk_clk_n,
    qsfp1_clk_clk_p,
    qsfp1_gt_grx_n,
    qsfp1_gt_grx_p,
    qsfp1_gt_gtx_n,
    qsfp1_gt_gtx_p);
  input [63:0]S00_AXI_araddr;
  output S00_AXI_arready;
  input S00_AXI_arvalid;
  input [63:0]S00_AXI_awaddr;
  output S00_AXI_awready;
  input S00_AXI_awvalid;
  input S00_AXI_bready;
  output [1:0]S00_AXI_bresp;
  output S00_AXI_bvalid;
  output [0:0]S00_AXI_rdata;
  input S00_AXI_rready;
  output [1:0]S00_AXI_rresp;
  output S00_AXI_rvalid;
  input [31:0]S00_AXI_wdata;
  output S00_AXI_wready;
  input [3:0]S00_AXI_wstrb;
  input S00_AXI_wvalid;
  input aclk;
  input aresetn;
  input [0:0]qsfp0_clk_clk_n;
  input [0:0]qsfp0_clk_clk_p;
  input [3:0]qsfp0_gt_grx_n;
  input [3:0]qsfp0_gt_grx_p;
  output [3:0]qsfp0_gt_gtx_n;
  output [3:0]qsfp0_gt_gtx_p;
  input [0:0]qsfp1_clk_clk_n;
  input [0:0]qsfp1_clk_clk_p;
  input [3:0]qsfp1_gt_grx_n;
  input [3:0]qsfp1_gt_grx_p;
  output [3:0]qsfp1_gt_gtx_n;
  output [3:0]qsfp1_gt_gtx_p;

  wire [63:0]S00_AXI_araddr;
  wire [0:0]\^S00_AXI_arready ;
  wire S00_AXI_arvalid;
  wire [63:0]S00_AXI_awaddr;
  wire [0:0]\^S00_AXI_awready ;
  wire S00_AXI_awvalid;
  wire S00_AXI_bready;
  wire [1:0]S00_AXI_bresp;
  wire [0:0]\^S00_AXI_bvalid ;
  wire \^S00_AXI_rdata ;
  wire S00_AXI_rready;
  wire [1:0]S00_AXI_rresp;
  wire [0:0]\^S00_AXI_rvalid ;
  wire [31:0]S00_AXI_wdata;
  wire [0:0]\^S00_AXI_wready ;
  wire [3:0]S00_AXI_wstrb;
  wire S00_AXI_wvalid;
  wire S_AXI_1_ARADDR;
  wire [2:0]S_AXI_1_ARPROT;
  wire S_AXI_1_ARREADY;
  wire [0:0]S_AXI_1_ARVALID;
  wire S_AXI_1_AWADDR;
  wire [2:0]S_AXI_1_AWPROT;
  wire S_AXI_1_AWREADY;
  wire [0:0]S_AXI_1_AWVALID;
  wire [0:0]S_AXI_1_BREADY;
  wire [1:0]S_AXI_1_BRESP;
  wire S_AXI_1_BVALID;
  wire [31:0]S_AXI_1_RDATA;
  wire [0:0]S_AXI_1_RREADY;
  wire [1:0]S_AXI_1_RRESP;
  wire S_AXI_1_RVALID;
  wire S_AXI_1_WDATA;
  wire S_AXI_1_WREADY;
  wire S_AXI_1_WSTRB;
  wire [0:0]S_AXI_1_WVALID;
  wire S_AXI_2_ARADDR;
  wire [2:0]S_AXI_2_ARPROT;
  wire S_AXI_2_ARREADY;
  wire [0:0]S_AXI_2_ARVALID;
  wire S_AXI_2_AWADDR;
  wire [2:0]S_AXI_2_AWPROT;
  wire S_AXI_2_AWREADY;
  wire [0:0]S_AXI_2_AWVALID;
  wire [0:0]S_AXI_2_BREADY;
  wire [1:0]S_AXI_2_BRESP;
  wire S_AXI_2_BVALID;
  wire [31:0]S_AXI_2_RDATA;
  wire [0:0]S_AXI_2_RREADY;
  wire [1:0]S_AXI_2_RRESP;
  wire S_AXI_2_RVALID;
  wire S_AXI_2_WDATA;
  wire S_AXI_2_WREADY;
  wire S_AXI_2_WSTRB;
  wire [0:0]S_AXI_2_WVALID;
  wire clk_wizard_0_clk_out1;
  wire interconnect_M00_AXI_ARADDR;
  wire interconnect_M00_AXI_ARREADY;
  wire [0:0]interconnect_M00_AXI_ARVALID;
  wire interconnect_M00_AXI_AWADDR;
  wire interconnect_M00_AXI_AWREADY;
  wire [0:0]interconnect_M00_AXI_AWVALID;
  wire [0:0]interconnect_M00_AXI_BREADY;
  wire [1:0]interconnect_M00_AXI_BRESP;
  wire interconnect_M00_AXI_BVALID;
  wire [31:0]interconnect_M00_AXI_RDATA;
  wire [0:0]interconnect_M00_AXI_RREADY;
  wire [1:0]interconnect_M00_AXI_RRESP;
  wire interconnect_M00_AXI_RVALID;
  wire interconnect_M00_AXI_WDATA;
  wire interconnect_M00_AXI_WREADY;
  wire [0:0]interconnect_M00_AXI_WVALID;
  wire interconnect_M01_AXI_ARADDR;
  wire [2:0]interconnect_M01_AXI_ARPROT;
  wire interconnect_M01_AXI_ARREADY;
  wire [0:0]interconnect_M01_AXI_ARVALID;
  wire interconnect_M01_AXI_AWADDR;
  wire [2:0]interconnect_M01_AXI_AWPROT;
  wire interconnect_M01_AXI_AWREADY;
  wire [0:0]interconnect_M01_AXI_AWVALID;
  wire [0:0]interconnect_M01_AXI_BREADY;
  wire [1:0]interconnect_M01_AXI_BRESP;
  wire interconnect_M01_AXI_BVALID;
  wire [31:0]interconnect_M01_AXI_RDATA;
  wire [0:0]interconnect_M01_AXI_RREADY;
  wire [1:0]interconnect_M01_AXI_RRESP;
  wire interconnect_M01_AXI_RVALID;
  wire interconnect_M01_AXI_WDATA;
  wire interconnect_M01_AXI_WREADY;
  wire interconnect_M01_AXI_WSTRB;
  wire [0:0]interconnect_M01_AXI_WVALID;
  (* CONN_BUS_INFO = "packet_gen_0_axis_out xilinx.com:interface:axis:1.0 None TDATA" *) (* DONT_TOUCH *) wire [511:0]packet_gen_0_axis_out_TDATA;
  (* CONN_BUS_INFO = "packet_gen_0_axis_out xilinx.com:interface:axis:1.0 None TKEEP" *) (* DONT_TOUCH *) wire [63:0]packet_gen_0_axis_out_TKEEP;
  (* CONN_BUS_INFO = "packet_gen_0_axis_out xilinx.com:interface:axis:1.0 None TLAST" *) (* DONT_TOUCH *) wire packet_gen_0_axis_out_TLAST;
  (* CONN_BUS_INFO = "packet_gen_0_axis_out xilinx.com:interface:axis:1.0 None TREADY" *) (* DONT_TOUCH *) wire packet_gen_0_axis_out_TREADY;
  (* CONN_BUS_INFO = "packet_gen_0_axis_out xilinx.com:interface:axis:1.0 None TVALID" *) (* DONT_TOUCH *) wire packet_gen_0_axis_out_TVALID;
  (* CONN_BUS_INFO = "packet_gen_1_axis_out xilinx.com:interface:axis:1.0 None TDATA" *) (* DONT_TOUCH *) wire [511:0]packet_gen_1_axis_out_TDATA;
  (* CONN_BUS_INFO = "packet_gen_1_axis_out xilinx.com:interface:axis:1.0 None TKEEP" *) (* DONT_TOUCH *) wire [63:0]packet_gen_1_axis_out_TKEEP;
  (* CONN_BUS_INFO = "packet_gen_1_axis_out xilinx.com:interface:axis:1.0 None TLAST" *) (* DONT_TOUCH *) wire packet_gen_1_axis_out_TLAST;
  (* CONN_BUS_INFO = "packet_gen_1_axis_out xilinx.com:interface:axis:1.0 None TREADY" *) (* DONT_TOUCH *) wire packet_gen_1_axis_out_TREADY;
  (* CONN_BUS_INFO = "packet_gen_1_axis_out xilinx.com:interface:axis:1.0 None TVALID" *) (* DONT_TOUCH *) wire packet_gen_1_axis_out_TVALID;
  wire proc_sys_reset_0_peripheral_aresetn;
  wire [0:0]qsfp0_clk_clk_n;
  wire [0:0]qsfp0_clk_clk_p;
  wire [3:0]qsfp0_gt_grx_n;
  wire [3:0]qsfp0_gt_grx_p;
  wire [3:0]qsfp0_gt_gtx_n;
  wire [3:0]qsfp0_gt_gtx_p;
  wire [0:0]qsfp1_clk_clk_n;
  wire [0:0]qsfp1_clk_clk_p;
  wire [3:0]qsfp1_gt_grx_n;
  wire [3:0]qsfp1_gt_grx_p;
  wire [3:0]qsfp1_gt_gtx_n;
  wire [3:0]qsfp1_gt_gtx_p;

  assign S00_AXI_arready = \^S00_AXI_arready [0];
  assign S00_AXI_awready = \^S00_AXI_awready [0];
  assign S00_AXI_bvalid = \^S00_AXI_bvalid [0];
  assign S00_AXI_rdata[0] = \^S00_AXI_rdata ;
  assign S00_AXI_rvalid = \^S00_AXI_rvalid [0];
  assign S00_AXI_wready = \^S00_AXI_wready [0];
  assign clk_wizard_0_clk_out1 = aclk;
  assign proc_sys_reset_0_peripheral_aresetn = aresetn;
  top_level_axis_ila_0_0 axis_ila
       (.SLOT_0_AXIS_tdata(packet_gen_0_axis_out_TDATA[7:0]),
        .SLOT_0_AXIS_tdest(1'b0),
        .SLOT_0_AXIS_tid(1'b0),
        .SLOT_0_AXIS_tkeep(packet_gen_0_axis_out_TKEEP[0]),
        .SLOT_0_AXIS_tlast(packet_gen_0_axis_out_TLAST),
        .SLOT_0_AXIS_tready(packet_gen_0_axis_out_TREADY),
        .SLOT_0_AXIS_tstrb(1'b1),
        .SLOT_0_AXIS_tuser(1'b0),
        .SLOT_0_AXIS_tvalid(packet_gen_0_axis_out_TVALID),
        .SLOT_1_AXIS_tdata(packet_gen_1_axis_out_TDATA[7:0]),
        .SLOT_1_AXIS_tdest(1'b0),
        .SLOT_1_AXIS_tid(1'b0),
        .SLOT_1_AXIS_tkeep(packet_gen_1_axis_out_TKEEP[0]),
        .SLOT_1_AXIS_tlast(packet_gen_1_axis_out_TLAST),
        .SLOT_1_AXIS_tready(packet_gen_1_axis_out_TREADY),
        .SLOT_1_AXIS_tstrb(1'b1),
        .SLOT_1_AXIS_tuser(1'b0),
        .SLOT_1_AXIS_tvalid(packet_gen_1_axis_out_TVALID),
        .clk(clk_wizard_0_clk_out1),
        .resetn(proc_sys_reset_0_peripheral_aresetn));
  top_level_icn_ctrl_0 interconnect
       (.M00_AXI_araddr(interconnect_M00_AXI_ARADDR),
        .M00_AXI_arready(interconnect_M00_AXI_ARREADY),
        .M00_AXI_arvalid(interconnect_M00_AXI_ARVALID),
        .M00_AXI_awaddr(interconnect_M00_AXI_AWADDR),
        .M00_AXI_awready(interconnect_M00_AXI_AWREADY),
        .M00_AXI_awvalid(interconnect_M00_AXI_AWVALID),
        .M00_AXI_bid(1'b0),
        .M00_AXI_bready(interconnect_M00_AXI_BREADY),
        .M00_AXI_bresp(interconnect_M00_AXI_BRESP),
        .M00_AXI_buser(1'b0),
        .M00_AXI_bvalid(interconnect_M00_AXI_BVALID),
        .M00_AXI_rdata(interconnect_M00_AXI_RDATA[0]),
        .M00_AXI_rid(1'b0),
        .M00_AXI_rlast(1'b0),
        .M00_AXI_rready(interconnect_M00_AXI_RREADY),
        .M00_AXI_rresp(interconnect_M00_AXI_RRESP),
        .M00_AXI_ruser(1'b0),
        .M00_AXI_rvalid(interconnect_M00_AXI_RVALID),
        .M00_AXI_wdata(interconnect_M00_AXI_WDATA),
        .M00_AXI_wready(interconnect_M00_AXI_WREADY),
        .M00_AXI_wvalid(interconnect_M00_AXI_WVALID),
        .M01_AXI_araddr(interconnect_M01_AXI_ARADDR),
        .M01_AXI_arprot(interconnect_M01_AXI_ARPROT),
        .M01_AXI_arready(interconnect_M01_AXI_ARREADY),
        .M01_AXI_arvalid(interconnect_M01_AXI_ARVALID),
        .M01_AXI_awaddr(interconnect_M01_AXI_AWADDR),
        .M01_AXI_awprot(interconnect_M01_AXI_AWPROT),
        .M01_AXI_awready(interconnect_M01_AXI_AWREADY),
        .M01_AXI_awvalid(interconnect_M01_AXI_AWVALID),
        .M01_AXI_bid(1'b0),
        .M01_AXI_bready(interconnect_M01_AXI_BREADY),
        .M01_AXI_bresp(interconnect_M01_AXI_BRESP),
        .M01_AXI_buser(1'b0),
        .M01_AXI_bvalid(interconnect_M01_AXI_BVALID),
        .M01_AXI_rdata(interconnect_M01_AXI_RDATA[0]),
        .M01_AXI_rid(1'b0),
        .M01_AXI_rlast(1'b0),
        .M01_AXI_rready(interconnect_M01_AXI_RREADY),
        .M01_AXI_rresp(interconnect_M01_AXI_RRESP),
        .M01_AXI_ruser(1'b0),
        .M01_AXI_rvalid(interconnect_M01_AXI_RVALID),
        .M01_AXI_wdata(interconnect_M01_AXI_WDATA),
        .M01_AXI_wready(interconnect_M01_AXI_WREADY),
        .M01_AXI_wstrb(interconnect_M01_AXI_WSTRB),
        .M01_AXI_wvalid(interconnect_M01_AXI_WVALID),
        .M02_AXI_araddr(S_AXI_1_ARADDR),
        .M02_AXI_arprot(S_AXI_1_ARPROT),
        .M02_AXI_arready(S_AXI_1_ARREADY),
        .M02_AXI_arvalid(S_AXI_1_ARVALID),
        .M02_AXI_awaddr(S_AXI_1_AWADDR),
        .M02_AXI_awprot(S_AXI_1_AWPROT),
        .M02_AXI_awready(S_AXI_1_AWREADY),
        .M02_AXI_awvalid(S_AXI_1_AWVALID),
        .M02_AXI_bid(1'b0),
        .M02_AXI_bready(S_AXI_1_BREADY),
        .M02_AXI_bresp(S_AXI_1_BRESP),
        .M02_AXI_buser(1'b0),
        .M02_AXI_bvalid(S_AXI_1_BVALID),
        .M02_AXI_rdata(S_AXI_1_RDATA[0]),
        .M02_AXI_rid(1'b0),
        .M02_AXI_rlast(1'b0),
        .M02_AXI_rready(S_AXI_1_RREADY),
        .M02_AXI_rresp(S_AXI_1_RRESP),
        .M02_AXI_ruser(1'b0),
        .M02_AXI_rvalid(S_AXI_1_RVALID),
        .M02_AXI_wdata(S_AXI_1_WDATA),
        .M02_AXI_wready(S_AXI_1_WREADY),
        .M02_AXI_wstrb(S_AXI_1_WSTRB),
        .M02_AXI_wvalid(S_AXI_1_WVALID),
        .M03_AXI_araddr(S_AXI_2_ARADDR),
        .M03_AXI_arprot(S_AXI_2_ARPROT),
        .M03_AXI_arready(S_AXI_2_ARREADY),
        .M03_AXI_arvalid(S_AXI_2_ARVALID),
        .M03_AXI_awaddr(S_AXI_2_AWADDR),
        .M03_AXI_awprot(S_AXI_2_AWPROT),
        .M03_AXI_awready(S_AXI_2_AWREADY),
        .M03_AXI_awvalid(S_AXI_2_AWVALID),
        .M03_AXI_bid(1'b0),
        .M03_AXI_bready(S_AXI_2_BREADY),
        .M03_AXI_bresp(S_AXI_2_BRESP),
        .M03_AXI_buser(1'b0),
        .M03_AXI_bvalid(S_AXI_2_BVALID),
        .M03_AXI_rdata(S_AXI_2_RDATA[0]),
        .M03_AXI_rid(1'b0),
        .M03_AXI_rlast(1'b0),
        .M03_AXI_rready(S_AXI_2_RREADY),
        .M03_AXI_rresp(S_AXI_2_RRESP),
        .M03_AXI_ruser(1'b0),
        .M03_AXI_rvalid(S_AXI_2_RVALID),
        .M03_AXI_wdata(S_AXI_2_WDATA),
        .M03_AXI_wready(S_AXI_2_WREADY),
        .M03_AXI_wstrb(S_AXI_2_WSTRB),
        .M03_AXI_wvalid(S_AXI_2_WVALID),
        .S00_AXI_araddr(S00_AXI_araddr[0]),
        .S00_AXI_arburst({1'b0,1'b1}),
        .S00_AXI_arcache({1'b0,1'b0,1'b1,1'b1}),
        .S00_AXI_arid(1'b0),
        .S00_AXI_arlen(1'b0),
        .S00_AXI_arlock(1'b0),
        .S00_AXI_arprot({1'b0,1'b0,1'b0}),
        .S00_AXI_arqos({1'b0,1'b0,1'b0,1'b0}),
        .S00_AXI_arready(\^S00_AXI_arready ),
        .S00_AXI_arregion({1'b0,1'b0,1'b0,1'b0}),
        .S00_AXI_arsize({1'b0,1'b1,1'b0}),
        .S00_AXI_aruser(1'b0),
        .S00_AXI_arvalid(S00_AXI_arvalid),
        .S00_AXI_awaddr(S00_AXI_awaddr[0]),
        .S00_AXI_awburst({1'b0,1'b1}),
        .S00_AXI_awcache({1'b0,1'b0,1'b1,1'b1}),
        .S00_AXI_awid(1'b0),
        .S00_AXI_awlen(1'b0),
        .S00_AXI_awlock(1'b0),
        .S00_AXI_awprot({1'b0,1'b0,1'b0}),
        .S00_AXI_awqos({1'b0,1'b0,1'b0,1'b0}),
        .S00_AXI_awready(\^S00_AXI_awready ),
        .S00_AXI_awregion({1'b0,1'b0,1'b0,1'b0}),
        .S00_AXI_awsize({1'b0,1'b1,1'b0}),
        .S00_AXI_awuser(1'b0),
        .S00_AXI_awvalid(S00_AXI_awvalid),
        .S00_AXI_bready(S00_AXI_bready),
        .S00_AXI_bresp(S00_AXI_bresp),
        .S00_AXI_bvalid(\^S00_AXI_bvalid ),
        .S00_AXI_rdata(\^S00_AXI_rdata ),
        .S00_AXI_rready(S00_AXI_rready),
        .S00_AXI_rresp(S00_AXI_rresp),
        .S00_AXI_rvalid(\^S00_AXI_rvalid ),
        .S00_AXI_wdata(S00_AXI_wdata[0]),
        .S00_AXI_wid(1'b0),
        .S00_AXI_wlast(1'b0),
        .S00_AXI_wready(\^S00_AXI_wready ),
        .S00_AXI_wstrb(S00_AXI_wstrb[0]),
        .S00_AXI_wuser(1'b0),
        .S00_AXI_wvalid(S00_AXI_wvalid),
        .aclk(clk_wizard_0_clk_out1),
        .aresetn(proc_sys_reset_0_peripheral_aresetn));
  packet_gen_0_imp_WS1ECX packet_gen_0
       (.S_AXI_araddr(S_AXI_1_ARADDR),
        .S_AXI_arprot(S_AXI_1_ARPROT),
        .S_AXI_arready(S_AXI_1_ARREADY),
        .S_AXI_arvalid(S_AXI_1_ARVALID),
        .S_AXI_awaddr(S_AXI_1_AWADDR),
        .S_AXI_awprot(S_AXI_1_AWPROT),
        .S_AXI_awready(S_AXI_1_AWREADY),
        .S_AXI_awvalid(S_AXI_1_AWVALID),
        .S_AXI_bready(S_AXI_1_BREADY),
        .S_AXI_bresp(S_AXI_1_BRESP),
        .S_AXI_bvalid(S_AXI_1_BVALID),
        .S_AXI_rdata(S_AXI_1_RDATA),
        .S_AXI_rready(S_AXI_1_RREADY),
        .S_AXI_rresp(S_AXI_1_RRESP),
        .S_AXI_rvalid(S_AXI_1_RVALID),
        .S_AXI_wdata(S_AXI_1_WDATA),
        .S_AXI_wready(S_AXI_1_WREADY),
        .S_AXI_wstrb(S_AXI_1_WSTRB),
        .S_AXI_wvalid(S_AXI_1_WVALID),
        .axis_out_tdata(packet_gen_0_axis_out_TDATA),
        .axis_out_tkeep(packet_gen_0_axis_out_TKEEP),
        .axis_out_tlast(packet_gen_0_axis_out_TLAST),
        .axis_out_tready(packet_gen_0_axis_out_TREADY),
        .axis_out_tvalid(packet_gen_0_axis_out_TVALID),
        .clk(clk_wizard_0_clk_out1),
        .resetn(proc_sys_reset_0_peripheral_aresetn));
  packet_gen_1_imp_16P2JTB packet_gen_1
       (.S_AXI_araddr(S_AXI_2_ARADDR),
        .S_AXI_arprot(S_AXI_2_ARPROT),
        .S_AXI_arready(S_AXI_2_ARREADY),
        .S_AXI_arvalid(S_AXI_2_ARVALID),
        .S_AXI_awaddr(S_AXI_2_AWADDR),
        .S_AXI_awprot(S_AXI_2_AWPROT),
        .S_AXI_awready(S_AXI_2_AWREADY),
        .S_AXI_awvalid(S_AXI_2_AWVALID),
        .S_AXI_bready(S_AXI_2_BREADY),
        .S_AXI_bresp(S_AXI_2_BRESP),
        .S_AXI_bvalid(S_AXI_2_BVALID),
        .S_AXI_rdata(S_AXI_2_RDATA),
        .S_AXI_rready(S_AXI_2_RREADY),
        .S_AXI_rresp(S_AXI_2_RRESP),
        .S_AXI_rvalid(S_AXI_2_RVALID),
        .S_AXI_wdata(S_AXI_2_WDATA),
        .S_AXI_wready(S_AXI_2_WREADY),
        .S_AXI_wstrb(S_AXI_2_WSTRB),
        .S_AXI_wvalid(S_AXI_2_WVALID),
        .axis_out_tdata(packet_gen_1_axis_out_TDATA),
        .axis_out_tkeep(packet_gen_1_axis_out_TKEEP),
        .axis_out_tlast(packet_gen_1_axis_out_TLAST),
        .axis_out_tready(packet_gen_1_axis_out_TREADY),
        .axis_out_tvalid(packet_gen_1_axis_out_TVALID),
        .clk(clk_wizard_0_clk_out1),
        .resetn(proc_sys_reset_0_peripheral_aresetn));
  vpk120_eth2x100_inst_0 vpk120_eth2x100
       (.qsfp0_clk_clk_n(qsfp0_clk_clk_n),
        .qsfp0_clk_clk_p(qsfp0_clk_clk_p),
        .qsfp0_gt_grx_n(qsfp0_gt_grx_n),
        .qsfp0_gt_grx_p(qsfp0_gt_grx_p),
        .qsfp0_gt_gtx_n(qsfp0_gt_gtx_n),
        .qsfp0_gt_gtx_p(qsfp0_gt_gtx_p),
        .qsfp1_clk_clk_n(qsfp1_clk_clk_n),
        .qsfp1_clk_clk_p(qsfp1_clk_clk_p),
        .qsfp1_gt_grx_n(qsfp1_gt_grx_n),
        .qsfp1_gt_grx_p(qsfp1_gt_grx_p),
        .qsfp1_gt_gtx_n(qsfp1_gt_gtx_n),
        .qsfp1_gt_gtx_p(qsfp1_gt_gtx_p),
        .s_axi_aresetn(proc_sys_reset_0_peripheral_aresetn),
        .s_axi_clk(clk_wizard_0_clk_out1),
        .s_axi_ctl_araddr(interconnect_M01_AXI_ARADDR),
        .s_axi_ctl_arprot(interconnect_M01_AXI_ARPROT),
        .s_axi_ctl_arready(interconnect_M01_AXI_ARREADY),
        .s_axi_ctl_arvalid(interconnect_M01_AXI_ARVALID),
        .s_axi_ctl_awaddr(interconnect_M01_AXI_AWADDR),
        .s_axi_ctl_awprot(interconnect_M01_AXI_AWPROT),
        .s_axi_ctl_awready(interconnect_M01_AXI_AWREADY),
        .s_axi_ctl_awvalid(interconnect_M01_AXI_AWVALID),
        .s_axi_ctl_bready(interconnect_M01_AXI_BREADY),
        .s_axi_ctl_bresp(interconnect_M01_AXI_BRESP),
        .s_axi_ctl_bvalid(interconnect_M01_AXI_BVALID),
        .s_axi_ctl_rdata(interconnect_M01_AXI_RDATA),
        .s_axi_ctl_rready(interconnect_M01_AXI_RREADY),
        .s_axi_ctl_rresp(interconnect_M01_AXI_RRESP),
        .s_axi_ctl_rvalid(interconnect_M01_AXI_RVALID),
        .s_axi_ctl_wdata(interconnect_M01_AXI_WDATA),
        .s_axi_ctl_wready(interconnect_M01_AXI_WREADY),
        .s_axi_ctl_wstrb(interconnect_M01_AXI_WSTRB),
        .s_axi_ctl_wvalid(interconnect_M01_AXI_WVALID),
        .s_axi_dcmac_araddr(interconnect_M00_AXI_ARADDR),
        .s_axi_dcmac_arready(interconnect_M00_AXI_ARREADY),
        .s_axi_dcmac_arvalid(interconnect_M00_AXI_ARVALID),
        .s_axi_dcmac_awaddr(interconnect_M00_AXI_AWADDR),
        .s_axi_dcmac_awready(interconnect_M00_AXI_AWREADY),
        .s_axi_dcmac_awvalid(interconnect_M00_AXI_AWVALID),
        .s_axi_dcmac_bready(interconnect_M00_AXI_BREADY),
        .s_axi_dcmac_bresp(interconnect_M00_AXI_BRESP),
        .s_axi_dcmac_bvalid(interconnect_M00_AXI_BVALID),
        .s_axi_dcmac_rdata(interconnect_M00_AXI_RDATA),
        .s_axi_dcmac_rready(interconnect_M00_AXI_RREADY),
        .s_axi_dcmac_rresp(interconnect_M00_AXI_RRESP),
        .s_axi_dcmac_rvalid(interconnect_M00_AXI_RVALID),
        .s_axi_dcmac_wdata(interconnect_M00_AXI_WDATA),
        .s_axi_dcmac_wready(interconnect_M00_AXI_WREADY),
        .s_axi_dcmac_wvalid(interconnect_M00_AXI_WVALID),
        .tx0_user_clk(clk_wizard_0_clk_out1),
        .tx0_user_resetn(proc_sys_reset_0_peripheral_aresetn),
        .tx0_user_tdata(packet_gen_0_axis_out_TDATA),
        .tx0_user_tkeep(packet_gen_0_axis_out_TKEEP),
        .tx0_user_tlast(packet_gen_0_axis_out_TLAST),
        .tx0_user_tready(packet_gen_0_axis_out_TREADY),
        .tx0_user_tvalid(packet_gen_0_axis_out_TVALID),
        .tx1_user_clk(clk_wizard_0_clk_out1),
        .tx1_user_resetn(proc_sys_reset_0_peripheral_aresetn),
        .tx1_user_tdata(packet_gen_1_axis_out_TDATA),
        .tx1_user_tkeep(packet_gen_1_axis_out_TKEEP),
        .tx1_user_tlast(packet_gen_1_axis_out_TLAST),
        .tx1_user_tready(packet_gen_1_axis_out_TREADY),
        .tx1_user_tvalid(packet_gen_1_axis_out_TVALID));
endmodule

(* CORE_GENERATION_INFO = "top_level,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=top_level,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=58,numReposBlks=47,numNonXlnxBlks=0,numHierBlks=11,maxHierDepth=3,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=21,numPkgbdBlks=1,bdsource=USER,da_cips_cnt=1,synth_mode=Hierarchical}" *) (* HW_HANDOFF = "top_level.hwdef" *) 
module top_level
   (UART_rxd,
    UART_txd,
    qsfp0_clk_clk_n,
    qsfp0_clk_clk_p,
    qsfp0_gt_grx_n,
    qsfp0_gt_grx_p,
    qsfp0_gt_gtx_n,
    qsfp0_gt_gtx_p,
    qsfp1_clk_clk_n,
    qsfp1_clk_clk_p,
    qsfp1_gt_grx_n,
    qsfp1_gt_grx_p,
    qsfp1_gt_gtx_n,
    qsfp1_gt_gtx_p);
  (* X_INTERFACE_INFO = "xilinx.com:interface:uart:1.0 UART RxD" *) (* X_INTERFACE_MODE = "Master" *) input UART_rxd;
  (* X_INTERFACE_INFO = "xilinx.com:interface:uart:1.0 UART TxD" *) output UART_txd;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 qsfp0_clk CLK_N" *) (* X_INTERFACE_MODE = "Slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME qsfp0_clk, CAN_DEBUG false, FREQ_HZ 156250000" *) input [0:0]qsfp0_clk_clk_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 qsfp0_clk CLK_P" *) input [0:0]qsfp0_clk_clk_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:gt:1.0 qsfp0_gt GRX_N" *) (* X_INTERFACE_MODE = "Master" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME qsfp0_gt, CAN_DEBUG false" *) input [3:0]qsfp0_gt_grx_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:gt:1.0 qsfp0_gt GRX_P" *) input [3:0]qsfp0_gt_grx_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:gt:1.0 qsfp0_gt GTX_N" *) output [3:0]qsfp0_gt_gtx_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:gt:1.0 qsfp0_gt GTX_P" *) output [3:0]qsfp0_gt_gtx_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 qsfp1_clk CLK_N" *) (* X_INTERFACE_MODE = "Slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME qsfp1_clk, CAN_DEBUG false, FREQ_HZ 156250000" *) input [0:0]qsfp1_clk_clk_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 qsfp1_clk CLK_P" *) input [0:0]qsfp1_clk_clk_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:gt:1.0 qsfp1_gt GRX_N" *) (* X_INTERFACE_MODE = "Master" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME qsfp1_gt, CAN_DEBUG false" *) input [3:0]qsfp1_gt_grx_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:gt:1.0 qsfp1_gt GRX_P" *) input [3:0]qsfp1_gt_grx_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:gt:1.0 qsfp1_gt GTX_N" *) output [3:0]qsfp1_gt_gtx_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:gt:1.0 qsfp1_gt GTX_P" *) output [3:0]qsfp1_gt_gtx_p;

  wire UART_rxd;
  wire UART_txd;
  wire [63:0]axi_uart_bridge_M_AXI_ARADDR;
  wire axi_uart_bridge_M_AXI_ARREADY;
  wire axi_uart_bridge_M_AXI_ARVALID;
  wire [63:0]axi_uart_bridge_M_AXI_AWADDR;
  wire axi_uart_bridge_M_AXI_AWREADY;
  wire axi_uart_bridge_M_AXI_AWVALID;
  wire axi_uart_bridge_M_AXI_BREADY;
  wire [1:0]axi_uart_bridge_M_AXI_BRESP;
  wire axi_uart_bridge_M_AXI_BVALID;
  wire [0:0]axi_uart_bridge_M_AXI_RDATA;
  wire axi_uart_bridge_M_AXI_RREADY;
  wire [1:0]axi_uart_bridge_M_AXI_RRESP;
  wire axi_uart_bridge_M_AXI_RVALID;
  wire [31:0]axi_uart_bridge_M_AXI_WDATA;
  wire axi_uart_bridge_M_AXI_WREADY;
  wire [3:0]axi_uart_bridge_M_AXI_WSTRB;
  wire axi_uart_bridge_M_AXI_WVALID;
  wire clk_wizard_0_clk_out1;
  wire [0:0]proc_sys_reset_0_peripheral_aresetn;
  wire [0:0]qsfp0_clk_clk_n;
  wire [0:0]qsfp0_clk_clk_p;
  wire [3:0]qsfp0_gt_grx_n;
  wire [3:0]qsfp0_gt_grx_p;
  wire [3:0]qsfp0_gt_gtx_n;
  wire [3:0]qsfp0_gt_gtx_p;
  wire [0:0]qsfp1_clk_clk_n;
  wire [0:0]qsfp1_clk_clk_p;
  wire [3:0]qsfp1_gt_grx_n;
  wire [3:0]qsfp1_gt_grx_p;
  wire [3:0]qsfp1_gt_gtx_n;
  wire [3:0]qsfp1_gt_gtx_p;

  axi_uart_bridge_imp_1OII57Q axi_uart_bridge
       (.M_AXI_araddr(axi_uart_bridge_M_AXI_ARADDR),
        .M_AXI_arready(axi_uart_bridge_M_AXI_ARREADY),
        .M_AXI_arvalid(axi_uart_bridge_M_AXI_ARVALID),
        .M_AXI_awaddr(axi_uart_bridge_M_AXI_AWADDR),
        .M_AXI_awready(axi_uart_bridge_M_AXI_AWREADY),
        .M_AXI_awvalid(axi_uart_bridge_M_AXI_AWVALID),
        .M_AXI_bready(axi_uart_bridge_M_AXI_BREADY),
        .M_AXI_bresp(axi_uart_bridge_M_AXI_BRESP),
        .M_AXI_bvalid(axi_uart_bridge_M_AXI_BVALID),
        .M_AXI_rdata(axi_uart_bridge_M_AXI_RDATA),
        .M_AXI_rready(axi_uart_bridge_M_AXI_RREADY),
        .M_AXI_rresp(axi_uart_bridge_M_AXI_RRESP),
        .M_AXI_rvalid(axi_uart_bridge_M_AXI_RVALID),
        .M_AXI_wdata(axi_uart_bridge_M_AXI_WDATA),
        .M_AXI_wready(axi_uart_bridge_M_AXI_WREADY),
        .M_AXI_wstrb(axi_uart_bridge_M_AXI_WSTRB),
        .M_AXI_wvalid(axi_uart_bridge_M_AXI_WVALID),
        .UART_rxd(UART_rxd),
        .UART_txd(UART_txd),
        .aclk(clk_wizard_0_clk_out1),
        .aresetn(proc_sys_reset_0_peripheral_aresetn));
  clk_and_reset_imp_OK11XN clk_and_reset
       (.peripheral_aresetn(proc_sys_reset_0_peripheral_aresetn),
        .sys_clk(clk_wizard_0_clk_out1));
  pl_rtl_imp_QFYSB7 pl_rtl
       (.S00_AXI_araddr(axi_uart_bridge_M_AXI_ARADDR),
        .S00_AXI_arready(axi_uart_bridge_M_AXI_ARREADY),
        .S00_AXI_arvalid(axi_uart_bridge_M_AXI_ARVALID),
        .S00_AXI_awaddr(axi_uart_bridge_M_AXI_AWADDR),
        .S00_AXI_awready(axi_uart_bridge_M_AXI_AWREADY),
        .S00_AXI_awvalid(axi_uart_bridge_M_AXI_AWVALID),
        .S00_AXI_bready(axi_uart_bridge_M_AXI_BREADY),
        .S00_AXI_bresp(axi_uart_bridge_M_AXI_BRESP),
        .S00_AXI_bvalid(axi_uart_bridge_M_AXI_BVALID),
        .S00_AXI_rdata(axi_uart_bridge_M_AXI_RDATA),
        .S00_AXI_rready(axi_uart_bridge_M_AXI_RREADY),
        .S00_AXI_rresp(axi_uart_bridge_M_AXI_RRESP),
        .S00_AXI_rvalid(axi_uart_bridge_M_AXI_RVALID),
        .S00_AXI_wdata(axi_uart_bridge_M_AXI_WDATA),
        .S00_AXI_wready(axi_uart_bridge_M_AXI_WREADY),
        .S00_AXI_wstrb(axi_uart_bridge_M_AXI_WSTRB),
        .S00_AXI_wvalid(axi_uart_bridge_M_AXI_WVALID),
        .aclk(clk_wizard_0_clk_out1),
        .aresetn(proc_sys_reset_0_peripheral_aresetn),
        .qsfp0_clk_clk_n(qsfp0_clk_clk_n),
        .qsfp0_clk_clk_p(qsfp0_clk_clk_p),
        .qsfp0_gt_grx_n(qsfp0_gt_grx_n),
        .qsfp0_gt_grx_p(qsfp0_gt_grx_p),
        .qsfp0_gt_gtx_n(qsfp0_gt_gtx_n),
        .qsfp0_gt_gtx_p(qsfp0_gt_gtx_p),
        .qsfp1_clk_clk_n(qsfp1_clk_clk_n),
        .qsfp1_clk_clk_p(qsfp1_clk_clk_p),
        .qsfp1_gt_grx_n(qsfp1_gt_grx_n),
        .qsfp1_gt_grx_p(qsfp1_gt_grx_p),
        .qsfp1_gt_gtx_n(qsfp1_gt_gtx_n),
        .qsfp1_gt_gtx_p(qsfp1_gt_gtx_p));
endmodule
