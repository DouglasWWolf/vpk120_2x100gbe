//====================================================================================
//                        ------->  Revision History  <------
//====================================================================================
//
//   Date     Who   Ver  Changes
//====================================================================================
// 01-Oct-25  DWW     1  Initial creation
//====================================================================================

/*
    Provides a register interface to "dcmac_helper", "dcmac_iface", and the DCMAC
*/ 
 

module dcmac_ctrl #
(
    parameter AW=8,
    parameter DEFAULT_PRECURSOR   = 3,
    parameter DEFAULT_POSTCURSOR  = 9,
    parameter DEFAULT_MAINCURSOR  = 75,
    parameter DCMAC_BASE_ADDR     = 32'hA400_0000,
    parameter DEFAULT_QSFP_POWER  = 0  /* 0 = QSFP Power Off, 1 = QSFP Power On */
)
(  
    input clk, resetn,

    // PCS-Aligned signals 
    input rx0_aligned, rx1_aligned,

    // Reset output for re-initializing dcmac_iface
    output resetn_out,

    // Used to enable or disable Ethernet RS-FEC
    output reg enable_rsfec,

    // Connect this to an active-low QSFP_LPMODE signal
    output reg qsfp_lpmode,

    // GTM configuration values
    output reg[2:0] gt_loopback,
    output reg[5:0] gt_precursor,
    output reg[5:0] gt_postcursor,
    output reg[6:0] gt_maincursor, 

    //================== This is an AXI4-Lite slave interface ==================
        
    // "Specify write address"              -- Master --    -- Slave --
    input [AW-1:0]                          S_AXI_AWADDR,   
    input                                   S_AXI_AWVALID,  
    input [   2:0]                          S_AXI_AWPROT,
    output                                                  S_AXI_AWREADY,


    // "Write Data"                         -- Master --    -- Slave --
    input [31:0]                            S_AXI_WDATA,      
    input                                   S_AXI_WVALID,
    input [ 3:0]                            S_AXI_WSTRB,
    output                                                  S_AXI_WREADY,

    // "Send Write Response"                -- Master --    -- Slave --
    output[1:0]                                             S_AXI_BRESP,
    output                                                  S_AXI_BVALID,
    input                                   S_AXI_BREADY,

    // "Specify read address"               -- Master --    -- Slave --
    input [AW-1:0]                          S_AXI_ARADDR,     
    input [   2:0]                          S_AXI_ARPROT,     
    input                                   S_AXI_ARVALID,
    output                                                  S_AXI_ARREADY,

    // "Read data back to master"           -- Master --    -- Slave --
    output[31:0]                                            S_AXI_RDATA,
    output                                                  S_AXI_RVALID,
    output[ 1:0]                                            S_AXI_RRESP,
    input                                   S_AXI_RREADY,
    //==========================================================================



    //====================  An AXI-Lite Master Interface  ======================
    // "Specify write address"          -- Master --    -- Slave --
    output[31:0]                        M_AXI_AWADDR,   
    output                              M_AXI_AWVALID,  
    output [2:0]                        M_AXI_AWPROT,
    input                                               M_AXI_AWREADY,

    // "Write Data"                     -- Master --    -- Slave --
    output[31:0]                        M_AXI_WDATA,
    output[3:0]                         M_AXI_WSTRB,      
    output                              M_AXI_WVALID,
    input                                               M_AXI_WREADY,

    // "Send Write Response"            -- Master --    -- Slave --
    input [1:0]                                         M_AXI_BRESP,
    input                                               M_AXI_BVALID,
    output                              M_AXI_BREADY,

    // "Specify read address"           -- Master --    -- Slave --
    output [31:0]                       M_AXI_ARADDR,     
    output [ 2:0]                       M_AXI_ARPROT,
    output                              M_AXI_ARVALID,
    input                                               M_AXI_ARREADY,

    // "Read data back to master"       -- Master --    -- Slave --
    input [31:0]                                        M_AXI_RDATA,
    input                                               M_AXI_RVALID,
    input [1:0]                                         M_AXI_RRESP,
    output                              M_AXI_RREADY
    //==========================================================================
);  



//==========================================================================
// We'll communicate with the AXI4-Lite Slave core with these signals.
//==========================================================================
// AXI Slave Handler Interface for write requests
wire[  31:0]  ashi_windx;     // Input   Write register-index
wire[AW-1:0]  ashi_waddr;     // Input:  Write-address
wire[  31:0]  ashi_wdata;     // Input:  Write-data
wire          ashi_write;     // Input:  1 = Handle a write request
reg [   1:0]  ashi_wresp;     // Output: Write-response (OKAY, DECERR, SLVERR)
wire          ashi_widle;     // Output: 1 = Write state machine is idle

// AXI Slave Handler Interface for read requests
wire[  31:0]  ashi_rindx;     // Input   Read register-index
wire[AW-1:0]  ashi_raddr;     // Input:  Read-address
wire          ashi_read;      // Input:  1 = Handle a read request
reg [  31:0]  ashi_rdata;     // Output: Read data
reg [   1:0]  ashi_rresp;     // Output: Read-response (OKAY, DECERR, SLVERR);
wire          ashi_ridle;     // Output: 1 = Read state machine is idle
//==========================================================================



//==================  The AXI Master Control Interface  ====================
// AMCI signals for performing AXI writes
reg [31:0]  amci_waddr;
reg [31:0]  amci_wdata;
reg         amci_write;
wire[ 1:0]  amci_wresp;
wire        amci_widle;

// AMCI signals for performing AXI reads
reg [31:0]  amci_raddr;
reg         amci_read ;
wire[31:0]  amci_rdata;
wire[ 1:0]  amci_rresp;
wire        amci_ridle;
//==========================================================================



// The state of the state-machines that handle AXI4-Lite read and AXI4-Lite write
reg ashi_write_state, ashi_read_state;

// The AXI4 slave state machines are idle when in state 0 and their "start" signals are low
assign ashi_widle = (ashi_write == 0) && (ashi_write_state == 0);
assign ashi_ridle = (ashi_read  == 0) && (ashi_read_state  == 0);

// "resetn_out" is asserted while the resetn_out timer is countdown down
reg[7:0] resetn_out_timer;
assign resetn_out = (resetn == 1) & (resetn_out_timer == 0);

// This address will be the target of an AXI-Lite read/write operation
reg[31:0] dcmac_addr;

// These are the valid values for ashi_rresp and ashi_wresp
localparam OKAY   = 0;
localparam SLVERR = 2;
localparam DECERR = 3;

// These are user accessible control/status registers
localparam REG_LINK_STATUS = 0;
localparam REG_RESET       = 1;
localparam REG_LOOPBACK    = 2;
localparam REG_RSFEC       = 3;
localparam REG_QSFP_POWER  = 4;
localparam REG_PRECURSOR   = 5;
localparam REG_POSTCURSOR  = 6;
localparam REG_MAINCURSOR  = 7;
localparam REG_DCMAC_ADDR  = 16;
localparam REG_DCMAC_DATA  = 17;


//==========================================================================
// This state machine handles AXI4-Lite write requests
//==========================================================================
always @(posedge clk) begin

    // This strobes high for one clock-cycle at a time
    amci_write <= 0;

    // The "resetn_out" timer always counts down to zero
    if (resetn_out_timer) resetn_out_timer <= resetn_out_timer - 1;

    // If we're in reset, initialize important registers
    if (resetn == 0) begin
        ashi_write_state <= 0;
        gt_loopback      <= 0;
        gt_precursor     <= DEFAULT_PRECURSOR;
        gt_postcursor    <= DEFAULT_POSTCURSOR;
        gt_maincursor    <= DEFAULT_MAINCURSOR;
        enable_rsfec     <= 1;
        qsfp_lpmode      <= ~DEFAULT_QSFP_POWER;
    end
    
    // Otherwise, we're not in reset...  
    else case (ashi_write_state)
        
        // If an AXI write-request has occured...
        0:  if (ashi_write) begin
       
                // Assume for the moment that the result will be OKAY
                ashi_wresp <= OKAY;              
            
                // ashi_windex = index of register to be written
                case (ashi_windx)
               

                    REG_RESET:      resetn_out_timer <= 64;
                    REG_RSFEC:      enable_rsfec     <= ashi_wdata[0];
                    REG_LOOPBACK:   gt_loopback      <= {2'b0, ashi_wdata[0]};
                    REG_QSFP_POWER: qsfp_lpmode      <= ~ashi_wdata[0];
                    REG_PRECURSOR:  gt_precursor     <= ashi_wdata[5:0];                
                    REG_POSTCURSOR: gt_precursor     <= ashi_wdata[5:0];
                    REG_MAINCURSOR: gt_maincursor    <= ashi_wdata[6:0];  
                    REG_DCMAC_ADDR: dcmac_addr       <= ashi_wdata | DCMAC_BASE_ADDR;
                    REG_DCMAC_DATA:
                        begin
                            amci_waddr       <= dcmac_addr;
                            amci_wdata       <= ashi_wdata;
                            amci_write       <= 1;
                            ashi_write_state <= ashi_write_state + 1;
                        end

                    // Writes to any other register are a decode-error
                    default: ashi_wresp <= DECERR;
                endcase
            end

        // Here we wait for an AXI-Lite write to the M_AXI bus to complete
        1:  if (amci_widle) begin
                ashi_wresp       <= amci_wresp;
                ashi_write_state <= 0;
            end

    endcase
end
//==========================================================================


 
//==========================================================================
// World's simplest state machine for handling AXI4-Lite read requests
//==========================================================================
always @(posedge clk) begin

    // This strobes high for one clock-cycle at a time
    amci_read <= 0;

    // If we're in reset, initialize important registers
    if (resetn == 0) begin
        ashi_read_state <= 0;
    end    
    
    else case(ashi_read_state)
   
        0:  if (ashi_read) begin
   
                // Assume for the moment that the result will be OKAY
                ashi_rresp <= OKAY;              

                // ashi_rindex = index of register to be read
                case (ashi_rindx)

                    // Allow a read from any valid register                
                    REG_LINK_STATUS:    ashi_rdata <= {rx1_aligned, rx0_aligned};
                    REG_RESET:          ashi_rdata <= (resetn_out == 0);
                    REG_RSFEC:          ashi_rdata <= enable_rsfec;
                    REG_QSFP_POWER:     ashi_rdata <= ~qsfp_lpmode;
                    REG_LOOPBACK:       ashi_rdata <= gt_loopback;
                    REG_PRECURSOR:      ashi_rdata <= gt_precursor;
                    REG_POSTCURSOR:     ashi_rdata <= gt_postcursor;
                    REG_MAINCURSOR:     ashi_rdata <= gt_maincursor;
                    REG_DCMAC_ADDR:     ashi_rdata <= dcmac_addr;
                    REG_DCMAC_DATA:
                        begin
                            amci_raddr      <= dcmac_addr;
                            amci_read       <= 1;
                            ashi_read_state <= ashi_read_state + 1;
                        end

                    // Reads of any other register are a decode-error
                    default: ashi_rresp <= DECERR;
                endcase
            end

        // Here we wait for a read of the M_AXI bus to complete
        1:  if (amci_ridle) begin
                ashi_rdata      <= amci_rdata;
                ashi_rresp      <= amci_rresp;
                ashi_read_state <= 0;
            end

    endcase
end
//==========================================================================



//==========================================================================
// This connects us to an AXI4-Lite slave core
//==========================================================================
axi4_lite_slave#(.AW(AW)) i_axi4lite_slave
(
    .clk            (clk),
    .resetn         (resetn),
    
    // AXI AW channel
    .AXI_AWADDR     (S_AXI_AWADDR),
    .AXI_AWPROT     (S_AXI_AWPROT),
    .AXI_AWVALID    (S_AXI_AWVALID),   
    .AXI_AWREADY    (S_AXI_AWREADY),
    
    // AXI W channel
    .AXI_WDATA      (S_AXI_WDATA),
    .AXI_WVALID     (S_AXI_WVALID),
    .AXI_WSTRB      (S_AXI_WSTRB),
    .AXI_WREADY     (S_AXI_WREADY),

    // AXI B channel
    .AXI_BRESP      (S_AXI_BRESP),
    .AXI_BVALID     (S_AXI_BVALID),
    .AXI_BREADY     (S_AXI_BREADY),

    // AXI AR channel
    .AXI_ARADDR     (S_AXI_ARADDR), 
    .AXI_ARPROT     (S_AXI_ARPROT),
    .AXI_ARVALID    (S_AXI_ARVALID),
    .AXI_ARREADY    (S_AXI_ARREADY),

    // AXI R channel
    .AXI_RDATA      (S_AXI_RDATA),
    .AXI_RVALID     (S_AXI_RVALID),
    .AXI_RRESP      (S_AXI_RRESP),
    .AXI_RREADY     (S_AXI_RREADY),

    // ASHI write-request registers
    .ASHI_WADDR     (ashi_waddr),
    .ASHI_WINDX     (ashi_windx),
    .ASHI_WDATA     (ashi_wdata),
    .ASHI_WRITE     (ashi_write),
    .ASHI_WRESP     (ashi_wresp),
    .ASHI_WIDLE     (ashi_widle),

    // ASHI read registers
    .ASHI_RADDR     (ashi_raddr),
    .ASHI_RINDX     (ashi_rindx),
    .ASHI_RDATA     (ashi_rdata),
    .ASHI_READ      (ashi_read ),
    .ASHI_RRESP     (ashi_rresp),
    .ASHI_RIDLE     (ashi_ridle)
);
//==========================================================================


//==========================================================================
// This instantiates an AXI4-Lite master
//==========================================================================
axi4_lite_master # (.DW(32), .AW(32)) i_axi4lite_master
(
    // Clock and reset
    .clk            (clk),
    .resetn         (resetn),

    // AXI Master Control Interface for performing writes
    .AMCI_WADDR     (amci_waddr),
    .AMCI_WDATA     (amci_wdata),
    .AMCI_WRITE     (amci_write),
    .AMCI_WRESP     (amci_wresp),
    .AMCI_WIDLE     (amci_widle),

    // AXI Master Control Interface for performing reads
    .AMCI_RADDR     (amci_raddr),
    .AMCI_READ      (amci_read ),
    .AMCI_RDATA     (amci_rdata),
    .AMCI_RRESP     (amci_rresp),
    .AMCI_RIDLE     (amci_ridle),

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
    .AXI_RDATA      (M_AXI_RDATA  ),
    .AXI_RVALID     (M_AXI_RVALID ),
    .AXI_RRESP      (M_AXI_RRESP  ),
    .AXI_RREADY     (M_AXI_RREADY )
);
//==========================================================================



endmodule
