
//====================================================================================
//                        ------->  Revision History  <------
//====================================================================================
//
//   Date     Who   Ver  Changes
//====================================================================================
// 26-Sep-25  DWW     1  Initial creation
//====================================================================================

/*
    This modules compares two datastreams (one tx and one rx) and raises an
    alarm if it finds a difference
*/ 


module packet_check # (parameter DW = 512, FIFO_DEPTH = 1024)
(
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF axis_rx:axis_tx" *)
    input   clk,
    input   resetn,

    // This is asserted when we find non-matching data
    output reg          alarm,
    output reg [DW-1:0] mismatch_tx,
    output reg [DW-1:0] mismatch_rx,    

    // Transmit stream
    (* X_INTERFACE_MODE = "monitor" *)
    input[  DW-1:0] axis_tx_tdata,
    input[DW/8-1:0] axis_tx_tkeep,
    input[     1:0] axis_tx_tuser,
    input           axis_tx_tlast,
    input           axis_tx_tvalid,
    input           axis_tx_tready,

    // Receive stream
    input[  DW-1:0] axis_rx_tdata,
    input[DW/8-1:0] axis_rx_tkeep,
    input[     1:0] axis_rx_tuser,
    input           axis_rx_tlast,
    input           axis_rx_tvalid,
    output          axis_rx_tready
);
genvar i;

//=============================================================================
// Build a bitmask we can use to mask off unused bytes in axis_tx_tdata
//=============================================================================
wire[DW-1:0] mask;
for (i=0; i<DW/8; i=i+1) begin
    assign mask[i*8 +: 8] = (axis_tx_tkeep[i]) ? 8'hFF : 8'h00;
end
//=============================================================================

// We're always ready to receive data on axis_rx
assign axis_rx_tready = (resetn == 1);

// These are the output bus of the FIFO
wire[  DW-1:0] fifo_tdata;
wire[DW/8-1:0] fifo_tkeep;
wire[     1:0] fifo_tuser;
wire           fifo_tlast;
wire           fifo_tvalid;
wire           fifo_tready;

// This is asserted when the axis_rx data doesn't match the current
// data that is on the outputs of the FIFO
wire mismatch = (axis_rx_tdata != fifo_tdata)
              | (axis_rx_tkeep != fifo_tkeep)
              | (axis_rx_tlast != fifo_tlast);

// Every time we receive data on axis_rx, advance the FIFO by one
assign fifo_tready = axis_rx_tvalid;

//=============================================================================
// This state machine raises the "alarm" signal if it detects a mismatch
// between the data arriving on axis_rx and the data present in the FIFO.
//=============================================================================
always @(posedge clk) begin
    
    if (resetn == 0) begin
        alarm       <= 0; 
        mismatch_tx <= 0;
        mismatch_rx <= 0;
    end
    
    else if (axis_rx_tvalid) begin
        if (mismatch) begin
            alarm <= 1;
            mismatch_tx <= fifo_tdata;
            mismatch_rx <= axis_rx_tdata;
        end
    end

end
//=============================================================================



//=============================================================================
// Whenever a tvalid/tready handshake occurs on axis_tx, the contents of the
// data-cycle are stuffed into this FIFO.
//=============================================================================
xpm_fifo_axis #
(
    .FIFO_DEPTH      (FIFO_DEPTH),
    .TDATA_WIDTH     (DW),
    .TUSER_WIDTH     (2),
    .FIFO_MEMORY_TYPE("auto"),
    .PACKET_FIFO     ("false"),
    .USE_ADV_FEATURES("0000"),
    .CLOCKING_MODE   ("common_clock")
)
i_fifo
(
    // Clock and reset
    .s_aclk         (clk   ),
    .m_aclk         (clk   ),
    .s_aresetn      (resetn),

    // The input bus to the FIFO
    .s_axis_tdata   (axis_tx_tdata & mask),
    .s_axis_tuser   (axis_tx_tuser),
    .s_axis_tkeep   (axis_tx_tkeep),
    .s_axis_tlast   (axis_tx_tlast),
    .s_axis_tvalid  (axis_tx_tvalid & axis_tx_tready),
    .s_axis_tready  (),

    // The output bus of the FIFO
    .m_axis_tdata   (fifo_tdata ),
    .m_axis_tuser   (fifo_tuser ),
    .m_axis_tkeep   (fifo_tkeep ),
    .m_axis_tlast   (fifo_tlast ),
    .m_axis_tvalid  (fifo_tvalid),
    .m_axis_tready  (fifo_tready),

    // Unused input stream signals
    .s_axis_tdest(),
    .s_axis_tid  (),
    .s_axis_tstrb(),

    // Unused output stream signals
    .m_axis_tdest(),
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



endmodule