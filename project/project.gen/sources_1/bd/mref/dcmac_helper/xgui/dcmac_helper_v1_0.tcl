# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "MAX_PORTS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SPEED" -parent ${Page_0}


}

proc update_PARAM_VALUE.MAX_PORTS { PARAM_VALUE.MAX_PORTS } {
	# Procedure called to update MAX_PORTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MAX_PORTS { PARAM_VALUE.MAX_PORTS } {
	# Procedure called to validate MAX_PORTS
	return true
}

proc update_PARAM_VALUE.SPEED { PARAM_VALUE.SPEED } {
	# Procedure called to update SPEED when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SPEED { PARAM_VALUE.SPEED } {
	# Procedure called to validate SPEED
	return true
}


proc update_MODELPARAM_VALUE.SPEED { MODELPARAM_VALUE.SPEED PARAM_VALUE.SPEED } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SPEED}] ${MODELPARAM_VALUE.SPEED}
}

proc update_MODELPARAM_VALUE.MAX_PORTS { MODELPARAM_VALUE.MAX_PORTS PARAM_VALUE.MAX_PORTS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MAX_PORTS}] ${MODELPARAM_VALUE.MAX_PORTS}
}

