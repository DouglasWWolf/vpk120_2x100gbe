
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
    data streams and outputs them to a 4-segment DCMAC tx interface
*/

module dcmac_tx_4seg
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
    output [127:0] tx_axis_tdata0,     tx_axis_tdata1,     tx_axis_tdata2,     tx_axis_tdata3,      
    output         tx_axis_tuser_ena0, tx_axis_tuser_ena1, tx_axis_tuser_ena2, tx_axis_tuser_ena3,  
    output         tx_axis_tuser_sop0, tx_axis_tuser_sop1, tx_axis_tuser_sop2, tx_axis_tuser_sop3, 
    output         tx_axis_tuser_eop0, tx_axis_tuser_eop1, tx_axis_tuser_eop2, tx_axis_tuser_eop3,   
    output [3:0]   tx_axis_tuser_mty0, tx_axis_tuser_mty1, tx_axis_tuser_mty2, tx_axis_tuser_mty3,      
    output         tx_axis_tuser_err0, tx_axis_tuser_err1, tx_axis_tuser_err2, tx_axis_tuser_err3,       

    // To DCMAC - Common valid/ready signals for the output segments
    output         tx_axis_valid,
    input          tx_axis_ready
);

// This will be asserted on the first cycle of every packet
reg sop;

// The cycle number within the incoming packet
reg[15:0] input_cycle;

// Data from all four inputs arrives in lockstep.
// Our output is valid whenever our input is valid
assign tx_axis_valid = axis0_in_tvalid;

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

// We're ready for input when downstream is ready
assign axis0_in_tready = tx_axis_ready;
assign axis1_in_tready = tx_axis_ready;
assign axis2_in_tready = tx_axis_ready;
assign axis3_in_tready = tx_axis_ready;

// Drive the packet data output lines
assign tx_axis_tdata0 = axis0_in_tdata;
assign tx_axis_tdata1 = axis1_in_tdata;
assign tx_axis_tdata2 = axis2_in_tdata;
assign tx_axis_tdata3 = axis3_in_tdata;

// Drive the "is this segment enabled?" output lines
assign tx_axis_tuser_ena0 = seg_ena[0];
assign tx_axis_tuser_ena1 = seg_ena[1];
assign tx_axis_tuser_ena2 = seg_ena[2];
assign tx_axis_tuser_ena3 = seg_ena[3];

// Drive the "Is this segment the start of a packet?" output lines.
// We will only ever start a packet on segment 0
assign tx_axis_tuser_sop0 = sop;
assign tx_axis_tuser_sop1 = 0;
assign tx_axis_tuser_sop2 = 0;
assign tx_axis_tuser_sop3 = 0;

// Drive the "Is this segment the end of a packet?" output lines
assign tx_axis_tuser_eop0 = seg_eop[0];
assign tx_axis_tuser_eop1 = seg_eop[1];
assign tx_axis_tuser_eop2 = seg_eop[2];
assign tx_axis_tuser_eop3 = seg_eop[3];

// We won't be generating any errors
assign tx_axis_tuser_err0 = 0;
assign tx_axis_tuser_err1 = 0;
assign tx_axis_tuser_err2 = 0;
assign tx_axis_tuser_err3 = 0;

// Drive values to "How many bytes in this segment are unused?" outputs
assign tx_axis_tuser_mty0 = axis0_in_tuser[3:0];
assign tx_axis_tuser_mty1 = axis1_in_tuser[3:0];
assign tx_axis_tuser_mty2 = axis2_in_tuser[3:0];
assign tx_axis_tuser_mty3 = axis3_in_tuser[3:0];

//=============================================================================
// Simple state machine to identify the first data-cycle of each packet
//=============================================================================
always @(posedge clk) begin

    if (resetn == 0) begin
        sop <= 1;
    end 

    else if (tx_axis_valid & tx_axis_ready) begin
        sop <= axis0_in_tlast;
    end

end
//=============================================================================

endmodule
