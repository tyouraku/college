set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports {clk}]


set_property -dict {PACKAGE_PIN B21 IOSTANDARD LVCMOS33} [get_ports {reset}]

set_property -dict {PACKAGE_PIN N2   IOSTANDARD LVCMOS33} [get_ports {BCD[0]}]
set_property -dict {PACKAGE_PIN P5   IOSTANDARD LVCMOS33} [get_ports {BCD[1]}]
set_property -dict {PACKAGE_PIN V5   IOSTANDARD LVCMOS33} [get_ports {BCD[2]}]
set_property -dict {PACKAGE_PIN U5   IOSTANDARD LVCMOS33} [get_ports {BCD[3]}]
set_property -dict {PACKAGE_PIN T5   IOSTANDARD LVCMOS33} [get_ports {BCD[4]}]
set_property -dict {PACKAGE_PIN P1   IOSTANDARD LVCMOS33} [get_ports {BCD[5]}]
set_property -dict {PACKAGE_PIN W4   IOSTANDARD LVCMOS33} [get_ports {BCD[6]}]

set_property -dict {PACKAGE_PIN Y3   IOSTANDARD LVCMOS33} [get_ports {AN[0]}]
set_property -dict {PACKAGE_PIN R1   IOSTANDARD LVCMOS33} [get_ports {AN[1]}]
set_property -dict {PACKAGE_PIN P2   IOSTANDARD LVCMOS33} [get_ports {AN[2]}]
set_property -dict {PACKAGE_PIN M2   IOSTANDARD LVCMOS33} [get_ports {AN[3]}]

create_clock -period 10.000 -name CLK -waveform {0.000 5.000} [get_ports clk]
