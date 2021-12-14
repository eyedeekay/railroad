# railroad

![Journey](journey.png)

Really, really easy, individual-oriented I2P blogging with a low barrier to
entry formerly based on [kabukky/journey](github.com/kabukky/journey), now
completely forked.

The first time you run Railroad you'll need to set a password, then re-start
the application. You can do this by visiting the WebView(via the traymenu) or
by visiting [http://localhost:8084/admin/login](http://localhost:8084/admin/login).

Enable the SAM API: Go to http://127.0.0.1:7657/configclients. Find the menu
item called "SAM application bridge." Select "Run at Startup" and press the small
arrow to the right of the text.

 - Easy: Markdown-based blogging with Side-by-Side WYSIWYG output for your
  blog's content. Edit live with a rich, intuitive interface.
 - Low barrier to Entry: Run on a desktop PC with any operating system. When
  it's running, it shows up as an application in your system tray.
 - Individual-oriented: Host it anywhere you can install an I2P router, no
  third-party hosting required. No complicated server setup.

## Get it:

![Menu](menu.png)

 - Windows I2P Plugin: [http://idk.i2p/railroad/railroad-windows.su3](http://idk.i2p/railroad/railroad-windows.su3)
 - Linux I2P Plugin: [http://idk.i2p/railroad/railroad-linux.su3](http://idk.i2p/railroad/railroad-linux.su3)

 - Binary Releases: [Github](https://github.com/eyedeekay/railroad/releases)
 - Source Code: [i2pgit.org](https://i2pgit.org/idk/railroad)

## build from source

![Editing a post](edit.png)

        go get -u i2pgit.org/idk/railroad

## build a 'package'

If your GOPATH is unset, set it to $HOME/go

        export GOPATH=$HOME/go

If your $GOPATH is set, leave it as-is.

        mkdir -p $GOPATH/src/i2pgit.org/idk/railroad
        git clone https://i2pgit.org/idk/railroad \
          $GOPATH/src/i2pgit.org/idk/railroad
        cd $GOPATH/src/i2pgit.org/idk/railroad
        make releases

## install a package

Enable the SAM API: Go to http://127.0.0.1:7657/configclients. Find the menu
item called "SAM application bridge." Select "Run at Startup" and press the small
arrow to the right of the text.

![SAM API Screenshot](configclients.png)

Download the package for your platform, `zip` for Windows, `tar.gz` for Linux.
Unzip the package and double-click the `railroad.exe` file for Windows or the
`railroad` file for Linux.

### build your own deb

Using `checkinstall` to generate a deb is done for you:

        mkdir -p $GOPATH/src/i2pgit.org/idk/railroad
        git clone https://i2pgit.org/idk/railroad \
          $GOPATH/src/i2pgit.org/idk/railroad
        cd $GOPATH/src/i2pgit.org/idk/railroad
        make checkinstall
        sudo apt-get install ./i2p-railroad_0.0.01-1_amd64.deb

will set up railroad on Debian and Ubuntu for your system.

## install using `make install`

When using make install a wrapper script is installed to set up railroad in
the user's $HOME/.config/railroad directory. It's installed to
`/usr/local/bin/railroad`.

        mkdir -p $GOPATH/src/i2pgit.org/idk/railroad
        git clone https://i2pgit.org/idk/railroad \
          $GOPATH/src/i2pgit.org/idk/railroad
        cd $GOPATH/src/i2pgit.org/idk/railroad
        sudo make install
