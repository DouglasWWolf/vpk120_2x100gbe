//====================================================================================
//                        ------->  Revision History  <------
//====================================================================================
//
//   Date     Who   Ver  Changes
//====================================================================================
// 01-Sep-25  DWW     1  Initial creation
//====================================================================================

/*
    This deskews the data segments coming from a DCMAC, re-arranging segments
    to ensure that a new packet always starts on segment 0.

    This module supports DCMAC configurations that have either 2 or 4 segments
    per logical port.
*/


module dcmac_rx_deskew # (parameter SEG_COUNT=2)
(
    input   clk, resetn,

    output dbg_is_active0, dbg_is_active1, dbg_is_active2, dbg_is_active3,

    output[1:0] dbg_first_seg,
    output[1:0] dbg_next_seg,
    output      dbg_has_sop, dbg_has_eop,
    output[2:0] dbg_valid_seg_count,
    output[3:0] dbg_in_tvalid,

    // Input streams, one per segment
    input [127:0]   in0_tdata,  in1_tdata,  in2_tdata,  in3_tdata,
    input [  3:0]   in0_tid,    in1_tid,    in2_tid,    in3_tid,
    input [  2:0]   in0_tuser,  in1_tuser,  in2_tuser,  in3_tuser,
    input           in0_tlast,  in1_tlast,  in2_tlast,  in3_tlast,
    input           in0_tvalid, in1_tvalid, in2_tvalid, in3_tvalid,
    output          in0_tready, in1_tready, in2_tready, in3_tready,

    // Output streams, one per segment
    output reg [127:0] out0_tdata,  out1_tdata,  out2_tdata,  out3_tdata,
    output reg [  3:0] out0_tid,    out1_tid,    out2_tid,    out3_tid,
    output reg [  2:0] out0_tuser,  out1_tuser,  out2_tuser,  out3_tuser,
    output reg         out0_tlast,  out1_tlast,  out2_tlast,  out3_tlast,
    output             out0_tvalid, out1_tvalid, out2_tvalid, out3_tvalid

);


// This will be a '1' if we're in four-segment mode
localparam[0:0] FOUR_SEGS = (SEG_COUNT == 4);

// These are the meanings of the bits in the TUSER fields
localparam TUSER_ERR = 0;
localparam TUSER_SOP = 1;
localparam TUSER_ENA = 2;

//=============================================================================
// This drives out<n>_tvalid
//=============================================================================
reg out_tvalid;
assign out0_tvalid = out_tvalid;
assign out1_tvalid = out_tvalid; 
assign out2_tvalid = out_tvalid & FOUR_SEGS;
assign out3_tvalid = out_tvalid & FOUR_SEGS;
//=============================================================================


//=============================================================================
// Make the in<n>tready signals indexable
//=============================================================================
reg[3:0] in_tready;
assign in0_tready = in_tready[0];
assign in1_tready = in_tready[1];
assign in2_tready = in_tready[2] & FOUR_SEGS;
assign in3_tready = in_tready[3] & FOUR_SEGS;
//=============================================================================

// This is the index of the first input segment
reg [1:0] first_seg;

// Determine the order that input segments go in
wire[1:0] idx0, idx1, idx2, idx3;
if (SEG_COUNT == 2) begin
    assign idx0 = (first_seg + 0) & 1;
    assign idx1 = (first_seg + 1) & 1;
    assign idx2 = 0;
    assign idx3 = 0;
end else begin
    assign idx0 = first_seg + 0;
    assign idx1 = first_seg + 1;
    assign idx2 = first_seg + 2;
    assign idx3 = first_seg + 3;
end

// Make in<n>_tdata indexable
wire [127:0] in_tdata[0:3];
assign in_tdata[0] = in0_tdata;
assign in_tdata[1] = in1_tdata;
assign in_tdata[2] = in2_tdata;
assign in_tdata[3] = in3_tdata;

// Make in<n>_tid indexable
wire [15:0] in_tid[0:3];
assign in_tid[0] = in0_tid;
assign in_tid[1] = in1_tid;
assign in_tid[2] = in2_tid;
assign in_tid[3] = in3_tid;

// Make in<n>_tuser indexable
wire [2:0] in_tuser[0:3];
assign in_tuser[0] = in0_tuser;
assign in_tuser[1] = in1_tuser;
assign in_tuser[2] = in2_tuser;
assign in_tuser[3] = in3_tuser;

// Make in<n>_tlast indexable
wire in_tlast[0:3];
assign in_tlast[0] = in0_tlast;
assign in_tlast[1] = in1_tlast;
assign in_tlast[2] = in2_tlast;
assign in_tlast[3] = in3_tlast;


//=============================================================================
// Build a map of which segments are valid
//=============================================================================
wire   seg_valid[0:3];
assign seg_valid[0] = in0_tvalid;
assign seg_valid[1] = in1_tvalid;
assign seg_valid[2] = in2_tvalid & FOUR_SEGS;
assign seg_valid[3] = in3_tvalid & FOUR_SEGS;

wire[2:0] valid_seg_count = seg_valid[0] + seg_valid[1] 
                          + seg_valid[2] + seg_valid[3];
//=============================================================================


//=============================================================================
// Build a map of which segments are valid end-of-packet segments
//=============================================================================
wire   seg_eop[0:3];
assign seg_eop[0] = in0_tvalid & in0_tlast;
assign seg_eop[1] = in1_tvalid & in1_tlast;
assign seg_eop[2] = in2_tvalid & in2_tlast & FOUR_SEGS;
assign seg_eop[3] = in3_tvalid & in3_tlast & FOUR_SEGS;

// This is asserted when any segment contains an end-of-packet marker
wire has_eop = seg_eop[0] | seg_eop[1] | seg_eop[2] | seg_eop[3];
//=============================================================================


//=============================================================================
// Build a map of which segments are valid start-of-packet segments
//=============================================================================
wire   seg_sop[0:3];
assign seg_sop[0] = in0_tvalid & in0_tuser[TUSER_SOP];
assign seg_sop[1] = in1_tvalid & in1_tuser[TUSER_SOP];
assign seg_sop[2] = in2_tvalid & in2_tuser[TUSER_SOP] & FOUR_SEGS;
assign seg_sop[3] = in3_tvalid & in3_tuser[TUSER_SOP] & FOUR_SEGS;

// This is asserted when any segment contains an start-of-packet marker
wire has_sop = seg_sop[0] | seg_sop[1] | seg_sop[2] | seg_sop[3];
//=============================================================================

//=============================================================================
// "valid_segs" is a 4-bit map of which segments are valid
//=============================================================================
wire[3:0] valid_segs;
//-----------------------------------------------------------------------------
if (SEG_COUNT == 2) begin
    assign valid_segs = {2'b0, seg_valid[idx1], seg_valid[idx0]};
end

if (SEG_COUNT == 4) begin
    assign valid_segs = {seg_valid[idx3], seg_valid[idx2],
                         seg_valid[idx1], seg_valid[idx0]};
end
//=============================================================================


//=============================================================================
// If there is an end-of-packer market on a segment, all higher numbered
// segments are inactive.
//=============================================================================
reg[3:0] is_active;
//-----------------------------------------------------------------------------
wire[3:0] active_segs = seg_eop[idx0] ? valid_segs & 4'b0001 :
                        seg_eop[idx1] ? valid_segs & 4'b0011 :
                        seg_eop[idx2] ? valid_segs & 4'b0111 : valid_segs;
//=============================================================================


//=============================================================================
// This is the equivalent of:
//     is_active[idx0] = active_segs[0];
//     is_active[idx1] = active_segs[1];
//
// And that is the equivelent of:
//   If "first_seg" is 0:
//     is_active[0] = active_segs[0];
//     is_active[1] = active_segs[1];
//
//   If "first_seg" is 1:
//     is_active[1] = active_segs[0];
//     is_active[0] = active_segs[1];
//
//=============================================================================
if (SEG_COUNT == 2) begin
    always @* begin
        case(first_seg[0])
    
            0:  begin
                    is_active = active_segs;
                    in_tready = active_segs;
                end

            1:  begin
                    is_active = {2'b0, active_segs[0], active_segs[1]};
                    in_tready = {2'b0, active_segs[0], active_segs[1]};
                end
        endcase
    end
end
//=============================================================================


//=============================================================================
// This is the equivalent of:
//     is_active[idx0] = active_segs[0];
//     is_active[idx1] = active_segs[1];
//     is_active[idx2] = active_segs[2];
//     is_active[idx3] = active_segs[3];
//
// And that is the equivelent of:
//   If "first_seg" is 0:
//     is_active[0] = active_segs[0];
//     is_active[1] = active_segs[1];
//     is_active[2] = active_segs[2];
//     is_active[3] = active_segs[3];
//
//   If "first_seg" is 1:
//     is_active[1] = active_segs[0];
//     is_active[2] = active_segs[1];
//     is_active[3] = active_segs[2];
//     is_active[0] = active_segs[3];
//
//   If "first_seg" is 2:
//     is_active[2] = active_segs[0];
//     is_active[3] = active_segs[1];
//     is_active[0] = active_segs[2];
//     is_active[1] = active_segs[3];
//
//   If "first_seg" is 3:
//     is_active[3] = active_segs[0];
//     is_active[0] = active_segs[1];
//     is_active[1] = active_segs[2];
//     is_active[2] = active_segs[3];
//
//=============================================================================
if (SEG_COUNT == 4) begin
    always @* begin
        case(first_seg)

            0:  begin
                    is_active = active_segs;
                    in_tready = active_segs;
                end

            1:  begin
                    is_active = {active_segs[2:0], active_segs[3:3]};
                    in_tready = {active_segs[2:0], active_segs[3:3]};
                end

            2:  begin
                    is_active = {active_segs[1:0], active_segs[3:2]};
                    in_tready = {active_segs[1:0], active_segs[3:2]};
                end

            3:  begin
                    is_active = {active_segs[0:0], active_segs[3:1]};
                    in_tready = {active_segs[0:0], active_segs[3:1]};
                end
        endcase
    end
end
//=============================================================================



//=============================================================================
// Determine how the input segments will be mapped at the beginning of the 
// next cycle.   The rules are:
//
// (1) Examine the SOP flags in the segments as they are currently mapped.
//     If one of the segments has an SOP flag, that becomes segment 0 on
//     the next clock cycle.
//
// (2) If no segment had an SOP, did any segment an an EOP?  An "end-of-packet"
//     marker (with no start-of-packet marker on the same cycle) means that
//     the current packet has completed, and the next packet will begin on
//     segment 0.
//
// (3) If there was neither a start-of-packet nor end-of-packet marker on
//     any segment, it means that the ordering of the segments won't change
//     on the next clock cycle
//=============================================================================
reg [1:0] next_seg;
//-----------------------------------------------------------------------------
always @* begin

    if (seg_sop[idx0])
        next_seg = idx0;

    else if (seg_sop[idx1])
        next_seg = idx1;

    else if (FOUR_SEGS & seg_sop[idx2])
        next_seg = idx2;

    else if (FOUR_SEGS & seg_sop[idx3]) 
        next_seg = idx3;

    else if (has_eop)
        next_seg = 0;
    
    else
        next_seg = first_seg;
end
//=============================================================================


//=============================================================================
// Make is_active[] indexable
//=============================================================================
wire   seg_active[0:3];
assign seg_active[0] = is_active[0];
assign seg_active[1] = is_active[1];
assign seg_active[2] = is_active[2];
assign seg_active[3] = is_active[3];
//=============================================================================


//=============================================================================
// This is the main logic that clocks data from input to output
//=============================================================================
always @(posedge clk) begin

    out0_tdata <= 0;
    out1_tdata <= 0;
    out2_tdata <= 0;
    out3_tdata <= 0;

    out0_tid   <= 0;
    out1_tid   <= 0;
    out2_tid   <= 0;
    out3_tid   <= 0;

    out0_tuser <= 0;
    out1_tuser <= 0;
    out2_tuser <= 0;
    out3_tuser <= 0;

    out0_tlast <= 0;
    out1_tlast <= 0;
    out2_tlast <= 0;
    out3_tlast <= 0;

    out_tvalid <= 0;

    if (resetn == 0) begin
        first_seg <= 0;
    end
    
    // If either all input segments are ready or one of 
    // our input segments contains an end-of-packet marker...
    else if (valid_seg_count == SEG_COUNT || has_eop) begin

        if (seg_active[idx0]) begin
            out0_tdata <= in_tdata[idx0];
            out0_tid   <= in_tid  [idx0];
            out0_tuser <= in_tuser[idx0];
            out0_tlast <= in_tlast[idx0];
        end

        if (seg_active[idx1]) begin
            out1_tdata <= in_tdata[idx1];
            out1_tid   <= in_tid  [idx1];
            out1_tuser <= in_tuser[idx1];
            out1_tlast <= in_tlast[idx1];
        end

        if (FOUR_SEGS & seg_active[idx2]) begin
            out2_tdata <= in_tdata[idx2];
            out2_tid   <= in_tid  [idx2];
            out2_tuser <= in_tuser[idx2];
            out2_tlast <= in_tlast[idx2];
        end

        if (FOUR_SEGS & seg_active[idx3]) begin
            out3_tdata <= in_tdata[idx3];
            out3_tid   <= in_tid  [idx3];
            out3_tuser <= in_tuser[idx3];
            out3_tlast <= in_tlast[idx3];
        end

        // Clock out this output cycle
        out_tvalid <= 1;

        // Map the input segments for the next data-cycle
        first_seg <= next_seg;
    end
end
//=============================================================================

assign dbg_is_active0      = is_active[0];
assign dbg_is_active1      = is_active[1];
assign dbg_is_active2      = is_active[2];
assign dbg_is_active3      = is_active[3];
assign dbg_first_seg       = first_seg;
assign dbg_next_seg        = next_seg;
assign dbg_has_sop         = has_sop;
assign dbg_has_eop         = has_eop;
assign dbg_valid_seg_count = valid_seg_count;
assign dbg_in_tvalid       = {in3_tvalid, in2_tvalid, in1_tvalid, in0_tvalid};
endmodule
