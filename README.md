# Simple D Version Management: denv

denv lets you easily switch between multiple versions of D. It's
simple, unobtrusive, and follows the UNIX tradition of single-purpose
tools that do one thing well.

denv is a D version of rbenv. Thanks to @sstephenson.

### denv _does?_

* Let you **change the global D version** on a per-user basis.
* Provide support for **per-project D versions**.
* Allow you to **override the D version** with an environment
  variable.

## Table of Contents

   * [1 How It Works](#section_1)
   * [2 Installation](#section_2)
      * [2.1 Basic GitHub Checkout](#section_2.1)
         * [2.1.1 Upgrading](#section_2.1.1)
      * [2.2 Neckbeard Configuration](#section_2.2)
   * [3 Usage](#section_3)
      * [3.1 denv global](#section_3.1)
      * [3.2 denv local](#section_3.2)
      * [3.3 denv shell](#section_3.3)
      * [3.4 denv versions](#section_3.4)
      * [3.5 denv version](#section_3.5)
      * [3.6 denv rehash](#section_3.6)
      * [3.7 denv which](#section_3.7)
      * [3.8 denv install](#section_3.8)
      * [3.9 denv uninstall](#section_3.9)
   * [4 Development](#section_4)
      * [4.1 Version History](#section_4.1)
      * [4.2 License](#section_4.2)

## <a name="section_1"></a> 1 How It Works

denv operates on the per-user directory `~/.denv`. Version names in
denv correspond to subdirectories of `~/.denv/versions`. For
example, you might have `~/.denv/versions/dmd-1.071` and
`~/.denv/versions/dmd-2.059`.

Each version is a working tree with its own binaries, like
`~/.denv/versions/dmd-1.071/bin/dmd` and
`~/.denv/versions/dmd-2.059/bin/rdmd`. denv makes _shim binaries_
for every such binary across all installed versions of D.

These shims are simple wrapper scripts that live in `~/.denv/shims`
and detect which D version you want to use. They insert the
directory for the selected version at the beginning of your `$PATH`
and then execute the corresponding binary.

Because of the simplicity of the shim approach, all you need to use
denv is `~/.denv/shims` in your `$PATH`.

## <a name="section_2"></a> 2 Installation

**Compatibility note**: denv is _incompatible_ with dvm.

### <a name="section_2.1"></a> 2.1 Basic GitHub Checkout

This will get you going with the latest version of denv and make it
easy to fork and contribute any changes back upstream.

1. Check out denv into `~/.denv`.

        $ cd
        $ git clone git://github.com/repeatedly/denv.git .denv

2. Add `~/.denv/bin` to your `$PATH` for access to the `denv`
   command-line utility.

        $ echo 'export PATH="$HOME/.denv/bin:$PATH"' >> ~/.bash_profile

    **Zsh note**: Modify your `~/.zshenv` file instead of `~/.bash_profile`.

3. Add denv init to your shell to enable shims and autocompletion.

        $ echo 'eval "$(denv init -)"' >> ~/.bash_profile

    **Zsh note**: Modify your `~/.zshenv` file instead of `~/.bash_profile`.

4. Restart your shell so the path changes take effect. You can now
   begin using denv.

        $ exec $SHELL

5. Install D versions by using `denv install`.

        $ denv install dmd-2.059

<!--
    The [d-build](https://github.com/repeatedly/d-build) project
    provides an `denv install` command that simplifies the process of
    installing new D versions to:

        $ denv install 2.059
-->

#### <a name="section_2.1.1"></a> 2.1.1 Upgrading

If you've installed denv using the instructions above, you can
upgrade your installation at any time using git.

To upgrade to the latest development version of denv, use `git pull`:

    $ cd ~/.denv
    $ git pull

To upgrade to a specific release of denv, check out the corresponding
tag:

    $ cd ~/.denv
    $ git fetch
    $ git tag
    v0.1.0
    v0.1.1
    v0.1.2
    v0.2.0
    $ git checkout v0.2.0

### <a name="section_2.2"></a> 2.2 Neckbeard Configuration

Skip this section unless you must know what every line in your shell
profile is doing.

`denv init` is the only command that crosses the line of loading
extra commands into your shell. Coming from rvm, some of you might be
opposed to this idea. Here's what `denv init` actually does:

1. Sets up your shims path. This is the only requirement for denv to
   function properly. You can do this by hand by prepending
   `~/.denv/shims` to your `$PATH`.

2. Installs autocompletion. This is entirely optional but pretty
   useful. Sourcing `~/.denv/completions/denv.bash` will set that
   up. There is also a `~/.denv/completions/denv.zsh` for Zsh
   users.

3. Rehashes shims. From time to time you'll need to rebuild your
   shim files. Doing this on init makes sure everything is up to
   date. You can always run `denv rehash` manually.

4. Installs the sh dispatcher. This bit is also optional, but allows
   denv and plugins to change variables in your current shell, making
   commands like `denv shell` possible. The sh dispatcher doesn't do
   anything crazy like override `cd` or hack your shell prompt, but if
   for some reason you need `denv` to be a real script rather than a
   shell function, you can safely skip it.

Run `denv init -` for yourself to see exactly what happens under the
hood.

## <a name="section_3"></a> 3 Usage

Like `git`, the `denv` command delegates to subcommands based on its
first argument. The most common subcommands are:

### <a name="section_3.1"></a> 3.1 denv global

Sets the global version of D to be used in all shells by writing
the version name to the `~/.denv/version` file. This version can be
overridden by a per-project `.denv-version` file, or by setting the
`DENV_VERSION` environment variable.

    $ denv global dmd-2.059

The special version name `system` tells denv to use the system D
(detected by searching your `$PATH`).

When run without a version number, `denv global` reports the
currently configured global version.

### <a name="section_3.2"></a> 3.2 denv local

Sets a local per-project D version by writing the version name to
an `.denv-version` file in the current directory. This version
overrides the global, and can be overridden itself by setting the
`DENV_VERSION` environment variable or with the `denv shell`
command.

    $ denv local dmd-2.058

When run without a version number, `denv local` reports the currently
configured local version. You can also unset the local version:

    $ denv local --unset

### <a name="section_3.3"></a> 3.3 denv shell

Sets a shell-specific D version by setting the `DENV_VERSION`
environment variable in your shell. This version overrides both
project-specific versions and the global version.

    $ denv shell dmd-2.059

When run without a version number, `denv shell` reports the current
value of `DENV_VERSION`. You can also unset the shell version:

    $ denv shell --unset

Note that you'll need denv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`DENV_VERSION` variable yourself:

    $ export DENV_VERSION=dmd-2.058

### <a name="section_3.4"></a> 3.4 denv versions

Lists all D versions known to denv, and shows an asterisk next to
the currently active version.

    $ denv versions
      dmd-2.058
    * dmd-2.059 (set by /Users/sam/.denv/global)
      gdc-2.x
      ldc-x.x

NOTE: Now, gdc is not supported.

### <a name="section_3.5"></a> 3.5 denv version

Displays the currently active D version, along with information on
how it was set.

    $ denv version
    dmd-2.059 (set by /Volumes/37signals/basecamp/.denv-version)

### <a name="section_3.6"></a> 3.6 denv rehash

Installs shims for all D binaries known to denv (i.e.,
`~/.denv/versions/*/os/bin/*`). Run this command after you install a new
version of D, or install a gem that provides binaries.

    $ denv rehash

### <a name="section_3.7"></a> 3.7 denv which

Displays the full path to the binary that denv will execute when you
run the given command.

    $ denv which dmd
    /Users/sam/.denv/versions/dmd-2.059/osx/bin/dmd

### <a name="section_3.8"></a> 3.8 denv install

Install a D version.

    $ denv install dmd-2.061
    Downloading 2.061...
    2013-01-20 18:02:24 URL:http://downloads.dlang.org.s3-website-us-east-1.amazonaws.com/releases/2013/dmd.2.061.zip [31601020/31601020] -> "-" [1]
    Installing 2.061 to /Users/sam/.denv/versions/dmd-2.061

Currenlty, support compiliers are dmd and ldc. gdc will be added.

### <a name="section_3.9"></a> 3.9 denv uninstall 

Uninstall a specific D version.

    $ denv uninstall dmd-2.061
    denv: remove /Users/sam/.denv/versions/dmd-2.061? y

## <a name="section_4"></a> 4 Development

The denv source code is [hosted on
GitHub](https://github.com/repeatedly/denv). It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/repeatedly/denv/issues).

### <a name="section_4.1"></a> 4.1 Version History

**0.1.2** (January 22, 2013)

* Add `install` and `uninstall`.

**0.1.1** (March 5, 2012)

* Fix Linux environemnt bug.

**0.1.0** (March 4, 2012)

* Fork [rbenv](https://github.com/sstephenson/rbenv)

### <a name="section_4.2"></a> 4.2 License

(The MIT license)

Copyright (c) 2011- Sam Stephenson, Masahiro Nakagawa

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
