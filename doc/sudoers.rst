Here are some useful settings to add to :file:`/etc/sudoers`:

.. code-block:: text

    Defaults env_keep="SSH_TTY SSH_CONNECTION SSH_CLIENT SSH_AUTH_SOCK"
    Defaults env_keep+="EDITOR VISUAL TERM_PROGRAM COLORFGBG COLORTERM"
    Defaults env_keep+="DISPLAY XAUTHORIZATION XAUTHORITY VIMUSER ETC_USER"
