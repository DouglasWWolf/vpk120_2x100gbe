
module dcmac_helper # (parameter MAX_PORTS = 6, DW = 256)
(
    // Reset for the tx_axis_0 and rx_axis_0.  Synchronous to axis_clk
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 axis0_resetn RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
    output  axis0_resetn,

    // Reset for the tx_axis_1 and rx_axis_1. Synchronous to axis_clk
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 axis1_resetn RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
    output  axis1_resetn,

    // This is the clock that is used for DCMAC AXI4MM register access
    input s_axi_clk,

    // Transceiver loopback mode
    input[2:0] gt_loopback_in,

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 axis_clk_in CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF tx_axis_0:tx_axis_1:axis_in0:axis_in1, ASSOCIATED_RESET axis0_resetn:axis1_resetn" *)
    input axis_clk_in,
    input core_clk_in,
    input ts_clk_in,
    input clkwiz_locked,

    // To DCMAC
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0  rx_core_clk  CLK" *)
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 781250000" *)
    output rx_core_clk,

    // To DCMAC 
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0  tx_core_clk  CLK" *)
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 781250000" *)
    output tx_core_clk,

    // To DCMAC
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0  rx_axi_clk  CLK" *)
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 390625000" *)
    output rx_axi_clk,

    // To DCMAC
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 tx_axi_clk CLK" *)
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 390625000" *)
    output tx_axi_clk,

    // To DCMAC
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0  rx_flexif_clk  CLK" *)
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 390625000" *)
    output[MAX_PORTS-1:0] rx_flexif_clk,

    // To DCMAC
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0  tx_flexif_clk  CLK" *)
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 390625000" *)
    output[MAX_PORTS-1:0] tx_flexif_clk,

    // To DCMAC
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0  rx_macif_clk  CLK" *)
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 390625000" *)
    output rx_macif_clk,

    // To DCMAC
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0  tx_macif_clk  CLK" *)
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 390625000" *)
    output tx_macif_clk,

    // To DCMAC
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0  ts_clk  CLK" *)
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 300000000" *)
    output[MAX_PORTS-1:0] ts_clk,

    // These come from the GT Quad
    input ch0_rx_usr_clk_0,
    input ch0_rx_usr_clk_1,
    input ch0_tx_usr_clk_0,
    input ch0_tx_usr_clk_1,
    input ch0_rx_usr_clk2_0,
    input ch0_rx_usr_clk2_1,
    input ch0_tx_usr_clk2_0,
    input ch0_tx_usr_clk2_1,

    // Clocks from the GT Quad that connect to the DCMAC
    (* X_INTERFACE_INFO = "xilinx.com:signal:gt_usrclk:1.0 rx_serdes_clk CLK" *)
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 644531000" *)
    output[MAX_PORTS-1:0] rx_serdes_clk,

    (* X_INTERFACE_INFO = "xilinx.com:signal:gt_usrclk:1.0 tx_serdes_clk CLK" *)
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 644531000" *)
    output[MAX_PORTS-1:0] tx_serdes_clk,

    (* X_INTERFACE_INFO = "xilinx.com:signal:gt_usrclk:1.0 rx_alt_serdes_clk CLK" *)
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 322265500" *)

    output[MAX_PORTS-1:0] rx_alt_serdes_clk,
    (* X_INTERFACE_INFO = "xilinx.com:signal:gt_usrclk:1.0 tx_alt_serdes_clk CLK" *)
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 322265500" *)
    output[MAX_PORTS-1:0] tx_alt_serdes_clk,



    // From the GT Quads
    input           gtpowergood_0,
    input           gtpowergood_1,

    // To the DCMAC
    output          gtpowergood_in,

    // From user-logic
    input[1:0]      user_gt_reset_rx_datapath,
    input           user_gt_reset_all,

    // To DCMAC
    output          gt_reset_tx_datapath_in_0,
    output          gt_reset_tx_datapath_in_1,
    output          gt_reset_rx_datapath_in_0,
    output          gt_reset_rx_datapath_in_1,
    output          gt_reset_all_in,

    // From DCMAC
    input           gt_rx_reset_done_out_0,
    input           gt_rx_reset_done_out_1,
    input           gt_rx_reset_done_out_2,
    input           gt_rx_reset_done_out_3,
    input           gt_rx_reset_done_out_4,
    input           gt_rx_reset_done_out_5,
    input           gt_rx_reset_done_out_6,
    input           gt_rx_reset_done_out_7,
    input           gt_tx_reset_done_out_0,
    input           gt_tx_reset_done_out_1,
    input           gt_tx_reset_done_out_2,
    input           gt_tx_reset_done_out_3,
    input           gt_tx_reset_done_out_4,
    input           gt_tx_reset_done_out_5,
    input           gt_tx_reset_done_out_6,
    input           gt_tx_reset_done_out_7,

    // To user-logic, one "reset_done" per MAC port
    output[1:0]     gt_rx_reset_done,
    output[1:0]     gt_tx_reset_done,

    // A standard AXI-Stream input
    input[DW-1:0]   axis_in0_tdata,
    input[DW/8-1:0] axis_in0_tkeep,
    input           axis_in0_tlast,
    input           axis_in0_tvalid,
    output          axis_in0_tready,


    // A standard AXI-Stream input
    input[DW-1:0]   axis_in1_tdata,
    input[DW/8-1:0] axis_in1_tkeep,
    input           axis_in1_tlast,
    input           axis_in1_tvalid,
    output          axis_in1_tready,

    // To DCMAC - AXI stream ports
    output        tx_axis_tvalid_0,
    output[127:0] tx_axis_tdata0,     tx_axis_tdata1,
    output        tx_axis_tuser_ena0, tx_axis_tuser_ena1,
    output        tx_axis_tuser_sop0, tx_axis_tuser_sop1,
    output        tx_axis_tuser_eop0, tx_axis_tuser_eop1,
    output[3:0]   tx_axis_tuser_mty0, tx_axis_tuser_mty1,
    output        tx_axis_tuser_err0, tx_axis_tuser_err1,
    input         tx_axis_tready_0,

    // To DCMAC - AXI stream ports
    output        tx_axis_tvalid_1,
    output[127:0] tx_axis_tdata2,     tx_axis_tdata3,
    output        tx_axis_tuser_ena2, tx_axis_tuser_ena3,
    output        tx_axis_tuser_sop2, tx_axis_tuser_sop3,
    output        tx_axis_tuser_eop2, tx_axis_tuser_eop3,
    output[3:0]   tx_axis_tuser_mty2, tx_axis_tuser_mty3,
    output        tx_axis_tuser_err2, tx_axis_tuser_err3,
    input         tx_axis_tready_1,

    // To DCMAC
    output[2:0] gt_loopback_0,  gt_loopback_1,
    output      gt_rxcdrhold_0, gt_rxcdrhold_1,

    // These drive the GT Quads
    output[6:0] gt_txmaincursor,
    output[5:0] gt_txprecursor,
    output[5:0] gt_txpostcursor
);

// These generated clocks all go to the DCMAC
assign rx_core_clk   = core_clk_in;
assign tx_core_clk   = core_clk_in;
assign rx_axi_clk    = axis_clk_in;
assign tx_axi_clk    = axis_clk_in;
assign rx_macif_clk  = axis_clk_in;
assign tx_macif_clk  = axis_clk_in;
assign rx_flexif_clk = {MAX_PORTS{axis_clk_in}};
assign tx_flexif_clk = {MAX_PORTS{axis_clk_in}};
assign ts_clk        = {MAX_PORTS{ts_clk_in}};

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//            The DCMAC serdes clock inputs from the GT Quads
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
assign rx_alt_serdes_clk = {1'b0,1'b0,1'b0,1'b0, ch0_rx_usr_clk2_1, ch0_rx_usr_clk2_0};
assign tx_alt_serdes_clk = {1'b0,1'b0,1'b0,1'b0, ch0_tx_usr_clk2_1, ch0_tx_usr_clk2_0};
assign rx_serdes_clk     = {1'b0,1'b0,1'b0,1'b0, ch0_rx_usr_clk_1 , ch0_rx_usr_clk_0 };
assign tx_serdes_clk     = {1'b0,1'b0,1'b0,1'b0, ch0_tx_usr_clk_1 , ch0_tx_usr_clk_0 };


// Tell the DCMAC when the GT Quads both have good power
assign gtpowergood_in = gtpowergood_0 & gtpowergood_1;

//  To GT Quads
assign gt_loopback_0 = gt_loopback_in;
assign gt_loopback_1 = gt_loopback_in;

// gt_rxcdrhold should be asserted only when the loopback mode is "Near-End PCS"
assign gt_rxcdrhold_0 = (gt_loopback_0 == 1);
assign gt_rxcdrhold_1 = (gt_loopback_1 == 1);

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//            Various signal shaping for the GT Quads
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
localparam DFL_TXMAINCURSOR = 75;
localparam DFL_TXPOSTCURSOR = 9;
localparam DFL_TXPRECURSOR  = 3;
assign gt_txmaincursor = DFL_TXMAINCURSOR;
assign gt_txpostcursor = DFL_TXPOSTCURSOR;
assign gt_txprecursor  = DFL_TXPRECURSOR;


//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//                         GT resets
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
assign gt_reset_tx_datapath_in_0 = 0;
assign gt_reset_tx_datapath_in_1 = 0;
assign gt_reset_rx_datapath_in_0 = user_gt_reset_rx_datapath[0];
assign gt_reset_rx_datapath_in_1 = user_gt_reset_rx_datapath[1];
assign gt_reset_all_in           = user_gt_reset_all;

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//                        GT "reset_done" lines
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
wire[1:0] async_rx_reset_done;
assign async_rx_reset_done[0] = 
{
    gt_rx_reset_done_out_0 &
    gt_rx_reset_done_out_1 &
    gt_rx_reset_done_out_2 &
    gt_rx_reset_done_out_3
};
assign async_rx_reset_done[1] = 
{
    gt_rx_reset_done_out_4 &
    gt_rx_reset_done_out_5 &
    gt_rx_reset_done_out_6 &
    gt_rx_reset_done_out_7
};

wire[1:0] async_tx_reset_done;
assign async_tx_reset_done[0] = 
{
    gt_tx_reset_done_out_0 &
    gt_tx_reset_done_out_1 &
    gt_tx_reset_done_out_2 &
    gt_tx_reset_done_out_3
};

assign async_tx_reset_done[1] = 
{
    gt_tx_reset_done_out_4 &
    gt_tx_reset_done_out_5 &
    gt_tx_reset_done_out_6 &
    gt_tx_reset_done_out_7
};


// Now synchronize rx_reset_done[1:0] to s_axi_clk
xpm_cdc_array_single #
(
   .DEST_SYNC_FF    (4),
   .SRC_INPUT_REG   (0),
   .WIDTH           (2)
)
i_sync_rx_reset_done
(
    .src_clk    (),
    .src_in     (async_rx_reset_done),
    .dest_clk   (s_axi_clk),
    .dest_out   (gt_rx_reset_done)
);


// Now synchronize tx_reset_done[1:0] to s_axi_clk
xpm_cdc_array_single #
(
   .DEST_SYNC_FF    (4),
   .SRC_INPUT_REG   (0),
   .WIDTH           (2)
)
i_sync_tx_reset_done
(
    .src_clk    (),
    .src_in     (async_tx_reset_done),
    .dest_clk   (s_axi_clk),
    .dest_out   (gt_tx_reset_done)
);



// These are the "reset" signals for [tx|rx]_axis0 and [tx|rx]_axis1
wire async_axis0_resetn = clkwiz_locked & async_rx_reset_done[0];
wire async_axis1_resetn = clkwiz_locked & async_rx_reset_done[1];

// Synchronize async_axis0_resetn to axis_clk
xpm_cdc_async_rst #
(
   .DEST_SYNC_FF    (4),
   .RST_ACTIVE_HIGH (0)
)
i_axis0_resetn
(
   .src_arst    (async_axis0_resetn),    
   .dest_arst   (axis0_resetn), 
   .dest_clk    (axis_clk)   
);

// Synchronize async_axis1_resetn to axis_clk
xpm_cdc_async_rst #
(
   .DEST_SYNC_FF    (4),
   .RST_ACTIVE_HIGH (0)
)
i_axis1_resetn
(
   .src_arst    (async_axis1_resetn),    
   .dest_arst   (axis1_resetn), 
   .dest_clk    (axis_clk)   
);

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//      Create an ordinary AXI stream for TX to QSFP_0
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
axis_to_dcmac #
(
    .DW(DW),
    .SW(128)
)
i_axis_to_dcmac_0
(
    .clk                (axis_clk),
    .resetn             (axis_resetn),
    .axis_in_tdata      (axis_in0_tdata),
    .axis_in_tkeep      (axis_in0_tkeep),
    .axis_in_tlast      (axis_in0_tlast),
    .axis_in_tvalid     (axis_in0_tvalid),
    .axis_in_tready     (axis_in0_tready),

    .tx_axis_tdata0     (tx_axis_tdata0),
    .tx_axis_tuser_ena0 (tx_axis_tuser_ena0),
    .tx_axis_tuser_sop0 (tx_axis_tuser_sop0),
    .tx_axis_tuser_eop0 (tx_axis_tuser_eop0),
    .tx_axis_tuser_err0 (tx_axis_tuser_err0),
    .tx_axis_tuser_mty0 (tx_axis_tuser_mty0),

    .tx_axis_tdata1     (tx_axis_tdata1),
    .tx_axis_tuser_ena1 (tx_axis_tuser_ena1),
    .tx_axis_tuser_sop1 (tx_axis_tuser_sop1),
    .tx_axis_tuser_eop1 (tx_axis_tuser_eop1),
    .tx_axis_tuser_err1 (tx_axis_tuser_err1),
    .tx_axis_tuser_mty1 (tx_axis_tuser_mty1),

    .tx_axis_tdata2     (),
    .tx_axis_tuser_ena2 (),
    .tx_axis_tuser_sop2 (),
    .tx_axis_tuser_eop2 (),
    .tx_axis_tuser_err2 (),
    .tx_axis_tuser_mty2 (),

    .tx_axis_tdata3     (),
    .tx_axis_tuser_ena3 (),
    .tx_axis_tuser_sop3 (),
    .tx_axis_tuser_eop3 (),
    .tx_axis_tuser_err3 (),
    .tx_axis_tuser_mty3 (),

    .tx_axis_tvalid     (tx_axis_tvalid_0),
    .tx_axis_tready     (tx_axis_tready_0)
);



//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//      Create an ordinary AXI stream for TX to QSFP_1
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
axis_to_dcmac #
(
    .DW(DW),
    .SW(128)
)
i_axis_to_dcmac_1
(
    .clk                (axis_clk),
    .resetn             (axis_resetn),
    .axis_in_tdata      (axis_in1_tdata),
    .axis_in_tkeep      (axis_in1_tkeep),
    .axis_in_tlast      (axis_in1_tlast),
    .axis_in_tvalid     (axis_in1_tvalid),
    .axis_in_tready     (axis_in1_tready),

    .tx_axis_tdata0     (tx_axis_tdata2),
    .tx_axis_tuser_ena0 (tx_axis_tuser_ena2),
    .tx_axis_tuser_sop0 (tx_axis_tuser_sop2),
    .tx_axis_tuser_eop0 (tx_axis_tuser_eop2),
    .tx_axis_tuser_err0 (tx_axis_tuser_err2),
    .tx_axis_tuser_mty0 (tx_axis_tuser_mty2),

    .tx_axis_tdata1     (tx_axis_tdata3),
    .tx_axis_tuser_ena1 (tx_axis_tuser_ena3),
    .tx_axis_tuser_sop1 (tx_axis_tuser_sop3),
    .tx_axis_tuser_eop1 (tx_axis_tuser_eop3),
    .tx_axis_tuser_err1 (tx_axis_tuser_err3),
    .tx_axis_tuser_mty1 (tx_axis_tuser_mty3),

    .tx_axis_tdata2     (),
    .tx_axis_tuser_ena2 (),
    .tx_axis_tuser_sop2 (),
    .tx_axis_tuser_eop2 (),
    .tx_axis_tuser_err2 (),
    .tx_axis_tuser_mty2 (),

    .tx_axis_tdata3     (),
    .tx_axis_tuser_ena3 (),
    .tx_axis_tuser_sop3 (),
    .tx_axis_tuser_eop3 (),
    .tx_axis_tuser_err3 (),
    .tx_axis_tuser_mty3 (),

    .tx_axis_tvalid     (tx_axis_tvalid_1),
    .tx_axis_tready     (tx_axis_tready_1)
);




endmodule
