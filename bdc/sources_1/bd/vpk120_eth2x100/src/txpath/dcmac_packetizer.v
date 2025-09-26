
//====================================================================================
//                        ------->  Revision History  <------
//====================================================================================
//
//   Date     Who   Ver  Changes
//====================================================================================
// 24-Sep-25  DWW     1  Initial creation
//====================================================================================

/*
    This module packetizes 4 AXI streams and ensures that data entering (and
    therefore, exiting) the four FIFOS always enters & exits in lockstep.
*/

module dcmac_packetizer # (parameter MAX_PACKET_SIZE = 16384)
(

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF axis0_in:axis1_in:axis2_in:axis3_in:axis0_out:axis1_out:axis2_out:axis3_out" *)
    input   clk,
    input resetn,

    // Input streams
    input [127:0]   axis0_in_tdata,  axis1_in_tdata,  axis2_in_tdata,  axis3_in_tdata,         
    input [  4:0]   axis0_in_tuser,  axis1_in_tuser,  axis2_in_tuser,  axis3_in_tuser,       
    input           axis0_in_tlast,  axis1_in_tlast,  axis2_in_tlast,  axis3_in_tlast,       
    input           axis0_in_tvalid, axis1_in_tvalid, axis2_in_tvalid, axis3_in_tvalid,       
    output          axis0_in_tready, axis1_in_tready, axis2_in_tready, axis3_in_tready,     


    // Output streams
    output [127:0]  axis0_out_tdata,  axis1_out_tdata,  axis2_out_tdata,  axis3_out_tdata,      
    output [  4:0]  axis0_out_tuser,  axis1_out_tuser,  axis2_out_tuser,  axis3_out_tuser,    
    output          axis0_out_tlast,  axis1_out_tlast,  axis2_out_tlast,  axis3_out_tlast,    
    output          axis0_out_tvalid, axis1_out_tvalid, axis2_out_tvalid, axis3_out_tvalid,    
    input           axis0_out_tready, axis1_out_tready, axis2_out_tready, axis3_out_tready  
);

// We want our FIFOs to be built of uram
localparam FIFO_MEMORY_TYPE = "ultra";

// Our datapath is four segments of 16 bytes each for a total 
// of 64 bytes wide.   Determine how many data-cycles we will
// have to store in order to store our largest possible packet.
localparam FIFO_DEPTH = MAX_PACKET_SIZE / 64;

// These are how the the FIFOs notify us that they are ready for input
wire fifo0_in_tready, fifo1_in_tready, fifo2_in_tready, fifo3_in_tready;

// This is asserted when all four input streams are presenting data
// and all four FIFOs are ready to receive it.
wire handshake = axis0_in_tvalid & axis1_in_tvalid &
                 axis2_in_tvalid & axis3_in_tvalid &
                 fifo0_in_tready & fifo1_in_tready &
                 fifo2_in_tready & fifo3_in_tready;

// No input stream will accept input until they can all accept input
assign axis0_in_tready = handshake;
assign axis1_in_tready = handshake;
assign axis2_in_tready = handshake;
assign axis3_in_tready = handshake;

// Incoming data hasn't "arrived" until it has arrived on all four segments. 
// this will gaurantee that data is written into all four FIFOs in lockstep 
// and therefore, data will be emitted from all four FIFOs in lockstep.
//
// Also, data is not considered "arrived" until all four FIFOs are ready to receive it
wire fifo_in_tvalid = handshake;

//-----------------------------------------------------------------------------
//                AXI Stream Data FIFO for Segment 0
//-----------------------------------------------------------------------------
xpm_fifo_axis #
(
    .FIFO_DEPTH      (FIFO_DEPTH),
    .TDATA_WIDTH     (128),
    .TUSER_WIDTH     (5),
    .FIFO_MEMORY_TYPE(FIFO_MEMORY_TYPE),
    .PACKET_FIFO     ("true"),
    .USE_ADV_FEATURES("0000"),
    .CLOCKING_MODE   ("common")
)
i_fifo0
(
    // Clock and reset
    .s_aclk         (clk),
    .m_aclk         (clk),
    .s_aresetn      (resetn),

    // The input bus to the FIFO
    .s_axis_tvalid  (fifo_in_tvalid),
    .s_axis_tdata   (axis0_in_tdata),
    .s_axis_tuser   (axis0_in_tuser),
    .s_axis_tlast   (axis0_in_tlast),
    .s_axis_tready  (fifo0_in_tready),

    // The output bus of the FIFO
    .m_axis_tdata   (axis0_out_tdata),
    .m_axis_tuser   (axis0_out_tuser),
    .m_axis_tlast   (axis0_out_tlast),
    .m_axis_tvalid  (axis0_out_tvalid),
    .m_axis_tready  (axis0_out_tready),

    // Unused input stream signals
    .s_axis_tdest(),
    .s_axis_tkeep(),
    .s_axis_tid  (),
    .s_axis_tstrb(),

    // Unused output stream signals
    .m_axis_tdest(),
    .m_axis_tkeep(),
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
//                AXI Stream Data FIFO for Segment 1
//-----------------------------------------------------------------------------
xpm_fifo_axis #
(
    .FIFO_DEPTH      (FIFO_DEPTH),
    .TDATA_WIDTH     (128),
    .TUSER_WIDTH     (5),
    .FIFO_MEMORY_TYPE(FIFO_MEMORY_TYPE),
    .PACKET_FIFO     ("true"),
    .USE_ADV_FEATURES("0000"),
    .CLOCKING_MODE   ("common")
)
i_fifo1
(
    // Clock and reset
    .s_aclk         (clk),
    .m_aclk         (clk),
    .s_aresetn      (resetn),

    // The input bus to the FIFO
    .s_axis_tvalid  (fifo_in_tvalid),
    .s_axis_tdata   (axis1_in_tdata),
    .s_axis_tuser   (axis1_in_tuser),
    .s_axis_tlast   (axis1_in_tlast),
    .s_axis_tready  (fifo1_in_tready),

    // The output bus of the FIFO
    .m_axis_tdata   (axis1_out_tdata),
    .m_axis_tuser   (axis1_out_tuser),
    .m_axis_tlast   (axis1_out_tlast),
    .m_axis_tvalid  (axis1_out_tvalid),
    .m_axis_tready  (axis1_out_tready),

    // Unused input stream signals
    .s_axis_tdest(),
    .s_axis_tkeep(),
    .s_axis_tid  (),
    .s_axis_tstrb(),

    // Unused output stream signals
    .m_axis_tdest(),
    .m_axis_tkeep(),
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
//                AXI Stream Data FIFO for Segment 2
//-----------------------------------------------------------------------------
xpm_fifo_axis #
(
    .FIFO_DEPTH      (FIFO_DEPTH),
    .TDATA_WIDTH     (128),
    .TUSER_WIDTH     (5),
    .FIFO_MEMORY_TYPE(FIFO_MEMORY_TYPE),
    .PACKET_FIFO     ("true"),
    .USE_ADV_FEATURES("0000"),
    .CLOCKING_MODE   ("common")
)
i_fifo2
(
    // Clock and reset
    .s_aclk         (clk),
    .m_aclk         (clk),
    .s_aresetn      (resetn),

    // The input bus to the FIFO
    .s_axis_tvalid  (fifo_in_tvalid),
    .s_axis_tdata   (axis2_in_tdata),
    .s_axis_tuser   (axis2_in_tuser),
    .s_axis_tlast   (axis2_in_tlast),
    .s_axis_tready  (fifo2_in_tready),

    // The output bus of the FIFO
    .m_axis_tdata   (axis2_out_tdata),
    .m_axis_tuser   (axis2_out_tuser),
    .m_axis_tlast   (axis2_out_tlast),
    .m_axis_tvalid  (axis2_out_tvalid),
    .m_axis_tready  (axis2_out_tready),

    // Unused input stream signals
    .s_axis_tdest(),
    .s_axis_tkeep(),
    .s_axis_tid  (),
    .s_axis_tstrb(),

    // Unused output stream signals
    .m_axis_tdest(),
    .m_axis_tkeep(),
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
//                AXI Stream Data FIFO for Segment 3
//-----------------------------------------------------------------------------
xpm_fifo_axis #
(
    .FIFO_DEPTH      (FIFO_DEPTH),
    .TDATA_WIDTH     (128),
    .TUSER_WIDTH     (5),
    .FIFO_MEMORY_TYPE(FIFO_MEMORY_TYPE),
    .PACKET_FIFO     ("true"),
    .USE_ADV_FEATURES("0000"),
    .CLOCKING_MODE   ("common")
)
i_fifo3
(
    // Clock and reset
    .s_aclk         (clk),
    .m_aclk         (clk),
    .s_aresetn      (resetn),

    // The input bus to the FIFO
    .s_axis_tvalid  (fifo_in_tvalid),
    .s_axis_tdata   (axis3_in_tdata),
    .s_axis_tuser   (axis3_in_tuser),
    .s_axis_tlast   (axis3_in_tlast),
    .s_axis_tready  (fifo3_in_tready),

    // The output bus of the FIFO
    .m_axis_tdata   (axis3_out_tdata),
    .m_axis_tuser   (axis3_out_tuser),
    .m_axis_tlast   (axis3_out_tlast),
    .m_axis_tvalid  (axis3_out_tvalid),
    .m_axis_tready  (axis3_out_tready),

    // Unused input stream signals
    .s_axis_tdest(),
    .s_axis_tkeep(),
    .s_axis_tid  (),
    .s_axis_tstrb(),

    // Unused output stream signals
    .m_axis_tdest(),
    .m_axis_tkeep(),
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