coveragepy.vim
==============
A Vim plugin to help integrate Ned Batchelder's excellent `coverage.py` (see:
http://nedbatchelder.com/code/coverage/) tool into the editor.

Allows you to bring up a buffer with detailed information from a coverage
report command and mark each line in your source that is not being covered.

You can also use that buffer to navigate into files that have reported missing
statements and display the missed lines.

Optionally, you can also hide or display the marks as you make progress.

Installation
------------
If you have Tim Pope's Pathogen you only need to place the plugin directory
inside your bundle dir, otherwise it is a single file that should go into::

    vim/ftplugin/python/

Usage
=====
This plugin provides a single command: `CoveragePy` that accepts a few
arguments. Each argument and its usage is described in detail below.

`report`
--------
The main action is performed with this command (same as with `coverage.py`) and
when it runs it calls `coverage.py` and loads the information into a split
buffer.

It also collects all the information needed to be able to mark all lines from
files that have reported missing coverage statements. To run this command do::

    :CoveragePy report


`session`
---------
This argument toggles the reporting buffer (closes it is open or opens if it is
not already there). Makes sense to map it directly as a shortcut as it is
completely toggable.


`show` and `noshow`
-------------------
Shows or hides the actual Vim `sign` marks that display which lines are missing
coverage.
It is useful to be able to hide these if you are already aware about the lines
that need to be covered and do not want to be visually disturbed by the signs.


`version`
---------
Displays the current plugin version


License
-------

MIT
Copyright (c) 2011 Alfredo Deza <alfredodeza [at] gmail [dot] com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


