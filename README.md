# TCL packer

TCL package manager

## Usage

First, install packer into project folder

```bash
$ mkdir myapp && cd myapp
$ curl https://raw.githubusercontent.com/mobilemindtec/tcl-packer/master/packer.tcl > packer
$ chmod +x ./packer && ./packer init
```

After, create your `build.yaml` into project folder:


```yaml
app:
  name: My app
  description: My app descripiton
  entrypoint: ./main.tcl
  testdir: ./tests

dependencies:
  #- https://raw.githubusercontent.com/mobilemindtec/tcl-hash/master/hash.tcl # import file
  - https://github.com/mobilemindtec/tcl-hash.git # import pure tcl lib
  - http-tcl # import c tcl lib

requirements:
  packages: 
    - mysqltcl # check if package is installed
    - tcllib
  cmds:
    - curl --version # check curl is installed
  
build:
  cmds:

# TCL c lib install
http-tcl:
  uri: https://github.com/anticrisis/tcl-http.git
  cmds:
    - ./act vcpkg setup
    - ./act build manifest.txt
    - mkdir -p build/tcl/modules/act && mkdir -p build/tcl/packages 
    - cp build/http-0.1.tm build/tcl/modules/act/
    - cp build/act_http/pkgIndex.tcl build/tcl/packages 
  imports:
    - ::tcl::tm::path add [file normalize ./.tcl/tcl-http/build/tcl/modules]
    - lappend ::auto_path [file normalize ./.tcl/tcl-http/build/tcl/packages]

commands:
  trails.migrate: ./app.tcl migrate
  trails.dev.forever: ./app.tcl dev
  trails.prod.forever: ./app.tcl prod
  trails.test: ./app.tcl test    

```

After, create your app script `main.tcl`

```bash

source .tcl/deps.tcl

package require act::http

act::http configure \
	-host 127.0.0.1 \
	-port 5151 \
	-get {list 200 "hello, world" "text/plain"}

puts "running web app on port 5151"

act::http run


```

So, build and run:

```shell
./packer build
./packer run
```

Or clone test project:


```bash
$ git clone https://github.com/mobilemindtech/tcl-packer-sample.git myapp
$ cd myapp && ./packer build
$ ./packer run
```


### Default commands:

* `build` start build and resolve deps
* `clean` clean `.tcl` folder
* `run` run app `entrypoint`
* `test` run tests on `testdir`
* `upgrade` upgrade packer to last version
* `init` init new project


### Custom commands


Examples:

* `trails.migrate: ./app.tcl migrate` run with `./packer trails migrate`
* `trails.dev.forever: ./app.tcl dev` run with `./packer trails prod`
* `trails.prod.forever: ./app.tcl prod` run with `./packer trails prod`
* `trails.test: ./app.tcl test`  run with `./packer.tcl trails test -- match "index_controller"`

### Test

Test can use test param using `--`

```
$ ./packer test --help
::> Test usage:
::> configure -file patternList
::> configure -notfile patternList
::> configure -match patternList
::> configure -skip patternList
::> matchFiles patternList = shortcut for configure -file
::> skipFiles patternList = shortcut for configure -notfile
::> match patternList = shortcut for configure -match
::> skip patternList = shortcut for configure -skip
::> See more at https://wiki.tcl-lang.org/page/tcltest

$ ./packer test -- match "match value"

```