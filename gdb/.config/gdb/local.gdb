# ~/.config/gdb/local.gdb -- personal additions, sourced after dashboard.gdb.

# Dashboard layout -------------------------------------------------------------
dashboard -layout assembly registers expressions history threads memory stack source breakpoints variables
dashboard variables -style compact False
dashboard variables -style align True
dashboard variables -style sort True
dashboard expressions -style align True

# gf2 frontend -----------------------------------------------------------------
# gf parses gdb's console output and waits for the literal "(gdb) " prompt.
# When gdb's parent process is gf2, turn the dashboard off and drop its
# prompt hook (which would otherwise override gf's `set prompt (gdb) `).
python
import os
try:
    with open('/proc/%d/comm' % os.getppid()) as _f:
        if _f.read().strip() == 'gf2':
            gdb.execute('dashboard -enabled off')
            gdb.prompt_hook = None
except Exception:
    pass
end

# Commands ---------------------------------------------------------------------
define vimdb
    dashboard assembly
    dashboard registers
    dashboard source
end
document vimdb
Toggle the assembly, registers and source dashboard modules.
end

define follow-children
    set follow-fork-mode child
    set detach-on-fork off
end
document follow-children
Follow the child after fork() and keep the parent attached (switch with `inferior N`).
end
