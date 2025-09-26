//====================================================================================
//                        ------->  Revision History  <------
//====================================================================================
//
//   Date     Who   Ver  Changes
//====================================================================================
// 23-Sep-25  DWW     1  Initial creation
//====================================================================================

/*
   This combines the segments of a segmented AXI stream into a single
   output stream.   The intended use is as the last step in rendering
   the RX packet output from a DCMAC into an ordinary AXI stream
*/  

module dcmac_to_axis # (parameter SEG_COUNT = 2)
(
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 391000600, ASSOCIATED_BUSIF axis_out:i_in0:i_in1:i_in2:i_in3" *)
    input   clk,
    input   resetn,

    // Input streams, one per segment
    input [127:0]   i_in0_tdata,  i_in1_tdata,  i_in2_tdata,  i_in3_tdata,
    input [ 15:0]   i_in0_tkeep,  i_in1_tkeep,  i_in2_tkeep,  i_in3_tkeep,
    input [  1:0]   i_in0_tuser,  i_in1_tuser,  i_in2_tuser,  i_in3_tuser,
    input           i_in0_tlast,  i_in1_tlast,  i_in2_tlast,  i_in3_tlast,
    input           i_in0_tvalid, i_in1_tvalid, i_in2_tvalid, i_in3_tvalid,

    // A single, unified output stream
    output [128*SEG_COUNT-1:0] axis_out_tdata,
    output [ 16*SEG_COUNT-1:0] axis_out_tkeep,
    output [              1:0] axis_out_tuser,
    output                     axis_out_tlast,
    output                     axis_out_tvalid
);


//=============================================================================
// We're going to register the inputs to make timing closure a little easier
//=============================================================================
reg[127:0] in0_tdata,  in1_tdata,  in2_tdata,  in3_tdata;
reg[ 15:0] in0_tkeep,  in1_tkeep,  in2_tkeep,  in3_tkeep;
reg[  1:0] in0_tuser,  in1_tuser,  in2_tuser,  in3_tuser;
reg        in0_tlast,  in1_tlast,  in2_tlast,  in3_tlast;
reg        in0_tvalid, in1_tvalid, in2_tvalid, in3_tvalid;
//-----------------------------------------------------------------------------
always @(posedge clk) begin

    in0_tdata <= i_in0_tdata;
    in1_tdata <= i_in1_tdata;
    in2_tdata <= i_in2_tdata;
    in3_tdata <= i_in3_tdata;

    in0_tkeep <= i_in0_tkeep;
    in1_tkeep <= i_in1_tkeep;
    in2_tkeep <= i_in2_tkeep;
    in3_tkeep <= i_in3_tkeep;

    in0_tuser <= i_in0_tuser;
    in1_tuser <= i_in1_tuser;
    in2_tuser <= i_in2_tuser;
    in3_tuser <= i_in3_tuser;

    in0_tlast <= i_in0_tlast;
    in1_tlast <= i_in1_tlast;
    in2_tlast <= i_in2_tlast;
    in3_tlast <= i_in3_tlast;

    in0_tvalid <= i_in0_tvalid;
    in1_tvalid <= i_in1_tvalid;
    in2_tvalid <= i_in2_tvalid;
    in3_tvalid <= i_in3_tvalid;
end
//=============================================================================

if (SEG_COUNT == 2) begin
    assign axis_out_tdata  = {in1_tdata, in0_tdata};
    assign axis_out_tkeep  = {in1_tkeep, in0_tkeep};
    assign axis_out_tuser  = in0_tuser | in1_tuser;
    assign axis_out_tlast  = in0_tlast | in1_tlast;
    assign axis_out_tvalid = in0_tvalid;
end

if (SEG_COUNT == 4) begin
    assign axis_out_tdata  = {in3_tdata, in2_tdata, in1_tdata, in0_tdata};
    assign axis_out_tkeep  = {in3_tkeep, in2_tkeep, in1_tkeep, in0_tkeep};
    assign axis_out_tuser  = in0_tuser | in1_tuser | in2_tuser | in3_tuser;
    assign axis_out_tlast  = in0_tlast | in1_tlast | in2_tlast | in3_tlast;
    assign axis_out_tvalid = in0_tvalid;
end

endmodule
