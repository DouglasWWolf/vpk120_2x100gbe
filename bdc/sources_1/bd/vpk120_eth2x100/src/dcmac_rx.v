//====================================================================================
//                        ------->  Revision History  <------
//====================================================================================
//
//   Date     Who   Ver  Changes
//====================================================================================
// 21-Sep-25  DWW     1  Initial creation
//====================================================================================


/*
    Converts DCMAC rx segments into individual AXI streams
*/ 


module dcmac_rx # (parameter FIFO_DEPTH = 512)
(
    input clk, resetn,

    // This is asserted when the inputs are valid
    input           valid,
    
    // Four input segments
    input[127:0]    data0, data1, data2, data3,
    input           ena0,  ena1,  ena2,  ena3,
    input           err0,  err1,  err2,  err3,
    input           sop0,  sop1,  sop2,  sop3,
    input           eop0,  eop1,  eop2,  eop3,
    input[3:0]      mty0,  mty1,  mty2,  mty3,

    // Four output FIFOs, one per input segment
    output[127:0]   seg0_tdata,  seg1_tdata,  seg2_tdata,  seg3_tdata,
    output[15:0]    seg0_tkeep,  seg1_tkeep,  seg2_tkeep,  seg3_tkeep,
    output[2:0]     seg0_tuser,  seg1_tuser,  seg2_tuser,  seg3_tuser,
    output          seg0_tlast,  seg1_tlast,  seg2_tlast,  seg3_tlast,
    output          seg0_tvalid, seg1_tvalid, seg2_tvalid, seg3_tvalid,
    input           seg0_tready, seg1_tready, seg2_tready, seg3_tready
);

// Convert an "mty" field to tkeep format
wire[15:0] mty_to_tkeep[0:15];
assign mty_to_tkeep[ 0] = 16'b1111_1111_1111_1111;
assign mty_to_tkeep[ 1] = 16'b0111_1111_1111_1111;
assign mty_to_tkeep[ 2] = 16'b0011_1111_1111_1111;
assign mty_to_tkeep[ 3] = 16'b0001_1111_1111_1111;
assign mty_to_tkeep[ 4] = 16'b0000_1111_1111_1111;
assign mty_to_tkeep[ 5] = 16'b0000_0111_1111_1111;
assign mty_to_tkeep[ 6] = 16'b0000_0011_1111_1111;
assign mty_to_tkeep[ 7] = 16'b0000_0001_1111_1111;
assign mty_to_tkeep[ 8] = 16'b0000_0000_1111_1111;
assign mty_to_tkeep[ 9] = 16'b0000_0000_0111_1111;
assign mty_to_tkeep[10] = 16'b0000_0000_0011_1111;
assign mty_to_tkeep[11] = 16'b0000_0000_0001_1111;
assign mty_to_tkeep[12] = 16'b0000_0000_0000_1111;
assign mty_to_tkeep[13] = 16'b0000_0000_0000_0111;
assign mty_to_tkeep[14] = 16'b0000_0000_0000_0011;
assign mty_to_tkeep[15] = 16'b0000_0000_0000_0001;


// "tdata" input to the FIFOs
wire[127:0] in0_tdata = (valid & ena0) ? data0 : 0;
wire[127:0] in1_tdata = (valid & ena1) ? data1 : 0;
wire[127:0] in2_tdata = (valid & ena2) ? data2 : 0;
wire[127:0] in3_tdata = (valid & ena3) ? data3 : 0;

// "tkeep" input to the FIFOs
wire[  15:0] in0_tkeep = (valid & ena0) ? mty_to_tkeep[mty0] : 0;
wire[  15:0] in1_tkeep = (valid & ena1) ? mty_to_tkeep[mty1] : 0;
wire[  15:0] in2_tkeep = (valid & ena2) ? mty_to_tkeep[mty2] : 0;
wire[  15:0] in3_tkeep = (valid & ena3) ? mty_to_tkeep[mty3] : 0;

// "tuser" input to the FIFOs
wire[   2:0] in0_tuser = (valid & ena0) ? {err0, sop0, ena0} : 0;
wire[   2:0] in1_tuser = (valid & ena1) ? {err1, sop1, ena1} : 0;
wire[   2:0] in2_tuser = (valid & ena2) ? {err2, sop2, ena2} : 0;
wire[   2:0] in3_tuser = (valid & ena3) ? {err3, sop3, ena3} : 0;

// "tlast" input to the FIFOs
wire         in0_tlast = (valid & ena0) ? eop0 : 0;
wire         in1_tlast = (valid & ena1) ? eop1 : 0;
wire         in2_tlast = (valid & ena2) ? eop2 : 0;
wire         in3_tlast = (valid & ena3) ? eop3 : 0;

// "tvalid" input to the FIFOs
wire         in0_tvalid = (valid & ena0);
wire         in1_tvalid = (valid & ena1);
wire         in2_tvalid = (valid & ena2);
wire         in3_tvalid = (valid & ena3);


//-----------------------------------------------------------------------------
//                AXI Stream Data FIFO for Segment 0
//-----------------------------------------------------------------------------
xpm_fifo_axis #
(
    .FIFO_DEPTH      (FIFO_DEPTH),
    .TDATA_WIDTH     (128),
    .TUSER_WIDTH     (3),
    .FIFO_MEMORY_TYPE("auto"),
    .PACKET_FIFO     ("false"),
    .USE_ADV_FEATURES("0000"),
    .CLOCKING_MODE   ("common_clock")
)
i_fifo0
(
    // Clock and reset
    .s_aclk   (clk   ),
    .m_aclk   (clk   ),
    .s_aresetn(resetn),

    // The input bus to the FIFO
    .s_axis_tdata   (in0_tdata),
    .s_axis_tkeep   (in0_tkeep),
    .s_axis_tuser   (in0_tuser),
    .s_axis_tlast   (in0_tlast),
    .s_axis_tvalid  (in0_tvalid),
    .s_axis_tready  (),

    // The output bus of the FIFO
    .m_axis_tdata   (seg0_tdata),
    .m_axis_tkeep   (seg0_tkeep),
    .m_axis_tuser   (seg0_tuser),
    .m_axis_tlast   (seg0_tlast),
    .m_axis_tvalid  (seg0_tvalid),
    .m_axis_tready  (seg0_tready),

    // Unused input stream signals
    .s_axis_tdest(),
    .s_axis_tid  (),
    .s_axis_tstrb(),

    // Unused output stream signals
    .m_axis_tdest(),
    .m_axis_tid  (),
    .m_axis_tstrb(),

    // Other unused signals
    .almost_empty_axis(),
    .almost_full_axis(),
    .dbiterr_axis(),
    .prog_empty_axis(),
    .prog_full_axis(),
    .rd_data_count_axis(),
    .sbiterr_axis(),
    .wr_data_count_axis(),
    .injectdbiterr_axis(),
    .injectsbiterr_axis()
);
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
//                AXI Stream Data FIFO for Segment 0
//-----------------------------------------------------------------------------
xpm_fifo_axis #
(
    .FIFO_DEPTH      (FIFO_DEPTH),
    .TDATA_WIDTH     (128),
    .TUSER_WIDTH     (3),
    .FIFO_MEMORY_TYPE("auto"),
    .PACKET_FIFO     ("false"),
    .USE_ADV_FEATURES("0000"),
    .CLOCKING_MODE   ("common_clock")
)
i_fifo1
(
    // Clock and reset
    .s_aclk   (clk   ),
    .m_aclk   (clk   ),
    .s_aresetn(resetn),

    // The input bus to the FIFO
    .s_axis_tdata   (in1_tdata),
    .s_axis_tkeep   (in1_tkeep),
    .s_axis_tuser   (in1_tuser),
    .s_axis_tlast   (in1_tlast),
    .s_axis_tvalid  (in1_tvalid),
    .s_axis_tready  (),

    // The output bus of the FIFO
    .m_axis_tdata   (seg1_tdata),
    .m_axis_tkeep   (seg1_tkeep),
    .m_axis_tuser   (seg1_tuser),
    .m_axis_tlast   (seg1_tlast),
    .m_axis_tvalid  (seg1_tvalid),
    .m_axis_tready  (seg1_tready),

    // Unused input stream signals
    .s_axis_tdest(),
    .s_axis_tid  (),
    .s_axis_tstrb(),

    // Unused output stream signals
    .m_axis_tdest(),
    .m_axis_tid  (),
    .m_axis_tstrb(),

    // Other unused signals
    .almost_empty_axis(),
    .almost_full_axis(),
    .dbiterr_axis(),
    .prog_empty_axis(),
    .prog_full_axis(),
    .rd_data_count_axis(),
    .sbiterr_axis(),
    .wr_data_count_axis(),
    .injectdbiterr_axis(),
    .injectsbiterr_axis()
);
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
//                AXI Stream Data FIFO for Segment 0
//-----------------------------------------------------------------------------
xpm_fifo_axis #
(
    .FIFO_DEPTH      (FIFO_DEPTH),
    .TDATA_WIDTH     (128),
    .TUSER_WIDTH     (3),
    .FIFO_MEMORY_TYPE("auto"),
    .PACKET_FIFO     ("false"),
    .USE_ADV_FEATURES("0000"),
    .CLOCKING_MODE   ("common_clock")
)
i_fifo2
(
    // Clock and reset
    .s_aclk   (clk   ),
    .m_aclk   (clk   ),
    .s_aresetn(resetn),

    // The input bus to the FIFO
    .s_axis_tdata   (in2_tdata),
    .s_axis_tkeep   (in2_tkeep),
    .s_axis_tuser   (in2_tuser),
    .s_axis_tlast   (in2_tlast),
    .s_axis_tvalid  (in2_tvalid),
    .s_axis_tready  (),

    // The output bus of the FIFO
    .m_axis_tdata   (seg2_tdata),
    .m_axis_tkeep   (seg2_tkeep),
    .m_axis_tuser   (seg2_tuser),
    .m_axis_tlast   (seg2_tlast),
    .m_axis_tvalid  (seg2_tvalid),
    .m_axis_tready  (seg2_tready),

    // Unused input stream signals
    .s_axis_tdest(),
    .s_axis_tid  (),
    .s_axis_tstrb(),

    // Unused output stream signals
    .m_axis_tdest(),
    .m_axis_tid  (),
    .m_axis_tstrb(),

    // Other unused signals
    .almost_empty_axis(),
    .almost_full_axis(),
    .dbiterr_axis(),
    .prog_empty_axis(),
    .prog_full_axis(),
    .rd_data_count_axis(),
    .sbiterr_axis(),
    .wr_data_count_axis(),
    .injectdbiterr_axis(),
    .injectsbiterr_axis()
);
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
//                AXI Stream Data FIFO for Segment 0
//-----------------------------------------------------------------------------
xpm_fifo_axis #
(
    .FIFO_DEPTH      (FIFO_DEPTH),
    .TDATA_WIDTH     (128),
    .TUSER_WIDTH     (3),
    .FIFO_MEMORY_TYPE("auto"),
    .PACKET_FIFO     ("false"),
    .USE_ADV_FEATURES("0000"),
    .CLOCKING_MODE   ("common_clock")
)
i_fifo3
(
    // Clock and reset
    .s_aclk   (clk   ),
    .m_aclk   (clk   ),
    .s_aresetn(resetn),

    // The input bus to the FIFO
    .s_axis_tdata   (in3_tdata),
    .s_axis_tkeep   (in3_tkeep),
    .s_axis_tuser   (in3_tuser),
    .s_axis_tlast   (in3_tlast),
    .s_axis_tvalid  (in3_tvalid),
    .s_axis_tready  (),

    // The output bus of the FIFO
    .m_axis_tdata   (seg3_tdata),
    .m_axis_tkeep   (seg3_tkeep),
    .m_axis_tuser   (seg3_tuser),
    .m_axis_tlast   (seg3_tlast),
    .m_axis_tvalid  (seg3_tvalid),
    .m_axis_tready  (seg3_tready),

    // Unused input stream signals
    .s_axis_tdest(),
    .s_axis_tid  (),
    .s_axis_tstrb(),

    // Unused output stream signals
    .m_axis_tdest(),
    .m_axis_tid  (),
    .m_axis_tstrb(),

    // Other unused signals
    .almost_empty_axis(),
    .almost_full_axis(),
    .dbiterr_axis(),
    .prog_empty_axis(),
    .prog_full_axis(),
    .rd_data_count_axis(),
    .sbiterr_axis(),
    .wr_data_count_axis(),
    .injectdbiterr_axis(),
    .injectsbiterr_axis()
);
//-----------------------------------------------------------------------------

endmodule


