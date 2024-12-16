# The TCL Package Manager

This utility operates with pure TCL libraries, tm builds, or binaries. 
Pure libraries are simply installed, looking at their dependencies, if any. 

Libraries that need to build tm or lib must define their build rules and artifact path. See the .yaml file below for a more detailed explanation.

## Usage

Install

```bash
sudo curl https://raw.githubusercontent.com/mobilemindtech/tclp/master/tclp -s -o /usr/bin/tclp && sudo chmod +x /usr/bin/tclp
```

After, create your `tclp.yaml` into app folder:


```yaml
app:
  name: myapp # libname
  description: myapp descripiton
  entrypoint: ./main.tcl
  testdir: ./tests

# We use dependencies directly from github. In this case, the repository must be a valid TCL package.
# Or we can provide a package with its own construction rule and then define that rule
dependencies:
  - https://github.com/mobilemindtech/tcl-request.git
  - https://github.com/mobilemindtech/tcl-sjson.git
  - https://github.com/mobilemindtech/tcl-tools.git
  #- https://github.com/mobilemindtec/tcl-http.git
  - http-tcl # lib with owner build rule

# requirements to check  
requirements:
  packages: 
  #  - mysqltcl # check if package is installed
  #  - tcllib
  cmds:
  #  - curl --version # check curl is installed
  
build:
  url: # use to "proxy" lib using this builder file
  libdir: # out dir module after build
  tm: # tm module rule
    file: # tm file genarated
    dir: # dir name to install if need 
  cmds:
    
    
# lib build rule
http-tcl:
  name: act_http
  url: https://github.com/anticrisis/tcl-http.git
  build:
    # In libdir we can inform the folder where lib and pkgIndex will be generated.
    # We must use this option or the .tm generation option.
    #libdir: build/act_http # out dir module after build

    # In tm we inform the path of the generated .tem package and the name of the folder where it will live,
    # if applicable. In the case below 'atc/http-0.1.tm' will be used as the package home,
    # whether in the local or global installation option.	
    tm: # tm module rule
      file: build/http-0.1.tm 
      dir: act

    # build commands
    cmds:
      - ./act vcpkg setup || true
      - ./act build manifest.txt

# custom commands
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
./tclp install
./tclp run
```


### CLI:

* `init`: Create tclp.yaml in current folder
* `install`: Install project packages localy
* `clean`: Delete `.tcl` folder
* `run`: Run app
* `test`: Run tests
* `upgrade`: Upgrade `tclp`
*  `new app <name>`: Create app
*  `new package <name>`: Create package
*  `pkg install <url> <name?>`: Install package from URL. See more information below
*  `pkg list`: List installed packages

#### pkg install <url> <name?>

The repository must be a valid TCL package or must have a tclp.yam with construction rule. 

Let's say the repository is called `tcl-mylib`, we can pass the package name `mylib` as a second parameter so this will be assumed as the package name.

We can also define a minimum file `tclp.yaml` within the package: 

```yaml
app:
  name: myapp
```

Then this name will be assumed. Otherwise, the repository name will be assumed.

#### install package via "proxy rule"

I also thought about the idea of ​​creating a "proxy" package that defines a build rule for an external package. For example.

```
app:
  name: act_http

build:
  url: https://github.com/anticrisis/tcl-http.git
  tm:
    file: build/http-0.1.tm
    dir: act  
  cmds:
    - ./act vcpkg setup
    - ./act build manifest.txt
```

In this case, we create a "proxy rule" repository for the `tcl-http` package where we define the construction rule. 
The key is to define the actual package `url` within the `build`. So it knows it needs to download the package for building. 

This is for global package installation, since for local installations (projects) the rule can be defined within the project itself.


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
