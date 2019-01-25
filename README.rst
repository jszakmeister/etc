etc
###

This contains some of my (often used) configuration settings for Mac and
Linux.  I hope you find it useful.

Parts
=====

The repository is broken into a few different pieces:

* bash/ - Contains my bash configuration.
* zsh/ - Contains my zsh configuration.
* shell-common/ - Contains support scripts used by both bash and zsh.
* editrc/ - Contains an rc script used to configure editline (used in
  various places on the Mac).
* inputrc/ - Contains an rc script used to configure readline.
* gitconfig/ - Contains a couple of files that I use to help configure git.
* git-addons/ - Contains a couple of git commands that I find myself using
  frequently.
* python/ - A startup.py script for use with the Mac to enable readline support.
* pair/ - Houses a script to change the author for git when doing pair
  programming.


Getting the Repository
======================

Things work best when using the default install location of
``$HOME/projects/etc``.  To do this, simply run::

  mkdir -p ~/projects
  cd ~/projects
  git clone https://github.com/jszakmeister/etc.git

You can choose to clone the repository elsewhere (``~/.etc`` is often a
useful place).  However, there is a tad more work you need to do.  Those steps
will be explained below.


Quick Start
===========

To opt into everything, the easiest thing to do is run the ``setup.sh`` file.
It will create the necessary files and symlinks to all the appropriate content.


Setting up Bash
===============

My Bash environment sets up quite a few things.  The most noticeable bit is the
prompt, but it also adjusts some shell options for history, smart
auto-completion, aliases, a few environment settings, and the PATH.  At the
moment, there is no way to dissect it and just get the bits you want.  Perhaps
down the road, I'll make it more severable.

To get started, all you really need to do is add a line to your ``~/.bashrc``
file::

  source $HOME/projects/etc/bash/bashrc

That will bring in the entire environment.  If you checkout out ``etc.git`` to a
different location, then you need something like this::

  ETC_HOME=/path/to/location
  source $ETC_HOME/bash/bashrc

So if you checkout out ``etc.git`` to ``~/.etc``, your ``~/.bashrc`` should
contain::

  ETC_HOME=$HOME/.etc
  source $ETC_HOME/bash/bashrc

You'll need to exit your shell, and create a new one.  That should let the new
settings take affect.

.. note:: The default configuration expects that you're using a terminal with
   a dark background color.  If you're using a light background, you may find
   the prompt to be unreadable as it uses some fairly light colors.


For the Mac
-----------

It seems that Macs don't have their shell environment setup out-of-the-box...
at least with Snow Leopard or earlier.  Therefore, you will need to add a
``~/.bash_profile`` with the following text::

  if [ "${BASH-no}" != "no" ]; then
          [ -r ~/.bashrc ] && . ~/.bashrc
  fi

This simply checks for the existence of ``~/.bashrc`` and sources it.


Setting up ZSH
==============

I've also been exploring the use of ZSH.  Primarily because ZSH has some better
prompting capabilities.  I won't waste time trying to compare Bash and ZSH.
Both are great shells, and both have strengths and weaknesses.

To get started, do is add a line to your ``~/.zshrc`` file (create the file if
it doesn't exist)::

  source $HOME/projects/etc/zsh/zshrc

As with Bash, it will bring in the entire environment.  If you checkout out
``etc.git`` a different location, then you need something like this::

  ETC_HOME=/path/to/location
  source $ETC_HOME/zsh/zshrc

So if you checkout out ``etc.git`` to ``~/.etc``, your ``~/.zshrc`` should
contain::

  ETC_HOME=$HOME/.etc
  source $ETC_HOME/zsh/zshrc

You'll need to exit your shell, and create a new one.  That should let the new
settings take affect.

Changing your Shell
-------------------

ZSH is usually not the default shell.  To start a ZSH, you can just run ``zsh``.
However, if you want to change your shell so that it's the default on launched,
you need to run this at the command line::

  chsh -s /bin/zsh

It'll ask for your password and switch the shell.

Getting PATH updates with ssh server <command>
----------------------------------------------

I occasionally have the need to run a command on a server with ssh.  However, I
set up some tools in path that are not the default locations.  To deal with
that, you need to have a ``~/.zshenv``.  If you anticipate the need to do such
a thing, they you'll want to create a ``~/.zshenv`` file that has the
following::

  source $HOME/projects/etc/zsh/zshenv

Or, if you have ``etc.git`` checked out elsewhere::

  ETC_HOME=/path/to/location
  source $ETC_HOME/zsh/zshenv


Prompt Configuration
====================

The prompt in the shell configuration will provide some useful information about
the status of your branch in a Git working tree or repository.  However, some of
what it provides can be expensive if you work in a large repository, or on a
branch that is many commits behind master.

To turn of the status indicator (the red ``*`` that lets you know the working
tree is dirty), simply create a file called ``.nostatus`` in the ``.git``
folder::

    touch .git/.nostatus

Whenever you create a new branch, if there's no upstream branch configured or if
there is no matching remote branch (in the case you have ``push.default`` set to
``current``, ``matching``, or ``simple``), then the prompt will perform a
comparison against ``master`` to let you know if you have real work hanging
around on a local branch, and how much.  To turn this off, create a file called
``.nomaster`` in the ``.git`` folder::

    touch .git/.nomaster


Readline
========

Years ago, I got hooked on being able to type a few characters, hit up, and
start scrolling through all commands that started with those characters.  In
fact, I feel disabled at the keyboard with out it.  So I've captured my
configuration in ``inputrc/inputrc``.  If you desire that feature, simply create
a symbolic link to the file at ``~/.inputrc``::

  cd ~
  ln -s /path/to/etc/inputrc/inputrc .inputrc

You can reload the readline settings by typing ``Ctrl-X Ctrl-R``, but I've had a
few experiences where that didn't seem to work.  You may need to logout and then
back in again for it to take effect.


Editline
========

Some applications on the Mac use editline, which is similar to readline.  I have
the equivalent settings in ``editrc/editrc``.  Editline seems to be less
capable, so it's not a perfect match but it's close enough.  Set it up by
doing::

  cd ~
  ln -s /path/to/etc/editrc/editrc .editrc


Git Configuration
=================

I keep some common options that I configure in ``gitconfig/gitconfig``.  They
make my git environment more usable for me.  Simply cut and paste what you want
from there, and put it in the appropriate section of ``~/.gitconfig``.  At some
point, I'm going to write a script to help automate this process more, but for
now, cut-and-paste is it.

.. note:: Pay close attention to ``excludesfile`` in the ``[core]`` section.
   It references ``$HOME/projects/etc/gitconfig/gitignores``.  Change this to
   the correct path, if you have etc in a different location.


Python
======

Only on the Mac, I set up the PYTHONSTARTUP variable to point at
``$ETC_HOME/python/startup.py``.  This simply sets up readline, so you get a
decent interpreter command line interface.


Nifty Features
==============

I'm highly productive, but I'm also lazy.  I don't like to type more than I need
to, so I've set up shortcuts for many things.

Some of my favorite are:

* ``cdt`` - Stands for "change directory to top."  This command will look for
  known directories, like .git or .svn, or for a file name ``.cdt-stop``
  starting from the current directory and working its way up the tree.  If it
  finds the required directory or file, it'll change to that folder.  This is an
  excellent way to get to the top of git tree or a project folder.

* ``cd<x>`` - where ``<x>`` is a character set of your choosing.  I have many,
  such as ``cdp`` to change to ``~/projects``.  There are also ``pd<x>``
  versions to push the current directory onto the stack and change to the
  designated folder.  You can use ``_add_dir_shortcut`` to create these aliases::

      _add_dir_shortcut p ~/projects true

  Here the ``p`` is the character that should come after ``cd`` and ``pd``.  The
  ``~/projects`` argument is the folder to change into.  And the ``true`` is
  really for zsh users... it'll create a directory alias, ``~p`` in this case,
  that you can use to reference that folder on the command line.

* ``_has_executable`` is a safe way to detect whether an executable is on the
  path.  There's not a good POSIX portable way of doing this (each shell has
  it's own way), so ``_has_executable`` was developed to provide this since I
  bounce between both zsh and bash environments.

* ``md`` - Makes a directory and then changes into it.

* ``ssh-add`` - Automatically starts an SSH agent, if one is not running.  Then
  adds the requested key.

* Command line completion for some included tools, such as git-ffwd.

* Auto-sourcing of virtualenvwrapper.sh, if found.

* ``update-common`` is a handy script for updating a series of repos that live
  at ``~/.vim``, ``~/.vimuser``, ``~/.ssh``, ``~/.etc``, and several other
  locations to help keep them up-to-date.  You can create a `~/.update-commonrc`
  file with a list of paths to update and the ``update-common`` script will
  update those paths too.  You can use ``~`` in the paths as the shell will
  expand it.

* ``simple-http`` is handy for when you need a quick webserver to serve up a
  directory of files.  It currently requires Python 2.

* ``gr`` - Used to open a file in an already running gvim instance (you have to
  start the original instance with ``gr`` too).  If you create a ``.gr-name``
  file with a name in it, it will use that name as the session to restore and
  the window name of the instance.  This may require a special tool on some
  systems to help bring the instance into the foreground.

* ``chrome`` and ``firefox`` contain user stylesheets for making the browser
  show monospaced fonts in places, like GitHub comments, where you might be
  typing code or markdown.

* ``ssh`` has some configuration files that give you an idea about some settings
  to put in your own configuration to change port numbers, limit authentication,
  and pass environment variables.

* ``fonts`` contains some handy fonts that I like to have available on a system.
  In particular, I like the Hack font.  The setup script will install these into
  the right location for your OS (Linux or macOS).

* And many, many, more features.  This is the accumulation of over 20 years
  worth of configuration.
