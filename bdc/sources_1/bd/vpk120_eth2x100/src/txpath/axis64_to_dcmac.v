//====================================================================================
//                        ------->  Revision History  <------
//====================================================================================
//
//   Date     Who   Ver  Changes
//====================================================================================
// 24-Aug-25  DWW     1  Initial creation
//====================================================================================

/*
    This module segmentizes a 512 bit wide input stream into 4 128-bit wide 
    output streams
*/

module axis64_to_dcmac 
(

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s_axis_clk CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF axis_in" *)
    input   s_axis_clk,
    input   s_resetn,

    // Input stream, in the "s_axis_clk" clock domain
    input[511:0]   axis_in_tdata,
    input[ 63:0]   axis_in_tkeep,
    input          axis_in_tlast,
    input          axis_in_tvalid,
    output         axis_in_tready,

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 m_axis_clk CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF axis0_out:axis1_out:axis2_out:axis3_out" *)
    input   m_axis_clk,

    // Output streams, in the "m_axis_clk" clock domain
    output [127:0]   axis0_out_tdata,  axis1_out_tdata,  axis2_out_tdata,  axis3_out_tdata,      
    output [  4:0]   axis0_out_tuser,  axis1_out_tuser,  axis2_out_tuser,  axis3_out_tuser,    
    output           axis0_out_tlast,  axis1_out_tlast,  axis2_out_tlast,  axis3_out_tlast,    
    output           axis0_out_tvalid, axis1_out_tvalid, axis2_out_tvalid, axis3_out_tvalid,    
    input            axis0_out_tready, axis1_out_tready, axis2_out_tready, axis3_out_tready  
);

// Used in functions
integer n;

//=============================================================================
// UW, SW, and SB are dictated by the size of a DCMAC segment 
//=============================================================================
localparam UW = 5;      // TUSER tracks the number of empty bytes in a cycle
localparam SW = 128;    // A segment is 128 bits wide
localparam SB = 16;     // A segment is 16 bytes wide
//=============================================================================

// The output FIFOs don't need to be very deep, they are just being used to 
// cross clock domains
localparam FIFO_DEPTH = 16;

//=============================================================================
// zero_bits() - This function counts the '0' bits a tkeep segment
//=============================================================================
function[UW-1:0] zero_bits(input[SB-1:0] field);
begin
    zero_bits = 0;
    for (n=0; n<SB; n=n+1) zero_bits = zero_bits + (field[n] == 0);
end
endfunction
//=============================================================================

// Segmentize axis_in_tdata
wire[SW-1:0] fifo0_tdata = axis_in_tdata[0 * SW +: SW];
wire[SW-1:0] fifo1_tdata = axis_in_tdata[1 * SW +: SW];
wire[SW-1:0] fifo2_tdata = axis_in_tdata[2 * SW +: SW];
wire[SW-1:0] fifo3_tdata = axis_in_tdata[3 * SW +: SW]; 

// Keep track of the number of zero bits in each segment of axis_in_tkeep
wire[UW-1:0] fifo0_tuser = zero_bits(axis_in_tkeep[0 * SB +: SB]);
wire[UW-1:0] fifo1_tuser = zero_bits(axis_in_tkeep[1 * SB +: SB]);
wire[UW-1:0] fifo2_tuser = zero_bits(axis_in_tkeep[2 * SB +: SB]);
wire[UW-1:0] fifo3_tuser = zero_bits(axis_in_tkeep[3 * SB +: SB]);

// One "FIFO is ready to accept data" bit per FIFO
wire[3:0] fifo_tready;

// A data exchange happens when axis_in_tvalid is asserted
// and all four FIFOs are ready to receive it
wire fifo_tvalid = axis_in_tvalid & (fifo_tready == 4'b1111);

// The module sending data to us will receive an acknowlegement
// only after all four FIFOs are ready to accept data
assign axis_in_tready = (fifo_tready == 4'b1111);


//-----------------------------------------------------------------------------
//                AXI Stream Data FIFO for Segment 0
//-----------------------------------------------------------------------------
xpm_fifo_axis #
(
    .FIFO_DEPTH      (FIFO_DEPTH),
    .TDATA_WIDTH     (SW),
    .TUSER_WIDTH     (UW),
    .FIFO_MEMORY_TYPE("auto"),
    .PACKET_FIFO     ("false"),
    .USE_ADV_FEATURES("0000"),
    .CLOCKING_MODE   ("independent_clock")
)
i_fifo0
(
    // Clock and reset
    .s_aclk         (s_axis_clk),
    .m_aclk         (m_axis_clk),
    .s_aresetn      (s_resetn  ),

    // The input bus to the FIFO
    .s_axis_tdata   (fifo0_tdata),
    .s_axis_tuser   (fifo0_tuser),
    .s_axis_tlast   (axis_in_tlast),
    .s_axis_tvalid  (fifo_tvalid),
    .s_axis_tready  (fifo_tready[0]),

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
    .TDATA_WIDTH     (SW),
    .TUSER_WIDTH     (UW),
    .FIFO_MEMORY_TYPE("auto"),
    .PACKET_FIFO     ("false"),
    .USE_ADV_FEATURES("0000"),
    .CLOCKING_MODE   ("independent_clock")
)
i_fifo1
(
    // Clock and reset
    .s_aclk         (s_axis_clk),
    .m_aclk         (m_axis_clk),
    .s_aresetn      (s_resetn  ),

    // The input bus to the FIFO
    .s_axis_tdata   (fifo1_tdata),
    .s_axis_tuser   (fifo1_tuser),
    .s_axis_tlast   (axis_in_tlast),
    .s_axis_tvalid  (fifo_tvalid),
    .s_axis_tready  (fifo_tready[1]),

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
    .TDATA_WIDTH     (SW),
    .TUSER_WIDTH     (UW),
    .FIFO_MEMORY_TYPE("auto"),
    .PACKET_FIFO     ("false"),
    .USE_ADV_FEATURES("0000"),
    .CLOCKING_MODE   ("independent_clock")
)
i_fifo2
(
    // Clock and reset
    .s_aclk         (s_axis_clk),
    .m_aclk         (m_axis_clk),
    .s_aresetn      (s_resetn  ),

    // The input bus to the FIFO
    .s_axis_tdata   (fifo2_tdata),
    .s_axis_tuser   (fifo2_tuser),
    .s_axis_tlast   (axis_in_tlast),
    .s_axis_tvalid  (fifo_tvalid),
    .s_axis_tready  (fifo_tready[2]),

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
    .TDATA_WIDTH     (SW),
    .TUSER_WIDTH     (UW),
    .FIFO_MEMORY_TYPE("auto"),
    .PACKET_FIFO     ("false"),
    .USE_ADV_FEATURES("0000"),
    .CLOCKING_MODE   ("independent_clock")
)
i_fifo3
(
    // Clock and reset
    .s_aclk         (s_axis_clk),
    .m_aclk         (m_axis_clk),
    .s_aresetn      (s_resetn  ),

    // The input bus to the FIFO
    .s_axis_tdata   (fifo3_tdata),
    .s_axis_tuser   (fifo3_tuser),
    .s_axis_tlast   (axis_in_tlast),
    .s_axis_tvalid  (fifo_tvalid),
    .s_axis_tready  (fifo_tready[3]),

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


