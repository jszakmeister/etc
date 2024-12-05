# Add a line like the following to your .bashrc:
#  export PYTHONSTARTUP="$ETC_HOME/python/startup.py"
from __future__ import print_function


def setup_readline():
    try:
        import readline, atexit, os, rlcompleter, sys

        if 'libedit' in readline.__doc__:
            is_libedit = True
        else:
            # System Python on Mac's lie about being readline.  They're really
            # libedit.
            is_libedit = False
            if sys.platform == 'darwin' and 'Apple' in sys.version:
                if readline.__file__.startswith(
                        '/System/Library/Frameworks/Python.framework/'):
                    is_libedit = True

        suffix = '-' + '.'.join(str(x) for x in sys.version_info[:2])
        suffix += (is_libedit and "-el") or "-rl"
        historypath = os.path.expanduser("~/.pyhistory" + suffix)
        editrcpath = os.path.expanduser("~/.editrc")
        inputrcpath = os.path.expanduser("~/.inputrc")

        if is_libedit:
            if not os.path.exists(editrcpath):
                readline.parse_and_bind("bind ^[[A ed-search-prev-history")
                readline.parse_and_bind("bind ^[[B ed-search-next-history")

            readline.parse_and_bind("bind ^I rl_complete")
        else:
            if not os.path.exists(inputrcpath):
                readline.parse_and_bind(r'"\e[A": history-search-backward')
                readline.parse_and_bind(r'"\e[B": history-search-forward')

            readline.parse_and_bind("tab: complete")

        def save_history(historypath=historypath):
            import readline
            if readline.get_current_history_length():
                readline.write_history_file(historypath)

        if os.path.exists(historypath):
            try:
                readline.read_history_file(historypath)
            except IOError:
                # If something went awry and left an empty file for the history,
                # editline complains that it cannot find the file.  Silence this
                # error.
                pass

        atexit.register(save_history)

    except ImportError:
        pass

setup_readline()

del setup_readline


try:
    import rich.pretty
    from rich import inspect

    rich.pretty.install()

    del rich
except ImportError:
    pass


# Gotta keep things Python 2.7 compatible for now.

def bits(i, groups, bit_width=32):
    fmt = "{{:0{bit_width}b}}".format(bit_width=bit_width)
    v = fmt.format(i)

    segments = []
    cur_pos = 0
    for width in groups:
        segments.append(v[cur_pos:cur_pos+width])
        cur_pos += width

    if cur_pos < bit_width:
        segments.append(v[cur_pos:])

    digits = ((bit_width + 7) // 8) * 2

    fmt = "{{:0{digits}X}}h: {{}}".format(digits=digits)

    print(fmt.format(i, " ".join(segments)))


def hexdump(data):
    if isinstance(data, str):
        data = data.encode("utf-8")

    for i in range(0, len(data), 16):
        block = bytearray(data[i:i+16])

        line_data_hex = (" ".join("%02x" % (x,) for x in block[0:8]) + "  " +
                         " ".join("%02x" % (x,) for x in block[8:]))
        line_data_ascii = "".join(chr(x) if 32 <= x < 127 else "." for x in block)

        if len(block) < 16:
            line_data_hex += " " * (48 - len(line_data_hex))

        line = "{i:10d} ({i:8x}h):  {line_data_hex}    {line_data_ascii}".format(
            i=i, line_data_hex=line_data_hex, line_data_ascii=line_data_ascii)

        print(line)


def errno_lookup(e):
    import errno

    try:
        code = int(e)
        name = errno.errorcode.get(code, "(unknown)")
    except ValueError:
        # We likely have a name
        name = e.upper()
        code = getattr(errno, name, "(unknown)")

    print("{name}: {code}".format(name=name, code=code))
