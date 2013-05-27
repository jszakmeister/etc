These settings are nice to add to :file:`/etc/ssh/sshd_config`:

.. code-block:: text

    AcceptEnv LANG LC_* TERM_PROGRAM

Depending on your setup, it may be beneficial to add ``VIMUSER`` and
``ETC_USER`` to that list.  In your :file:`~/.ssh/config`, you will want to add
a ``SendEnv`` line:

.. code-block:: text

    SendEnv TERM_PROGRAM

You may want to add ``VIMUSER`` and ``ETC_USER`` to that list as well.
