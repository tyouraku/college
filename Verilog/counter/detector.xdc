set_property -dict {PACKAGE_PIN AA1  IOSTANDARD LVCMOS33} [get_ports {leds[0]}]
set_property -dict {PACKAGE_PIN AB1  IOSTANDARD LVCMOS33} [get_ports {leds[1]}]
set_property -dict {PACKAGE_PIN AB2  IOSTANDARD LVCMOS33} [get_ports {leds[2]}]

set_property -dict {PACKAGE_PIN V2 IOSTANDARD LVCMOS33} [get_ports {pulse}]
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {serial_in}]
set_property -dict {PACKAGE_PIN B21 IOSTANDARD LVCMOS33} [get_ports {reset}]
set_property -dict {PACKAGE_PIN B22 IOSTANDARD LVCMOS33} [get_ports {clk}]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {clk}]