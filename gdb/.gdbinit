# Configuration file for gdb.
echo ---Loading ~/.gdbinit---\n

# Better GDB defaults --------------------------------------------------------
set history save on
set history filename ~/.gdb_history
set history remove-duplicates unlimited
set python print-stack full
set print pretty on
set print array off
set print array-indexes on
set pagination off
set confirm off
set verbose off

#
# C++ related beautifiers (optional)
#

set print object on
set print static-members on
set print vtbl on
set print demangle on
set demangle-style gnu-v3
set print sevenbit-strings off
set follow-fork-mode child
set detach-on-fork off


#=====================================
# ░█▀▀░█▀▄░█▀▄░█▀▄░█▀█░█▀▀░█░█
# ░█░█░█░█░█▀▄░█░█░█▀█░▀▀█░█▀█
# ░▀▀▀░▀▀░░▀▀░░▀▀░░▀░▀░▀▀▀░▀░▀
#gdb dashboard========================
python

# GDB dashboard - Modular visual interface for GDB in Python.
#
# https://github.com/cyrus-and/gdb-dashboard

# License ----------------------------------------------------------------------

# Copyright (c) 2015-2021 Andrea Cardaci <cyrus.and@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Imports ----------------------------------------------------------------------

import ast
import io
import itertools
import math
import os
import re
import struct
import traceback

# Common attributes ------------------------------------------------------------

class R():

    @staticmethod
    def attributes():
        return {
            # miscellaneous
            'ansi': {
                'doc': 'Control the ANSI output of the dashboard.',
                'default': True,
                'type': bool
            },
            'syntax_highlighting': {
                'doc': '''Pygments style to use for syntax highlighting.

Using an empty string (or a name not in the list) disables this feature. The
list of all the available styles can be obtained with (from GDB itself):

    python from pygments.styles import *
    python for style in get_all_styles(): print(style)''',
                'default': 'monokai'
            },
            'discard_scrollback': {
                'doc': '''Discard the scrollback buffer at each redraw.

This makes scrolling less confusing by discarding the previously printed
dashboards but only works with certain terminals.''',
                'default': True,
                'type': bool
            },
            # values formatting
            'compact_values': {
                'doc': 'Display complex objects in a single line.',
                'default': True,
                'type': bool
            },
            'max_value_length': {
                'doc': 'Maximum length of displayed values before truncation.',
                'default': 100,
                'type': int
            },
            'value_truncation_string': {
                'doc': 'String to use to mark value truncation.',
                'default': '…',
            },
            'dereference': {
                'doc': 'Annotate pointers with the pointed value.',
                'default': True,
                'type': bool
            },
            # prompt
            'prompt': {
                'doc': '''GDB prompt.

This value is used as a Python format string where `{status}` is expanded with
the substitution of either `prompt_running` or `prompt_not_running` attributes,
according to the target program status. The resulting string must be a valid GDB
prompt, see the command `python print(gdb.prompt.prompt_help())`''',
                'default': '{status}'
            },
            'prompt_running': {
                'doc': '''Define the value of `{status}` when the target program is running.

See the `prompt` attribute. This value is used as a Python format string where
`{pid}` is expanded with the process identifier of the target program.''',
                'default': '\[\e[1;35m\]>>>\[\e[0m\]'
            },
            'prompt_not_running': {
                'doc': '''Define the value of `{status}` when the target program is running.

See the `prompt` attribute. This value is used as a Python format string.''',
                'default': '\[\e[90m\]>>>\[\e[0m\]'
            },
            # divider
            'omit_divider': {
                'doc': 'Omit the divider in external outputs when only one module is displayed.',
                'default': False,
                'type': bool
            },
            'divider_fill_char_primary': {
                'doc': 'Filler around the label for primary dividers',
                'default': '─'
            },
            'divider_fill_char_secondary': {
                'doc': 'Filler around the label for secondary dividers',
                'default': '─'
            },
            'divider_fill_style_primary': {
                'doc': 'Style for `divider_fill_char_primary`',
                'default': '36'
            },
            'divider_fill_style_secondary': {
                'doc': 'Style for `divider_fill_char_secondary`',
                'default': '90'
            },
            'divider_label_style_on_primary': {
                'doc': 'Label style for non-empty primary dividers',
                'default': '1;33'
            },
            'divider_label_style_on_secondary': {
                'doc': 'Label style for non-empty secondary dividers',
                'default': '1;37'
            },
            'divider_label_style_off_primary': {
                'doc': 'Label style for empty primary dividers',
                'default': '33'
            },
            'divider_label_style_off_secondary': {
                'doc': 'Label style for empty secondary dividers',
                'default': '90'
            },
            'divider_label_skip': {
                'doc': 'Gap between the aligning border and the label.',
                'default': 3,
                'type': int,
                'check': check_ge_zero
            },
            'divider_label_margin': {
                'doc': 'Number of spaces around the label.',
                'default': 1,
                'type': int,
                'check': check_ge_zero
            },
            'divider_label_align_right': {
                'doc': 'Label alignment flag.',
                'default': False,
                'type': bool
            },
            # common styles
            'style_selected_1': {
                'default': '1;32'
            },
            'style_selected_2': {
                'default': '32'
            },
            'style_low': {
                'default': '90'
            },
            'style_high': {
                'default': '1;37'
            },
            'style_error': {
                'default': '31'
            },
            'style_critical': {
                'default': '0;41'
            }
        }

# Common -----------------------------------------------------------------------

class Beautifier():

    def __init__(self, hint, tab_size=4):
        self.tab_spaces = ' ' * tab_size
        self.active = False
        if not R.ansi or not R.syntax_highlighting:
            return
        # attempt to set up Pygments
        try:
            import pygments
            from pygments.lexers import GasLexer, NasmLexer
            from pygments.formatters import Terminal256Formatter
            if hint == 'att':
                self.lexer = GasLexer()
            elif hint == 'intel':
                self.lexer = NasmLexer()
            else:
                from pygments.lexers import get_lexer_for_filename
                self.lexer = get_lexer_for_filename(hint, stripnl=False)
            self.formatter = Terminal256Formatter(style=R.syntax_highlighting)
            self.active = True
        except ImportError:
            # Pygments not available
            pass
        except pygments.util.ClassNotFound:
            # no lexer for this file or invalid style
            pass

    def process(self, source):
        # convert tabs anyway
        source = source.replace('\t', self.tab_spaces)
        if self.active:
            import pygments
            source = pygments.highlight(source, self.lexer, self.formatter)
        return source.rstrip('\n')

def run(command):
    return gdb.execute(command, to_string=True)

def ansi(string, style):
    if R.ansi:
        return '\x1b[{}m{}\x1b[0m'.format(style, string)
    else:
        return string

def divider(width, label='', primary=False, active=True):
    if primary:
        divider_fill_style = R.divider_fill_style_primary
        divider_fill_char = R.divider_fill_char_primary
        divider_label_style_on = R.divider_label_style_on_primary
        divider_label_style_off = R.divider_label_style_off_primary
    else:
        divider_fill_style = R.divider_fill_style_secondary
        divider_fill_char = R.divider_fill_char_secondary
        divider_label_style_on = R.divider_label_style_on_secondary
        divider_label_style_off = R.divider_label_style_off_secondary
    if label:
        if active:
            divider_label_style = divider_label_style_on
        else:
            divider_label_style = divider_label_style_off
        skip = R.divider_label_skip
        margin = R.divider_label_margin
        before = ansi(divider_fill_char * skip, divider_fill_style)
        middle = ansi(label, divider_label_style)
        after_length = width - len(label) - skip - 2 * margin
        after = ansi(divider_fill_char * after_length, divider_fill_style)
        if R.divider_label_align_right:
            before, after = after, before
        return ''.join([before, ' ' * margin, middle, ' ' * margin, after])
    else:
        return ansi(divider_fill_char * width, divider_fill_style)

def check_gt_zero(x):
    return x > 0

def check_ge_zero(x):
    return x >= 0

def to_unsigned(value, size=8):
    # values from GDB can be used transparently but are not suitable for
    # being printed as unsigned integers, so a conversion is needed
    mask = (2 ** (size * 8)) - 1
    return int(value.cast(gdb.Value(mask).type)) & mask

def to_string(value):
    # attempt to convert an inferior value to string; OK when (Python 3 ||
    # simple ASCII); otherwise (Python 2.7 && not ASCII) encode the string as
    # utf8
    try:
        value_string = str(value)
    except UnicodeEncodeError:
        value_string = unicode(value).encode('utf8')
    except gdb.error as e:
        value_string = ansi(e, R.style_error)
    return value_string

def format_address(address):
    pointer_size = gdb.parse_and_eval('$pc').type.sizeof
    return ('0x{{:0{}x}}').format(pointer_size * 2).format(address)

def format_value(value, compact=None):
    # format references as referenced values
    # (TYPE_CODE_RVALUE_REF is not supported by old GDB)
    if value.type.code in (getattr(gdb, 'TYPE_CODE_REF', None),
                           getattr(gdb, 'TYPE_CODE_RVALUE_REF', None)):
        try:
            value = value.referenced_value()
        except gdb.error as e:
            return ansi(e, R.style_error)
    # format the value
    out = to_string(value)
    # dereference up to the actual value if requested
    if R.dereference and value.type.code == gdb.TYPE_CODE_PTR:
        while value.type.code == gdb.TYPE_CODE_PTR:
            try:
                value = value.dereference()
            except gdb.error as e:
                break
        else:
            formatted = to_string(value)
            out += '{} {}'.format(ansi(':', R.style_low), formatted)
    # compact the value
    if compact is not None and compact or R.compact_values:
        out = re.sub(r'$\s*', '', out, flags=re.MULTILINE)
    # truncate the value
    if R.max_value_length > 0 and len(out) > R.max_value_length:
        out = out[0:R.max_value_length] + ansi(R.value_truncation_string, R.style_critical)
    return out

# XXX parsing the output of `info breakpoints` is apparently the best option
# right now, see: https://sourceware.org/bugzilla/show_bug.cgi?id=18385
# XXX GDB version 7.11 (quire recent) does not have the pending field, so
# fall back to the parsed information
def fetch_breakpoints(watchpoints=False, pending=False):
    # fetch breakpoints addresses
    parsed_breakpoints = dict()
    for line in run('info breakpoints').split('\n'):
        # just keep numbered lines
        if not line or not line[0].isdigit():
            continue
        # extract breakpoint number, address and pending status
        fields = line.split()
        number = int(fields[0].split('.')[0])
        try:
            if len(fields) >= 5 and fields[1] == 'breakpoint':
                # multiple breakpoints have no address yet
                is_pending = fields[4] == '<PENDING>'
                is_multiple = fields[4] == '<MULTIPLE>'
                address = None if is_multiple or is_pending else int(fields[4], 16)
                is_enabled = fields[3] == 'y'
                address_info = address, is_enabled
                parsed_breakpoints[number] = [address_info], is_pending
            elif len(fields) >= 3 and number in parsed_breakpoints:
                # add this address to the list of multiple locations
                address = int(fields[2], 16)
                is_enabled = fields[1] == 'y'
                address_info = address, is_enabled
                parsed_breakpoints[number][0].append(address_info)
            else:
                # watchpoints
                parsed_breakpoints[number] = [], False
        except ValueError:
            pass
    # fetch breakpoints from the API and complement with address and source
    # information
    breakpoints = []
    # XXX in older versions gdb.breakpoints() returns None
    for gdb_breakpoint in gdb.breakpoints() or []:
        # skip internal breakpoints
        if gdb_breakpoint.number < 0:
            continue
        addresses, is_pending = parsed_breakpoints[gdb_breakpoint.number]
        is_pending = getattr(gdb_breakpoint, 'pending', is_pending)
        if not pending and is_pending:
            continue
        if not watchpoints and gdb_breakpoint.type != gdb.BP_BREAKPOINT:
            continue
        # add useful fields to the object
        breakpoint = dict()
        breakpoint['number'] = gdb_breakpoint.number
        breakpoint['type'] = gdb_breakpoint.type
        breakpoint['enabled'] = gdb_breakpoint.enabled
        breakpoint['location'] = gdb_breakpoint.location
        breakpoint['expression'] = gdb_breakpoint.expression
        breakpoint['condition'] = gdb_breakpoint.condition
        breakpoint['temporary'] = gdb_breakpoint.temporary
        breakpoint['hit_count'] = gdb_breakpoint.hit_count
        breakpoint['pending'] = is_pending
        # add addresses and source information
        breakpoint['addresses'] = []
        for address, is_enabled in addresses:
            if address:
                sal = gdb.find_pc_line(address)
            breakpoint['addresses'].append({
                'address': address,
                'enabled': is_enabled,
                'file_name': sal.symtab.filename if address and sal.symtab else None,
                'file_line': sal.line if address else None
            })
        breakpoints.append(breakpoint)
    return breakpoints

# Dashboard --------------------------------------------------------------------

class Dashboard(gdb.Command):
    '''Redisplay the dashboard.'''

    def __init__(self):
        gdb.Command.__init__(self, 'dashboard', gdb.COMMAND_USER, gdb.COMPLETE_NONE, True)
        # setup subcommands
        Dashboard.ConfigurationCommand(self)
        Dashboard.OutputCommand(self)
        Dashboard.EnabledCommand(self)
        Dashboard.LayoutCommand(self)
        # setup style commands
        Dashboard.StyleCommand(self, 'dashboard', R, R.attributes())
        # main terminal
        self.output = None
        # used to inhibit redisplays during init parsing
        self.inhibited = None
        # enabled by default
        self.enabled = None
        self.enable()

    def on_continue(self, _):
        # try to contain the GDB messages in a specified area unless the
        # dashboard is printed to a separate file (dashboard -output ...)
        # or there are no modules to display in the main terminal
        enabled_modules = list(filter(lambda m: not m.output and m.enabled, self.modules))
        if self.is_running() and not self.output and len(enabled_modules) > 0:
            width, _ = Dashboard.get_term_size()
            gdb.write(Dashboard.clear_screen())
            gdb.write(divider(width, 'Output/messages', True))
            gdb.write('\n')
            gdb.flush()

    def on_stop(self, _):
        if self.is_running():
            self.render(clear_screen=False)

    def on_exit(self, _):
        if not self.is_running():
            return
        # collect all the outputs
        outputs = set()
        outputs.add(self.output)
        outputs.update(module.output for module in self.modules)
        outputs.remove(None)
        # reset the terminal status
        for output in outputs:
            try:
                with open(output, 'w') as fs:
                    fs.write(Dashboard.reset_terminal())
            except:
                # skip cleanup for invalid outputs
                pass

    def enable(self):
        if self.enabled:
            return
        self.enabled = True
        # setup events
        gdb.events.cont.connect(self.on_continue)
        gdb.events.stop.connect(self.on_stop)
        gdb.events.exited.connect(self.on_exit)

    def disable(self):
        if not self.enabled:
            return
        self.enabled = False
        # setup events
        gdb.events.cont.disconnect(self.on_continue)
        gdb.events.stop.disconnect(self.on_stop)
        gdb.events.exited.disconnect(self.on_exit)

    def load_modules(self, modules):
        self.modules = []
        for module in modules:
            info = Dashboard.ModuleInfo(self, module)
            self.modules.append(info)

    def redisplay(self, style_changed=False):
        # manually redisplay the dashboard
        if self.is_running() and not self.inhibited:
            self.render(True, style_changed)

    def inferior_pid(self):
        return gdb.selected_inferior().pid

    def is_running(self):
        return self.inferior_pid() != 0

    def render(self, clear_screen, style_changed=False):
        # fetch module content and info
        all_disabled = True
        display_map = dict()
        for module in self.modules:
            # fall back to the global value
            output = module.output or self.output
            # add the instance or None if disabled
            if module.enabled:
                all_disabled = False
                instance = module.instance
            else:
                instance = None
            display_map.setdefault(output, []).append(instance)
        # process each display info
        for output, instances in display_map.items():
            try:
                buf = ''
                # use GDB stream by default
                fs = None
                if output:
                    fs = open(output, 'w')
                    fd = fs.fileno()
                    fs.write(Dashboard.setup_terminal())
                else:
                    fs = gdb
                    fd = 1  # stdout
                # get the terminal size (default main terminal if either the
                # output is not a file)
                try:
                    width, height = Dashboard.get_term_size(fd)
                except:
                    width, height = Dashboard.get_term_size()
                # clear the "screen" if requested for the main terminal,
                # auxiliary terminals are always cleared
                if fs is not gdb or clear_screen:
                    buf += Dashboard.clear_screen()
                # show message if all the modules in this output are disabled
                if not any(instances):
                    # skip the main terminal
                    if fs is gdb:
                        continue
                    # write the error message
                    buf += divider(width, 'Warning', True)
                    buf += '\n'
                    if self.modules:
                        buf += 'No module to display (see `dashboard -layout`)'
                    else:
                        buf += 'No module loaded'
                    buf += '\n'
                    fs.write(buf)
                    continue
                # process all the modules for that output
                for n, instance in enumerate(instances, 1):
                    # skip disabled modules
                    if not instance:
                        continue
                    try:
                        # ask the module to generate the content
                        lines = instance.lines(width, height, style_changed)
                    except Exception as e:
                        # allow to continue on exceptions in modules
                        stacktrace = traceback.format_exc().strip()
                        lines = [ansi(stacktrace, R.style_error)]
                    # create the divider if needed
                    div = []
                    if not R.omit_divider or len(instances) > 1 or fs is gdb:
                        div = [divider(width, instance.label(), True, lines)]
                    # write the data
                    buf += '\n'.join(div + lines)
                    # write the newline for all but last unless main terminal
                    if n != len(instances) or fs is gdb:
                        buf += '\n'
                # write the final newline and the terminator only if it is the
                # main terminal to allow the prompt to display correctly (unless
                # there are no modules to display)
                if fs is gdb and not all_disabled:
                    buf += divider(width, primary=True)
                    buf += '\n'
                fs.write(buf)
            except Exception as e:
                cause = traceback.format_exc().strip()
                Dashboard.err('Cannot write the dashboard\n{}'.format(cause))
            finally:
                # don't close gdb stream
                if fs and fs is not gdb:
                    fs.close()

# Utility methods --------------------------------------------------------------

    @staticmethod
    def start():
        # initialize the dashboard
        dashboard = Dashboard()
        Dashboard.set_custom_prompt(dashboard)
        # parse Python inits, load modules then parse GDB inits
        dashboard.inhibited = True
        Dashboard.parse_inits(True)
        modules = Dashboard.get_modules()
        dashboard.load_modules(modules)
        Dashboard.parse_inits(False)
        dashboard.inhibited = False
        # GDB overrides
        run('set pagination off')
        # display if possible (program running and not explicitly disabled by
        # some configuration file)
        if dashboard.enabled:
            dashboard.redisplay()

    @staticmethod
    def get_term_size(fd=1):  # defaults to the main terminal
        try:
            if sys.platform == 'win32':
                import curses
                # XXX always neglects the fd parameter
                height, width = curses.initscr().getmaxyx()
                curses.endwin()
                return int(width), int(height)
            else:
                import termios
                import fcntl
                # first 2 shorts (4 byte) of struct winsize
                raw = fcntl.ioctl(fd, termios.TIOCGWINSZ, ' ' * 4)
                height, width = struct.unpack('hh', raw)
                return int(width), int(height)
        except (ImportError, OSError):
            # this happens when no curses library is found on windows or when
            # the terminal is not properly configured
            return 80, 24  # hardcoded fallback value

    @staticmethod
    def set_custom_prompt(dashboard):
        def custom_prompt(_):
            # render thread status indicator
            if dashboard.is_running():
                pid = dashboard.inferior_pid()
                status = R.prompt_running.format(pid=pid)
            else:
                status = R.prompt_not_running
            # build prompt
            prompt = R.prompt.format(status=status)
            prompt = gdb.prompt.substitute_prompt(prompt)
            return prompt + ' '  # force trailing space
        gdb.prompt_hook = custom_prompt

    @staticmethod
    def parse_inits(python):
        # paths where the .gdbinit.d directory might be
        search_paths = [
            '/etc/gdb-dashboard',
            '{}/gdb-dashboard'.format(os.getenv('XDG_CONFIG_HOME', '~/.config')),
            '~/Library/Preferences/gdb-dashboard',
            '~/.gdbinit.d'
        ]
        # expand the tilde and walk the paths
        inits_dirs = (os.walk(os.path.expanduser(path)) for path in search_paths)
        # process all the init files in order
        for root, dirs, files in itertools.chain.from_iterable(inits_dirs):
            dirs.sort()
            for init in sorted(files):
                path = os.path.join(root, init)
                _, ext = os.path.splitext(path)
                # either load Python files or GDB
                if python == (ext == '.py'):
                    gdb.execute('source ' + path)

    @staticmethod
    def get_modules():
        # scan the scope for modules
        modules = []
        for name in globals():
            obj = globals()[name]
            try:
                if issubclass(obj, Dashboard.Module):
                    modules.append(obj)
            except TypeError:
                continue
        # sort modules alphabetically
        modules.sort(key=lambda x: x.__name__)
        return modules

    @staticmethod
    def create_command(name, invoke, doc, is_prefix, complete=None):
        Class = type('', (gdb.Command,), {'invoke': invoke, '__doc__': doc})
        Class(name, gdb.COMMAND_USER, complete or gdb.COMPLETE_NONE, is_prefix)

    @staticmethod
    def err(string):
        print(ansi(string, R.style_error))

    @staticmethod
    def complete(word, candidates):
        return filter(lambda candidate: candidate.startswith(word), candidates)

    @staticmethod
    def parse_arg(arg):
        # encode unicode GDB command arguments as utf8 in Python 2.7
        if type(arg) is not str:
            arg = arg.encode('utf8')
        return arg

    @staticmethod
    def clear_screen():
        # ANSI: move the cursor to top-left corner and clear the screen
        # (optionally also clear the scrollback buffer if supported by the
        # terminal)
        return '\x1b[H\x1b[J' + '\x1b[3J' if R.discard_scrollback else ''

    @staticmethod
    def setup_terminal():
        # ANSI: enable alternative screen buffer and hide cursor
        return '\x1b[?1049h\x1b[?25l'

    @staticmethod
    def reset_terminal():
        # ANSI: disable alternative screen buffer and show cursor
        return '\x1b[?1049l\x1b[?25h'

# Module descriptor ------------------------------------------------------------

    class ModuleInfo:

        def __init__(self, dashboard, module):
            self.name = module.__name__.lower()  # from class to module name
            self.enabled = True
            self.output = None  # value from the dashboard by default
            self.instance = module()
            self.doc = self.instance.__doc__ or '(no documentation)'
            self.prefix = 'dashboard {}'.format(self.name)
            # add GDB commands
            self.add_main_command(dashboard)
            self.add_output_command(dashboard)
            self.add_style_command(dashboard)
            self.add_subcommands(dashboard)

        def add_main_command(self, dashboard):
            module = self
            def invoke(self, arg, from_tty, info=self):
                arg = Dashboard.parse_arg(arg)
                if arg == '':
                    info.enabled ^= True
                    if dashboard.is_running():
                        dashboard.redisplay()
                    else:
                        status = 'enabled' if info.enabled else 'disabled'
                        print('{} module {}'.format(module.name, status))
                else:
                    Dashboard.err('Wrong argument "{}"'.format(arg))
            doc_brief = 'Configure the {} module, with no arguments toggles its visibility.'.format(self.name)
            doc = '{}\n\n{}'.format(doc_brief, self.doc)
            Dashboard.create_command(self.prefix, invoke, doc, True)

        def add_output_command(self, dashboard):
            Dashboard.OutputCommand(dashboard, self.prefix, self)

        def add_style_command(self, dashboard):
            Dashboard.StyleCommand(dashboard, self.prefix, self.instance, self.instance.attributes())

        def add_subcommands(self, dashboard):
            for name, command in self.instance.commands().items():
                self.add_subcommand(dashboard, name, command)

        def add_subcommand(self, dashboard, name, command):
            action = command['action']
            doc = command['doc']
            complete = command.get('complete')
            def invoke(self, arg, from_tty, info=self):
                arg = Dashboard.parse_arg(arg)
                if info.enabled:
                    try:
                        action(arg)
                    except Exception as e:
                        Dashboard.err(e)
                        return
                    # don't catch redisplay errors
                    dashboard.redisplay()
                else:
                    Dashboard.err('Module disabled')
            prefix = '{} {}'.format(self.prefix, name)
            Dashboard.create_command(prefix, invoke, doc, False, complete)

# GDB commands -----------------------------------------------------------------

    # handler for the `dashboard` command itself
    def invoke(self, arg, from_tty):
        arg = Dashboard.parse_arg(arg)
        # show messages for checks in redisplay
        if arg != '':
            Dashboard.err('Wrong argument "{}"'.format(arg))
        elif not self.is_running():
            Dashboard.err('Is the target program running?')
        else:
            self.redisplay()

    class ConfigurationCommand(gdb.Command):
        '''Dump or save the dashboard configuration.

With an optional argument the configuration will be written to the specified
file.

This command allows to configure the dashboard live then make the changes
permanent, for example:

    dashboard -configuration ~/.gdbinit.d/init

At startup the `~/.gdbinit.d/` directory tree is walked and files are evaluated
in alphabetical order but giving priority to Python files. This is where user
configuration files must be placed.'''

        def __init__(self, dashboard):
            gdb.Command.__init__(self, 'dashboard -configuration',
                                 gdb.COMMAND_USER, gdb.COMPLETE_FILENAME)
            self.dashboard = dashboard

        def invoke(self, arg, from_tty):
            arg = Dashboard.parse_arg(arg)
            if arg:
                with open(os.path.expanduser(arg), 'w') as fs:
                    fs.write('# auto generated by GDB dashboard\n\n')
                    self.dump(fs)
            self.dump(gdb)

        def dump(self, fs):
            # dump layout
            self.dump_layout(fs)
            # dump styles
            self.dump_style(fs, R)
            for module in self.dashboard.modules:
                self.dump_style(fs, module.instance, module.prefix)
            # dump outputs
            self.dump_output(fs, self.dashboard)
            for module in self.dashboard.modules:
                self.dump_output(fs, module, module.prefix)

        def dump_layout(self, fs):
            layout = ['dashboard -layout']
            for module in self.dashboard.modules:
                mark = '' if module.enabled else '!'
                layout.append('{}{}'.format(mark, module.name))
            fs.write(' '.join(layout))
            fs.write('\n')

        def dump_style(self, fs, obj, prefix='dashboard'):
            attributes = getattr(obj, 'attributes', lambda: dict())()
            for name, attribute in attributes.items():
                real_name = attribute.get('name', name)
                default = attribute.get('default')
                value = getattr(obj, real_name)
                if value != default:
                    fs.write('{} -style {} {!r}\n'.format(prefix, name, value))

        def dump_output(self, fs, obj, prefix='dashboard'):
            output = getattr(obj, 'output')
            if output:
                fs.write('{} -output {}\n'.format(prefix, output))

    class OutputCommand(gdb.Command):
        '''Set the output file/TTY for the whole dashboard or single modules.

The dashboard/module will be written to the specified file, which will be
created if it does not exist. If the specified file identifies a terminal then
its geometry will be used, otherwise it falls back to the geometry of the main
GDB terminal.

When invoked without argument on the dashboard, the output/messages and modules
which do not specify an output themselves will be printed on standard output
(default).

When invoked without argument on a module, it will be printed where the
dashboard will be printed.

An overview of all the outputs can be obtained with the `dashboard -layout`
command.'''

        def __init__(self, dashboard, prefix=None, obj=None):
            if not prefix:
                prefix = 'dashboard'
            if not obj:
                obj = dashboard
            prefix = prefix + ' -output'
            gdb.Command.__init__(self, prefix, gdb.COMMAND_USER, gdb.COMPLETE_FILENAME)
            self.dashboard = dashboard
            self.obj = obj  # None means the dashboard itself

        def invoke(self, arg, from_tty):
            arg = Dashboard.parse_arg(arg)
            # reset the terminal status
            if self.obj.output:
                try:
                    with open(self.obj.output, 'w') as fs:
                        fs.write(Dashboard.reset_terminal())
                except:
                    # just do nothing if the file is not writable
                    pass
            # set or open the output file
            if arg == '':
                self.obj.output = None
            else:
                self.obj.output = arg
            # redisplay the dashboard in the new output
            self.dashboard.redisplay()

    class EnabledCommand(gdb.Command):
        '''Enable or disable the dashboard.

The current status is printed if no argument is present.'''

        def __init__(self, dashboard):
            gdb.Command.__init__(self, 'dashboard -enabled', gdb.COMMAND_USER)
            self.dashboard = dashboard

        def invoke(self, arg, from_tty):
            arg = Dashboard.parse_arg(arg)
            if arg == '':
                status = 'enabled' if self.dashboard.enabled else 'disabled'
                print('The dashboard is {}'.format(status))
            elif arg == 'on':
                self.dashboard.enable()
                self.dashboard.redisplay()
            elif arg == 'off':
                self.dashboard.disable()
            else:
                msg = 'Wrong argument "{}"; expecting "on" or "off"'
                Dashboard.err(msg.format(arg))

        def complete(self, text, word):
            return Dashboard.complete(word, ['on', 'off'])

    class LayoutCommand(gdb.Command):
        '''Set or show the dashboard layout.

Accepts a space-separated list of directive. Each directive is in the form
"[!]<module>". Modules in the list are placed in the dashboard in the same order
as they appear and those prefixed by "!" are disabled by default. Omitted
modules are hidden and placed at the bottom in alphabetical order.

Without arguments the current layout is shown where the first line uses the same
form expected by the input while the remaining depict the current status of
output files.

Passing `!` as a single argument resets the dashboard original layout.'''

        def __init__(self, dashboard):
            gdb.Command.__init__(self, 'dashboard -layout', gdb.COMMAND_USER)
            self.dashboard = dashboard

        def invoke(self, arg, from_tty):
            arg = Dashboard.parse_arg(arg)
            directives = str(arg).split()
            if directives:
                # apply the layout
                if directives == ['!']:
                    self.reset()
                else:
                    if not self.layout(directives):
                        return  # in case of errors
                # redisplay or otherwise notify
                if from_tty:
                    if self.dashboard.is_running():
                        self.dashboard.redisplay()
                    else:
                        self.show()
            else:
                self.show()

        def reset(self):
            modules = self.dashboard.modules
            modules.sort(key=lambda module: module.name)
            for module in modules:
                module.enabled = True

        def show(self):
            global_str = 'Dashboard'
            default = '(default TTY)'
            max_name_len = max(len(module.name) for module in self.dashboard.modules)
            max_name_len = max(max_name_len, len(global_str))
            fmt = '{{}}{{:{}s}}{{}}'.format(max_name_len + 2)
            print((fmt + '\n').format(' ', global_str, self.dashboard.output or default))
            for module in self.dashboard.modules:
                mark = ' ' if module.enabled else '!'
                style = R.style_high if module.enabled else R.style_low
                line = fmt.format(mark, module.name, module.output or default)
                print(ansi(line, style))

        def layout(self, directives):
            modules = self.dashboard.modules
            # parse and check directives
            parsed_directives = []
            selected_modules = set()
            for directive in directives:
                enabled = (directive[0] != '!')
                name = directive[not enabled:]
                if name in selected_modules:
                    Dashboard.err('Module "{}" already set'.format(name))
                    return False
                if next((False for module in modules if module.name == name), True):
                    Dashboard.err('Cannot find module "{}"'.format(name))
                    return False
                parsed_directives.append((name, enabled))
                selected_modules.add(name)
            # reset visibility
            for module in modules:
                module.enabled = False
            # move and enable the selected modules on top
            last = 0
            for name, enabled in parsed_directives:
                todo = enumerate(modules[last:], start=last)
                index = next(index for index, module in todo if name == module.name)
                modules[index].enabled = enabled
                modules.insert(last, modules.pop(index))
                last += 1
            return True

        def complete(self, text, word):
            all_modules = (m.name for m in self.dashboard.modules)
            return Dashboard.complete(word, all_modules)

    class StyleCommand(gdb.Command):
        '''Access the stylable attributes.

Without arguments print all the stylable attributes.

When only the name is specified show the current value.

With name and value set the stylable attribute. Values are parsed as Python
literals and converted to the proper type. '''

        def __init__(self, dashboard, prefix, obj, attributes):
            self.prefix = prefix + ' -style'
            gdb.Command.__init__(self, self.prefix, gdb.COMMAND_USER, gdb.COMPLETE_NONE, True)
            self.dashboard = dashboard
            self.obj = obj
            self.attributes = attributes
            self.add_styles()

        def add_styles(self):
            this = self
            for name, attribute in self.attributes.items():
                # fetch fields
                attr_name = attribute.get('name', name)
                attr_type = attribute.get('type', str)
                attr_check = attribute.get('check', lambda _: True)
                attr_default = attribute['default']
                # set the default value (coerced to the type)
                value = attr_type(attr_default)
                setattr(self.obj, attr_name, value)
                # create the command
                def invoke(self, arg, from_tty,
                           name=name,
                           attr_name=attr_name,
                           attr_type=attr_type,
                           attr_check=attr_check):
                    new_value = Dashboard.parse_arg(arg)
                    if new_value == '':
                        # print the current value
                        value = getattr(this.obj, attr_name)
                        print('{} = {!r}'.format(name, value))
                    else:
                        try:
                            # convert and check the new value
                            parsed = ast.literal_eval(new_value)
                            value = attr_type(parsed)
                            if not attr_check(value):
                                msg = 'Invalid value "{}" for "{}"'
                                raise Exception(msg.format(new_value, name))
                        except Exception as e:
                            Dashboard.err(e)
                        else:
                            # set and redisplay
                            setattr(this.obj, attr_name, value)
                            this.dashboard.redisplay(True)
                prefix = self.prefix + ' ' + name
                doc = attribute.get('doc', 'This style is self-documenting')
                Dashboard.create_command(prefix, invoke, doc, False)

        def invoke(self, arg, from_tty):
            # an argument here means that the provided attribute is invalid
            if arg:
                Dashboard.err('Invalid argument "{}"'.format(arg))
                return
            # print all the pairs
            for name, attribute in self.attributes.items():
                attr_name = attribute.get('name', name)
                value = getattr(self.obj, attr_name)
                print('{} = {!r}'.format(name, value))

# Base module ------------------------------------------------------------------

    # just a tag
    class Module():
        '''Base class for GDB dashboard modules.

        Modules are instantiated once at initialization time and kept during the
        whole the GDB session.

        The name of a module is automatically obtained by the class name.

        Optionally, a module may include a description which will appear in the
        GDB help system by specifying a Python docstring for the class. By
        convention the first line should contain a brief description.'''

        def label(self):
            '''Return the module label which will appear in the divider.'''
            pass

        def lines(self, term_width, term_height, style_changed):
            '''Return a list of strings which will form the module content.

            When a module is temporarily unable to produce its content, it
            should return an empty list; its divider will then use the styles
            with the "off" qualifier.

            term_width and term_height are the dimension of the terminal where
            this module will be displayed. If `style_changed` is `True` then
            some attributes have changed since the last time so the
            implementation may want to update its status.'''
            pass

        def attributes(self):
            '''Return the dictionary of available attributes.

            The key is the attribute name and the value is another dictionary
            with items:

            - `default` is the initial value for this attribute;

            - `doc` is the optional documentation of this attribute which will
              appear in the GDB help system;

            - `name` is the name of the attribute of the Python object (defaults
              to the key value);

            - `type` is the Python type of this attribute defaulting to the
              `str` type, it is used to coerce the value passed as an argument
              to the proper type, or raise an exception;

            - `check` is an optional control callback which accept the coerced
              value and returns `True` if the value satisfies the constraint and
              `False` otherwise.

            Those attributes can be accessed from the implementation using
            instance variables named `name`.'''
            return {}

        def commands(self):
            '''Return the dictionary of available commands.

            The key is the attribute name and the value is another dictionary
            with items:

            - `action` is the callback to be executed which accepts the raw
              input string from the GDB prompt, exceptions in these functions
              will be shown automatically to the user;

            - `doc` is the documentation of this command which will appear in
              the GDB help system;

            - `completion` is the optional completion policy, one of the
              `gdb.COMPLETE_*` constants defined in the GDB reference manual
              (https://sourceware.org/gdb/onlinedocs/gdb/Commands-In-Python.html).'''
            return {}

# Default modules --------------------------------------------------------------

class Source(Dashboard.Module):
    '''Show the program source code, if available.'''

    def __init__(self):
        self.file_name = None
        self.source_lines = []
        self.ts = None
        self.highlighted = False
        self.offset = 0

    def label(self):
        return 'Source'

    def lines(self, term_width, term_height, style_changed):
        # skip if the current thread is not stopped
        if not gdb.selected_thread().is_stopped():
            return []
        # try to fetch the current line (skip if no line information)
        sal = gdb.selected_frame().find_sal()
        current_line = sal.line
        if current_line == 0:
            return []
        # try to lookup the source file
        candidates = [
            sal.symtab.fullname(),
            sal.symtab.filename,
            # XXX GDB also uses absolute filename but it is harder to implement
            # properly and IMHO useless
            os.path.basename(sal.symtab.filename)]
        for candidate in candidates:
            file_name = candidate
            ts = None
            try:
                ts = os.path.getmtime(file_name)
                break
            except:
                # try another or delay error check to open()
                continue
        # style changed, different file name or file modified in the meanwhile
        if style_changed or file_name != self.file_name or ts and ts > self.ts:
            try:
                # reload the source file if changed
                with io.open(file_name, errors='replace') as source_file:
                    highlighter = Beautifier(file_name, self.tab_size)
                    self.highlighted = highlighter.active
                    source = highlighter.process(source_file.read())
                    self.source_lines = source.split('\n')
                # store file name and timestamp only if success to have
                # persistent errors
                self.file_name = file_name
                self.ts = ts
            except IOError as e:
                msg = 'Cannot display "{}"'.format(file_name)
                return [ansi(msg, R.style_error)]
        # compute the line range
        height = self.height or (term_height - 1)
        start = current_line - 1 - int(height / 2) + self.offset
        end = start + height
        # extra at start
        extra_start = 0
        if start < 0:
            extra_start = min(-start, height)
            start = 0
        # extra at end
        extra_end = 0
        if end > len(self.source_lines):
            extra_end = min(end - len(self.source_lines), height)
            end = len(self.source_lines)
        else:
            end = max(end, 0)
        # return the source code listing
        breakpoints = fetch_breakpoints()
        out = []
        number_format = '{{:>{}}}'.format(len(str(end)))
        for number, line in enumerate(self.source_lines[start:end], start + 1):
            # properly handle UTF-8 source files
            line = to_string(line)
            if int(number) == current_line:
                # the current line has a different style without ANSI
                if R.ansi:
                    if self.highlighted and not self.highlight_line:
                        line_format = '{}' + ansi(number_format, R.style_selected_1) + '  {}'
                    else:
                        line_format = '{}' + ansi(number_format + '  {}', R.style_selected_1)
                else:
                    # just show a plain text indicator
                    line_format = '{}' + number_format + '> {}'
            else:
                line_format = '{}' + ansi(number_format, R.style_low) + '  {}'
            # check for breakpoint presence
            enabled = None
            for breakpoint in breakpoints:
                addresses = breakpoint['addresses']
                is_root_enabled = addresses[0]['enabled']
                for address in addresses:
                    # note, despite the lookup path always use the relative
                    # (sal.symtab.filename) file name to match source files with
                    # breakpoints
                    if address['file_line'] == number and address['file_name'] == sal.symtab.filename:
                        enabled = enabled or (address['enabled'] and is_root_enabled)
            if enabled is None:
                breakpoint = ' '
            else:
                breakpoint = ansi('!', R.style_critical) if enabled else ansi('-', R.style_low)
            out.append(line_format.format(breakpoint, number, line.rstrip('\n')))
        # return the output along with scroll indicators
        if len(out) <= height:
            extra = [ansi('~', R.style_low)]
            return extra_start * extra + out + extra_end * extra
        else:
            return out

    def commands(self):
        return {
            'scroll': {
                'action': self.scroll,
                'doc': 'Scroll by relative steps or reset if invoked without argument.'
            }
        }

    def attributes(self):
        return {
            'height': {
                'doc': '''Height of the module.

A value of 0 uses the whole height.''',
                'default': 10,
                'type': int,
                'check': check_ge_zero
            },
            'tab-size': {
                'doc': 'Number of spaces used to display the tab character.',
                'default': 4,
                'name': 'tab_size',
                'type': int,
                'check': check_gt_zero
            },
            'highlight-line': {
                'doc': 'Decide whether the whole current line should be highlighted.',
                'default': False,
                'name': 'highlight_line',
                'type': bool
            }
        }

    def scroll(self, arg):
        if arg:
            self.offset += int(arg)
        else:
            self.offset = 0

class Assembly(Dashboard.Module):
    '''Show the disassembled code surrounding the program counter.

The instructions constituting the current statement are marked, if available.'''

    def __init__(self):
        self.offset = 0
        self.cache_key = None
        self.cache_asm = None

    def label(self):
        return 'Assembly'

    def lines(self, term_width, term_height, style_changed):
        # skip if the current thread is not stopped
        if not gdb.selected_thread().is_stopped():
            return []
        # flush the cache if the style is changed
        if style_changed:
            self.cache_key = None
        # prepare the highlighter
        try:
            flavor = gdb.parameter('disassembly-flavor')
        except:
            flavor = 'att'  # not always defined (see #36)
        highlighter = Beautifier(flavor)
        # fetch the assembly code
        line_info = None
        frame = gdb.selected_frame()  # PC is here
        height = self.height or (term_height - 1)
        try:
            # disassemble the current block
            asm_start, asm_end = self.fetch_function_boundaries()
            asm = self.fetch_asm(asm_start, asm_end, False, highlighter)
            # find the location of the PC
            pc_index = next(index for index, instr in enumerate(asm)
                            if instr['addr'] == frame.pc())
            # compute the instruction range
            start = pc_index - int(height / 2) + self.offset
            end = start + height
            # extra at start
            extra_start = 0
            if start < 0:
                extra_start = min(-start, height)
                start = 0
            # extra at end
            extra_end = 0
            if end > len(asm):
                extra_end = min(end - len(asm), height)
                end = len(asm)
            else:
                end = max(end, 0)
            # fetch actual interval
            asm = asm[start:end]
            # if there are line information then use it, it may be that
            # line_info is not None but line_info.last is None
            line_info = gdb.find_pc_line(frame.pc())
            line_info = line_info if line_info.last else None
        except (gdb.error, RuntimeError, StopIteration):
            # if it is not possible (stripped binary or the PC is not present in
            # the output of `disassemble` as per issue #31) start from PC
            try:
                extra_start = 0
                extra_end = 0
                # allow to scroll down nevertheless
                clamped_offset = min(self.offset, 0)
                asm = self.fetch_asm(frame.pc(), height - clamped_offset, True, highlighter)
                asm = asm[-clamped_offset:]
            except gdb.error as e:
                msg = '{}'.format(e)
                return [ansi(msg, R.style_error)]
        # fetch function start if available (e.g., not with @plt)
        func_start = None
        if self.show_function and frame.function():
            func_start = to_unsigned(frame.function().value())
        # compute the maximum offset size
        if asm and func_start:
            max_offset = max(len(str(abs(asm[0]['addr'] - func_start))),
                             len(str(abs(asm[-1]['addr'] - func_start))))
        # return the machine code
        breakpoints = fetch_breakpoints()
        max_length = max(instr['length'] for instr in asm) if asm else 0
        inferior = gdb.selected_inferior()
        out = []
        for index, instr in enumerate(asm):
            addr = instr['addr']
            length = instr['length']
            text = instr['asm']
            addr_str = format_address(addr)
            if self.show_opcodes:
                # fetch and format opcode
                region = inferior.read_memory(addr, length)
                opcodes = (' '.join('{:02x}'.format(ord(byte)) for byte in region))
                opcodes += (max_length - len(region)) * 3 * ' ' + '  '
            else:
                opcodes = ''
            # compute the offset if available
            if self.show_function:
                if func_start:
                    offset = '{:+d}'.format(addr - func_start)
                    offset = offset.ljust(max_offset + 1)  # sign
                    func_info = '{}{}'.format(frame.function(), offset)
                else:
                    func_info = '?'
            else:
                func_info = ''
            format_string = '{}{}{}{}{}{}'
            indicator = '  '
            text = ' ' + text
            if addr == frame.pc():
                if not R.ansi:
                    indicator = '> '
                addr_str = ansi(addr_str, R.style_selected_1)
                indicator = ansi(indicator, R.style_selected_1)
                opcodes = ansi(opcodes, R.style_selected_1)
                func_info = ansi(func_info, R.style_selected_1)
                if not highlighter.active or self.highlight_line:
                    text = ansi(text, R.style_selected_1)
            elif line_info and line_info.pc <= addr < line_info.last:
                if not R.ansi:
                    indicator = ': '
                addr_str = ansi(addr_str, R.style_selected_2)
                indicator = ansi(indicator, R.style_selected_2)
                opcodes = ansi(opcodes, R.style_selected_2)
                func_info = ansi(func_info, R.style_selected_2)
                if not highlighter.active or self.highlight_line:
                    text = ansi(text, R.style_selected_2)
            else:
                addr_str = ansi(addr_str, R.style_low)
                func_info = ansi(func_info, R.style_low)
            # check for breakpoint presence
            enabled = None
            for breakpoint in breakpoints:
                addresses = breakpoint['addresses']
                is_root_enabled = addresses[0]['enabled']
                for address in addresses:
                    if address['address'] == addr:
                        enabled = enabled or (address['enabled'] and is_root_enabled)
            if enabled is None:
                breakpoint = ' '
            else:
                breakpoint = ansi('!', R.style_critical) if enabled else ansi('-', R.style_low)
            out.append(format_string.format(breakpoint, addr_str, indicator, opcodes, func_info, text))
        # return the output along with scroll indicators
        if len(out) <= height:
            extra = [ansi('~', R.style_low)]
            return extra_start * extra + out + extra_end * extra
        else:
            return out

    def commands(self):
        return {
            'scroll': {
                'action': self.scroll,
                'doc': 'Scroll by relative steps or reset if invoked without argument.'
            }
        }

    def attributes(self):
        return {
            'height': {
                'doc': '''Height of the module.

A value of 0 uses the whole height.''',
                'default': 10,
                'type': int,
                'check': check_ge_zero
            },
            'opcodes': {
                'doc': 'Opcodes visibility flag.',
                'default': False,
                'name': 'show_opcodes',
                'type': bool
            },
            'function': {
                'doc': 'Function information visibility flag.',
                'default': True,
                'name': 'show_function',
                'type': bool
            },
            'highlight-line': {
                'doc': 'Decide whether the whole current line should be highlighted.',
                'default': False,
                'name': 'highlight_line',
                'type': bool
            }
        }

    def scroll(self, arg):
        if arg:
            self.offset += int(arg)
        else:
            self.offset = 0

    def fetch_function_boundaries(self):
        frame = gdb.selected_frame()
        # parse the output of the disassemble GDB command to find the function
        # boundaries, this should handle cases in which a function spans
        # multiple discontinuous blocks
        disassemble = run('disassemble')
        for block_start, block_end in re.findall(r'Address range 0x([0-9a-f]+) to 0x([0-9a-f]+):', disassemble):
            block_start = int(block_start, 16)
            block_end = int(block_end, 16)
            if block_start <= frame.pc() < block_end:
                return block_start, block_end - 1 # need to be inclusive
        # if function information is available then try to obtain the
        # boundaries by looking at the superblocks
        block = frame.block()
        if frame.function():
            while block and (not block.function or block.function.name != frame.function().name):
                block = block.superblock
            block = block or frame.block()
        return block.start, block.end - 1

    def fetch_asm(self, start, end_or_count, relative, highlighter):
        # fetch asm from cache or disassemble
        if self.cache_key == (start, end_or_count):
            asm = self.cache_asm
        else:
            kwargs = {
                'start_pc': start,
                'count' if relative else 'end_pc': end_or_count
            }
            asm = gdb.selected_frame().architecture().disassemble(**kwargs)
            self.cache_key = (start, end_or_count)
            self.cache_asm = asm
            # syntax highlight the cached entry
            for instr in asm:
                instr['asm'] = highlighter.process(instr['asm'])
        return asm

class Variables(Dashboard.Module):
    '''Show arguments and locals of the selected frame.'''

    def label(self):
        return 'Variables'

    def lines(self, term_width, term_height, style_changed):
        return Variables.format_frame(
            gdb.selected_frame(), self.show_arguments, self.show_locals, self.compact, self.align, self.sort)

    def attributes(self):
        return {
            'arguments': {
                'doc': 'Frame arguments visibility flag.',
                'default': True,
                'name': 'show_arguments',
                'type': bool
            },
            'locals': {
                'doc': 'Frame locals visibility flag.',
                'default': True,
                'name': 'show_locals',
                'type': bool
            },
            'compact': {
                'doc': 'Single-line display flag.',
                'default': True,
                'type': bool
            },
            'align': {
                'doc': 'Align variables in column flag (only if not compact).',
                'default': False,
                'type': bool
            },
            'sort': {
                'doc': 'Sort variables by name.',
                'default': False,
                'type': bool
            }
        }

    @staticmethod
    def format_frame(frame, show_arguments, show_locals, compact, align, sort):
        out = []
        # fetch frame arguments and locals
        decorator = gdb.FrameDecorator.FrameDecorator(frame)
        separator = ansi(', ', R.style_low)
        if show_arguments:
            def prefix(line):
                return Stack.format_line('arg', line)
            frame_args = decorator.frame_args()
            args_lines = Variables.fetch(frame, frame_args, compact, align, sort)
            if args_lines:
                if compact:
                    args_line = separator.join(args_lines)
                    single_line = prefix(args_line)
                    out.append(single_line)
                else:
                    out.extend(map(prefix, args_lines))
        if show_locals:
            def prefix(line):
                return Stack.format_line('loc', line)
            frame_locals = decorator.frame_locals()
            locals_lines = Variables.fetch(frame, frame_locals, compact, align, sort)
            if locals_lines:
                if compact:
                    locals_line = separator.join(locals_lines)
                    single_line = prefix(locals_line)
                    out.append(single_line)
                else:
                    out.extend(map(prefix, locals_lines))
        return out

    @staticmethod
    def fetch(frame, data, compact, align, sort):
        lines = []
        name_width = 0
        if align and not compact:
            name_width = max(len(str(elem.sym)) for elem in data) if data else 0
        for elem in data or []:
            name = ansi(elem.sym, R.style_high) + ' ' * (name_width - len(str(elem.sym)))
            equal = ansi('=', R.style_low)
            value = format_value(elem.sym.value(frame), compact)
            lines.append('{} {} {}'.format(name, equal, value))
        if sort:
            lines.sort()
        return lines

class Stack(Dashboard.Module):
    '''Show the current stack trace including the function name and the file location, if available.

Optionally list the frame arguments and locals too.'''

    def label(self):
        return 'Stack'

    def lines(self, term_width, term_height, style_changed):
        # skip if the current thread is not stopped
        if not gdb.selected_thread().is_stopped():
            return []
        # find the selected frame (i.e., the first to display)
        selected_index = 0
        frame = gdb.newest_frame()
        while frame:
            if frame == gdb.selected_frame():
                break
            frame = frame.older()
            selected_index += 1
        # format up to "limit" frames
        frames = []
        number = selected_index
        more = False
        while frame:
            # the first is the selected one
            selected = (len(frames) == 0)
            # fetch frame info
            style = R.style_selected_1 if selected else R.style_selected_2
            frame_id = ansi(str(number), style)
            info = Stack.get_pc_line(frame, style)
            frame_lines = []
            frame_lines.append('[{}] {}'.format(frame_id, info))
            # add frame arguments and locals
            variables = Variables.format_frame(
                frame, self.show_arguments, self.show_locals, self.compact, self.align, self.sort)
            frame_lines.extend(variables)
            # add frame
            frames.append(frame_lines)
            # next
            frame = frame.older()
            number += 1
            # check finished according to the limit
            if self.limit and len(frames) == self.limit:
                # more frames to show but limited
                if frame:
                    more = True
                break
        # format the output
        lines = []
        for frame_lines in frames:
            lines.extend(frame_lines)
        # add the placeholder
        if more:
            lines.append('[{}]'.format(ansi('+', R.style_selected_2)))
        return lines

    def attributes(self):
        return {
            'limit': {
                'doc': 'Maximum number of displayed frames (0 means no limit).',
                'default': 10,
                'type': int,
                'check': check_ge_zero
            },
            'arguments': {
                'doc': 'Frame arguments visibility flag.',
                'default': False,
                'name': 'show_arguments',
                'type': bool
            },
            'locals': {
                'doc': 'Frame locals visibility flag.',
                'default': False,
                'name': 'show_locals',
                'type': bool
            },
            'compact': {
                'doc': 'Single-line display flag.',
                'default': False,
                'type': bool
            },
            'align': {
                'doc': 'Align variables in column flag (only if not compact).',
                'default': False,
                'type': bool
            },
            'sort': {
                'doc': 'Sort variables by name.',
                'default': False,
                'type': bool
            }
        }

    @staticmethod
    def format_line(prefix, line):
        prefix = ansi(prefix, R.style_low)
        return '{} {}'.format(prefix, line)

    @staticmethod
    def get_pc_line(frame, style):
        frame_pc = ansi(format_address(frame.pc()), style)
        info = 'from {}'.format(frame_pc)
        # if a frame function symbol is available then use it to fetch the
        # current function name and address, otherwise fall back relying on the
        # frame name
        if frame.function():
            name = ansi(frame.function(), style)
            func_start = to_unsigned(frame.function().value())
            offset = ansi(str(frame.pc() - func_start), style)
            info += ' in {}+{}'.format(name, offset)
        elif frame.name():
            name = ansi(frame.name(), style)
            info += ' in {}'.format(name)
        sal = frame.find_sal()
        if sal and sal.symtab:
            file_name = ansi(sal.symtab.filename, style)
            file_line = ansi(str(sal.line), style)
            info += ' at {}:{}'.format(file_name, file_line)
        return info

class History(Dashboard.Module):
    '''List the last entries of the value history.'''

    def label(self):
        return 'History'

    def lines(self, term_width, term_height, style_changed):
        out = []
        # fetch last entries
        for i in range(-self.limit + 1, 1):
            try:
                value = format_value(gdb.history(i))
                value_id = ansi('$${}', R.style_high).format(abs(i))
                equal = ansi('=', R.style_low)
                line = '{} {} {}'.format(value_id, equal, value)
                out.append(line)
            except gdb.error:
                continue
        return out

    def attributes(self):
        return {
            'limit': {
                'doc': 'Maximum number of values to show.',
                'default': 3,
                'type': int,
                'check': check_gt_zero
            }
        }

class Memory(Dashboard.Module):
    '''Allow to inspect memory regions.'''

    DEFAULT_LENGTH = 16

    class Region():
        def __init__(self, expression, length, module):
            self.expression = expression
            self.length = length
            self.module = module
            self.original = None
            self.latest = None

        def reset(self):
            self.original = None
            self.latest = None

        def format(self, per_line):
            # fetch the memory content
            try:
                address = Memory.parse_as_address(self.expression)
                inferior = gdb.selected_inferior()
                memory = inferior.read_memory(address, self.length)
                # set the original memory snapshot if needed
                if not self.original:
                    self.original = memory
            except gdb.error as e:
                msg = 'Cannot access {} bytes starting at {}: {}'
                msg = msg.format(self.length, self.expression, e)
                return [ansi(msg, R.style_error)]
            # format the memory content
            out = []
            for i in range(0, len(memory), per_line):
                region = memory[i:i + per_line]
                pad = per_line - len(region)
                address_str = format_address(address + i)
                # compute changes
                hexa = []
                text = []
                for j in range(len(region)):
                    rel = i + j
                    byte = memory[rel]
                    hexa_byte = '{:02x}'.format(ord(byte))
                    text_byte = self.module.format_byte(byte)
                    # differences against the latest have the highest priority
                    if self.latest and memory[rel] != self.latest[rel]:
                        hexa_byte = ansi(hexa_byte, R.style_selected_1)
                        text_byte = ansi(text_byte, R.style_selected_1)
                    # cumulative changes if enabled
                    elif self.module.cumulative and memory[rel] != self.original[rel]:
                        hexa_byte = ansi(hexa_byte, R.style_selected_2)
                        text_byte = ansi(text_byte, R.style_selected_2)
                    # format the text differently for clarity
                    else:
                        text_byte = ansi(text_byte, R.style_high)
                    hexa.append(hexa_byte)
                    text.append(text_byte)
                # output the formatted line
                hexa_placeholder = ' {}'.format(self.module.placeholder[0] * 2)
                text_placeholder = self.module.placeholder[0]
                out.append('{}  {}{}  {}{}'.format(
                    ansi(address_str, R.style_low),
                    ' '.join(hexa), ansi(pad * hexa_placeholder, R.style_low),
                    ''.join(text), ansi(pad * text_placeholder, R.style_low)))
            # update the latest memory snapshot
            self.latest = memory
            return out

    def __init__(self):
        self.table = {}

    def label(self):
        return 'Memory'

    def lines(self, term_width, term_height, style_changed):
        out = []
        for expression, region in self.table.items():
            out.append(divider(term_width, expression))
            out.extend(region.format(self.get_per_line(term_width)))
        return out

    def commands(self):
        return {
            'watch': {
                'action': self.watch,
                'doc': '''Watch a memory region by expression and length.

The length defaults to 16 bytes.''',
                'complete': gdb.COMPLETE_EXPRESSION
            },
            'unwatch': {
                'action': self.unwatch,
                'doc': 'Stop watching a memory region by expression.',
                'complete': gdb.COMPLETE_EXPRESSION
            },
            'clear': {
                'action': self.clear,
                'doc': 'Clear all the watched regions.'
            }
        }

    def attributes(self):
        return {
            'cumulative': {
                'doc': 'Highlight changes cumulatively, watch again to reset.',
                'default': False,
                'type': bool
            },
            'full': {
                'doc': 'Take the whole horizontal space.',
                'default': False,
                'type': bool
            },
            'placeholder': {
                'doc': 'Placeholder used for missing items and unprintable characters.',
                'default': '·'
            }
        }

    def watch(self, arg):
        if arg:
            expression, _, length_str = arg.partition(' ')
            length = Memory.parse_as_address(length_str) if length_str else Memory.DEFAULT_LENGTH
            # keep the length when the memory is watched to reset the changes
            region = self.table.get(expression)
            if region and not length_str:
                region.reset()
            else:
                self.table[expression] = Memory.Region(expression, length, self)
        else:
            raise Exception('Specify a memory location')

    def unwatch(self, arg):
        if arg:
            try:
                del self.table[arg]
            except KeyError:
                raise Exception('Memory expression not watched')
        else:
            raise Exception('Specify a matched memory expression')

    def clear(self, arg):
        self.table.clear()

    def format_byte(self, byte):
        # `type(byte) is bytes` in Python 3
        if 0x20 < ord(byte) < 0x7f:
            return chr(ord(byte))
        else:
            return self.placeholder[0]

    def get_per_line(self, term_width):
        if self.full:
            padding = 3  # two double spaces separator (one is part of below)
            elem_size = 4 # HH + 1 space + T
            address_length = gdb.parse_and_eval('$pc').type.sizeof * 2 + 2  # 0x
            return max(int((term_width - address_length - padding) / elem_size), 1)
        else:
            return Memory.DEFAULT_LENGTH

    @staticmethod
    def parse_as_address(expression):
        value = gdb.parse_and_eval(expression)
        return to_unsigned(value)

class Registers(Dashboard.Module):
    '''Show the CPU registers and their values.'''

    def __init__(self):
        self.table = {}

    def label(self):
        return 'Registers'

    def lines(self, term_width, term_height, style_changed):
        # skip if the current thread is not stopped
        if not gdb.selected_thread().is_stopped():
            return []
        # obtain the registers to display
        if style_changed:
            self.table = {}
        if self.register_list:
            register_list = self.register_list.split()
        else:
            register_list = Registers.fetch_register_list()
        # fetch registers status
        registers = []
        for name in register_list:
            # exclude registers with a dot '.' or parse_and_eval() will fail
            if '.' in name:
                continue
            value = gdb.parse_and_eval('${}'.format(name))
            string_value = Registers.format_value(value)
            # exclude unavailable registers (see #255)
            if string_value == '<unavailable>':
                continue
            changed = self.table and (self.table.get(name, '') != string_value)
            self.table[name] = string_value
            registers.append((name, string_value, changed))
        # compute lengths considering an extra space between and around the
        # entries (hence the +2 and term_width - 1)
        max_name = max(len(name) for name, _, _ in registers)
        max_value = max(len(value) for _, value, _ in registers)
        max_width = max_name + max_value + 2
        columns = min(int((term_width - 1) / max_width) or 1, len(registers))
        rows = int(math.ceil(float(len(registers)) / columns))
        # build the registers matrix
        if self.column_major:
            matrix = list(registers[i:i + rows] for i in range(0, len(registers), rows))
        else:
            matrix = list(registers[i::columns] for i in range(columns))
        # compute the lengths column wise
        max_names_column = list(max(len(name) for name, _, _ in column) for column in matrix)
        max_values_column = list(max(len(value) for _, value, _ in column) for column in matrix)
        line_length = sum(max_names_column) + columns + sum(max_values_column)
        extra = term_width - line_length
        # compute padding as if there were one more column
        base_padding = int(extra / (columns + 1))
        padding_column = [base_padding] * columns
        # distribute the remainder among columns giving the precedence to
        # internal padding
        rest = extra % (columns + 1)
        while rest:
            padding_column[rest % columns] += 1
            rest -= 1
        # format the registers
        out = [''] * rows
        for i, column in enumerate(matrix):
            max_name = max_names_column[i]
            max_value = max_values_column[i]
            for j, (name, value, changed) in enumerate(column):
                name = ' ' * (max_name - len(name)) + ansi(name, R.style_low)
                style = R.style_selected_1 if changed else ''
                value = ansi(value, style) + ' ' * (max_value - len(value))
                padding = ' ' * padding_column[i]
                item = '{}{} {}'.format(padding, name, value)
                out[j] += item
        return out

    def attributes(self):
        return {
            'column-major': {
                'doc': 'Show registers in columns instead of rows.',
                'default': False,
                'name': 'column_major',
                'type': bool
            },
            'list': {
                'doc': '''String of space-separated register names to display.

The empty list (default) causes to show all the available registers.''',
                'default': '',
                'name': 'register_list',
            }
        }

    @staticmethod
    def format_value(value):
        try:
            if value.type.code in [gdb.TYPE_CODE_INT, gdb.TYPE_CODE_PTR]:
                int_value = to_unsigned(value, value.type.sizeof)
                value_format = '0x{{:0{}x}}'.format(2 * value.type.sizeof)
                return value_format.format(int_value)
        except (gdb.error, ValueError):
            # convert to unsigned but preserve code and flags information
            pass
        return str(value)

    @staticmethod
    def fetch_register_list(*match_groups):
        names = []
        for line in run('maintenance print register-groups').split('\n'):
            fields = line.split()
            if len(fields) != 7:
                continue
            name, _, _, _, _, _, groups = fields
            if not re.match('\w', name):
                continue
            for group in groups.split(','):
                if group in (match_groups or ('general',)):
                    names.append(name)
                    break
        return names

class Threads(Dashboard.Module):
    '''List the currently available threads.'''

    def label(self):
        return 'Threads'

    def lines(self, term_width, term_height, style_changed):
        out = []
        selected_thread = gdb.selected_thread()
        # do not restore the selected frame if the thread is not stopped
        restore_frame = gdb.selected_thread().is_stopped()
        if restore_frame:
            selected_frame = gdb.selected_frame()
        # fetch the thread list
        threads = []
        for inferior in gdb.inferiors():
            if self.all_inferiors or inferior == gdb.selected_inferior():
                threads += gdb.Inferior.threads(inferior)
        for thread in threads:
            # skip running threads if requested
            if self.skip_running and thread.is_running():
                continue
            is_selected = (thread.ptid == selected_thread.ptid)
            style = R.style_selected_1 if is_selected else R.style_selected_2
            if self.all_inferiors:
                number = '{}.{}'.format(thread.inferior.num, thread.num)
            else:
                number = str(thread.num)
            number = ansi(number, style)
            tid = ansi(str(thread.ptid[1] or thread.ptid[2]), style)
            info = '[{}] id {}'.format(number, tid)
            if thread.name:
                info += ' name {}'.format(ansi(thread.name, style))
            # switch thread to fetch info (unless is running in non-stop mode)
            try:
                thread.switch()
                frame = gdb.newest_frame()
                info += ' ' + Stack.get_pc_line(frame, style)
            except gdb.error:
                info += ' (running)'
            out.append(info)
        # restore thread and frame
        selected_thread.switch()
        if restore_frame:
            selected_frame.select()
        return out

    def attributes(self):
        return {
            'skip-running': {
                'doc': 'Skip running threads.',
                'default': False,
                'name': 'skip_running',
                'type': bool
            },
            'all-inferiors': {
                'doc': 'Show threads from all inferiors.',
                'default': False,
                'name': 'all_inferiors',
                'type': bool
            },
        }

class Expressions(Dashboard.Module):
    '''Watch user expressions.'''

    def __init__(self):
        self.table = set()

    def label(self):
        return 'Expressions'

    def lines(self, term_width, term_height, style_changed):
        out = []
        label_width = 0
        if self.align:
            label_width = max(len(expression) for expression in self.table) if self.table else 0
        default_radix = Expressions.get_default_radix()
        for expression in self.table:
            label = expression
            match = re.match('^/(\d+) +(.+)$', expression)
            try:
                if match:
                    radix, expression = match.groups()
                    run('set output-radix {}'.format(radix))
                value = format_value(gdb.parse_and_eval(expression))
            except gdb.error as e:
                value = ansi(e, R.style_error)
            finally:
                if match:
                    run('set output-radix {}'.format(default_radix))
            label = ansi(expression, R.style_high) + ' ' * (label_width - len(expression))
            equal = ansi('=', R.style_low)
            out.append('{} {} {}'.format(label, equal, value))
        return out

    def commands(self):
        return {
            'watch': {
                'action': self.watch,
                'doc': 'Watch an expression using the format `[/<radix>] <expression>`.',
                'complete': gdb.COMPLETE_EXPRESSION
            },
            'unwatch': {
                'action': self.unwatch,
                'doc': 'Stop watching an expression.',
                'complete': gdb.COMPLETE_EXPRESSION
            },
            'clear': {
                'action': self.clear,
                'doc': 'Clear all the watched expressions.'
            }
        }

    def attributes(self):
        return {
            'align': {
                'doc': 'Align variables in column flag.',
                'default': False,
                'type': bool
            }
        }

    def watch(self, arg):
        if arg:
            self.table.add(arg)
        else:
            raise Exception('Specify an expression')

    def unwatch(self, arg):
        if arg:
            try:
                self.table.remove(arg)
            except:
                raise Exception('Expression not watched')
        else:
            raise Exception('Specify an expression')

    def clear(self, arg):
        self.table.clear()

    @staticmethod
    def get_default_radix():
        try:
            return gdb.parameter('output-radix')
        except RuntimeError:
            # XXX this is a fix for GDB <8.1.x see #161
            message = run('show output-radix')
            match = re.match('^Default output radix for printing of values is (\d+)\.$', message)
            return match.groups()[0] if match else 10  # fallback

class Breakpoints(Dashboard.Module):
    '''Display the breakpoints list.'''

    NAMES = {
        gdb.BP_BREAKPOINT: 'break',
        gdb.BP_WATCHPOINT: 'watch',
        gdb.BP_HARDWARE_WATCHPOINT: 'write watch',
        gdb.BP_READ_WATCHPOINT: 'read watch',
        gdb.BP_ACCESS_WATCHPOINT: 'access watch'
    }

    def label(self):
        return 'Breakpoints'

    def lines(self, term_width, term_height, style_changed):
        out = []
        breakpoints = fetch_breakpoints(watchpoints=True, pending=self.show_pending)
        for breakpoint in breakpoints:
            sub_lines = []
            # format common information
            style = R.style_selected_1 if breakpoint['enabled'] else R.style_selected_2
            number = ansi(breakpoint['number'], style)
            bp_type = ansi(Breakpoints.NAMES[breakpoint['type']], style)
            if breakpoint['temporary']:
                bp_type = bp_type + ' {}'.format(ansi('once', style))
            if not R.ansi and breakpoint['enabled']:
                bp_type = 'disabled ' + bp_type
            line = '[{}] {}'.format(number, bp_type)
            if breakpoint['type'] == gdb.BP_BREAKPOINT:
                for i, address in enumerate(breakpoint['addresses']):
                    addr = address['address']
                    if i == 0 and addr:
                        # this is a regular breakpoint
                        line += ' at {}'.format(ansi(format_address(addr), style))
                        # format source information
                        file_name = address.get('file_name')
                        file_line = address.get('file_line')
                        if file_name and file_line:
                            file_name = ansi(file_name, style)
                            file_line = ansi(file_line, style)
                            line += ' in {}:{}'.format(file_name, file_line)
                    elif i > 0:
                        # this is a sub breakpoint
                        sub_style = R.style_selected_1 if address['enabled'] else R.style_selected_2
                        sub_number = ansi('{}.{}'.format(breakpoint['number'], i), sub_style)
                        sub_line = '[{}]'.format(sub_number)
                        sub_line += ' at {}'.format(ansi(format_address(addr), sub_style))
                        # format source information
                        file_name = address.get('file_name')
                        file_line = address.get('file_line')
                        if file_name and file_line:
                            file_name = ansi(file_name, sub_style)
                            file_line = ansi(file_line, sub_style)
                            sub_line += ' in {}:{}'.format(file_name, file_line)
                        sub_lines += [sub_line]
                # format user location
                location = breakpoint['location']
                line += ' for {}'.format(ansi(location, style))
            else:
                # format user expression
                expression = breakpoint['expression']
                line += ' for {}'.format(ansi(expression, style))
            # format condition
            condition = breakpoint['condition']
            if condition:
                line += ' if {}'.format(ansi(condition, style))
            # format hit count
            hit_count = breakpoint['hit_count']
            if hit_count:
                word = 'time{}'.format('s' if hit_count > 1 else '')
                line += ' hit {} {}'.format(ansi(breakpoint['hit_count'], style), word)
            # append the main line and possibly sub breakpoints
            out.append(line)
            out.extend(sub_lines)
        return out

    def attributes(self):
        return {
            'pending': {
                'doc': 'Also show pending breakpoints.',
                'default': True,
                'name': 'show_pending',
                'type': bool
            }
        }

# XXX traceback line numbers in this Python block must be increased by 1
end

# Start ------------------------------------------------------------------------

python Dashboard.start()

# Profiles ---------------------------------------------------------------------
dashboard -layout assembly registers expressions history threads memory stack source breakpoints variables
dashboard variables -style compact False
dashboard variables -style align True
dashboard variables -style sort True
dashboard expressions -style align True

define vimdb
    dashboard assembly
    dashboard registers
    dashboard source
end

# File variables ---------------------------------------------------------------

# vim: filetype=python
# Local Variables:
# mode: python
# End:

##=====================================
## ░█▀▀░█▀▄░█▀▄░█▀▀░█▀▀░█▀▀
## ░█░█░█░█░█▀▄░█░█░█▀▀░█▀▀
## ░▀▀▀░▀▀░░▀▀░░▀▀▀░▀▀▀░▀░░
##gdbgef===============================
#
##GDB Enhanced Features (GEF)
#source /usr/share/gef/gef.py
#
####Verbose
## INSTALL INSTRUCTIONS: save as ~/.gdbinit
#
## DESCRIPTION: A user-friendly gdb configuration file.
#
## REVISION : 7.3 (16/04/2010)
#
## CONTRIBUTORS: mammon_, elaine, pusillus, mong, zhang le, l0kit,
##               truthix the cyberpunk, fG!, gln
#
## FEEDBACK: https://www.reverse-engineering.net
##           The Linux Area
##           Topic: "+HCU's .gdbinit Version 7.1 -- humble announce"
##           http://reverse.put.as
#
## NOTES: 'help user' in gdb will list the commands/descriptions in this file
##        'context on' now enables auto-display of context screen
#
## MAC OS X NOTES: If you are using this on Mac OS X, you must either attach gdb to a process
##                 or launch gdb without any options and then load the binary file you want to analyse with "exec-file" option
##                 If you load the binary from the command line, like $gdb binary-name, this will not work as it should
##                 For more information, read it here http://reverse.put.as/2008/11/28/apples-gdb-bug/
#
##                 UPDATE: This bug can be fixed in gdb source. Refer to http://reverse.put.as/2009/08/10/fix-for-apples-gdb-bug-or-why-apple-forks-are-bad/
##                         and http://reverse.put.as/2009/08/26/gdb-patches/ (if you want the fixed binary for i386)
#
## CHANGELOG:
#
##   Version 7.3 (16/04/2010)
##     Support for 64bits targets. Default is 32bits, you should modify the variable or use the 32bits or 64bits to choose the mode.
##       I couldn't find another way to recognize the type of binaryâ€¦ Testing the register doesn't work that well.
##     TODO: fix objectivec messages and stepo for 64bits
#
##   Version 7.2.1 (24/11/2009)
##     Another fix to stepo (0xFF92 missing)
#
##   Version 7.2 (11/10/2009)
##     Added the smallregisters function to create 16 and 8 bit versions from the registers EAX, EBX, ECX, EDX
##     Revised and fixed all the dumpjump stuff, following Intel manuals. There were some errors (thx to rev who pointed the jle problem).
##     Small fix to stepo command (missed a few call types)
#
##   Version 7.1.7
##     Added the possibility to modify what's displayed with the context window. You can change default options at the gdb options part. For example, kernel debugging is much slower if the stack display is enabled...
##     New commands enableobjectivec, enablecpuregisters, enablestack, enabledatawin and their disable equivalents (to support realtime change of default options)
##     Fixed problem with the assemble command. I was calling /bin/echo which doesn't support the -e option ! DUH ! Should have used bash internal version.
##     Small fixes to colours...
##     New commands enablesolib and disablesolib . Just shortcuts for the stop-on-solib-events fantastic trick ! Hey... I'm lazy ;)
##     Fixed this: Possible removal of "u" command, info udot is missing in gdb 6.8-debian . Doesn't exist on OS X so bye bye !!!
##     Displays affected flags in jump decisions
#
##   Version 7.1.6
##     Added modified assemble command from Tavis Ormandy (further modified to work with Mac OS X) (shell commands used use full path name, working for Leopard, modify for others if necessary)
##     Renamed thread command to threads because thread is an internal gdb command that allows to move between program threads
#
##   Version 7.1.5 (04/01/2009)
##     Fixed crash on Leopard ! There was a If Else condition where the else had no code and that made gdb crash on Leopard (CRAZY!!!!)
##     Better code indention
#
##   Version 7.1.4 (02/01/2009)
##     Bug in show objective c messages with Leopard ???
##     Nop routine support for single address or range (contribution from gln [ghalen at hack.se])
##     Used the same code from nop to null routine
#
##   Version 7.1.3 (31/12/2008)
##     Added a new command 'stepo'. This command will step a temporary breakpoint on next instruction after the call, so you can skip over
##     the call. Did this because normal commands not always skip over (mainly with objc_msgSend)
#
##   Version 7.1.2 (31/12/2008)
##     Support for the jump decision (will display if a conditional jump will be taken or not)
#
##   Version 7.1.1 (29/12/2008)
##     Moved gdb options to the beginning (makes more sense)
##     Added support to dump message being sent to msgSend (easier to understand what's going on)
#
##   Version 7.1
##     Fixed serious (and old) bug in dd and datawin, causing dereference of
##     obviously invalid address. See below:
##     gdb$ dd 0xffffffff
##     FFFFFFFF : Cannot access memory at address 0xffffffff
#
##   Version 7.0
##     Added cls command.
##     Improved documentation of many commands.
##     Removed bp_alloc, was neither portable nor usefull.
##     Checking of passed argument(s) in these commands:
##       contextsize-stack, contextsize-data, contextsize-code
##       bp, bpc, bpe, bpd, bpt, bpm, bhb,...
##     Fixed bp and bhb inconsistencies, look at * signs in Version 6.2
##     Bugfix in bhb command, changed "break" to "hb" command body
##     Removed $SHOW_CONTEXT=1 from several commands, this variable
##     should only be controlled globally with context-on and context-off
##     Improved stack, func, var and sig, dis, n, go,...
##     they take optional argument(s) now
##     Fixed wrong $SHOW_CONTEXT assignment in context-off
##     Fixed serious bug in cft command, forgotten ~ sign
##     Fixed these bugs in step_to_call:
##       1) the correct logging sequence is:
##          set logging file > set logging redirect > set logging on
##       2) $SHOW_CONTEXT is now correctly restored from $_saved_ctx
##     Fixed these bugs in trace_calls:
##       1) the correct logging sequence is:
##          set logging file > set logging overwrite >
##          set logging redirect > set logging on
##       2) removed the "clean up trace file" part, which is not needed now,
##          stepi output is properly redirected to /dev/null
##       3) $SHOW_CONTEXT is now correctly restored from $_saved_ctx
##     Fixed bug in trace_run:
##       1) $SHOW_CONTEXT is now correctly restored from $_saved_ctx
##     Fixed print_insn_type -- removed invalid semicolons!, wrong value checking,
##     Added TODO entry regarding the "u" command
##     Changed name from gas_assemble to assemble_gas due to consistency
##     Output from assemble and assemble_gas is now similar, because i made
##     both of them to use objdump, with respect to output format (AT&T|Intel).
##     Whole code was checked and made more consistent, readable/maintainable.
#
##   Version 6.2
##     Add global variables to allow user to control stack, data and code window sizes
##     Increase readability for registers
##     Some corrections (hexdump, ddump, context, cfp, assemble, gas_asm, tips, prompt)
#
##   Version 6.1-color-user
##     Took the Gentoo route and ran sed s/user/user/g
#
##   Version 6.1-color
##     Added color fixes from
##       http://gnurbs.blogsome.com/2006/12/22/colorizing-mamons-gdbinit/
#
##   Version 6.1
##     Fixed filename in step_to_call so it points to /dev/null
##     Changed location of logfiles from /tmp  to ~
#
##   Version 6
##     Added print_insn_type, get_insn_type, context-on, context-off commands
##     Added trace_calls, trace_run, step_to_call commands
##     Changed hook-stop so it checks $SHOW_CONTEXT variable
#
##   Version 5
##     Added bpm, dump_bin, dump_hex, bp_alloc commands
##     Added 'assemble' by elaine, 'gas_asm' by mong
##     Added Tip Topics for aspiring users ;)
#
##   Version 4
##     Added eflags-changing insns by pusillus
##     Added bp, nop, null, and int3 patch commands, also hook-stop
#
##   Version 3
##     Incorporated elaine's if/else goodness into the hex/ascii dump
#
##   Version 2
##     Radix bugfix by elaine
#
##   TODO:
##     Add dump, append, set write, etc commands
##     Add more tips !
#
#
###__________________gdb options_________________
#
## set to 1 to enable 64bits target by default (32bit is the default)
#set $64BITS = 1
#
#set confirm off
#set verbose off
#set prompt \033[31mgdb$ \033[0m
#
#set output-radix 0x10
#set input-radix 0x10
#
## These make gdb never pause in its output
#set height 0
#set width 0
#
## Display instructions in Intel format
#set disassembly-flavor intel
#
#set $SHOW_CONTEXT = 1
#set $SHOW_NEST_INSN = 1
#
#set $CONTEXTSIZE_STACK = 6
#set $CONTEXTSIZE_DATA  = 8
#set $CONTEXTSIZE_CODE  = 8
#
## set to 0 to remove display of objectivec messages (default is 1)
#set $SHOWOBJECTIVEC = 1
## set to 0 to remove display of cpu registers (default is 1)
#set $SHOWCPUREGISTERS = 1
## set to 1 to enable display of stack (default is 0)
#set $SHOWSTACK = 1
## set to 1 to enable display of data window (default is 0)
#set $SHOWDATAWIN = 1
#
#
## __________________end gdb options_________________
#
## ______________window size control___________
#define contextsize-stack
#    if $argc != 1
#        help contextsize-stack
#    else
#        set $CONTEXTSIZE_STACK = $arg0
#    end
#end
#document contextsize-stack
#Set stack dump window size to NUM lines.
#Usage: contextsize-stack NUM
#end
#
#
#define contextsize-data
#    if $argc != 1
#        help contextsize-data
#    else
#        set $CONTEXTSIZE_DATA = $arg0
#    end
#end
#document contextsize-data
#Set data dump window size to NUM lines.
#Usage: contextsize-data NUM
#end
#
#
#define contextsize-code
#    if $argc != 1
#        help contextsize-code
#    else
#        set $CONTEXTSIZE_CODE = $arg0
#    end
#end
#document contextsize-code
#Set code window size to NUM lines.
#Usage: contextsize-code NUM
#end
#
#
#
#
## _____________breakpoint aliases_____________
#define bpl
#    info breakpoints
#end
#document bpl
#List all breakpoints.
#end
#
#define bp
#    if $argc != 1
#        help bp
#    else
#        break $arg0
#    end
#end
#document bp
#Set breakpoint.
#Usage: bp LOCATION
#LOCATION may be a line number, function name, or "*" and an address.
#
#To break on a symbol you must enclose symbol name inside "".
#Example:
#bp "[NSControl stringValue]"
#Or else you can use directly the break command (break [NSControl stringValue])
#end
#
#
#define bpc
#    if $argc != 1
#        help bpc
#    else
#        clear $arg0
#    end
#end
#document bpc
#Clear breakpoint.
#Usage: bpc LOCATION
#LOCATION may be a line number, function name, or "*" and an address.
#end
#
#
#define bpe
#    if $argc != 1
#        help bpe
#    else
#        enable $arg0
#    end
#end
#document bpe
#Enable breakpoint with number NUM.
#Usage: bpe NUM
#end
#
#
#define bpd
#    if $argc != 1
#        help bpd
#    else
#        disable $arg0
#    end
#end
#document bpd
#Disable breakpoint with number NUM.
#Usage: bpd NUM
#end
#
#
#define bpt
#    if $argc != 1
#        help bpt
#    else
#        tbreak $arg0
#    end
#end
#document bpt
#Set a temporary breakpoint.
#Will be deleted when hit!
#Usage: bpt LOCATION
#LOCATION may be a line number, function name, or "*" and an address.
#end
#
#
#define bpm
#    if $argc != 1
#        help bpm
#    else
#        awatch $arg0
#    end
#end
#document bpm
#Set a read/write breakpoint on EXPRESSION, e.g. *address.
#Usage: bpm EXPRESSION
#end
#
#
#define bhb
#    if $argc != 1
#        help bhb
#    else
#        hb $arg0
#    end
#end
#document bhb
#Set hardware assisted breakpoint.
#Usage: bhb LOCATION
#LOCATION may be a line number, function name, or "*" and an address.
#end
#
#
#
#
## ______________process information____________
#define argv
#    show args
#end
#document argv
#Print program arguments.
#end
#
#
#define stack
#    if $argc == 0
#        info stack
#    end
#    if $argc == 1
#        info stack $arg0
#    end
#    if $argc > 1
#        help stack
#    end
#end
#document stack
#Print backtrace of the call stack, or innermost COUNT frames.
#Usage: stack <COUNT>
#end
#
#
#define frame
#    info frame
#    info args
#    info locals
#end
#document frame
#Print stack frame.
#end
#
#
#define flags
## OF (overflow) flag
#    if (($eflags >> 0xB) & 1)
#        printf "O "
#        set $_of_flag = 1
#    else
#        printf "o "
#        set $_of_flag = 0
#    end
#    if (($eflags >> 0xA) & 1)
#        printf "D "
#    else
#        printf "d "
#    end
#    if (($eflags >> 9) & 1)
#        printf "I "
#    else
#        printf "i "
#    end
#    if (($eflags >> 8) & 1)
#        printf "T "
#    else
#        printf "t "
#    end
## SF (sign) flag
#    if (($eflags >> 7) & 1)
#        printf "S "
#        set $_sf_flag = 1
#    else
#        printf "s "
#        set $_sf_flag = 0
#    end
## ZF (zero) flag
#    if (($eflags >> 6) & 1)
#        printf "Z "
#   set $_zf_flag = 1
#    else
#        printf "z "
#   set $_zf_flag = 0
#    end
#    if (($eflags >> 4) & 1)
#        printf "A "
#    else
#        printf "a "
#    end
## PF (parity) flag
#    if (($eflags >> 2) & 1)
#        printf "P "
#   set $_pf_flag = 1
#    else
#        printf "p "
#   set $_pf_flag = 0
#    end
## CF (carry) flag
#    if ($eflags & 1)
#        printf "C "
#   set $_cf_flag = 1
#    else
#        printf "c "
#   set $_cf_flag = 0
#    end
#    printf "\n"
#end
#document flags
#Print flags register.
#end
#
#
#define eflags
#    printf "     OF <%d>  DF <%d>  IF <%d>  TF <%d>",\
#           (($eflags >> 0xB) & 1), (($eflags >> 0xA) & 1), \
#           (($eflags >> 9) & 1), (($eflags >> 8) & 1)
#    printf "  SF <%d>  ZF <%d>  AF <%d>  PF <%d>  CF <%d>\n",\
#           (($eflags >> 7) & 1), (($eflags >> 6) & 1),\
#           (($eflags >> 4) & 1), (($eflags >> 2) & 1), ($eflags & 1)
#    printf "     ID <%d>  VIP <%d> VIF <%d> AC <%d>",\
#           (($eflags >> 0x15) & 1), (($eflags >> 0x14) & 1), \
#           (($eflags >> 0x13) & 1), (($eflags >> 0x12) & 1)
#    printf "  VM <%d>  RF <%d>  NT <%d>  IOPL <%d>\n",\
#           (($eflags >> 0x11) & 1), (($eflags >> 0x10) & 1),\
#           (($eflags >> 0xE) & 1), (($eflags >> 0xC) & 3)
#end
#document eflags
#Print eflags register.
#end
#
#
#define reg
# if ($64BITS == 1)
## 64bits stuff
#    printf "  "
#    echo \033[32m
#    printf "RAX:"
#    echo \033[0m
#    printf " 0x%016lX  ", $rax
#    echo \033[32m
#    printf "RBX:"
#    echo \033[0m
#    printf " 0x%016lX  ", $rbx
#    echo \033[32m
#    printf "RCX:"
#    echo \033[0m
#    printf " 0x%016lX  ", $rcx
#    echo \033[32m
#    printf "RDX:"
#    echo \033[0m
#    printf " 0x%016lX  ", $rdx
#    echo \033[1m\033[4m\033[31m
#    flags
#    echo \033[0m
#    printf "  "
#    echo \033[32m
#    printf "RSI:"
#    echo \033[0m
#    printf " 0x%016lX  ", $rsi
#    echo \033[32m
#    printf "RDI:"
#    echo \033[0m
#    printf " 0x%016lX  ", $rdi
#    echo \033[32m
#    printf "RBP:"
#    echo \033[0m
#    printf " 0x%016lX  ", $rbp
#    echo \033[32m
#    printf "RSP:"
#    echo \033[0m
#    printf " 0x%016lX  ", $rsp
#    echo \033[32m
#    printf "RIP:"
#    echo \033[0m
#    printf " 0x%016lX\n  ", $rip
#    echo \033[32m
#    printf "R8 :"
#    echo \033[0m
#    printf " 0x%016lX  ", $r8
#    echo \033[32m
#    printf "R9 :"
#    echo \033[0m
#    printf " 0x%016lX  ", $r9
#    echo \033[32m
#    printf "R10:"
#    echo \033[0m
#    printf " 0x%016lX  ", $r10
#    echo \033[32m
#    printf "R11:"
#    echo \033[0m
#    printf " 0x%016lX  ", $r11
#    echo \033[32m
#    printf "R12:"
#    echo \033[0m
#    printf " 0x%016lX\n  ", $r12
#    echo \033[32m
#    printf "R13:"
#    echo \033[0m
#    printf " 0x%016lX  ", $r13
#    echo \033[32m
#    printf "R14:"
#    echo \033[0m
#    printf " 0x%016lX  ", $r14
#    echo \033[32m
#    printf "R15:"
#    echo \033[0m
#    printf " 0x%016lX\n  ", $r15
#    echo \033[32m
#    printf "CS:"
#    echo \033[0m
#    printf " %04X  ", $cs
#    echo \033[32m
#    printf "DS:"
#    echo \033[0m
#    printf " %04X  ", $ds
#    echo \033[32m
#    printf "ES:"
#    echo \033[0m
#    printf " %04X  ", $es
#    echo \033[32m
#    printf "FS:"
#    echo \033[0m
#    printf " %04X  ", $fs
#    echo \033[32m
#    printf "GS:"
#    echo \033[0m
#    printf " %04X  ", $gs
#    echo \033[32m
#    printf "SS:"
#    echo \033[0m
#    printf " %04X", $ss
#    echo \033[0m
## 32bits stuff
# else
#    printf "  "
#    echo \033[32m
#    printf "EAX:"
#    echo \033[0m
#    printf " 0x%08X  ", $eax
#    echo \033[32m
#    printf "EBX:"
#    echo \033[0m
#    printf " 0x%08X  ", $ebx
#    echo \033[32m
#    printf "ECX:"
#    echo \033[0m
#    printf " 0x%08X  ", $ecx
#    echo \033[32m
#    printf "EDX:"
#    echo \033[0m
#    printf " 0x%08X  ", $edx
#    echo \033[1m\033[4m\033[31m
#    flags
#    echo \033[0m
#    printf "  "
#    echo \033[32m
#    printf "ESI:"
#    echo \033[0m
#    printf " 0x%08X  ", $esi
#    echo \033[32m
#    printf "EDI:"
#    echo \033[0m
#    printf " 0x%08X  ", $edi
#    echo \033[32m
#    printf "EBP:"
#    echo \033[0m
#    printf " 0x%08X  ", $ebp
#    echo \033[32m
#    printf "ESP:"
#    echo \033[0m
#    printf " 0x%08X  ", $esp
#    echo \033[32m
#    printf "EIP:"
#    echo \033[0m
#    printf " 0x%08X\n  ", $eip
#    echo \033[32m
#    printf "CS:"
#    echo \033[0m
#    printf " %04X  ", $cs
#    echo \033[32m
#    printf "DS:"
#    echo \033[0m
#    printf " %04X  ", $ds
#    echo \033[32m
#    printf "ES:"
#    echo \033[0m
#    printf " %04X  ", $es
#    echo \033[32m
#    printf "FS:"
#    echo \033[0m
#    printf " %04X  ", $fs
#    echo \033[32m
#    printf "GS:"
#    echo \033[0m
#    printf " %04X  ", $gs
#    echo \033[32m
#    printf "SS:"
#    echo \033[0m
#    printf " %04X", $ss
#    echo \033[0m
# end
## call smallregisters
#   smallregisters
## display conditional jump routine
#   if ($64BITS == 1)
#    printf "\t\t\t\t"
#   end
#    dumpjump
#    printf "\n"
#end
#document reg
#Print CPU registers.
#end
#
#define smallregisters
# if ($64BITS == 1)
##64bits stuff
#   # from rax
#   set $eax = $rax & 0xffffffff
#   set $ax = $rax & 0xffff
#   set $al = $ax & 0xff
#   set $ah = $ax >> 8
#   # from rbx
#   set $bx = $rbx & 0xffff
#   set $bl = $bx & 0xff
#   set $bh = $bx >> 8
#   # from rcx
#   set $ecx = $rcx & 0xffffffff
#   set $cx = $rcx & 0xffff
#   set $cl = $cx & 0xff
#   set $ch = $cx >> 8
#   # from rdx
#   set $edx = $rdx & 0xffffffff
#   set $dx = $rdx & 0xffff
#   set $dl = $dx & 0xff
#   set $dh = $dx >> 8
#   # from rsi
#   set $esi = $rsi & 0xffffffff
#   set $si = $rsi & 0xffff
#   # from rdi
#   set $edi = $rdi & 0xffffffff
#   set $di = $rdi & 0xffff
##32 bits stuff
# else
#   # from eax
#   set $ax = $eax & 0xffff
#   set $al = $ax & 0xff
#   set $ah = $ax >> 8
#   # from ebx
#   set $bx = $ebx & 0xffff
#   set $bl = $bx & 0xff
#   set $bh = $bx >> 8
#   # from ecx
#   set $cx = $ecx & 0xffff
#   set $cl = $cx & 0xff
#   set $ch = $cx >> 8
#   # from edx
#   set $dx = $edx & 0xffff
#   set $dl = $dx & 0xff
#   set $dh = $dx >> 8
#   # from esi
#   set $si = $esi & 0xffff
#   # from edi
#   set $di = $edi & 0xffff
# end
#
#end
#document smallregisters
#Create the 16 and 8 bit cpu registers (gdb doesn't have them by default)
#And 32bits if we are dealing with 64bits binaries
#end
#
#define func
#    if $argc == 0
#        info functions
#    end
#    if $argc == 1
#        info functions $arg0
#    end
#    if $argc > 1
#        help func
#    end
#end
#document func
#Print all function names in target, or those matching REGEXP.
#Usage: func <REGEXP>
#end
#
#
#define var
#    if $argc == 0
#        info variables
#    end
#    if $argc == 1
#        info variables $arg0
#    end
#    if $argc > 1
#        help var
#    end
#end
#document var
#Print all global and static variable names (symbols), or those matching REGEXP.
#Usage: var <REGEXP>
#end
#
#
#define lib
#    info sharedlibrary
#end
#document lib
#Print shared libraries linked to target.
#end
#
#
#define sig
#    if $argc == 0
#        info signals
#    end
#    if $argc == 1
#        info signals $arg0
#    end
#    if $argc > 1
#        help sig
#    end
#end
#document sig
#Print what debugger does when program gets various signals.
#Specify a SIGNAL as argument to print info on that signal only.
#Usage: sig <SIGNAL>
#end
#
#
#define threads
#    info threads
#end
#document threads
#Print threads in target.
#end
#
#
#define dis
#    if $argc == 0
#        disassemble
#    end
#    if $argc == 1
#        disassemble $arg0
#    end
#    if $argc == 2
#        disassemble $arg0 $arg1
#    end
#    if $argc > 2
#        help dis
#    end
#end
#document dis
#Disassemble a specified section of memory.
#Default is to disassemble the function surrounding the PC (program counter)
#of selected frame. With one argument, ADDR1, the function surrounding this
#address is dumped. Two arguments are taken as a range of memory to dump.
#Usage: dis <ADDR1> <ADDR2>
#end
#
#
#
#
## __________hex/ascii dump an address_________
#define ascii_char
#    if $argc != 1
#        help ascii_char
#    else
#        # thanks elaine :)
#        set $_c = *(unsigned char *)($arg0)
#        if ($_c < 0x20 || $_c > 0x7E)
#            printf "."
#        else
#            printf "%c", $_c
#        end
#    end
#end
#document ascii_char
#Print ASCII value of byte at address ADDR.
#Print "." if the value is unprintable.
#Usage: ascii_char ADDR
#end
#
#
#define hex_quad
#    if $argc != 1
#        help hex_quad
#    else
#        printf "%02X %02X %02X %02X %02X %02X %02X %02X", \
#               *(unsigned char*)($arg0), *(unsigned char*)($arg0 + 1),     \
#               *(unsigned char*)($arg0 + 2), *(unsigned char*)($arg0 + 3), \
#               *(unsigned char*)($arg0 + 4), *(unsigned char*)($arg0 + 5), \
#               *(unsigned char*)($arg0 + 6), *(unsigned char*)($arg0 + 7)
#    end
#end
#document hex_quad
#Print eight hexadecimal bytes starting at address ADDR.
#Usage: hex_quad ADDR
#end
#
#define hexdump
#    if $argc != 1
#        help hexdump
#    else
#        echo \033[1m
#        if ($64BITS == 1)
#         printf "0x%016lX : ", $arg0
#        else
#         printf "0x%08X : ", $arg0
#        end
#        echo \033[0m
#        hex_quad $arg0
#        echo \033[1m
#        printf " - "
#        echo \033[0m
#        hex_quad $arg0+8
#        printf " "
#        echo \033[1m
#        ascii_char $arg0+0x0
#        ascii_char $arg0+0x1
#        ascii_char $arg0+0x2
#        ascii_char $arg0+0x3
#        ascii_char $arg0+0x4
#        ascii_char $arg0+0x5
#        ascii_char $arg0+0x6
#        ascii_char $arg0+0x7
#        ascii_char $arg0+0x8
#        ascii_char $arg0+0x9
#        ascii_char $arg0+0xA
#        ascii_char $arg0+0xB
#        ascii_char $arg0+0xC
#        ascii_char $arg0+0xD
#        ascii_char $arg0+0xE
#        ascii_char $arg0+0xF
#        echo \033[0m
#        printf "\n"
#    end
#end
#document hexdump
#Display a 16-byte hex/ASCII dump of memory at address ADDR.
#Usage: hexdump ADDR
#end
#
#
## _______________data window__________________
#define ddump
#    if $argc != 1
#        help ddump
#    else
#        echo \033[34m
#        if ($64BITS == 1)
#         printf "[0x%04X:0x%016lX]", $ds, $data_addr
#        else
#         printf "[0x%04X:0x%08X]", $ds, $data_addr
#        end
#   echo \033[34m
#   printf "------------------------"
#    printf "-------------------------------"
#    if ($64BITS == 1)
#     printf "-------------------------------------"
#   end
#
#   echo \033[1;34m
#   printf "[data]\n"
#        echo \033[0m
#        set $_count = 0
#        while ($_count < $arg0)
#            set $_i = ($_count * 0x10)
#            hexdump $data_addr+$_i
#            set $_count++
#        end
#    end
#end
#document ddump
#Display NUM lines of hexdump for address in $data_addr global variable.
#Usage: ddump NUM
#end
#
#
#define dd
#    if $argc != 1
#        help dd
#    else
#        if ((($arg0 >> 0x18) == 0x40) || (($arg0 >> 0x18) == 0x08) || (($arg0 >> 0x18) == 0xBF))
#            set $data_addr = $arg0
#            ddump 0x10
#        else
#            printf "Invalid address: %08X\n", $arg0
#        end
#    end
#end
#document dd
#Display 16 lines of a hex dump of address starting at ADDR.
#Usage: dd ADDR
#end
#
#
#define datawin
# if ($64BITS == 1)
#    if ((($rsi >> 0x18) == 0x40) || (($rsi >> 0x18) == 0x08) || (($rsi >> 0x18) == 0xBF))
#        set $data_addr = $rsi
#    else
#        if ((($rdi >> 0x18) == 0x40) || (($rdi >> 0x18) == 0x08) || (($rdi >> 0x18) == 0xBF))
#            set $data_addr = $rdi
#        else
#            if ((($rax >> 0x18) == 0x40) || (($rax >> 0x18) == 0x08) || (($rax >> 0x18) == 0xBF))
#                set $data_addr = $rax
#            else
#                set $data_addr = $rsp
#            end
#        end
#    end
#
# else
#    if ((($esi >> 0x18) == 0x40) || (($esi >> 0x18) == 0x08) || (($esi >> 0x18) == 0xBF))
#        set $data_addr = $esi
#    else
#        if ((($edi >> 0x18) == 0x40) || (($edi >> 0x18) == 0x08) || (($edi >> 0x18) == 0xBF))
#            set $data_addr = $edi
#        else
#            if ((($eax >> 0x18) == 0x40) || (($eax >> 0x18) == 0x08) || (($eax >> 0x18) == 0xBF))
#                set $data_addr = $eax
#            else
#                set $data_addr = $esp
#            end
#        end
#    end
# end
#    ddump $CONTEXTSIZE_DATA
#end
#document datawin
#Display valid address from one register in data window.
#Registers to choose are: esi, edi, eax, or esp.
#end
#
#################################
###### ALERT ALERT ALERT ########
#################################
## Huge mess going here :) HAHA #
#################################
#define dumpjump
### grab the first two bytes from the instruction so we can determine the jump instruction
# set $_byte1 = *(unsigned char *)$pc
# set $_byte2 = *(unsigned char *)($pc+1)
### and now check what kind of jump we have (in case it's a jump instruction)
### I changed the flags routine to save the flag into a variable, so we don't need to repeat the process :) (search for "define flags")
#
### opcode 0x77: JA, JNBE (jump if CF=0 and ZF=0)
### opcode 0x0F87: JNBE, JA
# if ( ($_byte1 == 0x77) || ($_byte1 == 0x0F && $_byte2 == 0x87) )
#   # cf=0 and zf=0
#   if ($_cf_flag == 0 && $_zf_flag == 0)
#       echo \033[31m
#           printf "  Jump is taken (c=0 and z=0)"
#   else
#   # cf != 0 or zf != 0
#           echo \033[31m
#           printf "  Jump is NOT taken (c!=0 or z!=0)"
#   end
# end
#
### opcode 0x73: JAE, JNB, JNC (jump if CF=0)
### opcode 0x0F83: JNC, JNB, JAE (jump if CF=0)
# if ( ($_byte1 == 0x73) || ($_byte1 == 0x0F && $_byte2 == 0x83) )
#   # cf=0
#   if ($_cf_flag == 0)
#       echo \033[31m
#           printf "  Jump is taken (c=0)"
#   else
#   # cf != 0
#           echo \033[31m
#           printf "  Jump is NOT taken (c!=0)"
#   end
# end
#
### opcode 0x72: JB, JC, JNAE (jump if CF=1)
### opcode 0x0F82: JNAE, JB, JC
# if ( ($_byte1 == 0x72) || ($_byte1 == 0x0F && $_byte2 == 0x82) )
#   # cf=1
#   if ($_cf_flag == 1)
#       echo \033[31m
#           printf "  Jump is taken (c=1)"
#   else
#   # cf != 1
#           echo \033[31m
#           printf "  Jump is NOT taken (c!=1)"
#   end
# end
#
### opcode 0x76: JBE, JNA (jump if CF=1 or ZF=1)
### opcode 0x0F86: JBE, JNA
# if ( ($_byte1 == 0x76) || ($_byte1 == 0x0F && $_byte2 == 0x86) )
#   # cf=1 or zf=1
#   if (($_cf_flag == 1) || ($_zf_flag == 1))
#       echo \033[31m
#           printf "  Jump is taken (c=1 or z=1)"
#   else
#   # cf != 1 or zf != 1
#           echo \033[31m
#           printf "  Jump is NOT taken (c!=1 or z!=1)"
#   end
# end
#
### opcode 0xE3: JCXZ, JECXZ, JRCXZ (jump if CX=0 or ECX=0 or RCX=0)
# if ($_byte1 == 0xE3)
#   # cx=0 or ecx=0
#   if (($ecx == 0) || ($cx == 0))
#       echo \033[31m
#           printf "  Jump is taken (cx=0 or ecx=0)"
#   else
#   #
#           echo \033[31m
#           printf "  Jump is NOT taken (cx!=0 or ecx!=0)"
#   end
# end
#
### opcode 0x74: JE, JZ (jump if ZF=1)
### opcode 0x0F84: JZ, JE, JZ (jump if ZF=1)
# if ( ($_byte1 == 0x74) || ($_byte1 == 0x0F && $_byte2 == 0x84) )
# # ZF = 1
#   if ($_zf_flag == 1)
#           echo \033[31m
#           printf "  Jump is taken (z=1)"
#   else
# # ZF = 0
#           echo \033[31m
#           printf "  Jump is NOT taken (z!=1)"
#   end
# end
#
### opcode 0x7F: JG, JNLE (jump if ZF=0 and SF=OF)
### opcode 0x0F8F: JNLE, JG (jump if ZF=0 and SF=OF)
# if ( ($_byte1 == 0x7F) || ($_byte1 == 0x0F && $_byte2 == 0x8F) )
# # zf = 0 and sf = of
#   if (($_zf_flag == 0) && ($_sf_flag == $_of_flag))
#           echo \033[31m
#           printf "  Jump is taken (z=0 and s=o)"
#   else
# #
#           echo \033[31m
#           printf "  Jump is NOT taken (z!=0 or s!=o)"
#   end
# end
#
### opcode 0x7D: JGE, JNL (jump if SF=OF)
### opcode 0x0F8D: JNL, JGE (jump if SF=OF)
# if ( ($_byte1 == 0x7D) || ($_byte1 == 0x0F && $_byte2 == 0x8D) )
# # sf = of
#   if ($_sf_flag == $_of_flag)
#           echo \033[31m
#           printf "  Jump is taken (s=o)"
#   else
# #
#           echo \033[31m
#           printf "  Jump is NOT taken (s!=o)"
#   end
# end
#
### opcode: 0x7C: JL, JNGE (jump if SF != OF)
### opcode: 0x0F8C: JNGE, JL (jump if SF != OF)
# if ( ($_byte1 == 0x7C) || ($_byte1 == 0x0F && $_byte2 == 0x8C) )
# # sf != of
#   if ($_sf_flag != $_of_flag)
#           echo \033[31m
#           printf "  Jump is taken (s!=o)"
#   else
# #
#           echo \033[31m
#           printf "  Jump is NOT taken (s=o)"
#   end
# end
#
### opcode 0x7E: JLE, JNG (jump if ZF = 1 or SF != OF)
### opcode 0x0F8E: JNG, JLE (jump if ZF = 1 or SF != OF)
# if ( ($_byte1 == 0x7E) || ($_byte1 == 0x0F && $_byte2 == 0x8E) )
# # zf = 1 or sf != of
#   if (($_zf_flag == 1) || ($_sf_flag != $_of_flag))
#           echo \033[31m
#           printf "  Jump is taken (zf=1 or sf!=of)"
#   else
# #
#           echo \033[31m
#           printf "  Jump is NOT taken (zf!=1 or sf=of)"
#   end
# end
#
### opcode 0x75: JNE, JNZ (jump if ZF = 0)
### opcode 0x0F85: JNE, JNZ (jump if ZF = 0)
# if ( ($_byte1 == 0x75) || ($_byte1 == 0x0F && $_byte2 == 0x85) )
# # ZF = 0
#   if ($_zf_flag == 0)
#           echo \033[31m
#           printf "  Jump is taken (z=0)"
#   else
# # ZF = 1
#           echo \033[31m
#           printf "  Jump is NOT taken (z!=0)"
#   end
# end
#
### opcode 0x71: JNO (OF = 0)
### opcode 0x0F81: JNO (OF = 0)
# if ( ($_byte1 == 0x71) || ($_byte1 == 0x0F && $_byte2 == 0x81) )
# # OF = 0
#   if ($_of_flag == 0)
#           echo \033[31m
#           printf "  Jump is taken (o=0)"
#   else
# # OF != 0
#           echo \033[31m
#           printf "  Jump is NOT taken (o!=0)"
#   end
# end
#
### opcode 0x7B: JNP, JPO (jump if PF = 0)
### opcode 0x0F8B: JPO (jump if PF = 0)
# if ( ($_byte1 == 0x7B) || ($_byte1 == 0x0F && $_byte2 == 0x8B) )
# # PF = 0
#   if ($_pf_flag == 0)
#           echo \033[31m
#           printf "  Jump is NOT taken (p=0)"
#   else
# # PF != 0
#           echo \033[31m
#           printf "  Jump is taken (p!=0)"
#   end
# end
#
### opcode 0x79: JNS (jump if SF = 0)
### opcode 0x0F89: JNS (jump if SF = 0)
# if ( ($_byte1 == 0x79) || ($_byte1 == 0x0F && $_byte2 == 0x89) )
# # SF = 0
#   if ($_sf_flag == 0)
#           echo \033[31m
#           printf "  Jump is taken (s=0)"
#   else
# # SF != 0
#           echo \033[31m
#           printf "  Jump is NOT taken (s!=0)"
#   end
# end
#
### opcode 0x70: JO (jump if OF=1)
### opcode 0x0F80: JO (jump if OF=1)
# if ( ($_byte1 == 0x70) || ($_byte1 == 0x0F && $_byte2 == 0x80) )
# # OF = 1
#   if ($_of_flag == 1)
#       echo \033[31m
#           printf "  Jump is taken (o=1)"
#   else
# # OF != 1
#           echo \033[31m
#           printf "  Jump is NOT taken (o!=1)"
#   end
# end
#
### opcode 0x7A: JP, JPE (jump if PF=1)
### opcode 0x0F8A: JP, JPE (jump if PF=1)
# if ( ($_byte1 == 0x7A) || ($_byte1 == 0x0F && $_byte2 == 0x8A) )
# # PF = 1
#   if ($_pf_flag == 1)
#           echo \033[31m
#           printf "  Jump is taken (p=1)"
#   else
# # PF = 0
#           echo \033[31m
#           printf "  Jump is NOT taken (p!=1)"
#   end
# end
#
### opcode 0x78: JS (jump if SF=1)
### opcode 0x0F88: JS (jump if SF=1)
# if ( ($_byte1 == 0x78) || ($_byte1 == 0x0F && $_byte2 == 0x88) )
# # SF = 1
#   if ($_sf_flag == 1)
#           echo \033[31m
#           printf "  Jump is taken (s=1)"
#   else
# # SF != 1
#           echo \033[31m
#           printf "  Jump is NOT taken (s!=1)"
#   end
# end
#
## end of dumpjump function
#end
#document dumpjump
#Display if conditional jump will be taken or not
#end
#
## _______________process context______________
## initialize variable
#set $displayobjectivec = 0
#
#define context
#    echo \033[34m
#    if $SHOWCPUREGISTERS == 1
#       printf "----------------------------------------"
#       printf "----------------------------------"
#       if ($64BITS == 1)
#        printf "---------------------------------------------"
#       end
#       echo \033[34m\033[1m
#       printf "[regs]\n"
#       echo \033[0m
#       reg
#       echo \033[36m
#    end
#    if $SHOWSTACK == 1
#   echo \033[34m
#       if ($64BITS == 1)
#        printf "[0x%04X:0x%016lX]", $ss, $rsp
#       else
#        printf "[0x%04X:0x%08X]", $ss, $esp
#       end
#        echo \033[34m
#       printf "-------------------------"
#       printf "-----------------------------"
#       if ($64BITS == 1)
#        printf "-------------------------------------"
#       end
#   echo \033[34m\033[1m
#   printf "[stack]\n"
#       echo \033[0m
#       set $context_i = $CONTEXTSIZE_STACK
#       while ($context_i > 0)
#            set $context_t = $sp + 0x10 * ($context_i - 1)
#            hexdump $context_t
#            set $context_i--
#       end
#    end
## show the objective C message being passed to msgSend
#   if $SHOWOBJECTIVEC == 1
##FIXME64
## What a piece of crap that's going on here :)
## detect if it's the correct opcode we are searching for
#       set $__byte1 = *(unsigned char *)$pc
#       set $__byte = *(int *)$pc
##
#       if ($__byte == 0x4244489)
#           set $objectivec = $eax
#           set $displayobjectivec = 1
#       end
##
#       if ($__byte == 0x4245489)
#           set $objectivec = $edx
#           set $displayobjectivec = 1
#       end
##
#       if ($__byte == 0x4244c89)
#           set $objectivec = $edx
#           set $displayobjectivec = 1
#       end
## and now display it or not (we have no interest in having the info displayed after the call)
#       if $__byte1 == 0xE8
#           if $displayobjectivec == 1
#               echo \033[34m
#               printf "--------------------------------------------------------------------"
#               if ($64BITS == 1)
#                printf "---------------------------------------------"
#               end
#           echo \033[34m\033[1m
#           printf "[ObjectiveC]\n"
#               echo \033[0m\033[30m
#               x/s $objectivec
#           end
#           set $displayobjectivec = 0
#       end
#       if $displayobjectivec == 1
#           echo \033[34m
#           printf "--------------------------------------------------------------------"
#           if ($64BITS == 1)
#            printf "---------------------------------------------"
#           end
#       echo \033[34m\033[1m
#       printf "[ObjectiveC]\n"
#           echo \033[0m\033[30m
#           x/s $objectivec
#       end
#   end
#    echo \033[0m
## and this is the end of this little crap
#
#    if $SHOWDATAWIN == 1
#    datawin
#    end
#
#    echo \033[34m
#    printf "--------------------------------------------------------------------------"
#    if ($64BITS == 1)
#    printf "---------------------------------------------"
#   end
#    echo \033[34m\033[1m
#    printf "[code]\n"
#    echo \033[0m
#    set $context_i = $CONTEXTSIZE_CODE
#    if($context_i > 0)
#        x /i $pc
#        set $context_i--
#    end
#    while ($context_i > 0)
#        x /i
#        set $context_i--
#    end
#    echo \033[34m
#    printf "----------------------------------------"
#    printf "----------------------------------------"
#    if ($64BITS == 1)
#     printf "---------------------------------------------\n"
#   else
#    printf "\n"
#   end
#
#    echo \033[0m
#end
#document context
#Print context window, i.e. regs, stack, ds:esi and disassemble cs:eip.
#end
#
#
#define context-on
#    set $SHOW_CONTEXT = 1
#    printf "Displaying of context is now ON\n"
#end
#document context-on
#Enable display of context on every program break.
#end
#
#
#define context-off
#    set $SHOW_CONTEXT = 0
#    printf "Displaying of context is now OFF\n"
#end
#document context-off
#Disable display of context on every program break.
#end
#
#
## _______________process control______________
#define n
#    if $argc == 0
#        nexti
#    end
#    if $argc == 1
#        nexti $arg0
#    end
#    if $argc > 1
#        help n
#    end
#end
#document n
#Step one instruction, but proceed through subroutine calls.
#If NUM is given, then repeat it NUM times or till program stops.
#This is alias for nexti.
#Usage: n <NUM>
#end
#
#
#define go
#    if $argc == 0
#        stepi
#    end
#    if $argc == 1
#        stepi $arg0
#    end
#    if $argc > 1
#        help go
#    end
#end
#document go
#Step one instruction exactly.
#If NUM is given, then repeat it NUM times or till program stops.
#This is alias for stepi.
#Usage: go <NUM>
#end
#
#
#define pret
#    finish
#end
#document pret
#Execute until selected stack frame returns (step out of current call).
#Upon return, the value returned is printed and put in the value history.
#end
#
#
#define init
#    set $SHOW_NEST_INSN = 0
#    tbreak _init
#    r
#end
#document init
#Run program and break on _init().
#end
#
#
#define start
#    set $SHOW_NEST_INSN = 0
#    tbreak _start
#    r
#end
#document start
#Run program and break on _start().
#end
#
#
#define sstart
#    set $SHOW_NEST_INSN = 0
#    tbreak __libc_start_main
#    r
#end
#document sstart
#Run program and break on __libc_start_main().
#Useful for stripped executables.
#end
#
#
#define main
#    set $SHOW_NEST_INSN = 0
#    tbreak main
#    r
#end
#document main
#Run program and break on main().
#end
#
## FIXME64
##### WARNING ! WARNING !!
##### More more messy stuff starting !!!
##### I was thinking about how to do this and then it ocurred me that it could be as simple as this ! :)
#define stepo
### we know that an opcode starting by 0xE8 has a fixed length
### for the 0xFF opcodes, we can enumerate what is possible to have
## first we grab the first 3 bytes from the current program counter
# set $_byte1 = *(unsigned char *)$pc
# set $_byte2 = *(unsigned char *)($pc+1)
# set $_byte3 = *(unsigned char *)($pc+2)
## and start the fun
## if it's a 0xE8 opcode, the total instruction size will be 5 bytes
## so we can simply calculate the next address and use a temporary breakpoint ! Voila :)
# set $_nextaddress = 0
# # this one is the must useful for us !!!
# if ($_byte1 == 0xE8)
#  set $_nextaddress = $pc + 0x5
# else
#   # just other cases we might be interested in... maybe this should be removed since the 0xE8 opcode is the one we will use more
#   # this is a big fucking mess and can be improved for sure :) I don't like the way it is ehehehe
#   if ($_byte1 == 0xFF)
#    # call *%eax (0xFFD0) || call *%edx (0xFFD2) || call *(%ecx) (0xFFD1) || call (%eax) (0xFF10) || call *%esi (0xFFD6) || call *%ebx (0xFFD3)
#    if ($_byte2 == 0xD0 || $_byte2 == 0xD1 || $_byte2 == 0xD2 || $_byte2 == 0xD3 || $_byte2 == 0xD6 || $_byte2 == 0x10 )
#     set $_nextaddress = $pc + 0x2
#    end
#    # call *0x??(%ebp) (0xFF55??) || call *0x??(%esi) (0xFF56??) || call *0x??(%edi) (0xFF5F??) || call *0x??(%ebx)
#    # call *0x??(%edx) (0xFF52??) || call *0x??(%ecx) (0xFF51??) || call *0x??(%edi) (0xFF57??) || call *0x??(%eax) (0xFF50??)
#    if ($_byte2 == 0x55 || $_byte2 == 0x56 || $_byte2 == 0x5F || $_byte2 == 0x53 || $_byte2 == 0x52 || $_byte2 == 0x51 || $_byte2 == 0x57 || $_byte2 == 0x50)
#     set $_nextaddress = $pc + 0x3
#    end
#    # call *0x????????(%ebx) (0xFF93????????) ||
#    if ($_byte2 == 0x93 || $_byte2 == 0x94 || $_byte2 == 0x90 || $_byte2 == 0x92)
#     set $_nextaddress = $pc + 6
#    end
#    # call *0x????????(%ebx,%eax,4) (0xFF94??????????)
#    if ($_byte2 == 0x94)
#     set $_nextaddress = $pc + 7
#    end
#   end
# end
## if we have found a call to bypass we set a temporary breakpoint on next instruction and continue
# if ($_nextaddress != 0)
#  tbreak *$_nextaddress
#  continue
## else we just single step
# else
#  nexti
# end
## end of stepo function
#end
#document stepo
#Step over calls (interesting to bypass the ones to msgSend)
#This function will set a temporary breakpoint on next instruction after the call so the call will be bypassed
#You can safely use it instead nexti or n since it will single step code if it's not a call instruction (unless you want to go into the call function)
#end
#
#
#
## _______________eflags commands______________
#define cfc
#    if ($eflags & 1)
#        set $eflags = $eflags&~0x1
#    else
#        set $eflags = $eflags|0x1
#    end
#end
#document cfc
#Change Carry Flag.
#end
#
#
#define cfp
#    if (($eflags >> 2) & 1)
#        set $eflags = $eflags&~0x4
#    else
#        set $eflags = $eflags|0x4
#    end
#end
#document cfp
#Change Parity Flag.
#end
#
#
#define cfa
#    if (($eflags >> 4) & 1)
#        set $eflags = $eflags&~0x10
#    else
#        set $eflags = $eflags|0x10
#    end
#end
#document cfa
#Change Auxiliary Carry Flag.
#end
#
#
#define cfz
#    if (($eflags >> 6) & 1)
#        set $eflags = $eflags&~0x40
#    else
#        set $eflags = $eflags|0x40
#    end
#end
#document cfz
#Change Zero Flag.
#end
#
#
#define cfs
#    if (($eflags >> 7) & 1)
#        set $eflags = $eflags&~0x80
#    else
#        set $eflags = $eflags|0x80
#    end
#end
#document cfs
#Change Sign Flag.
#end
#
#
#define cft
#    if (($eflags >>8) & 1)
#        set $eflags = $eflags&~0x100
#    else
#        set $eflags = $eflags|0x100
#    end
#end
#document cft
#Change Trap Flag.
#end
#
#
#define cfi
#    if (($eflags >> 9) & 1)
#        set $eflags = $eflags&~0x200
#    else
#        set $eflags = $eflags|0x200
#    end
#end
#document cfi
#Change Interrupt Flag.
#Only privileged applications (usually the OS kernel) may modify IF.
#This only applies to protected mode (real mode code may always modify IF).
#end
#
#
#define cfd
#    if (($eflags >>0xA) & 1)
#        set $eflags = $eflags&~0x400
#    else
#        set $eflags = $eflags|0x400
#    end
#end
#document cfd
#Change Direction Flag.
#end
#
#
#define cfo
#    if (($eflags >> 0xB) & 1)
#        set $eflags = $eflags&~0x800
#    else
#        set $eflags = $eflags|0x800
#    end
#end
#document cfo
#Change Overflow Flag.
#end
#
#
#
## ____________________patch___________________
#define nop
#    if ($argc > 2 || $argc == 0)
#        help nop
#    end
#
#    if ($argc == 1)
#       set *(unsigned char *)$arg0 = 0x90
#    else
#   set $addr = $arg0
#   while ($addr < $arg1)
#       set *(unsigned char *)$addr = 0x90
#       set $addr = $addr + 1
#   end
#    end
#end
#document nop
#Usage: nop ADDR1 [ADDR2]
#Patch a single byte at address ADDR1, or a series of bytes between ADDR1 and ADDR2 to a NOP (0x90) instruction.
#
#end
#
#
#define null
#    if ( $argc >2 || $argc == 0)
#        help null
#    end
#
#    if ($argc == 1)
#   set *(unsigned char *)$arg0 = 0
#    else
#   set $addr = $arg0
#   while ($addr < $arg1)
#           set *(unsigned char *)$addr = 0
#       set $addr = $addr +1
#   end
#    end
#end
#document null
#Usage: null ADDR1 [ADDR2]
#Patch a single byte at address ADDR1 to NULL (0x00), or a series of bytes between ADDR1 and ADDR2.
#
#end
#
#
#define int3
#    if $argc != 1
#        help int3
#    else
#        set *(unsigned char *)$arg0 = 0xCC
#    end
#end
#document int3
#Patch byte at address ADDR to an INT3 (0xCC) instruction.
#Usage: int3 ADDR
#end
#
#
#
#
## ____________________cflow___________________
#define print_insn_type
#    if $argc != 1
#        help print_insn_type
#    else
#        if ($arg0 < 0 || $arg0 > 5)
#            printf "UNDEFINED/WRONG VALUE"
#        end
#        if ($arg0 == 0)
#            printf "UNKNOWN"
#        end
#        if ($arg0 == 1)
#            printf "JMP"
#        end
#        if ($arg0 == 2)
#            printf "JCC"
#        end
#        if ($arg0 == 3)
#            printf "CALL"
#        end
#        if ($arg0 == 4)
#            printf "RET"
#        end
#        if ($arg0 == 5)
#            printf "INT"
#        end
#    end
#end
#document print_insn_type
#Print human-readable mnemonic for the instruction type (usually $INSN_TYPE).
#Usage: print_insn_type INSN_TYPE_NUMBER
#end
#
#
#define get_insn_type
#    if $argc != 1
#        help get_insn_type
#    else
#        set $INSN_TYPE = 0
#        set $_byte1 = *(unsigned char *)$arg0
#        if ($_byte1 == 0x9A || $_byte1 == 0xE8)
#            # "call"
#            set $INSN_TYPE = 3
#        end
#        if ($_byte1 >= 0xE9 && $_byte1 <= 0xEB)
#            # "jmp"
#            set $INSN_TYPE = 1
#        end
#        if ($_byte1 >= 0x70 && $_byte1 <= 0x7F)
#            # "jcc"
#            set $INSN_TYPE = 2
#        end
#        if ($_byte1 >= 0xE0 && $_byte1 <= 0xE3 )
#            # "jcc"
#            set $INSN_TYPE = 2
#        end
#        if ($_byte1 == 0xC2 || $_byte1 == 0xC3 || $_byte1 == 0xCA || \
#            $_byte1 == 0xCB || $_byte1 == 0xCF)
#            # "ret"
#            set $INSN_TYPE = 4
#        end
#        if ($_byte1 >= 0xCC && $_byte1 <= 0xCE)
#            # "int"
#            set $INSN_TYPE = 5
#        end
#        if ($_byte1 == 0x0F )
#            # two-byte opcode
#            set $_byte2 = *(unsigned char *)($arg0 + 1)
#            if ($_byte2 >= 0x80 && $_byte2 <= 0x8F)
#                # "jcc"
#                set $INSN_TYPE = 2
#            end
#        end
#        if ($_byte1 == 0xFF)
#            # opcode extension
#            set $_byte2 = *(unsigned char *)($arg0 + 1)
#            set $_opext = ($_byte2 & 0x38)
#            if ($_opext == 0x10 || $_opext == 0x18)
#                # "call"
#                set $INSN_TYPE = 3
#            end
#            if ($_opext == 0x20 || $_opext == 0x28)
#                # "jmp"
#                set $INSN_TYPE = 1
#            end
#        end
#    end
#end
#document get_insn_type
#Recognize instruction type at address ADDR.
#Take address ADDR and set the global $INSN_TYPE variable to
#0, 1, 2, 3, 4, 5 if the instruction at that address is
#unknown, a jump, a conditional jump, a call, a return, or an interrupt.
#Usage: get_insn_type ADDR
#end
#
#
#define step_to_call
#    set $_saved_ctx = $SHOW_CONTEXT
#    set $SHOW_CONTEXT = 0
#    set $SHOW_NEST_INSN = 0
#
#    set logging file /dev/null
#    set logging redirect on
#    set logging on
#
#    set $_cont = 1
#    while ($_cont > 0)
#        stepi
#        get_insn_type $pc
#        if ($INSN_TYPE == 3)
#            set $_cont = 0
#        end
#    end
#
#    set logging off
#
#    if ($_saved_ctx > 0)
#        context
#    end
#
#    set $SHOW_CONTEXT = $_saved_ctx
#    set $SHOW_NEST_INSN = 0
#
#    set logging file ~/gdb.txt
#    set logging redirect off
#    set logging on
#
#    printf "step_to_call command stopped at:\n  "
#    x/i $pc
#    printf "\n"
#    set logging off
#
#end
#document step_to_call
#Single step until a call instruction is found.
#Stop before the call is taken.
#Log is written into the file ~/gdb.txt.
#end
#
#
#define trace_calls
#
#    printf "Tracing...please wait...\n"
#
#    set $_saved_ctx = $SHOW_CONTEXT
#    set $SHOW_CONTEXT = 0
#    set $SHOW_NEST_INSN = 0
#    set $_nest = 1
#    set listsize 0
#
#    set logging overwrite on
#    set logging file ~/gdb_trace_calls.txt
#    set logging on
#    set logging off
#    set logging overwrite off
#
#    while ($_nest > 0)
#        get_insn_type $pc
#        # handle nesting
#        if ($INSN_TYPE == 3)
#            set $_nest = $_nest + 1
#        else
#            if ($INSN_TYPE == 4)
#                set $_nest = $_nest - 1
#            end
#        end
#        # if a call, print it
#        if ($INSN_TYPE == 3)
#            set logging file ~/gdb_trace_calls.txt
#            set logging redirect off
#            set logging on
#
#            set $x = $_nest - 2
#            while ($x > 0)
#                printf "\t"
#                set $x = $x - 1
#            end
#            x/i $pc
#        end
#
#        set logging off
#        set logging file /dev/null
#        set logging redirect on
#        set logging on
#        stepi
#        set logging redirect off
#        set logging off
#    end
#
#    set $SHOW_CONTEXT = $_saved_ctx
#    set $SHOW_NEST_INSN = 0
#
#    printf "Done, check ~/gdb_trace_calls.txt\n"
#end
#document trace_calls
#Create a runtime trace of the calls made by target.
#Log overwrites(!) the file ~/gdb_trace_calls.txt.
#end
#
#
#define trace_run
#
#    printf "Tracing...please wait...\n"
#
#    set $_saved_ctx = $SHOW_CONTEXT
#    set $SHOW_CONTEXT = 0
#    set $SHOW_NEST_INSN = 1
#    set logging overwrite on
#    set logging file ~/gdb_trace_run.txt
#    set logging redirect on
#    set logging on
#    set $_nest = 1
#
#    while ( $_nest > 0 )
#
#        get_insn_type $pc
#        # jmp, jcc, or cll
#        if ($INSN_TYPE == 3)
#            set $_nest = $_nest + 1
#        else
#            # ret
#            if ($INSN_TYPE == 4)
#                set $_nest = $_nest - 1
#            end
#        end
#        stepi
#    end
#
#    printf "\n"
#
#    set $SHOW_CONTEXT = $_saved_ctx
#    set $SHOW_NEST_INSN = 0
#    set logging redirect off
#    set logging off
#
#    # clean up trace file
#    shell  grep -v ' at ' ~/gdb_trace_run.txt > ~/gdb_trace_run.1
#    shell  grep -v ' in ' ~/gdb_trace_run.1 > ~/gdb_trace_run.txt
#    shell  rm -f ~/gdb_trace_run.1
#    printf "Done, check ~/gdb_trace_run.txt\n"
#end
#document trace_run
#Create a runtime trace of target.
#Log overwrites(!) the file ~/gdb_trace_run.txt.
#end
#
#
#
#
## ____________________misc____________________
#define hook-stop
#
#    # this makes 'context' be called at every BP/step
#    if ($SHOW_CONTEXT > 0)
#        context
#    end
#    if ($SHOW_NEST_INSN > 0)
#        set $x = $_nest
#        while ($x > 0)
#            printf "\t"
#            set $x = $x - 1
#        end
#    end
#end
#document hook-stop
#!!! FOR INTERNAL USE ONLY - DO NOT CALL !!!
#end
#
## original by Tavis Ormandy (http://my.opera.com/taviso/blog/index.dml/tag/gdb) (great fix!)
## modified to work with Mac OS X by fG!
## seems nasm shipping with Mac OS X has problems accepting input from stdin or heredoc
## input is read into a variable and sent to a temporary file which nasm can read
#define assemble
# # dont enter routine again if user hits enter
# dont-repeat
# if ($argc)
#  if (*$arg0 = *$arg0)
#    # check if we have a valid address by dereferencing it,
#    # if we havnt, this will cause the routine to exit.
#  end
#  printf "Instructions will be written to %#x.\n", $arg0
# else
#  printf "Instructions will be written to stdout.\n"
# end
# printf "Type instructions, one per line."
# echo \033[1m
# printf " Do not forget to use NASM assembler syntax!\n"
# echo \033[0m
# printf "End with a line saying just \"end\".\n"
# if ($argc)
#  # argument specified, assemble instructions into memory at address specified.
#  shell ASMOPCODE="$(while read -ep '>' r && test "$r" != end ; do echo -E "$r"; done)" ; FILENAME=$RANDOM; \
#   echo -e "BITS 32\n$ASMOPCODE" >/tmp/$FILENAME ; /usr/bin/nasm -f bin -o /dev/stdout /tmp/$FILENAME | /usr/bin/hexdump -ve '1/1 "set *((unsigned char *) $arg0 + %#2_ax) = %#02x\n"' >/tmp/gdbassemble ; /bin/rm -f /tmp/$FILENAME
#  source /tmp/gdbassemble
#  # all done. clean the temporary file
#  shell /bin/rm -f /tmp/gdbassemble
# else
#  # no argument, assemble instructions to stdout
#  shell ASMOPCODE="$(while read -ep '>' r && test "$r" != end ; do echo -E "$r"; done)" ; FILENAME=$RANDOM; \
#   echo -e "BITS 32\n$ASMOPCODE" >/tmp/$FILENAME ; /usr/bin/nasm -f bin -o /dev/stdout /tmp/$FILENAME | /usr/bin/ndisasm -i -b32 /dev/stdin ; /bin/rm -f /tmp/$FILENAME
# end
#end
#document assemble
#Assemble instructions using nasm.
#Type a line containing "end" to indicate the end.
#If an address is specified, insert/modify instructions at that address.
#If no address is specified, assembled instructions are printed to stdout.
#Use the pseudo instruction "org ADDR" to set the base address.
#end
#
#define assemble_gas
#    printf "\nType code to assemble and hit Ctrl-D when finished.\n"
#    printf "You must use GNU assembler (AT&T) syntax.\n"
#
#    shell filename=$(mktemp); \
#          binfilename=$(mktemp); \
#          echo -e "Writing into: ${filename}\n"; \
#          cat > $filename; echo ""; \
#          as -o $binfilename < $filename; \
#          objdump -d -j .text $binfilename; \
#          rm -f $binfilename; \
#          rm -f $filename; \
#          echo -e "temporaly files deleted.\n"
#end
#document assemble_gas
#Assemble instructions to binary opcodes. Uses GNU as and objdump.
#Usage: assemble_gas
#end
#
#
#define dump_hexfile
#    dump ihex memory $arg0 $arg1 $arg2
#end
#document dump_hexfile
#Write a range of memory to a file in Intel ihex (hexdump) format.
#The range is specified by ADDR1 and ADDR2 addresses.
#Usage: dump_hexfile FILENAME ADDR1 ADDR2
#end
#
#
#define dump_binfile
#    dump memory $arg0 $arg1 $arg2
#end
#document dump_binfile
#Write a range of memory to a binary file.
#The range is specified by ADDR1 and ADDR2 addresses.
#Usage: dump_binfile FILENAME ADDR1 ADDR2
#end
#
#
#define cls
#    shell clear
#end
#document cls
#Clear screen.
#end
#
## _________________user tips_________________
## The 'tips' command is used to provide tutorial-like info to the user
#define tips
#    printf "Tip Topic Commands:\n"
#    printf "\ttip_display : Automatically display values on each break\n"
#    printf "\ttip_patch   : Patching binaries\n"
#    printf "\ttip_strip   : Dealing with stripped binaries\n"
#    printf "\ttip_syntax  : AT&T vs Intel syntax\n"
#end
#document tips
#Provide a list of tips from users on various topics.
#end
#
#
#define tip_patch
#    printf "\n"
#    printf "                   PATCHING MEMORY\n"
#    printf "Any address can be patched using the 'set' command:\n"
#    printf "\t`set ADDR = VALUE` \te.g. `set *0x8049D6E = 0x90`\n"
#    printf "\n"
#    printf "                 PATCHING BINARY FILES\n"
#    printf "Use `set write` in order to patch the target executable\n"
#    printf "directly, instead of just patching memory\n"
#    printf "\t`set write on` \t`set write off`\n"
#    printf "Note that this means any patches to the code or data segments\n"
#    printf "will be written to the executable file\n"
#    printf "When either of these commands has been issued,\n"
#    printf "the file must be reloaded.\n"
#    printf "\n"
#end
#document tip_patch
#Tips on patching memory and binary files.
#end
#
#
#define tip_strip
#    printf "\n"
#    printf "             STOPPING BINARIES AT ENTRY POINT\n"
#    printf "Stripped binaries have no symbols, and are therefore tough to\n"
#    printf "start automatically. To debug a stripped binary, use\n"
#    printf "\tinfo file\n"
#    printf "to get the entry point of the file\n"
#    printf "The first few lines of output will look like this:\n"
#    printf "\tSymbols from '/tmp/a.out'\n"
#    printf "\tLocal exec file:\n"
#    printf "\t        `/tmp/a.out', file type elf32-i386.\n"
#    printf "\t        Entry point: 0x80482e0\n"
#    printf "Use this entry point to set an entry point:\n"
#    printf "\t`tbreak *0x80482e0`\n"
#    printf "The breakpoint will delete itself after the program stops as\n"
#    printf "the entry point\n"
#    printf "\n"
#end
#document tip_strip
#Tips on dealing with stripped binaries.
#end
#
#
#define tip_syntax
#    printf "\n"
#    printf "\t    INTEL SYNTAX                        AT&T SYNTAX\n"
#    printf "\tmnemonic dest, src, imm            mnemonic src, dest, imm\n"
#    printf "\t[base+index*scale+disp]            disp(base, index, scale)\n"
#    printf "\tregister:      eax                 register:      %%eax\n"
#    printf "\timmediate:     0xFF                immediate:     $0xFF\n"
#    printf "\tdereference:   [addr]              dereference:   addr(,1)\n"
#    printf "\tabsolute addr: addr                absolute addr: *addr\n"
#    printf "\tbyte insn:     mov byte ptr        byte insn:     movb\n"
#    printf "\tword insn:     mov word ptr        word insn:     movw\n"
#    printf "\tdword insn:    mov dword ptr       dword insn:    movd\n"
#    printf "\tfar call:      call far            far call:      lcall\n"
#    printf "\tfar jump:      jmp far             far jump:      ljmp\n"
#    printf "\n"
#    printf "Note that order of operands in reversed, and that AT&T syntax\n"
#    printf "requires that all instructions referencing memory operands \n"
#    printf "use an operand size suffix (b, w, d, q)\n"
#    printf "\n"
#end
#document tip_syntax
#Summary of Intel and AT&T syntax differences.
#end
#
#
#define tip_display
#    printf "\n"
#    printf "Any expression can be set to automatically be displayed every time\n"
#    printf "the target stops. The commands for this are:\n"
#    printf "\t`display expr'     : automatically display expression 'expr'\n"
#    printf "\t`display'          : show all displayed expressions\n"
#    printf "\t`undisplay num'    : turn off autodisplay for expression # 'num'\n"
#    printf "Examples:\n"
#    printf "\t`display/x *(int *)$esp`      : print top of stack\n"
#    printf "\t`display/x *(int *)($ebp+8)`  : print first parameter\n"
#    printf "\t`display (char *)$esi`        : print source string\n"
#    printf "\t`display (char *)$edi`        : print destination string\n"
#    printf "\n"
#end
#document tip_display
#Tips on automatically displaying values when a program stops.
#end
#
## bunch of semi-useless commands
#
## enable and disable shortcuts for stop-on-solib-events fantastic trick!
#define enablesolib
#   set stop-on-solib-events 1
#end
#document enablesolib
#Shortcut to enable stop-on-solib-events trick!
#end
#
#define disablesolib
#   set stop-on-solib-events 0
#end
#document disablesolib
#Shortcut to disable stop-on-solib-events trick!
#end
#
## enable commands for different displays
#define enableobjectivec
#   set $SHOWOBJECTIVEC = 1
#end
#document enableobjectivec
#Enable display of objective-c information in the context window
#end
#
#define enablecpuregisters
#   set $SHOWCPUREGISTERS = 1
#end
#document enablecpuregisters
#Enable display of cpu registers in the context window
#end
#
#define enablestack
#   set $SHOWSTACK = 1
#end
#document enablestack
#Enable display of stack in the context window
#end
#
#define enabledatawin
#   set $SHOWDATAWIN = 1
#end
#document enabledatawin
#Enable display of data window in the context window
#end
#
## disable commands for different displays
#define disableobjectivec
#   set $SHOWOBJECTIVEC = 0
#end
#document disableobjectivec
#Disable display of objective-c information in the context window
#end
#
#define disablecpuregisters
#   set $SHOWCPUREGISTERS = 0
#end
#document disablecpuregisters
#Disable display of cpu registers in the context window
#end
#
#define disablestack
#   set $SHOWSTACK = 0
#end
#document disablestack
#Disable display of stack information in the context window
#end
#
#define disabledatawin
#   set $SHOWDATAWIN = 0
#end
#document disabledatawin
#Disable display of data window in the context window
#end
#
#define 32bits
#   set $64BITS = 0
#end
#document 32bits
#Set gdb to work with 32bits binaries
#end
#
#define 64bits
#   set $64BITS = 1
#end
#document 64bits
#Set gdb to work with 64bits binaries
#end
#
##EOF

#
#===============================================================
# ░█▀█░█▀▄░█▀▀░▀█▀░▀█▀░█░█░░░█▀█░█▀▄░▀█▀░█▀█░▀█▀░█▀▀░█▀▄░█▀▀
# ░█▀▀░█▀▄░█▀▀░░█░░░█░░░█░░░░█▀▀░█▀▄░░█░░█░█░░█░░█▀▀░█▀▄░▀▀█
# ░▀░░░▀░▀░▀▀▀░░▀░░░▀░░░▀░░░░▀░░░▀░▀░▀▀▀░▀░▀░░▀░░▀▀▀░▀░▀░▀▀▀
#===============================================================
#   STL GDB evaluators/views/utilities - 1.03
#
#   The new GDB commands:
#       are entirely non instrumental
#       do not depend on any "inline"(s) - e.g. size(), [], etc
#       are extremely tolerant to debugger settings
#
#   This file should be "included" in .gdbinit as following:
#   source stl-views.gdb or just paste it into your .gdbinit file
#
#   The following STL containers are currently supported:
#
#       std::vector<T> -- via pvector command
#       std::list<T> -- via plist or plist_member command
#       std::map<T,T> -- via pmap or pmap_member command
#       std::multimap<T,T> -- via pmap or pmap_member command
#       std::set<T> -- via pset command
#       std::multiset<T> -- via pset command
#       std::deque<T> -- via pdequeue command
#       std::stack<T> -- via pstack command
#       std::queue<T> -- via pqueue command
#       std::priority_queue<T> -- via ppqueue command
#       std::bitset<n> -- via pbitset command
#       std::string -- via pstring command
#       std::widestring -- via pwstring command
#
#   The end of this file contains (optional) C++ beautifiers
#   Make sure your debugger supports $argc
#
#   Simple GDB Macros writen by Dan Marinescu (H-PhD) - License GPL
#   Inspired by intial work of Tom Malnar,
#     Tony Novac (PhD) / Cornell / Stanford,
#     Gilad Mishne (PhD) and Many Many Others.
#   Contact: dan_c_marinescu@yahoo.com (Subject: STL)
#
#   Modified to work with g++ 4.3 by Anders Elton
#   Also added _member functions, that instead of printing the entire class in map, prints a member.



#
# std::vector<>
#

define pvector
    if $argc == 0
        help pvector
    else
        set $size = $arg0._M_impl._M_finish - $arg0._M_impl._M_start
        set $capacity = $arg0._M_impl._M_end_of_storage - $arg0._M_impl._M_start
        set $size_max = $size - 1
    end
    if $argc == 1
        set $i = 0
        while $i < $size
            printf "elem[%u]: ", $i
            p *($arg0._M_impl._M_start + $i)
            set $i++
        end
    end
    if $argc == 2
        set $idx = $arg1
        if $idx < 0 || $idx > $size_max
            printf "idx1, idx2 are not in acceptable range: [0..%u].\n", $size_max
        else
            printf "elem[%u]: ", $idx
            p *($arg0._M_impl._M_start + $idx)
        end
    end
    if $argc == 3
      set $start_idx = $arg1
      set $stop_idx = $arg2
      if $start_idx > $stop_idx
        set $tmp_idx = $start_idx
        set $start_idx = $stop_idx
        set $stop_idx = $tmp_idx
      end
      if $start_idx < 0 || $stop_idx < 0 || $start_idx > $size_max || $stop_idx > $size_max
        printf "idx1, idx2 are not in acceptable range: [0..%u].\n", $size_max
      else
        set $i = $start_idx
        while $i <= $stop_idx
            printf "elem[%u]: ", $i
            p *($arg0._M_impl._M_start + $i)
            set $i++
        end
      end
    end
    if $argc > 0
        printf "Vector size = %u\n", $size
        printf "Vector capacity = %u\n", $capacity
        printf "Element "
        whatis $arg0._M_impl._M_start
    end
end

document pvector
    Prints std::vector<T> information.
    Syntax: pvector <vector> <idx1> <idx2>
    Note: idx, idx1 and idx2 must be in acceptable range [0..<vector>.size()-1].
    Examples:
    pvector v - Prints vector content, size, capacity and T typedef
    pvector v 0 - Prints element[idx] from vector
    pvector v 1 2 - Prints elements in range [idx1..idx2] from vector
end

#
# std::list<>
#

define plist
    if $argc == 0
        help plist
    else
        set $head = &$arg0._M_impl._M_node
        set $current = $arg0._M_impl._M_node._M_next
        set $size = 0
        while $current != $head
            if $argc == 2
                printf "elem[%u]: ", $size
                p *($arg1*)($current + 1)
            end
            if $argc == 3
                if $size == $arg2
                    printf "elem[%u]: ", $size
                    p *($arg1*)($current + 1)
                end
            end
            set $current = $current._M_next
            set $size++
        end
        printf "List size = %u \n", $size
        if $argc == 1
            printf "List "
            whatis $arg0
            printf "Use plist <variable_name> <element_type> to see the elements in the list.\n"
        end
    end
end

document plist
    Prints std::list<T> information.
    Syntax: plist <list> <T> <idx>: Prints list size, if T defined all elements or just element at idx
    Examples:
    plist l - prints list size and definition
    plist l int - prints all elements and list size
    plist l int 2 - prints the third element in the list (if exists) and list size
end

define plist_member
    if $argc == 0
        help plist_member
    else
        set $head = &$arg0._M_impl._M_node
        set $current = $arg0._M_impl._M_node._M_next
        set $size = 0
        while $current != $head
            if $argc == 3
                printf "elem[%u]: ", $size
                p (*($arg1*)($current + 1)).$arg2
            end
            if $argc == 4
                if $size == $arg3
                    printf "elem[%u]: ", $size
                    p (*($arg1*)($current + 1)).$arg2
                end
            end
            set $current = $current._M_next
            set $size++
        end
        printf "List size = %u \n", $size
        if $argc == 1
            printf "List "
            whatis $arg0
            printf "Use plist_member <variable_name> <element_type> <member> to see the elements in the list.\n"
        end
    end
end

document plist_member
    Prints std::list<T> information.
    Syntax: plist <list> <T> <idx>: Prints list size, if T defined all elements or just element at idx
    Examples:
    plist_member l int member - prints all elements and list size
    plist_member l int member 2 - prints the third element in the list (if exists) and list size
end


#
# std::map and std::multimap
#

define pmap
    if $argc == 0
        help pmap
    else
        set $tree = $arg0
        set $i = 0
        set $node = $tree._M_t._M_impl._M_header._M_left
        set $end = $tree._M_t._M_impl._M_header
        set $tree_size = $tree._M_t._M_impl._M_node_count
        if $argc == 1
            printf "Map "
            whatis $tree
            printf "Use pmap <variable_name> <left_element_type> <right_element_type> to see the elements in the map.\n"
        end
        if $argc == 3
            while $i < $tree_size
                set $value = (void *)($node + 1)
                printf "elem[%u].left: ", $i
                p *($arg1*)$value
                set $value = $value + sizeof($arg1)
                printf "elem[%u].right: ", $i
                p *($arg2*)$value
                if $node._M_right != 0
                    set $node = $node._M_right
                    while $node._M_left != 0
                        set $node = $node._M_left
                    end
                else
                    set $tmp_node = $node._M_parent
                    while $node == $tmp_node._M_right
                        set $node = $tmp_node
                        set $tmp_node = $tmp_node._M_parent
                    end
                    if $node._M_right != $tmp_node
                        set $node = $tmp_node
                    end
                end
                set $i++
            end
        end
        if $argc == 4
            set $idx = $arg3
            set $ElementsFound = 0
            while $i < $tree_size
                set $value = (void *)($node + 1)
                if *($arg1*)$value == $idx
                    printf "elem[%u].left: ", $i
                    p *($arg1*)$value
                    set $value = $value + sizeof($arg1)
                    printf "elem[%u].right: ", $i
                    p *($arg2*)$value
                    set $ElementsFound++
                end
                if $node._M_right != 0
                    set $node = $node._M_right
                    while $node._M_left != 0
                        set $node = $node._M_left
                    end
                else
                    set $tmp_node = $node._M_parent
                    while $node == $tmp_node._M_right
                        set $node = $tmp_node
                        set $tmp_node = $tmp_node._M_parent
                    end
                    if $node._M_right != $tmp_node
                        set $node = $tmp_node
                    end
                end
                set $i++
            end
            printf "Number of elements found = %u\n", $ElementsFound
        end
        if $argc == 5
            set $idx1 = $arg3
            set $idx2 = $arg4
            set $ElementsFound = 0
            while $i < $tree_size
                set $value = (void *)($node + 1)
                set $valueLeft = *($arg1*)$value
                set $valueRight = *($arg2*)($value + sizeof($arg1))
                if $valueLeft == $idx1 && $valueRight == $idx2
                    printf "elem[%u].left: ", $i
                    p $valueLeft
                    printf "elem[%u].right: ", $i
                    p $valueRight
                    set $ElementsFound++
                end
                if $node._M_right != 0
                    set $node = $node._M_right
                    while $node._M_left != 0
                        set $node = $node._M_left
                    end
                else
                    set $tmp_node = $node._M_parent
                    while $node == $tmp_node._M_right
                        set $node = $tmp_node
                        set $tmp_node = $tmp_node._M_parent
                    end
                    if $node._M_right != $tmp_node
                        set $node = $tmp_node
                    end
                end
                set $i++
            end
            printf "Number of elements found = %u\n", $ElementsFound
        end
        printf "Map size = %u\n", $tree_size
    end
end

document pmap
    Prints std::map<TLeft and TRight> or std::multimap<TLeft and TRight> information. Works for std::multimap as well.
    Syntax: pmap <map> <TtypeLeft> <TypeRight> <valLeft> <valRight>: Prints map size, if T defined all elements or just element(s) with val(s)
    Examples:
    pmap m - prints map size and definition
    pmap m int int - prints all elements and map size
    pmap m int int 20 - prints the element(s) with left-value = 20 (if any) and map size
    pmap m int int 20 200 - prints the element(s) with left-value = 20 and right-value = 200 (if any) and map size
end


define pmap_member
    if $argc == 0
        help pmap_member
    else
        set $tree = $arg0
        set $i = 0
        set $node = $tree._M_t._M_impl._M_header._M_left
        set $end = $tree._M_t._M_impl._M_header
        set $tree_size = $tree._M_t._M_impl._M_node_count
        if $argc == 1
            printf "Map "
            whatis $tree
            printf "Use pmap <variable_name> <left_element_type> <right_element_type> to see the elements in the map.\n"
        end
        if $argc == 5
            while $i < $tree_size
                set $value = (void *)($node + 1)
                printf "elem[%u].left: ", $i
                p (*($arg1*)$value).$arg2
                set $value = $value + sizeof($arg1)
                printf "elem[%u].right: ", $i
                p (*($arg3*)$value).$arg4
                if $node._M_right != 0
                    set $node = $node._M_right
                    while $node._M_left != 0
                        set $node = $node._M_left
                    end
                else
                    set $tmp_node = $node._M_parent
                    while $node == $tmp_node._M_right
                        set $node = $tmp_node
                        set $tmp_node = $tmp_node._M_parent
                    end
                    if $node._M_right != $tmp_node
                        set $node = $tmp_node
                    end
                end
                set $i++
            end
        end
        if $argc == 6
            set $idx = $arg5
            set $ElementsFound = 0
            while $i < $tree_size
                set $value = (void *)($node + 1)
                if *($arg1*)$value == $idx
                    printf "elem[%u].left: ", $i
                    p (*($arg1*)$value).$arg2
                    set $value = $value + sizeof($arg1)
                    printf "elem[%u].right: ", $i
                    p (*($arg3*)$value).$arg4
                    set $ElementsFound++
                end
                if $node._M_right != 0
                    set $node = $node._M_right
                    while $node._M_left != 0
                        set $node = $node._M_left
                    end
                else
                    set $tmp_node = $node._M_parent
                    while $node == $tmp_node._M_right
                        set $node = $tmp_node
                        set $tmp_node = $tmp_node._M_parent
                    end
                    if $node._M_right != $tmp_node
                        set $node = $tmp_node
                    end
                end
                set $i++
            end
            printf "Number of elements found = %u\n", $ElementsFound
        end
        printf "Map size = %u\n", $tree_size
    end
end

document pmap_member
    Prints std::map<TLeft and TRight> or std::multimap<TLeft and TRight> information. Works for std::multimap as well.
    Syntax: pmap <map> <TtypeLeft> <TypeRight> <valLeft> <valRight>: Prints map size, if T defined all elements or just element(s) with val(s)
    Examples:
    pmap_member m class1 member1 class2 member2 - prints class1.member1 : class2.member2
    pmap_member m class1 member1 class2 member2 lvalue - prints class1.member1 : class2.member2 where class1 == lvalue
end


#
# std::set and std::multiset
#

define pset
    if $argc == 0
        help pset
    else
        set $tree = $arg0
        set $i = 0
        set $node = $tree._M_t._M_impl._M_header._M_left
        set $end = $tree._M_t._M_impl._M_header
        set $tree_size = $tree._M_t._M_impl._M_node_count
        if $argc == 1
            printf "Set "
            whatis $tree
            printf "Use pset <variable_name> <element_type> to see the elements in the set.\n"
        end
        if $argc == 2
            while $i < $tree_size
                set $value = (void *)($node + 1)
                printf "elem[%u]: ", $i
                p *($arg1*)$value
                if $node._M_right != 0
                    set $node = $node._M_right
                    while $node._M_left != 0
                        set $node = $node._M_left
                    end
                else
                    set $tmp_node = $node._M_parent
                    while $node == $tmp_node._M_right
                        set $node = $tmp_node
                        set $tmp_node = $tmp_node._M_parent
                    end
                    if $node._M_right != $tmp_node
                        set $node = $tmp_node
                    end
                end
                set $i++
            end
        end
        if $argc == 3
            set $idx = $arg2
            set $ElementsFound = 0
            while $i < $tree_size
                set $value = (void *)($node + 1)
                if *($arg1*)$value == $idx
                    printf "elem[%u]: ", $i
                    p *($arg1*)$value
                    set $ElementsFound++
                end
                if $node._M_right != 0
                    set $node = $node._M_right
                    while $node._M_left != 0
                        set $node = $node._M_left
                    end
                else
                    set $tmp_node = $node._M_parent
                    while $node == $tmp_node._M_right
                        set $node = $tmp_node
                        set $tmp_node = $tmp_node._M_parent
                    end
                    if $node._M_right != $tmp_node
                        set $node = $tmp_node
                    end
                end
                set $i++
            end
            printf "Number of elements found = %u\n", $ElementsFound
        end
        printf "Set size = %u\n", $tree_size
    end
end

document pset
    Prints std::set<T> or std::multiset<T> information. Works for std::multiset as well.
    Syntax: pset <set> <T> <val>: Prints set size, if T defined all elements or just element(s) having val
    Examples:
    pset s - prints set size and definition
    pset s int - prints all elements and the size of s
    pset s int 20 - prints the element(s) with value = 20 (if any) and the size of s
end



#
# std::dequeue
#

define pdequeue
    if $argc == 0
        help pdequeue
    else
        set $size = 0
        set $start_cur = $arg0._M_impl._M_start._M_cur
        set $start_last = $arg0._M_impl._M_start._M_last
        set $start_stop = $start_last
        while $start_cur != $start_stop
            p *$start_cur
            set $start_cur++
            set $size++
        end
        set $finish_first = $arg0._M_impl._M_finish._M_first
        set $finish_cur = $arg0._M_impl._M_finish._M_cur
        set $finish_last = $arg0._M_impl._M_finish._M_last
        if $finish_cur < $finish_last
            set $finish_stop = $finish_cur
        else
            set $finish_stop = $finish_last
        end
        while $finish_first != $finish_stop
            p *$finish_first
            set $finish_first++
            set $size++
        end
        printf "Dequeue size = %u\n", $size
    end
end

document pdequeue
    Prints std::dequeue<T> information.
    Syntax: pdequeue <dequeue>: Prints dequeue size, if T defined all elements
    Deque elements are listed "left to right" (left-most stands for front and right-most stands for back)
    Example:
    pdequeue d - prints all elements and size of d
end



#
# std::stack
#

define pstack
    if $argc == 0
        help pstack
    else
        set $start_cur = $arg0.c._M_impl._M_start._M_cur
        set $finish_cur = $arg0.c._M_impl._M_finish._M_cur
        set $size = $finish_cur - $start_cur
        set $i = $size - 1
        while $i >= 0
            p *($start_cur + $i)
            set $i--
        end
        printf "Stack size = %u\n", $size
    end
end

document pstack
    Prints std::stack<T> information.
    Syntax: pstack <stack>: Prints all elements and size of the stack
    Stack elements are listed "top to buttom" (top-most element is the first to come on pop)
    Example:
    pstack s - prints all elements and the size of s
end



#
# std::queue
#

define pqueue
    if $argc == 0
        help pqueue
    else
        set $start_cur = $arg0.c._M_impl._M_start._M_cur
        set $finish_cur = $arg0.c._M_impl._M_finish._M_cur
        set $size = $finish_cur - $start_cur
        set $i = 0
        while $i < $size
            p *($start_cur + $i)
            set $i++
        end
        printf "Queue size = %u\n", $size
    end
end

document pqueue
    Prints std::queue<T> information.
    Syntax: pqueue <queue>: Prints all elements and the size of the queue
    Queue elements are listed "top to bottom" (top-most element is the first to come on pop)
    Example:
    pqueue q - prints all elements and the size of q
end



#
# std::priority_queue
#

define ppqueue
    if $argc == 0
        help ppqueue
    else
        set $size = $arg0.c._M_impl._M_finish - $arg0.c._M_impl._M_start
        set $capacity = $arg0.c._M_impl._M_end_of_storage - $arg0.c._M_impl._M_start
        set $i = $size - 1
        while $i >= 0
            p *($arg0.c._M_impl._M_start + $i)
            set $i--
        end
        printf "Priority queue size = %u\n", $size
        printf "Priority queue capacity = %u\n", $capacity
    end
end

document ppqueue
    Prints std::priority_queue<T> information.
    Syntax: ppqueue <priority_queue>: Prints all elements, size and capacity of the priority_queue
    Priority_queue elements are listed "top to buttom" (top-most element is the first to come on pop)
    Example:
    ppqueue pq - prints all elements, size and capacity of pq
end



#
# std::bitset
#

define pbitset
    if $argc == 0
        help pbitset
    else
        p /t $arg0._M_w
    end
end

document pbitset
    Prints std::bitset<n> information.
    Syntax: pbitset <bitset>: Prints all bits in bitset
    Example:
    pbitset b - prints all bits in b
end



#
# std::string
#

define pstring
    if $argc == 0
        help pstring
    else
        printf "String \t\t\t= \"%s\"\n", $arg0._M_data()
        printf "String size/length \t= %u\n", $arg0._M_rep()._M_length
        printf "String capacity \t= %u\n", $arg0._M_rep()._M_capacity
        printf "String ref-count \t= %d\n", $arg0._M_rep()._M_refcount
    end
end

document pstring
    Prints std::string information.
    Syntax: pstring <string>
    Example:
    pstring s - Prints content, size/length, capacity and ref-count of string s
end

#
# std::wstring
#

define pwstring
    if $argc == 0
        help pwstring
    else
        call printf("WString \t\t= \"%ls\"\n", $arg0._M_data())
        printf "WString size/length \t= %u\n", $arg0._M_rep()._M_length
        printf "WString capacity \t= %u\n", $arg0._M_rep()._M_capacity
        printf "WString ref-count \t= %d\n", $arg0._M_rep()._M_refcount
    end
end

document pwstring
    Prints std::wstring information.
    Syntax: pwstring <wstring>
    Example:
    pwstring s - Prints content, size/length, capacity and ref-count of wstring s
end
