# TCL packer

Use file or package from github

## Usage

Into tcl project

```bash
$ curl https://raw.githubusercontent.com/mobilemindtec/tcl-packer/master/packer.tcl > packer.tcl
```

Into tcl file

```tcl
source ./packer.tcl

# import single file
packer https://raw.githubusercontent.com/mobilemindtec/tcl-hash/master/hash.tcl

# or import packege
packer::import https://github.com/mobilemindtec/tcl-hash.git
package require hash 1.0

hash::hash m :a 1 :b 2
puts [hash::hget $m :a]
```
