![Logo Remoton](https://cloud.githubusercontent.com/assets/1474826/8950994/543baebc-358e-11e5-886c-d4c440d3417f.png)

# Release

(Go) Own remote desktop platform - builder binaries/installer

A crosscompile scripts for building GNU/Linux and M.Windows binaries/installer release.

## Usage

~~~bash
$ git clone https://github.com/bit4bit/remoton-release.git
$ cd remoton-release
$ make remoton-src
$ make all
~~~

## Usage on Vagrant
~~~bash
$ cd /vagrant
$ make remoton-src
$ make all
~~~

## Requeriments

  * [GNU/Linux](http://www.gnu.org)
  * [Go](http://www.golang.org)
  * wget
  * unzip
  * Make
  * mingw
  * Nsis
  * [Fpm](https://github.com/jordansissel/fpm)
  * Wine
  
