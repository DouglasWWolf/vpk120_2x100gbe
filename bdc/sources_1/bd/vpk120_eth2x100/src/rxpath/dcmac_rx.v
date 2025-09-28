//====================================================================================
//                        ------->  Revision History  <------
//====================================================================================
//
//   Date     Who   Ver  Changes
//====================================================================================
// 21-Sep-25  DWW     1  Initial creation
//====================================================================================


/*
    Converts DCMAC rx segments into buffered (via FIFOs) AXI streams.
    "Missing" input segments (i.e., segments with "ena" deasserted)
    are not written to the output FIFOs.

    On the output side, we carry the DMCAC "mty0/mty1/mty2/mty3" signals
    in the AXI stream "TID" field.
*/ 


module dcmac_rx # (parameter FIFO_DEPTH = 512)
(
    input clk, resetn,

    // This is asserted when the inputs are valid
    input           i_valid,
    
    // Four input segments
    input[127:0]    i_data0, i_data1, i_data2, i_data3,
    input           i_ena0,  i_ena1,  i_ena2,  i_ena3,
    input           i_err0,  i_err1,  i_err2,  i_err3,
    input           i_sop0,  i_sop1,  i_sop2,  i_sop3,
    input           i_eop0,  i_eop1,  i_eop2,  i_eop3,
    input[3:0]      i_mty0,  i_mty1,  i_mty2,  i_mty3,

    // Four output FIFOs, one per input segment
    output[127:0]   seg0_tdata,  seg1_tdata,  seg2_tdata,  seg3_tdata,
    output[  3:0]   seg0_tid,    seg1_tid,    seg2_tid,    seg3_tid,
    output[  2:0]   seg0_tuser,  seg1_tuser,  seg2_tuser,  seg3_tuser,
    output          seg0_tlast,  seg1_tlast,  seg2_tlast,  seg3_tlast,
    output          seg0_tvalid, seg1_tvalid, seg2_tvalid, seg3_tvalid,
    input           seg0_tready, seg1_tready, seg2_tready, seg3_tready
);

//=============================================================================
// We're going to register the inputs to make timing closure a little easier
//=============================================================================
reg           valid;
reg[127:0]    data0, data1, data2, data3;
reg            ena0,  ena1,  ena2,  ena3;
reg            err0,  err1,  err2,  err3;
reg            sop0,  sop1,  sop2,  sop3;
reg            eop0,  eop1,  eop2,  eop3;
reg[3:0]       mty0,  mty1,  mty2,  mty3;
//-----------------------------------------------------------------------------
always @(posedge clk) begin
    valid <= i_valid;

    data0 <= i_data0;
    data1 <= i_data1;
    data2 <= i_data2;
    data3 <= i_data3;

    ena0  <= i_ena0;
    ena1  <= i_ena1;
    ena2  <= i_ena2;
    ena3  <= i_ena3;        

    err0  <= i_err0;
    err1  <= i_err1;
    err2  <= i_err2;
    err3  <= i_err3;        

    sop0  <= i_sop0;
    sop1  <= i_sop1;
    sop2  <= i_sop2;
    sop3  <= i_sop3;        

    eop0  <= i_eop0;
    eop1  <= i_eop1;
    eop2  <= i_eop2;
    eop3  <= i_eop3;        

    mty0  <= i_mty0;
    mty1  <= i_mty1;
    mty2  <= i_mty2;
    mty3  <= i_mty3;        
end
//=============================================================================

// We're going to mask-off unused databytes to 0 to make the data
// eaiser to interpret during debugging
wire[127:0] mask[0:15];
assign mask[ 0] = 128'hFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF;
assign mask[ 1] = 128'h00FFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF;
assign mask[ 2] = 128'h0000FFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF;
assign mask[ 3] = 128'h000000FF_FFFFFFFF_FFFFFFFF_FFFFFFFF;
assign mask[ 4] = 128'h00000000_FFFFFFFF_FFFFFFFF_FFFFFFFF;
assign mask[ 5] = 128'h00000000_00FFFFFF_FFFFFFFF_FFFFFFFF;
assign mask[ 6] = 128'h00000000_0000FFFF_FFFFFFFF_FFFFFFFF;
assign mask[ 7] = 128'h00000000_000000FF_FFFFFFFF_FFFFFFFF;
assign mask[ 8] = 128'h00000000_00000000_FFFFFFFF_FFFFFFFF;
assign mask[ 9] = 128'h00000000_00000000_00FFFFFF_FFFFFFFF;
assign mask[10] = 128'h00000000_00000000_0000FFFF_FFFFFFFF;
assign mask[11] = 128'h00000000_00000000_000000FF_FFFFFFFF;
assign mask[12] = 128'h00000000_00000000_00000000_FFFFFFFF;
assign mask[13] = 128'h00000000_00000000_00000000_00FFFFFF;
assign mask[14] = 128'h00000000_00000000_00000000_0000FFFF;
assign mask[15] = 128'h00000000_00000000_00000000_000000FF;

// "tdata" input to the FIFOs
wire[127:0] in0_tdata = (valid & ena0) ? data0 & mask[mty0] : 0;
wire[127:0] in1_tdata = (valid & ena1) ? data1 & mask[mty1] : 0;
wire[127:0] in2_tdata = (valid & ena2) ? data2 & mask[mty2] : 0;
wire[127:0] in3_tdata = (valid & ena3) ? data3 & mask[mty3] : 0;

// We're going to carry "mty" in the AXI stream "TID" field
wire[   3:0] in0_tid = (valid & ena0) ? mty0 : 0;
wire[   3:0] in1_tid = (valid & ena1) ? mty1 : 0;
wire[   3:0] in2_tid = (valid & ena2) ? mty2 : 0;
wire[   3:0] in3_tid = (valid & ena3) ? mty3 : 0;

// "tuser" input to the FIFOs
wire[   2:0] in0_tuser = (valid & ena0) ? {ena0, sop0, err0} : 0;
wire[   2:0] in1_tuser = (valid & ena1) ? {ena1, sop1, err1} : 0;
wire[   2:0] in2_tuser = (valid & ena2) ? {ena2, sop2, err2} : 0;
wire[   2:0] in3_tuser = (valid & ena3) ? {ena3, sop3, err3} : 0;

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
    .TID_WIDTH       (4),
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
    .s_axis_tdata   (in0_tdata ),
    .s_axis_tid     (in0_tid   ),
    .s_axis_tuser   (in0_tuser ),
    .s_axis_tlast   (in0_tlast ),
    .s_axis_tvalid  (in0_tvalid),
    .s_axis_tready  (),

    // The output bus of the FIFO
    .m_axis_tdata   (seg0_tdata),
    .m_axis_tid     (seg0_tid  ),
    .m_axis_tuser   (seg0_tuser),
    .m_axis_tlast   (seg0_tlast),
    .m_axis_tvalid  (seg0_tvalid),
    .m_axis_tready  (seg0_tready),

    // Unused input stream signals
    .s_axis_tdest(),
    .s_axis_tkeep(),
    .s_axis_tstrb(),

    // Unused output stream signals
    .m_axis_tdest(),
    .m_axis_tkeep(),
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
    .TID_WIDTH       (4),
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
    .s_axis_tdata   (in1_tdata ),
    .s_axis_tid     (in1_tid   ),
    .s_axis_tuser   (in1_tuser ),
    .s_axis_tlast   (in1_tlast ),
    .s_axis_tvalid  (in1_tvalid),
    .s_axis_tready  (),

    // The output bus of the FIFO
    .m_axis_tdata   (seg1_tdata ),
    .m_axis_tid     (seg1_tid   ),
    .m_axis_tuser   (seg1_tuser ),
    .m_axis_tlast   (seg1_tlast ),
    .m_axis_tvalid  (seg1_tvalid),
    .m_axis_tready  (seg1_tready),

    // Unused input stream signals
    .s_axis_tdest(),
    .s_axis_tkeep(),
    .s_axis_tstrb(),

    // Unused output stream signals
    .m_axis_tdest(),
    .m_axis_tkeep(),
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
    .TID_WIDTH       (4),    
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
    .s_axis_tdata   (in2_tdata ),
    .s_axis_tid     (in2_tid   ),
    .s_axis_tuser   (in2_tuser ),
    .s_axis_tlast   (in2_tlast ),
    .s_axis_tvalid  (in2_tvalid),
    .s_axis_tready  (),

    // The output bus of the FIFO
    .m_axis_tdata   (seg2_tdata ),
    .m_axis_tid     (seg2_tid   ),
    .m_axis_tuser   (seg2_tuser ),
    .m_axis_tlast   (seg2_tlast ),
    .m_axis_tvalid  (seg2_tvalid),
    .m_axis_tready  (seg2_tready),

    // Unused input stream signals
    .s_axis_tdest(),
    .s_axis_tkeep(),
    .s_axis_tstrb(),

    // Unused output stream signals
    .m_axis_tdest(),
    .m_axis_tkeep(),
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
    .TID_WIDTH       (4),
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
    .s_axis_tdata   (in3_tdata ),
    .s_axis_tid     (in3_tid   ),
    .s_axis_tuser   (in3_tuser ),
    .s_axis_tlast   (in3_tlast ),
    .s_axis_tvalid  (in3_tvalid),
    .s_axis_tready  (),

    // The output bus of the FIFO
    .m_axis_tdata   (seg3_tdata ),
    .m_axis_tid     (seg3_tid   ),
    .m_axis_tuser   (seg3_tuser ), 
    .m_axis_tlast   (seg3_tlast ),
    .m_axis_tvalid  (seg3_tvalid),
    .m_axis_tready  (seg3_tready),

    // Unused input stream signals
    .s_axis_tdest(),
    .s_axis_tkeep(),
    .s_axis_tstrb(),

    // Unused output stream signals
    .m_axis_tdest(),
    .m_axis_tkeep(),
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


