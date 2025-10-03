# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "AW" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DCMAC_BASE_ADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DEFAULT_MAINCURSOR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DEFAULT_POSTCURSOR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DEFAULT_PRECURSOR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DEFAULT_QSFP_POWER" -parent ${Page_0}


}

proc update_PARAM_VALUE.AW { PARAM_VALUE.AW } {
	# Procedure called to update AW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AW { PARAM_VALUE.AW } {
	# Procedure called to validate AW
	return true
}

proc update_PARAM_VALUE.DCMAC_BASE_ADDR { PARAM_VALUE.DCMAC_BASE_ADDR } {
	# Procedure called to update DCMAC_BASE_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DCMAC_BASE_ADDR { PARAM_VALUE.DCMAC_BASE_ADDR } {
	# Procedure called to validate DCMAC_BASE_ADDR
	return true
}

proc update_PARAM_VALUE.DEFAULT_MAINCURSOR { PARAM_VALUE.DEFAULT_MAINCURSOR } {
	# Procedure called to update DEFAULT_MAINCURSOR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_MAINCURSOR { PARAM_VALUE.DEFAULT_MAINCURSOR } {
	# Procedure called to validate DEFAULT_MAINCURSOR
	return true
}

proc update_PARAM_VALUE.DEFAULT_POSTCURSOR { PARAM_VALUE.DEFAULT_POSTCURSOR } {
	# Procedure called to update DEFAULT_POSTCURSOR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_POSTCURSOR { PARAM_VALUE.DEFAULT_POSTCURSOR } {
	# Procedure called to validate DEFAULT_POSTCURSOR
	return true
}

proc update_PARAM_VALUE.DEFAULT_PRECURSOR { PARAM_VALUE.DEFAULT_PRECURSOR } {
	# Procedure called to update DEFAULT_PRECURSOR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_PRECURSOR { PARAM_VALUE.DEFAULT_PRECURSOR } {
	# Procedure called to validate DEFAULT_PRECURSOR
	return true
}

proc update_PARAM_VALUE.DEFAULT_QSFP_POWER { PARAM_VALUE.DEFAULT_QSFP_POWER } {
	# Procedure called to update DEFAULT_QSFP_POWER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_QSFP_POWER { PARAM_VALUE.DEFAULT_QSFP_POWER } {
	# Procedure called to validate DEFAULT_QSFP_POWER
	return true
}


proc update_MODELPARAM_VALUE.AW { MODELPARAM_VALUE.AW PARAM_VALUE.AW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AW}] ${MODELPARAM_VALUE.AW}
}

proc update_MODELPARAM_VALUE.DEFAULT_PRECURSOR { MODELPARAM_VALUE.DEFAULT_PRECURSOR PARAM_VALUE.DEFAULT_PRECURSOR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_PRECURSOR}] ${MODELPARAM_VALUE.DEFAULT_PRECURSOR}
}

proc update_MODELPARAM_VALUE.DEFAULT_POSTCURSOR { MODELPARAM_VALUE.DEFAULT_POSTCURSOR PARAM_VALUE.DEFAULT_POSTCURSOR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_POSTCURSOR}] ${MODELPARAM_VALUE.DEFAULT_POSTCURSOR}
}

proc update_MODELPARAM_VALUE.DEFAULT_MAINCURSOR { MODELPARAM_VALUE.DEFAULT_MAINCURSOR PARAM_VALUE.DEFAULT_MAINCURSOR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_MAINCURSOR}] ${MODELPARAM_VALUE.DEFAULT_MAINCURSOR}
}

proc update_MODELPARAM_VALUE.DCMAC_BASE_ADDR { MODELPARAM_VALUE.DCMAC_BASE_ADDR PARAM_VALUE.DCMAC_BASE_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DCMAC_BASE_ADDR}] ${MODELPARAM_VALUE.DCMAC_BASE_ADDR}
}

proc update_MODELPARAM_VALUE.DEFAULT_QSFP_POWER { MODELPARAM_VALUE.DEFAULT_QSFP_POWER PARAM_VALUE.DEFAULT_QSFP_POWER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_QSFP_POWER}] ${MODELPARAM_VALUE.DEFAULT_QSFP_POWER}
}

