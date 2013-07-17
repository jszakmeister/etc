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
