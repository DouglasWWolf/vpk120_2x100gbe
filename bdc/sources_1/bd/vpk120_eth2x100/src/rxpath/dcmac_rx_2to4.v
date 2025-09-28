//====================================================================================
//                        ------->  Revision History  <------
//====================================================================================
//
//   Date     Who   Ver  Changes
//====================================================================================
// 26-Sep-25  DWW     1  Initial creation
//====================================================================================

/*
    This converts a 2-segment DCMAC output to a 4-segment output.  This module
    assumes that segment deskew has already been done.

    We're somewhat abusing the concept of "AXI Streams" here.   The two input
    streams and the four output streams are really DCMAC segments. We are using
    AXI streams to represent our segments largely so that it's super convenient
    to examine them in an ILA at debug time.  Using AXI streams to carry DCMAC
    segments also means the usual assortment of AXI Stream IP functionality
    (FIFOs, clock-crossing, register slices, etc) is available to us without
    having to create them from scratch.
    
    Here's how the DCMAC segment signals are mapped into the AXI Stream:
                    DCMAC               AXI    
                   ---------------- = -----------
                    tdata           =  tdata         
                    tvalid*         =  tvalid*         
                    mty             =  tid              
                    {ena, sop, err} =  tuser               
                    eop             =  tlast         

    Data always arrives on the two input segments in lockstep and always
    leaves on the four output segments in lockstep.

    *Note:
    
    Since data arrives in lockstep and leaves in lockstep, the input tvalids
    will always assert/deassert simultaneously, and the output tvalids will 
    always assert, deassert simultaneously.   This means that in1_tvalid,
    out1_tvalid, out2_tvalid, and out3_tvalid are redundant.

    The segment-deskew logic, when operating in 2-segment mode, will always
    output data for both segments in lock-step.   Be aware that the 2nd 
    segment will always be empty if the first segment has tlast asserted!

    The segment-deskew logic will never output a pair of segments in which
    both segments are inactive (i.e., empty).   This means that since we
    are are using 64-byte (i.e., four segment) wide output data-cycles, we 
    will have to allow for the fact that in a packet that has at least 2
    empty segments at the end, we will never receive those last two empty
    segments.
*/


module dcmac_rx_2to4 
(
    input   clk, resetn,

    // Input streams, one per segment
    input      [127:0] in0_tdata,   in1_tdata, 
    input      [  3:0] in0_tid,     in1_tid,   
    input      [  2:0] in0_tuser,   in1_tuser, 
    input              in0_tlast,   in1_tlast, 
    input              in0_tvalid,  in1_tvalid,

    // Output streams, one per segment
    output reg [127:0] out0_tdata,  out1_tdata,  out2_tdata,  out3_tdata,
    output reg [  3:0] out0_tid,    out1_tid,    out2_tid,    out3_tid,
    output reg [  2:0] out0_tuser,  out1_tuser,  out2_tuser,  out3_tuser,
    output reg         out0_tlast,  out1_tlast,  out2_tlast,  out3_tlast,
    output             out0_tvalid, out1_tvalid, out2_tvalid, out3_tvalid
);


//=============================================================================
// Here we register the inputs to make timing closure easier
//=============================================================================
reg        r_tvalid;
reg[127:0] r_tdata[0:1];
reg[  3:0]   r_tid[0:1];
reg[  2:0] r_tuser[0:1];
reg        r_tlast[0:1];
//-----------------------------------------------------------------------------
always @(posedge clk) begin
    r_tvalid <= in0_tvalid;

    r_tdata[0] <= in0_tdata;
    r_tuser[0] <= in0_tuser;
    r_tlast[0] <= in0_tlast;
      r_tid[0] <= in0_tid;

    r_tdata[1] <= in1_tdata;
    r_tuser[1] <= in1_tuser;
    r_tlast[1] <= in1_tlast;
      r_tid[1] <= in1_tid;
end
//=============================================================================


//=============================================================================
// All four output streams become valid in lockstep
//=============================================================================
reg    out_tvalid;
assign out0_tvalid = out_tvalid;
assign out1_tvalid = out_tvalid;
assign out2_tvalid = out_tvalid;
assign out3_tvalid = out_tvalid;
//=============================================================================


// A 4-segment output requires two sets of input pairs
reg first_pair;

// This is a truncated (i.e., 2-segment) data-cycle when this is true while
// first_pair is asserted
wire truncated_cycle = (r_tlast[0] | r_tlast[1]);

//=============================================================================
// This state machine clocks out all four segments in lockstep.  
//=============================================================================
always @(posedge clk) begin

    // This cycles high for a single cycle at a time
    out_tvalid <= 0;

    if (resetn == 0) begin
        first_pair <= 1;
    end
    
    else if (r_tvalid) begin
        if (first_pair) begin
            out0_tdata <= r_tdata[0];
            out0_tid   <=   r_tid[0];
            out0_tuser <= r_tuser[0];
            out0_tlast <= r_tlast[0];

            out1_tdata <= r_tdata[1];
            out1_tid   <=   r_tid[1];
            out1_tuser <= r_tuser[1];
            out1_tlast <= r_tlast[1];

            out2_tdata <= 0; 
            out2_tid   <= 0;
            out2_tuser <= 0;
            out2_tlast <= 0;

            out3_tdata <= 0; 
            out3_tid   <= 0;
            out3_tuser <= 0;
            out3_tlast <= 0;

            out_tvalid <= truncated_cycle;
            first_pair <= truncated_cycle;
        end

        else begin
            out2_tdata <= r_tdata[0];
            out2_tid   <=   r_tid[0];
            out2_tuser <= r_tuser[0];
            out2_tlast <= r_tlast[0];

            out3_tdata <= r_tdata[1];
            out3_tid   <=   r_tid[1];
            out3_tuser <= r_tuser[1];
            out3_tlast <= r_tlast[1];

            out_tvalid <= 1;
            first_pair <= 1;
        end

    end
end
//=============================================================================

endmodule
