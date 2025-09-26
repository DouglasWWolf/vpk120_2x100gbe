
//====================================================================================
//                        ------->  Revision History  <------
//====================================================================================
//
//   Date     Who   Ver  Changes
//====================================================================================
// 24-Sep-25  DWW     1  Initial creation
//====================================================================================

/*
    This module inputs 4 synchronized, packed (i.e., no idle cycles within a packet)
    data streams and outputs them to a 2-segment DCMAC tx interface
*/

module dcmac_tx_2seg
(

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF axis0_in:axis1_in:axis2_in:axis3_in" *)
    input   clk,
    input resetn,

    // Input streams
    input [127:0]  axis0_in_tdata,  axis1_in_tdata,  axis2_in_tdata,  axis3_in_tdata,         
    input [  4:0]  axis0_in_tuser,  axis1_in_tuser,  axis2_in_tuser,  axis3_in_tuser,       
    input          axis0_in_tlast,  axis1_in_tlast,  axis2_in_tlast,  axis3_in_tlast,       
    input          axis0_in_tvalid, axis1_in_tvalid, axis2_in_tvalid, axis3_in_tvalid,       
    output         axis0_in_tready, axis1_in_tready, axis2_in_tready, axis3_in_tready,     

    // To DCMAC - Segment data
    output [127:0] tx_axis_tdata0,     tx_axis_tdata1,      
    output         tx_axis_tuser_ena0, tx_axis_tuser_ena1,  
    output         tx_axis_tuser_sop0, tx_axis_tuser_sop1, 
    output         tx_axis_tuser_eop0, tx_axis_tuser_eop1,   
    output [3:0]   tx_axis_tuser_mty0, tx_axis_tuser_mty1,      
    output         tx_axis_tuser_err0, tx_axis_tuser_err1,       

    // To DCMAC - Common valid/ready signals for the output segments
    output         tx_axis_valid,
    input          tx_axis_ready
);

// This will be asserted on the first output data-cycle of every packet
reg sop;

// This determines which pair of input segments are mapped to the output segments
reg pair_select;

// Data from all four inputs arrives in lockstep.
// Our output is valid whenever our input is valid
assign tx_axis_valid = axis0_in_tvalid;

// We're ready for input when downstream is ready and when 
// we're waiting for the first clock-cycle of the pair
wire ready_for_input = tx_axis_ready & (pair_select == 1);
assign axis0_in_tready = ready_for_input;
assign axis1_in_tready = ready_for_input;
assign axis2_in_tready = ready_for_input;
assign axis3_in_tready = ready_for_input;

// Bit 4 of TUSER is 0 when the corresponding segment contains data
wire[0:3] seg_ena;
assign seg_ena[0] = (axis0_in_tuser[4] == 0);
assign seg_ena[1] = (axis1_in_tuser[4] == 0);
assign seg_ena[2] = (axis2_in_tuser[4] == 0);
assign seg_ena[3] = (axis3_in_tuser[4] == 0);

// If this is the last data-cycle of the packet, keep
// track of the highest-numbered active segment.  That
// segment is where our EOP marker goes.
wire[3:0] seg_eop = (axis0_in_tlast == 0) ? 4'b0000 :
                    (seg_ena[3])          ? 4'b1000 :
                    (seg_ena[2])          ? 4'b0100 :
                    (seg_ena[1])          ? 4'b0010 :
                    (seg_ena[0])          ? 4'b0001 : 0;

// Drive the correct pair of inputs to tx_axis_tdata
assign tx_axis_tdata0 = (pair_select == 0) ? axis0_in_tdata : axis2_in_tdata;
assign tx_axis_tdata1 = (pair_select == 0) ? axis1_in_tdata : axis3_in_tdata;

// Drive the correct pair of inputs to tx_axis_tuser_ena
assign tx_axis_tuser_ena0 = (pair_select == 0) ? seg_ena[0] : seg_ena[2];
assign tx_axis_tuser_ena1 = (pair_select == 0) ? seg_ena[1] : seg_ena[3];

// Start-Of-Packet markers are only ever in lane 0;
assign tx_axis_tuser_sop0 = (pair_select == 0) & sop;
assign tx_axis_tuser_sop1 = 0;

// Drive the correct pair of inputs to tx_axis_tuser_ena
assign tx_axis_tuser_eop0 = (pair_select == 0) ? seg_eop[0] : seg_eop[2];
assign tx_axis_tuser_eop1 = (pair_select == 0) ? seg_eop[1] : seg_eop[3];

// We won't be generating any errors
assign tx_axis_tuser_err0 = 0;
assign tx_axis_tuser_err1 = 0;

// Drive the correct pair of inputs to tx_axis_tuser_mty0
assign tx_axis_tuser_mty0 = (pair_select == 0) ? axis0_in_tuser[3:0] : axis2_in_tuser[3:0];
assign tx_axis_tuser_mty1 = (pair_select == 0) ? axis1_in_tuser[3:0] : axis3_in_tuser[3:0];


//=============================================================================
// A simple state machine to determine when a data-cycle is the start of a
// packet, and to select which pair of input streams is mapped to the outputs
//=============================================================================
always @(posedge clk) begin

    if (resetn == 0) begin
        pair_select <= 0;
        sop         <= 1;
    end 

    // Every time we clock out data...
    else if (tx_axis_valid & tx_axis_ready) begin

        // Outputting the last cycle of a packet means
        // that the next input data-cycle is a start-of-packet
        sop <= (pair_select & axis0_in_tlast);

        // pair_select flips every time we clock out data
        pair_select <= ~pair_select;
    end

end
//=============================================================================

endmodule
