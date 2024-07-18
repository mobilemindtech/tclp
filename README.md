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

## Use build file

into main project folder, create `build.yaml`

```yaml
app:
  name: My app
  description: My app descripiton
  entrypoint: ./main.tcl

dependencies:
  # - https://raw.githubusercontent.com/mobilemindtec/tcl-hash/master/hash.tcl
  - https://github.com/mobilemindtec/tcl-hash.git
  - http-tcl

requirements:
  packages: 
    - mysqltcl
  cmds:
    - curl --version
  

build:
  cmds:

http-tcl:
  uri: https://github.com/anticrisis/tcl-http.git
  cmds:
    - ./act build manifest.txt
    - mkdir -p build/tcl/modules/act && mkdir -p build/tcl/packages 
    - cp build/http-0.1.tm build/tcl/modules/act/
    - cp build/act_http/pkgIndex.tcl build/tcl/packages 
  imports:
    - ::tcl::tm::path add [file normalize ./.tcl/tcl-http/build/tcl/modules]
    - lappend ::auto_path [file normalize ./.tcl/tcl-http/build/tcl/packages]

```

main.tcl

```tcl

source .tcl/deps.tcl

package require act::http

act::http configure \
	-host 127.0.0.1 \
	-port 5151 \
	-get {list 200 "hello, world" "text/plain"}

puts "running web app on port 5151"

act::http run

```

execute

```shell
./packer.tcl build
./packer.tcl run
```

See complete example on http://github.com/mobilemindtec/packer-tcl-example
