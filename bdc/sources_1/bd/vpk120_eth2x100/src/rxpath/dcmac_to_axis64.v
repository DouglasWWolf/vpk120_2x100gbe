//====================================================================================
//                        ------->  Revision History  <------
//====================================================================================
//
//   Date     Who   Ver  Changes
//====================================================================================
// 26-Sep-25  DWW     1  Initial creation
//====================================================================================

/*
    This turns 4 input segments from the DCMAC into a single 64-byte wide
    output AXI stream.

    We're somewhat abusing the concept of "AXI Streams" on the inputs here. 
    The four input streams are really DCMAC segments. We are using AXI streams
    to represent our segments largely so that it's super convenient to examine
    them in an ILA at debug time.  Using AXI streams to carry DCMAC segments
    also means the usual assortment of AXI Stream IP functionality (FIFOs,
    clock-crossing, register slices, etc) is available to us without having to
    create them from scratch.
    
    Here's how the DCMAC segment signals are mapped into the AXI input streams:
                    DCMAC               AXI    
                   ---------------- = -----------
                    tdata           =  tdata         
                    tvalid*         =  tvalid*         
                    mty             =  tid              
                    {ena, sop, err} =  tuser               
                    eop             =  tlast         

    Data always arrives on the four input segments in lockstep.  Because the 
    output FIFOs cross clock domains, data is not gauranteed to egress those
    FIFOs in lockstop.  Other logic in this file ensures that data is not 
    emitted on the output stream until valid date is present at the output of
    all four FIFOs

    *Note:
    
    Since data arrives in lockstep, the input tvalids will always
    assert/deassert simultaneously.

*/


module dcmac_to_axis64 # (parameter FIFO_DEPTH = 128)
(
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s_clk CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF in0:in1:in2:in3" *)
    input   s_clk,
    input   s_resetn,

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 m_axis_clk CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF m_axis" *)
    input   m_axis_clk,

    // Input streams, one per segment
    input [127:0] in0_tdata,   in1_tdata,  in2_tdata,   in3_tdata,     
    input [  3:0] in0_tid,     in1_tid,    in2_tid,     in3_tid,       
    input [  2:0] in0_tuser,   in1_tuser,  in2_tuser,   in3_tuser,     
    input         in0_tlast,   in1_tlast,  in2_tlast,   in3_tlast,     
    input         in0_tvalid,  in1_tvalid, in2_tvalid,  in3_tvalid,    

    // The single, unified output stream
    output [511:0] m_axis_tdata,
    output [ 63:0] m_axis_tkeep,
    output [  1:0] m_axis_tuser,
    output         m_axis_tlast,
    output         m_axis_tvalid,
    input          m_axis_tready
);
genvar  i;


// These are determined by the geometry of the DCMAC and should never change
localparam DW=128;
localparam UW=3;
localparam IW=4;

// These are the signals packed into TUSER
localparam TUSER_ERR = 0;
localparam TUSER_SOP = 1;
localparam TUSER_ENA = 2;


// Convert a DCMAC "mty" field to tkeep format
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



//=============================================================================
// Here we register the inputs to make timing closure easier.  These
// registers are going to be fed to the input side of the FIFOs
//=============================================================================
reg         r_tvalid;
reg[DW-1:0] r_tdata[0:3];
reg[IW-1:0] r_tid  [0:3];
reg[UW-1:0] r_tuser[0:3];
reg         r_tlast[0:3];
//-----------------------------------------------------------------------------
always @(posedge s_clk) begin
    r_tvalid   <= in0_tvalid;

    r_tdata[0] <= in0_tdata;
    r_tuser[0] <= in0_tuser;
    r_tlast[0] <= in0_tlast;
      r_tid[0] <= in0_tid;

    r_tdata[1] <= in1_tdata;
    r_tuser[1] <= in1_tuser;
    r_tlast[1] <= in1_tlast;
      r_tid[1] <= in1_tid;

    r_tdata[2] <= in2_tdata;
    r_tuser[2] <= in2_tuser;
    r_tlast[2] <= in2_tlast;
      r_tid[2] <= in2_tid;

    r_tdata[3] <= in3_tdata;
    r_tuser[3] <= in3_tuser;
    r_tlast[3] <= in3_tlast;
      r_tid[3] <= in3_tid;
end
//=============================================================================


//=============================================================================
// These are the output side of the FIFOs
//=============================================================================
wire          fifo_tvalid[0:3];
reg           fifo_tready;
wire [DW-1:0] fifo_tdata [0:3];
wire [IW-1:0] fifo_tid   [0:3];
wire [UW-1:0] fifo_tuser [0:3];
wire          fifo_tlast [0:3];
//=============================================================================


// This will be asserted when all FIFOs are presenting valid data and the 
// module downstream of us is ready to accept it
wire handshake = fifo_tvalid[0] & fifo_tvalid[1]
               & fifo_tvalid[2] & fifo_tvalid[3]
               & m_axis_tready;

// These are the "segment enabled" bit for each segment
wire[3:0] ena =
{
    fifo_tuser[3][TUSER_ENA],
    fifo_tuser[2][TUSER_ENA],
    fifo_tuser[1][TUSER_ENA],
    fifo_tuser[0][TUSER_ENA]
};

// Fill in m_axis_tdata from the FIFO outputs
assign m_axis_tdata[DW*0 +: DW] = ena[0] ? fifo_tdata[0] : 0;
assign m_axis_tdata[DW*1 +: DW] = ena[1] ? fifo_tdata[1] : 0;
assign m_axis_tdata[DW*2 +: DW] = ena[2] ? fifo_tdata[2] : 0;
assign m_axis_tdata[DW*3 +: DW] = ena[3] ? fifo_tdata[3] : 0;

// Fill in m_axis_tkeep from the FIFO outputs
assign m_axis_tkeep[16*0 +: 16] = ena[0] ? mty_to_tkeep[fifo_tid[0]] : 0;
assign m_axis_tkeep[16*1 +: 16] = ena[1] ? mty_to_tkeep[fifo_tid[1]] : 0;
assign m_axis_tkeep[16*2 +: 16] = ena[2] ? mty_to_tkeep[fifo_tid[2]] : 0;
assign m_axis_tkeep[16*3 +: 16] = ena[3] ? mty_to_tkeep[fifo_tid[3]] : 0;

// Our tuser of the output stream only needs the 'err' and 'sop' signals
assign m_axis_tuser = fifo_tuser[0][1:0]
                    | fifo_tuser[1][1:0]
                    | fifo_tuser[2][1:0]
                    | fifo_tuser[3][1:0];

// If any segment shows "end of packet", reflect that in m_axis_tlast                     
assign m_axis_tlast = fifo_tlast[0]
                    | fifo_tlast[1]
                    | fifo_tlast[2]
                    | fifo_tlast[3];

// Write data to the output stream when all FIFOs and the receiver are ready
assign m_axis_tvalid = handshake;

//-----------------------------------------------------------------------------
//              AXI Stream Data FIFO for all four segments
//-----------------------------------------------------------------------------
for (i=0; i<4; i=i+1) begin
    xpm_fifo_axis #
    (
        .FIFO_DEPTH      (FIFO_DEPTH),
        .TDATA_WIDTH     (DW),
        .TUSER_WIDTH     (UW),
        .TID_WIDTH       (IW),
        .FIFO_MEMORY_TYPE("auto"),
        .PACKET_FIFO     ("false"),
        .USE_ADV_FEATURES("0000"),
        .CLOCKING_MODE   ("independent_clock")
    )
    i_fifo
    (
        // Clock and reset
        .s_aclk         (s_clk     ),
        .m_aclk         (m_axis_clk),
        .s_aresetn      (s_resetn  ),

        // The input bus to the FIFO
        .s_axis_tdata   (r_tdata[i]),
        .s_axis_tuser   (r_tuser[i]),
        .s_axis_tid     (r_tid  [i]),
        .s_axis_tlast   (r_tlast[i]),
        .s_axis_tvalid  (r_tvalid  ),
        .s_axis_tready  (          ),

        // The output bus of the FIFO
        .m_axis_tdata   (fifo_tdata [i]),
        .m_axis_tuser   (fifo_tuser [i]),
        .m_axis_tid     (fifo_tid   [i]),
        .m_axis_tlast   (fifo_tlast [i]),
        .m_axis_tvalid  (fifo_tvalid[i]),
        .m_axis_tready  (handshake     ),

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
end
//-----------------------------------------------------------------------------





endmodule