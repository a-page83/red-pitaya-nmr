
set core_name [lindex $argv 0]

set part_name [lindex $argv 1]

file delete -force tmp/cores/cores_page/$core_name tmp/cores/cores_page/$core_name.cache tmp/cores/cores_page/$core_name.hw tmp/cores/cores_page/$core_name.ip_user_files tmp/cores/cores_page/$core_name.sim tmp/cores/cores_page/$core_name.xpr

create_project -part $part_name $core_name tmp/cores/cores_page

add_files -norecurse cores/cores_page/$core_name.v

set_property TOP $core_name [current_fileset]

# set files [glob -nocomplain modules/*.v]
# if {[llength $files] > 0} {
#   add_files -norecurse $files
# }

ipx::package_project -root_dir tmp/cores/$core_name 

set core [ipx::current_core]

set_property VERSION {1.0} $core
set_property NAME $core_name $core
set_property LIBRARY {user} $core
set_property VENDOR {page} $core
set_property VENDOR_DISPLAY_NAME {Adrien Page} $core
set_property COMPANY_URL {} $core
set_property SUPPORTED_FAMILIES {zynq Production} $core

ipx::create_xgui_files $core
ipx::update_checksums $core
ipx::save_core $core

close_project
