//====================================================================================
//                        ------->  Revision History  <------
//====================================================================================
//
//   Date     Who   Ver  Changes
//====================================================================================
// 20-Sep-25  DWW     1  Initial creation
//====================================================================================

/*
    This serves an a "pin controlled" interface to important DCMAC registers
*/

module dcmac_iface #
(
    parameter AW=32,
    parameter DW=32,
    parameter DCMAC_BASE = 32'hA400_0000,
    parameter SPEED = 100,
    parameter FREQ_HZ = 250000000
)
( 
    input  clk, resetn,
         
    output reg  gt_reset_all,

    // This should normally be asserted, to enable RS-FEC
    input  enable_rsfec,
 
    // One per MAC port    
    output reg [1:0] gt_reset_rx_datapath,
    input      [1:0] rx_reset_done,
    input      [1:0] tx_reset_done,

    // PCS alignment status
    output     rx0_aligned,
    output     rx1_aligned,

    //====================  An AXI-Lite Master Interface  ======================
    // "Specify write address"          -- Master --    -- Slave --
    output [AW-1:0]                     M_AXI_AWADDR,   
    output                              M_AXI_AWVALID,  
    output    [2:0]                     M_AXI_AWPROT,
    input                                               M_AXI_AWREADY,

    // "Write Data"                     -- Master --    -- Slave --
    output [DW-1:0]                     M_AXI_WDATA,
    output [DW/8-1:0]                   M_AXI_WSTRB,      
    output                              M_AXI_WVALID,
    input                                               M_AXI_WREADY,

    // "Send Write Response"            -- Master --    -- Slave --
    input  [1:0]                                        M_AXI_BRESP,
    input                                               M_AXI_BVALID,
    output                              M_AXI_BREADY,

    // "Specify read address"           -- Master --    -- Slave --
    output [AW-1:0]                     M_AXI_ARADDR,     
    output [   2:0]                     M_AXI_ARPROT,
    output                              M_AXI_ARVALID,
    input                                               M_AXI_ARREADY,

    // "Read data back to master"       -- Master --    -- Slave --
    input [DW-1:0]                                      M_AXI_RDATA,
    input                                               M_AXI_RVALID,
    input [1:0]                                         M_AXI_RRESP,
    output                              M_AXI_RREADY
    //==========================================================================

);

//==================  The AXI Master Control Interface  =======================
// AMCI signals for performing AXI writes
reg [AW-1:0]  AMCI_WADDR;
reg [DW-1:0]  AMCI_WDATA;
reg           AMCI_WRITE;
wire[   1:0]  AMCI_WRESP;
wire          AMCI_WIDLE;

// AMCI signals for performing AXI reads
reg [AW-1:0]  AMCI_RADDR;
reg           AMCI_READ ;
wire[DW-1:0]  AMCI_RDATA;
wire[   1:0]  AMCI_RRESP;
wire          AMCI_RIDLE;
//=============================================================================

// DCMAC registers
localparam REG_GLOBAL_MODE       = DCMAC_BASE + 16'h0004;
localparam REG_GLOBAL_CONTROL_RX = DCMAC_BASE + 16'h00F0;
localparam REG_GLOBAL_CONTROL_TX = DCMAC_BASE + 16'h00F8;
localparam C0_CHANNEL_CONFIG_TX  = DCMAC_BASE + 16'h1000;
localparam C0_CHANNEL_CONFIG_RX  = DCMAC_BASE + 16'h1004;
localparam C0_CHANNEL_CONTROL_RX = DCMAC_BASE + 16'h1030;
localparam C0_CHANNEL_CONTROL_TX = DCMAC_BASE + 16'h1038;
localparam C0_TX_MODE            = DCMAC_BASE + 16'h1040;
localparam C0_RX_MODE            = DCMAC_BASE + 16'h1044;
localparam C0_PORT_CONTROL_RX    = DCMAC_BASE + 16'h10F0;
localparam C0_PORT_CONTROL_TX    = DCMAC_BASE + 16'h10F8;
localparam C0_RX_PHY_STATUS      = DCMAC_BASE + 16'h1C04;

localparam LPORT0_STATUS   = C0_RX_PHY_STATUS;
localparam LPORT1_STATUS   = C0_RX_PHY_STATUS + ((SPEED == 100) ? 32'h1000 : 32'h2000);
localparam LPORT0_CHANNELS = (SPEED == 100) ? 6'b000001 : 6'b000011;
localparam LPORT1_CHANNELS = (SPEED == 100) ? 6'b000010 : 6'b001100;
localparam ALL_CHANNELS    = (LPORT0_CHANNELS | LPORT1_CHANNELS);

localparam FSMW = 6;
localparam STACK_DEPTH=5;

// These are for programming Cn_TX_MODE and Cn_RX_MODE
localparam RSFEC_MODE = (SPEED == 100) ? 5 : 8; // 5=100G KR4, 8=200G
localparam DATA_RATE  = (SPEED == 100) ? 0 : 1; // 0=100G,     1=200G
wire[4:0] rsfec_mode = (enable_rsfec) ? RSFEC_MODE : 0;

// This is the state of our state machine
reg[FSMW-1:0] fsm_state;

// This is a countdown timer for implementing delays
reg[31:0] sleep;

// When this non-zero, we're waiting for PCS alignment
reg[31:0] wait_for_alignment;

// This is a call stack
reg[FSMW*STACK_DEPTH-1:0] stack;

// Ordinary stackable call and return operations
`define call(x) stack<=(stack<<FSMW)|fsm_state+1;fsm_state<=x
`define return  fsm_state<=stack[FSMW-1:0];stack<=(stack>>FSMW)


//=============================================================================
// This keeps track of which logical ports still need to acheive PCS alignment
// and which DCMAC channels those logical ports occupy.
//=============================================================================
reg[1:0] rx_aligned;
reg[5:0] alignment_channels;
always @* begin
    case (rx_aligned)
        0:  alignment_channels = ALL_CHANNELS;
        1:  alignment_channels = LPORT1_CHANNELS;
        2:  alignment_channels = LPORT0_CHANNELS;
        3:  alignment_channels = 0;
    endcase
end
assign rx0_aligned = rx_aligned[0];
assign rx1_aligned = rx_aligned[1];
localparam ALIGNMENT_TIME = FREQ_HZ / 2;
//=============================================================================


//=============================================================================
// This state machine converts between pin-oriented control and register-
// oriented control
//=============================================================================
localparam FSM_TOP          =  0;
localparam FSM_LOOP         =  1;
localparam FSM_INIT_DCMAC   = 20;
localparam FSM_DCMAC_RESETS = 40;
localparam FSM_SPAM         = 50;

// A bitmap of the channels to be configured when calling FSM_SPAM
reg[5:0] channels;

// The desired state of the DCMAC reset registers when calling FSM_RESET
reg      dcmac_reset;

//=============================================================================
// The main state machine.  This configures the DCMAC, reports on the state
// of PCS alignment for each ports, and continuously attempts to acheive 
// alignment on each PCS port.
//=============================================================================
always @(posedge clk) begin
    
    AMCI_READ  <= 0;
    AMCI_WRITE <= 0;

    // Count down the sleep timer    
    if (sleep)
        sleep <= sleep - 1;

    // Count down the timer that waits for alignment
    if (wait_for_alignment)
        wait_for_alignment <= wait_for_alignment - 1;

    if (resetn == 0) begin
        fsm_state          <= 0;
        sleep              <= 250000;
        wait_for_alignment <= 0;
        rx_aligned         <= 0;
        gt_reset_all       <= 1;
    end else case (fsm_state)

        // As we come out of reset, initialize the DCMAC registers
        FSM_TOP:
            if (sleep == 0) begin
                `call(FSM_INIT_DCMAC);
            end

        // After DCMAC initialization, we'll sit in a loop attempting
        // to maintain PCS alignment on each of the logical ports
        FSM_LOOP:
            if (AMCI_RIDLE) begin
                AMCI_RADDR <= LPORT0_STATUS;
                AMCI_READ  <= 1;
                fsm_state  <= fsm_state + 1;
            end

        FSM_LOOP+1:
            if (AMCI_RIDLE) begin
                if (AMCI_RRESP == 0) rx_aligned[0] <= AMCI_RDATA[2];
                AMCI_RADDR <= LPORT1_STATUS;
                AMCI_READ  <= 1;
                fsm_state  <= fsm_state + 1;
            end

        FSM_LOOP+2:
            if (AMCI_RIDLE) begin
                if (AMCI_RRESP == 0) rx_aligned[1] <= AMCI_RDATA[2];
                fsm_state <= fsm_state + 1;
            end

        // If one of the ports requires an rx-datapath reset, assert it
        FSM_LOOP+3: 
            if (rx_aligned == 2'b11 || wait_for_alignment)
                fsm_state <= FSM_LOOP;
            else begin
                gt_reset_rx_datapath <= ~rx_aligned;
                sleep                <= 1000;
                fsm_state            <= fsm_state + 1;             
            end

        // Deassert the rx-datapath reset
        FSM_LOOP+4:
            if (sleep == 0) begin
                gt_reset_rx_datapath <= 0;
                sleep                <= 1000;
                fsm_state            <= fsm_state + 1;
            end

        // Once the rx-datapath reset is complete, reset the port in the DCMAC
        FSM_LOOP+5:
            if (sleep == 0 && rx_reset_done == 2'b11) begin
                AMCI_WADDR <= C0_PORT_CONTROL_RX;
                AMCI_WDATA <= 2;
                channels   <= alignment_channels;
                `call(FSM_SPAM);
            end

        // Leave resert asserted for a bit
        FSM_LOOP+6:
            begin
                sleep     <= 1000;
                fsm_state <= fsm_state + 1;
            end
        
        // Deassert the port control resets in the DCMAC
        FSM_LOOP+7:
            if (sleep == 0) begin
                AMCI_WADDR <= C0_PORT_CONTROL_RX;
                AMCI_WDATA <= 0;
                channels   <= alignment_channels;
                `call(FSM_SPAM);
            end

        // Set up the timer that waits for alignment to occur and 
        // go wait.
        FSM_LOOP+8:
            begin
                wait_for_alignment <= ALIGNMENT_TIME;
                fsm_state          <= FSM_LOOP;
            end



        //----------------------------------------------------------------------------
        // This subroutine initializes the DCMAC and should be called at startup
        //----------------------------------------------------------------------------

        // Assert "gt_reset_all"
        FSM_INIT_DCMAC:
            begin
                gt_reset_all <= 1;
                sleep        <= 1000;
                fsm_state    <= fsm_state + 1;
            end

        // Deassert "gt_reset_all"
        FSM_INIT_DCMAC + 1:
            if (sleep == 0) begin
                gt_reset_all <= 0;
                sleep        <= 1000;
                fsm_state    <= fsm_state + 1;
            end

        // Wait for the GTMs to finish their reset process then 
        // assert all of the DCMAC's internal resets
        FSM_INIT_DCMAC + 2:
            if (sleep == 0 && rx_reset_done == 2'b11 && tx_reset_done == 2'b11) begin
                dcmac_reset <= 1;
                sleep       <= 1000;
                `call(FSM_DCMAC_RESETS);
            end

        // Program the global-mode register
        FSM_INIT_DCMAC + 3:
            if (AMCI_WIDLE && sleep == 0) begin
                AMCI_WADDR <= REG_GLOBAL_MODE;
                AMCI_WDATA <= 32'h07550000;
                AMCI_WRITE <= 1;
                fsm_state  <= fsm_state + 1;
            end

        // Basic RX channel configuration
        FSM_INIT_DCMAC + 4:
            if (AMCI_WIDLE) begin
                AMCI_WADDR <= C0_CHANNEL_CONFIG_RX;
                AMCI_WDATA <= 32'h25800062;
                channels   <= ALL_CHANNELS;
                `call(FSM_SPAM);
            end

        // Basic TX channel configuration
        FSM_INIT_DCMAC + 5:
            if (AMCI_WIDLE) begin
                AMCI_WADDR <= C0_CHANNEL_CONFIG_TX;
                AMCI_WDATA <= 32'hC01;
                channels   <= ALL_CHANNELS;
                `call(FSM_SPAM);
            end

        // Set the FEC mode for TX
        FSM_INIT_DCMAC + 6:
            if (AMCI_WIDLE) begin
                AMCI_WADDR <= C0_TX_MODE;
                AMCI_WDATA <= (DATA_RATE | rsfec_mode << 16);
                channels   <= ALL_CHANNELS;
                `call(FSM_SPAM);
            end

        // Set the FEC mode for RX
        FSM_INIT_DCMAC + 7:
            if (AMCI_WIDLE) begin
                AMCI_WADDR <= C0_RX_MODE;
                AMCI_WDATA <= (DATA_RATE | rsfec_mode << 16);
                channels   <= ALL_CHANNELS;
                `call(FSM_SPAM);
            end

        // Release all of the DCMAC's resets
        FSM_INIT_DCMAC + 8:
            if (AMCI_WIDLE) begin
                dcmac_reset <= 0;
                sleep       <= 1000;
                `call(FSM_DCMAC_RESETS);
            end

        // When the sleep is completed, return
        FSM_INIT_DCMAC + 9:
            if (AMCI_WIDLE && sleep == 0) begin
                wait_for_alignment <= ALIGNMENT_TIME;
                `return;
            end
        //----------------------------------------------------------------------------

        //----------------------------------------------------------------------------
        // This subroutine initializes the DCMAC reset registers
        // On entry:  dcmac_reset = 1 = "Assert resets"
        //            dcmac_reset = 0 = "Clear resets"
        //----------------------------------------------------------------------------
        FSM_DCMAC_RESETS:
            if (AMCI_WIDLE) begin
                AMCI_WADDR <= REG_GLOBAL_CONTROL_RX;
                AMCI_WDATA <= (dcmac_reset) ? 7 : 0;
                AMCI_WRITE <= 1;
                fsm_state  <= fsm_state + 1;
            end

        FSM_DCMAC_RESETS + 1:
            if (AMCI_WIDLE) begin
                AMCI_WADDR <= REG_GLOBAL_CONTROL_TX;
                AMCI_WDATA <= (dcmac_reset) ? 7 : 0;
                AMCI_WRITE <= 1;
                fsm_state  <= fsm_state + 1;
            end
        
        FSM_DCMAC_RESETS + 2:
            if (AMCI_WIDLE) begin
                AMCI_WADDR <= C0_PORT_CONTROL_TX;
                AMCI_WDATA <= (dcmac_reset) ? 3 : 0;
                channels   <= ALL_CHANNELS;
                `call(FSM_SPAM);
            end

        FSM_DCMAC_RESETS + 3:
            if (AMCI_WIDLE) begin
                AMCI_WADDR <= C0_PORT_CONTROL_RX;
                AMCI_WDATA <= (dcmac_reset) ? 3 : 0;
                channels   <= ALL_CHANNELS;
                `call(FSM_SPAM);
            end
 
        FSM_DCMAC_RESETS + 4:
            if (AMCI_WIDLE) begin
                AMCI_WADDR <= C0_CHANNEL_CONTROL_RX;
                AMCI_WDATA <= (dcmac_reset) ? 1 : 0;
                channels   <= ALL_CHANNELS;
                `call(FSM_SPAM);
            end

        FSM_DCMAC_RESETS + 5:
            if (AMCI_WIDLE) begin
                AMCI_WADDR <= C0_CHANNEL_CONTROL_TX;
                AMCI_WDATA <= (dcmac_reset) ? 1 : 0;
                channels   <= ALL_CHANNELS;
                `call(FSM_SPAM);
            end

        FSM_DCMAC_RESETS + 6:
            if (AMCI_WIDLE) begin
                `return;
            end
        //----------------------------------------------------------------------------


        // On entry to this subroutine:
        //     AMCI_WADDR    = The appropraiate C0_XXXXX address
        //     ACMI_WDATA    = The data to be written
        //     channels[5:0] = Bitmap of which DCMAC channels to write to
        FSM_SPAM:
            if (channels == 0) begin
                `return;
            end else begin
                AMCI_WRITE <= channels[0];
                fsm_state  <= fsm_state + 1;
            end
                    
        FSM_SPAM + 1:
            if (AMCI_WIDLE) begin
                channels   <= (channels >> 1);
                AMCI_WADDR <= AMCI_WADDR + 32'h1000;
                fsm_state  <= fsm_state - 1;
            end


    endcase

end
//=============================================================================


//=============================================================================
// This instantiates an AXI4-Lite master
//=============================================================================
axi4_lite_master # (.DW(DW), .AW(AW)) axi4_master
(
    // Clock and reset
    .clk            (clk),
    .resetn         (resetn),

    // AXI Master Control Interface for performing writes
    .AMCI_WADDR     (AMCI_WADDR),
    .AMCI_WDATA     (AMCI_WDATA),
    .AMCI_WRITE     (AMCI_WRITE),
    .AMCI_WRESP     (AMCI_WRESP),
    .AMCI_WIDLE     (AMCI_WIDLE),

    // AXI Master Control Interface for performing reads
    .AMCI_RADDR     (AMCI_RADDR),
    .AMCI_READ      (AMCI_READ ),
    .AMCI_RDATA     (AMCI_RDATA),
    .AMCI_RRESP     (AMCI_RRESP),
    .AMCI_RIDLE     (AMCI_RIDLE),

    // AXI4-Lite AW channel
    .AXI_AWADDR     (M_AXI_AWADDR ),
    .AXI_AWVALID    (M_AXI_AWVALID),
    .AXI_AWPROT     (M_AXI_AWPROT ),
    .AXI_AWREADY    (M_AXI_AWREADY),

    // AXI4-Lite W channel
    .AXI_WDATA      (M_AXI_WDATA  ),
    .AXI_WSTRB      (M_AXI_WSTRB  ),
    .AXI_WVALID     (M_AXI_WVALID ),
    .AXI_WREADY     (M_AXI_WREADY ),

    // AXI4-Lite B channel
    .AXI_BRESP      (M_AXI_BRESP  ),
    .AXI_BVALID     (M_AXI_BVALID ),
    .AXI_BREADY     (M_AXI_BREADY ),

    // AXI4-Lite AR channel
    .AXI_ARADDR     (M_AXI_ARADDR ),
    .AXI_ARPROT     (M_AXI_ARPROT ),
    .AXI_ARVALID    (M_AXI_ARVALID),
    .AXI_ARREADY    (M_AXI_ARREADY),

    // AXI4-Lite R channel
    .AXI_RDATA      (M_AXI_RDATA  ),
    .AXI_RVALID     (M_AXI_RVALID ),
    .AXI_RRESP      (M_AXI_RRESP  ),
    .AXI_RREADY     (M_AXI_RREADY )
);
//=============================================================================


endmodule
