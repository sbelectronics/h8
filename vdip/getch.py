glo_old_settings = None
glo_fd = None
def raw():
    import sys, tty, termios
    global glo_old_settings, glo_fd
    glo_fd = sys.stdin.fileno()
    glo_old_settings = termios.tcgetattr(glo_fd)
    tty.setraw(sys.stdin.fileno())

def unRaw():
    import sys, tty, termios
    termios.tcsetattr(glo_fd, termios.TCSADRAIN, glo_old_settings)

def getch():
    import sys
    from select import select
    [i, o, e] = select([sys.stdin.fileno()], [], [], 0)
    if i:
        ch = sys.stdin.read(1)
    else:
        ch = None

    return ch
