#
# The Versal VPK120 FPGA is xcvp1202-vsva2785-2MP-e-S
#

#
# Bitstream configuration
#
set_property BITSTREAM.GENERAL.COMPRESS TRUE  [current_design]

#
# PL UART
#
set_property -dict {PACKAGE_PIN V32  IOSTANDARD LVCMOS15}  [get_ports UART_txd]
set_property -dict {PACKAGE_PIN U32  IOSTANDARD LVCMOS15}  [get_ports UART_rxd]

