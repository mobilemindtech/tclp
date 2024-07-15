package require http
package require tls

http::register https 443 [list ::tls::socket -autoservername true]


namespace eval ::packer {
   
}

proc packer::import {uri} {

	set deps "./.deps"

	if {![file exists $deps]} {
		file mkdir $deps
	}

	if {[string match *.tcl $uri]} {
		load_file_from_uri $deps $uri
	} elseif {[string match *github.com* $uri]} {
		load_lib_from_git $deps $uri
	}

}

proc packer::load_lib_from_git {deps uri} {

	global auto_path

	set dirname [lindex [split $uri /] end]
	set dirname [lindex [split $dirname .] end-1]

	if {![file exists $deps/$dirname]} {
		set cmd [list git clone $uri $deps/$dirname]
		exec {*}$cmd 
	}

	puts "add autopath $deps/$dirname"
	lappend auto_path $deps/$dirname
}

proc packer::load_file_from_uri {deps uri} {
	set filename [lindex [split $uri /] end]
	set file_path $deps/$filename
	if {![file exists $file_path]} {
		puts "downloading dep $filename.."
		set token [http::geturl $uri]
		set data [::http::data $token]
		::http::cleanup $token
		set fd [open $file_path w+]
		puts $fd $data
		close $fd
		puts "dep $filename downloaded"
	}
	puts "use file from $"
	source $deps/$filename	
}