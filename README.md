# The TCL Project Manager

TCL project manager

## Usage

First, install tclp into project folder

```bash
mkdir myapp && cd myapp
curl https://raw.githubusercontent.com/mobilemindtech/tclp/master/tclp -o tclp
chmod +x ./tclp && ./tclp init
```

Or global

```
$ curl https://raw.githubusercontent.com/mobilemindtech/tclp/master/tclp -o /bin/tclp && sudo chmod +x /bin/tclp
```

After, create your `build.yaml` into project folder:


```yaml
app:
  name: My app
  description: My app descripiton
  entrypoint: ./main.tcl
  testdir: ./tests

dependencies:
  #- https://raw.githubusercontent.com/mobilemindtech/tcl-hash/master/hash.tcl # import file
  - https://github.com/mobilemindtech/tcl-hash.git # import pure tcl lib
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
./tclp build
./tclp run
```

Or clone test project:


```bash
$ git clone https://github.com/mobilemindtech/tcl-tclp-sample.git myapp
$ cd myapp && ./tclp build
$ ./tclp run
```


### Default commands:

* `init`: Create build.yaml in current folder
* `build`: Build project
* `clean`: Delete .tcl folder
* `run`: Run project
* `test`: Run project tests
* `upgrade`: Upgrade tclp
*  `new <package or app> <name>`: Create packate or app project

### Custom commands

Examples:

* `trails.migrate: ./app.tcl migrate` run with `./tclp trails migrate`
* `trails.dev.forever: ./app.tcl dev` run with `./tclp trails prod`
* `trails.prod.forever: ./app.tcl prod` run with `./tclp trails prod`
* `trails.test: ./app.tcl test`  run with `./tclp trails test -- match "index_controller"`

### Test

You can pass test args with `--`

```
$ ./tclp test --help
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

$ ./tclp test -- match "match value"

```