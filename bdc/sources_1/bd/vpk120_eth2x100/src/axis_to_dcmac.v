//====================================================================================
//                        ------->  Revision History  <------
//====================================================================================
//
//   Date     Who   Ver  Changes
//====================================================================================
// 01-Sep-25  DWW     1  Initial creation
//====================================================================================

/*
    This converts an ordinary AXI stream into the oddball stream that 
    the DCMAC wants for an input.  This module supports either 2 or 4
    output segments.  DW (Data Width) must be either 2x or 4x the SW 
    (Segment Width)
*/

module axis_to_dcmac # (parameter DW = 256, SW=128)
(
    input   clk,
    input   resetn,

    // A standard AXI-Stream input
    input[DW-1:0]   axis_in_tdata,
    input[DW/8-1:0] axis_in_tkeep,
    input           axis_in_tlast,
    input           axis_in_tvalid,
    output          axis_in_tready,

    // A DCMAC compatible output stream
    output[SW-1:0]           tx_axis_tdata0,     tx_axis_tdata1,         
    output                   tx_axis_tuser_ena0, tx_axis_tuser_ena1,      
    output                   tx_axis_tuser_sop0, tx_axis_tuser_sop1,           
    output                   tx_axis_tuser_eop0, tx_axis_tuser_eop1,        
    output                   tx_axis_tuser_err0, tx_axis_tuser_err1,         
    output[$clog2(SW/8)-1:0] tx_axis_tuser_mty0, tx_axis_tuser_mty1,          

    // In a 2-segment system, these are all driven to 0
    output[SW-1:0]           tx_axis_tdata2,     tx_axis_tdata3,         
    output                   tx_axis_tuser_ena2, tx_axis_tuser_ena3,      
    output                   tx_axis_tuser_sop2, tx_axis_tuser_sop3,           
    output                   tx_axis_tuser_eop2, tx_axis_tuser_eop3,        
    output                   tx_axis_tuser_err2, tx_axis_tuser_err3,         
    output[$clog2(SW/8)-1:0] tx_axis_tuser_mty2, tx_axis_tuser_mty3,          

    // DCMAC AXI stream VALID and READY signals
    output                   tx_axis_tvalid,
    input                    tx_axis_tready
);

// Declare variables
genvar i;
integer n;

// Figure out how many segments we'll use.  Must be 2 or 4
localparam SEG_COUNT = DW / SW;

// This is the maximum number of segments we support
localparam MAX_SEGS = 4;

// This is the width of a single tx_axis_tdata<N> in bytes
localparam SEG_BYTES = SW/8;

// How many bits does it take to hold the value SEG_BYTES?
localparam SEG_BYTES_W = $clog2(SEG_BYTES);

// Split "axis_in_tkeep" into segments, 1 bit per segment byte
wire[SEG_BYTES-1:0] tkeep[0:SEG_COUNT - 1];
for (i=0; i<SEG_COUNT; i=i+1) begin
    assign tkeep[i] = axis_in_tkeep[i* SEG_BYTES +: SEG_BYTES];
end

// The data-cycle number within the incoming packet
reg[9:0] packet_cycle;

//=============================================================================
// zero_bits() - This function counts the '0' bits a tkeep segment
//=============================================================================
function[15:0] zero_bits(input[SEG_BYTES-1:0] field);
begin
    zero_bits = 0;
    for (n=0; n<SEG_BYTES; n=n+1) zero_bits = zero_bits + (field[n] == 0);
end
endfunction
//=============================================================================

//=============================================================================
// Keep track of how many empty bytes are in each segment
//=============================================================================
wire[15:0] empty_bytes[0:MAX_SEGS-1];
wire[MAX_SEGS-1:0] segment_has_data;
for (i=0; i<MAX_SEGS; i=i+1) begin
    if (i < SEG_COUNT) begin
        assign empty_bytes[i]      = zero_bits(tkeep[i]);
        assign segment_has_data[i] = (empty_bytes[i] != SEG_BYTES);
    end else begin
        assign empty_bytes[i]      = SEG_BYTES;
        assign segment_has_data[i] = 0;
    end
end
//=============================================================================


//=============================================================================
// top_bit- This zeros out every bit of the input except for the highest
//          bit that is set.
//=============================================================================
function[SEG_COUNT-1:0] top_bit_only(input[SEG_COUNT-1:0] field);
begin
    top_bit_only = 0;
    for (n=SEG_COUNT-1; n >= 0; n=n-1) begin
        if (field[n] && top_bit_only == 0) begin
            top_bit_only[n] = 1;
        end
    end
end
endfunction
//=============================================================================

// Keep track of the highest segment that contains data
wire[MAX_SEGS-1:0] eop = top_bit_only(segment_has_data);

// Connect the outputs that can be directly driven 
assign tx_axis_tvalid     = axis_in_tvalid;
assign axis_in_tready     = tx_axis_tready;

assign tx_axis_tuser_err0 = 0;
assign tx_axis_tuser_err1 = 0;
assign tx_axis_tuser_err2 = 0;
assign tx_axis_tuser_err3 = 0;

assign tx_axis_tuser_sop0 = (axis_in_tvalid && packet_cycle == 0);
assign tx_axis_tuser_sop1 = 0; // We'll never start a packet in the 2nd segment
assign tx_axis_tuser_sop2 = 0; // We'll never start a packet in the 3rd segment
assign tx_axis_tuser_sop3 = 0; // We'll never start a packet in the 4th segment

assign tx_axis_tuser_mty0 = empty_bytes[0][SEG_BYTES_W-1:0];
assign tx_axis_tuser_mty1 = empty_bytes[1][SEG_BYTES_W-1:0];
assign tx_axis_tuser_mty2 = empty_bytes[2][SEG_BYTES_W-1:0];
assign tx_axis_tuser_mty3 = empty_bytes[3][SEG_BYTES_W-1:0];

assign tx_axis_tuser_ena0 = axis_in_tvalid & segment_has_data[0];
assign tx_axis_tuser_ena1 = axis_in_tvalid & segment_has_data[1];
assign tx_axis_tuser_ena2 = axis_in_tvalid & segment_has_data[2];
assign tx_axis_tuser_ena3 = axis_in_tvalid & segment_has_data[3];

assign tx_axis_tuser_eop0 = axis_in_tvalid & axis_in_tlast & eop[0];
assign tx_axis_tuser_eop1 = axis_in_tvalid & axis_in_tlast & eop[1];
assign tx_axis_tuser_eop2 = axis_in_tvalid & axis_in_tlast & eop[2];
assign tx_axis_tuser_eop3 = axis_in_tvalid & axis_in_tlast & eop[3];


// Drive the input data to the output segments
if (SEG_COUNT == 2) begin
    assign tx_axis_tdata0 = axis_in_tdata[0*SW +: SW];
    assign tx_axis_tdata1 = axis_in_tdata[1*SW +: SW];
    assign tx_axis_tdata2 = 0;
    assign tx_axis_tdata3 = 0;
end else begin
    assign tx_axis_tdata0 = axis_in_tdata[0*SW +: SW];
    assign tx_axis_tdata1 = axis_in_tdata[1*SW +: SW];
    assign tx_axis_tdata2 = axis_in_tdata[2*SW +: SW];
    assign tx_axis_tdata3 = axis_in_tdata[3*SW +: SW];
end


//===============================================================
// This block counts data-cycles in a packet
//===============================================================
always @(posedge clk) begin
    if (resetn == 0)
        packet_cycle <= 0;
    else if (axis_in_tvalid & axis_in_tready) begin
        if (axis_in_tlast)
            packet_cycle <= 0;
        else
            packet_cycle <= packet_cycle + 1;
    end
end
//===============================================================

endmodule
