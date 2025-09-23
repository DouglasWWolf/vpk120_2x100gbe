
//====================================================================================
//                        ------->  Revision History  <------
//====================================================================================
//
//   Date     Who   Ver  Changes
//====================================================================================
// 01-Sep-25  DWW     1  Initial creation
//====================================================================================

/*
    This converts the segmented streams that is output by DCMAC to 
    an ordinary AXI stream.
*/


module dcmac_to_axis # (parameter DW=512, SEG_COUNT=2)
(
    input   clk, resetn,

    // Input streams, one per segment
    input [127:0]   seg0_tdata,  seg1_tdata,  seg2_tdata,  seg3_tdata,
    input [15:0]    seg0_tkeep,  seg1_tkeep,  seg2_tkeep,  seg3_tkeep,
    input [2:0]     seg0_tuser,  seg1_tuser,  seg2_tuser,  seg3_tuser,
    input           seg0_tlast,  seg1_tlast,  seg2_tlast,  seg3_tlast,
    input           seg0_tvalid, seg1_tvalid, seg2_tvalid, seg3_tvalid,
    output          seg0_tready, seg1_tready, seg2_tready, seg3_tready

    // This is an ordinary AXI output stream
    output     [DW-1:0]   axis_out_tdata,
    output     [DW/8-1:0] axis_out_tkeep,
    output     [1:0]      axis_out_tuser,
    output reg            axis_out_tlast,
    output reg            axis_out_tvalid
);

// Input from the segments is only valid when they're all valid
wire seg_tvalid = seg0_tvalid & seg1_tvalid & seg2_tvalid & seg3_tvalid;

// Drive all of the input stream "tready" signals from register seg_tready
reg  seg_tready;
assign seg0_tready = seg_tready;
assign seg1_tready = seg_tready;
assign seg2_tready = seg_tready;
assign seg3_tready = seg_tready;

// These will be driven from the per-segment input streams
wire[127:0] seg_tdata [0:3];
wire[ 15:0] seg_tkeep [0:3];
wire        seg_ena   [0:3];
wire        seg_sop   [0:3];
wire        seg_err   [0:3];
wire        seg_tlast [0:3];
wire        seg_tvalid[0:3];

// Make seg<n>_tdata indexable
assign seg_tdata[0] = seg0_tdata;
assign seg_tdata[1] = seg1_tdata;
assign seg_tdata[2] = seg2_tdata;
assign seg_tdata[3] = seg3_tdata;

// Make seg<n>_tkeep indexable
assign seg_tkeep[0] = seg0_tkeep;
assign seg_tkeep[1] = seg1_tkeep;
assign seg_tkeep[2] = seg2_tkeep;
assign seg_tkeep[3] = seg3_tkeep;

// Make seg<n>_tuser indexable
assign seg_tuser[0] = seg0_tuser;
assign seg_tuser[1] = seg1_tuser;
assign seg_tuser[2] = seg2_tuser;
assign seg_tuser[3] = seg3_tuser;

// Make seg<n>_tuser[0] indexable
assign seg_ena[0] = seg0_tuser[0];
assign seg_ena[1] = seg1_tuser[0];
assign seg_ena[2] = seg2_tuser[0];
assign seg_ena[3] = seg3_tuser[0];

// Make seg<n>_tuser[1] indexable
assign seg_sop[0] = seg0_tuser[1];
assign seg_sop[1] = seg1_tuser[1];
assign seg_sop[2] = seg2_tuser[1];
assign seg_sop[3] = seg3_tuser[1];

// Make seg<n>_tuser[2] indexable
assign seg_err[0] = seg0_tuser[2];
assign seg_err[1] = seg1_tuser[2];
assign seg_err[2] = seg2_tuser[2];
assign seg_err[3] = seg3_tuser[2];

// Make seg<n>_tlast indexable
assign seg_tlast[0] = seg0_tlast;
assign seg_tlast[1] = seg1_tlast;
assign seg_tlast[2] = seg2_tlast;
assign seg_tlast[3] = seg3_tlast;

// Make seg<n>_tvalid indexable
assign seg_valid[0] = seg0_tvalid;
assign seg_valid[1] = seg1_tvalid;
assign seg_valid[2] = seg2_tvalid;
assign seg_valid[3] = seg3_tvalid;

// These will be combined together into the output stream
reg[127:0] out_tdata[0:3];
reg[ 15:0] out_tkeep[0:3];

// Indices of the current input segment and current output segment
reg[1:0] input_seg, output_seg;

// If asserted, we expect to find an SOP on the current input segment
reg expect_sop;

// Combine the output segments into a single field
assign axis_out_tdata = {out_tdata[3], out_tdata[2], out_tdata[1], out_tdata[0]};
assign axis_out_tkeep = {out_tkeep[3], out_tkeep[2], out_tkeep[1], out_tkeep[0]};

//=============================================================================
// Create an unpacked map of which input segments are valid
//=============================================================================
wire valid_segment[0:SEG_COUNT-1];
assign valid_segment[0] = seg0_tvalid;
assign valid_segment[1] = seg1_tvalid;
if (SEG_COUNT == 4) begin
    assign valid_segment[2] = seg2_tvalid;
    assign valid_segment[3] = seg3_tvalid;
end
//=============================================================================


//=============================================================================
// Create an unpacked map of which input segments have TLAST set
//=============================================================================
wire eop_segment[0:SEG_COUNT-1];
assign eop_segment[0] = (seg0_tvalid & seg0_tlast);
assign eop_segment[1] = (seg1_tvalid & seg1_tlast);
if (SEG_COUNT == 4) begin
    assign eop_segment[2] = (seg2_tvalid & seg2_tlast);
    assign eop_segment[3] = (seg3_tvalid & seg3_tlast);
end
//=============================================================================



//=============================================================================
// Create a packed bitmap of which input segments are valid
//=============================================================================
wire[SEG_COUNT-1:0] valid_segment_packed;
assign valid_segment_packed[0] = seg0_tvalid;
assign valid_segment_packed[1] = seg1_tvalid;
if (SEG_COUNT == 4) begin
    assign valid_segment_packed[2] = seg2_tvalid;
    assign valid_segment_packed[3] = seg3_tvalid;
end
//=============================================================================

reg[3:0] available_segments;

always @* begin
    available_segments = 0;

    if (valid_segment[input_seg]) begin
        available_segments = 1;

        if (eop_segment[input_seg] == 0 && valid_segment[input_seg + 1]) begin
            available_segments = 2;

            if (SEG_COUNT == 4) begin

                if (eop_segment[input_seg + 1] == 0 && valid_segment[input_seg + 2]) begin
                    available_segments = 3;

                    if (eop_segment[input_seg+2] == 0 && valid_segment[input_seg + 3]) begin
                        available_segments = 4;
                    end

                end

            end

        end

    end
end


//=============================================================================
// This state machine fills in "cycle_has_eop" and "eop_segment"
//=============================================================================
reg cycle_has_eop;
reg[1:0] eop_segment;

always @* begin
    cycle_has_eop = 0;
    if (seg_ena[0] & seg_tlast[0]) begin
        cycle_has_eop = 1;
        eop_segment   = 0;

    end else if (seg_ena[1] & seg_tlast[1]) begin
        cycle_has_eop = 1;
        eop_segment   = 1;

    end else if (seg_ena[2] & seg_tlast[2]) begin
        cycle_has_eop = 1;
        eop_segment   = 2;

    end else if (seg_ena[3] & seg_tlast[3]) begin
        cycle_has_eop = 1;
        eop_segment   = 3;
    end
end
//=============================================================================


//=============================================================================
// This state machine fills in "cycle_has_sop" and "sop_segment"
//=============================================================================
reg cycle_has_sop;
reg[1:0] sop_segment;

always @* begin
    cycle_has_sop = 0;
    if (seg_ena[0] & seg_sop[0]]) begin
        cycle_has_sop = 1;
        sop_segment   = 0;

    end else if (seg_ena[1] & seg_sop[1]) begin
        cycle_has_sop = 1;
        sop_segment   = 1;

    end else if (seg_ena[2] & seg_sop[2]) begin
        cycle_has_sop = 1;
        sop_segment   = 2;

    end else if (seg_ena[3] & seg_sop[3]) begin
        cycle_has_sop = 1;
        sop_segment   = 3;
    end        if (seg_ena[input_seg + 2]) begin
            out_tdata[output_seg + 2] <= seg_tdata[input_seg + 2];
            out_tkeep[output_seg + 2] <= seg_tkeep[input_seg + 2];
        end

end
//=============================================================================


wire[1:0] input_idx0, input_idx1, input_idx2, input_idx3;

assign input_idx0 = input_seg + 0;
assign input_idx1 = input_seg + 1;
assign input_idx2 = input_seg + 2;
assign input_idx3 = input_seg + 3;

reg write_output;
always @* begin


end



always @(posedge clk) begin

    // This strobes high for a single cycle at a time
    axis_out_tlast  <= 0;
    axis_out_tvalid <= 0;
    seg_tready      <= 0;

    if (resetn == 0) begin
        input_seg  <= 0;
        output_seg <= 0;
        expect_sop <= 1;
    
    end else if (seg_tvalid) begin

        // If we're starting a new output data-cycle, initialize
        // fields of the output stream
        if (output_seg == 0) begin
            out_tdata[0] <= 0;
            out_tdata[1] <= 0;
            out_tdata[2] <= 0;
            out_tdata[3] <= 0;
            out_tkeep[0] <= 0;
            out_tkeep[1] <= 0;
            out_tkeep[2] <= 0;
            out_tkeep[3] <= 0;
            out_tlast    <= 0;
        end

        if (seg_ena[input_seg + 0]) begin
            out_tdata[output_seg + 0] <= seg_tdata[input_seg + 0];
            out_tkeep[output_seg + 0] <= seg_tkeep[input_seg + 0];
        end

        if (seg_ena[input_seg + 1]) begin
            out_tdata[output_seg + 1] <= seg_tdata[input_seg + 1];
            out_tkeep[output_seg + 1] <= seg_tkeep[input_seg + 1];
        end

        if (seg_ena[input_seg + 2]) begin
            out_tdata[output_seg + 2] <= seg_tdata[input_seg + 2];
            out_tkeep[output_seg + 2] <= seg_tkeep[input_seg + 2];
        end

        if (seg_ena[input_seg + 3]) begin
            out_tdata[output_seg + 3] <= seg_tdata[input_seg + 3];
            out_tkeep[output_seg + 3] <= seg_tkeep[input_seg + 3];
        end




    end



end


endmodule
