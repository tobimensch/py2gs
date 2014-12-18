README
======

py2gs is a simple bash script that converts python code to genie code.
> genie is like vala, but with syntax similar to python, it's integrated in the valac compiler

Please note that it's not a good transformation, it's just a very rough
transformation using sed and the code can't and isn't supposed to work after the tranformation.

py2gs really is nothing more than a starting point for porting python (Gtk oriented most likely) code
to genie code.
The differences between the languages are too big (static typing etc., properties and so on) to
possibly solve it with a few lines of sed and py2gs isn't more than that.
Furthermore not more than an hour has gone into py2gs development.

Given these restraints the following example transformation isn't that bad actually:
```
from gi.repository import Gtk

class StackWindow(Gtk.Window):

    def __init__(self):
        Gtk.Window.__init__(self, title="Stack Demo")
        self.set_border_width(10)

        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        self.add(vbox)

        stack = Gtk.Stack()
        stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT)
        stack.set_transition_duration(1000)
        
        checkbutton = Gtk.CheckButton("Click me!")
        stack.add_titled(checkbutton, "check", "Check Button")
        
        label = Gtk.Label()
        label.set_markup("<big>A fancy label</big>")
        stack.add_titled(label, "label", "A label")

        stack_switcher = Gtk.StackSwitcher()
        stack_switcher.set_stack(stack)
        vbox.pack_start(stack_switcher, True, True, 0)
        vbox.pack_start(stack, True, True, 0)

win = StackWindow()
win.connect("delete-event", Gtk.main_quit)
win.show_all()
Gtk.main()
```

will be tranformed into:
```
[indent=4]

class StackWindow : Gtk.Window

    init
        Gtk.Window.__init__( title="Stack Demo")
        set_border_width(10)

        var vbox = new Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        add(vbox)

        var stack = new Gtk.Stack()
        stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT)
        stack.set_transition_duration(1000)
        
        var checkbutton = new Gtk.CheckButton("Click me!")
        stack.add_titled(checkbutton, "check", "Check Button")
        
        var label = new Gtk.Label()
        label.set_markup("<big>A fancy label</big>")
        stack.add_titled(label, "label", "A label")

        var stack_switcher = new Gtk.StackSwitcher()
        stack_switcher.set_stack(stack)
        vbox.pack_start(stack_switcher, true, true, 0)
        vbox.pack_start(stack, true, true, 0)

var win = new StackWindow()
win.connect("delete-event", Gtk.main_quit)
win.show_all()
Gtk.main()
```

And with the following manual code changes it compiles and runs successfully:
```
[indent=4]

class StackWindow : Gtk.Window

    init
        //Gtk.Window.__init__( title="Stack Demo")
        set_border_width(10)

        var vbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 6)
        add(vbox)

        var stack = new Gtk.Stack()
        stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT)
        stack.set_transition_duration(1000)
        
        var checkbutton = new Gtk.CheckButton()
        checkbutton.label= "Click me!"
        stack.add_titled(checkbutton, "check", "Check Button")
        
        var label = new Gtk.Label("")
        label.set_markup("<big>A fancy label</big>")
        stack.add_titled(label, "label", "A label")

        var stack_switcher = new Gtk.StackSwitcher()
        stack_switcher.set_stack(stack)
        vbox.pack_start(stack_switcher, true, true, 0)
        vbox.pack_start(stack, true, true, 0)

init
    Gtk.init(ref args)
    var win = new StackWindow()
    win.destroy.connect(Gtk.main_quit)
    win.show_all()
    Gtk.main()

```

The changes that were needed to make this work are left as an exercise for the reader.

How to run py2gs
================

> It's a bash script tested on GNU/Linux. Patches to make it more universal are welcome!

rename py2gs.sh to py2gs and put it in your PATH

    py2gs myapp.py

The transformed code is sent to stdout.

    py2gs myapp.py > myapp.gs

Simply redirect stdout to put the code in a genie file.

What py2gs does and what it doesn't
===================================

Just look at the script, every line has a comment and it's short enough.

Is there room for improvement?
==============================

In principle a lot. Patches very welcome.

Examples:
 - Using pyropes to get static types of all variables and insert it in all the method declarations
 - transform connect calls to correct genie syntax
 - automatically create init/main
 - better constructors / initializing calls to base classes
 - bug fixes

Why?
====

I started a python gtk project and half-way into it I learned about genie. I'm very happy with python,
but the ability to compile to C and not to depend on python is also very appealing.
Python is the ideal prototyping language for me, but when I'm done with prototyping then genie might
be a good solution.

