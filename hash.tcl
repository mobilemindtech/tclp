proc hget {d k {def ""}} { 
	if {[dict exists $d $k]} {
		dict get $d $k 
	} else {
		return $def
	}
}

proc hset {d k v} {
	upvar $d d_
	dict set d_ $k $v
}

proc hcount {d} { dict size $d }
proc hcontains {d k} { dict exists $d $k }
proc hash {var args} { 
	upvar $var var_	
	set var_ [dict create {*}$args]
}
