# write_ips
#   Write a Tcl script which recreates IP cores and their configuration.
#
#   Recreating IP cores from a Tcl script prevents version control systems to
#   report changes on XCI files due to updated IP cache ID or other nuisances.
# Parameters:
#   ips    : list of IP objects (as returned by Vivado's get_ips command).
#   ipFile : output file name.
#

proc write_ips {ips ipFile} {
  set ipFH [open $ipFile "w"];
  puts $ipFH "# File generated by write_ips with Vivado [version -short].";
  foreach {ip} $ips {
    set ipVLNV [get_property IPDEF $ip];
    set ipName [get_property NAME $ip];
    set ipPart [get_property PART $ip];
    set ipSelectedSimModel [get_property SELECTED_SIM_MODEL $ip];
    set ipIsLocked [get_property IS_LOCKED $ip];
    set ipConfig [list_property $ip -regex CONFIG.*];
    
    puts $ipFH \
"################################################################################";
    puts $ipFH "# $ipName";
    puts $ipFH \
"################################################################################";
    puts $ipFH "set ipName $ipName";
    puts $ipFH "if \[catch {";
    puts $ipFH "  create_ip -vlnv $ipVLNV -module_name \$ipName";
    puts $ipFH "} errCreateIp optCreateIp\] {";
    puts $ipFH "  puts \$errCreateIp";
    puts $ipFH "} else {";
    puts $ipFH "if \[catch {";
    puts $ipFH "  \# set_property PART $ipPart \[get_ips \$ipName\]";
    puts $ipFH "  set_property SELECTED_SIM_MODEL $ipSelectedSimModel \[get_ips \$ipName\]";
    puts $ipFH "  set_property IS_LOCKED $ipIsLocked \[get_ips \$ipName\]";
    foreach {p} $ipConfig {
      puts $ipFH "  set_property $p [get_property $p $ip] \[get_ips \$ipName\]";
    }
    puts $ipFH "} errSetProperty optSetProperty\] {";
    puts $ipFH "  puts \$errSetProperty";
    # puts $ipFH "puts \"Error encountered during IP configuration, cleaning up IP \$ipName\"";
    # puts $ipFH "set ipFile \[get_property IP_FILE \$ipName\]";
    # puts $ipFH "set ipDir \[get_property IP_DIR \$ipName\]";
    # puts $ipFH "export_ip_user_files -of_objects \$ipFile -no_script -reset -force -quiet";
    # puts $ipFH "remove_files \$ipFile";
    # puts $ipFH "file delete -force \$ipDir";
    puts $ipFH "}";
    puts $ipFH "}";
  }
  close $ipFH;
}
