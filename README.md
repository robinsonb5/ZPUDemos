ZPUDemos
========

Since my ZPUTest repo is in a state of flux and doesn't always contain
anything that builds cleanly, I'll devote this one to a collection of
example and test projects that will be kept in good order, to serve
as reference material for anyone wanting to experiment with the ZPUFlex
core.

Checkout instructions
=====================

Since ZPUFlex is incorporated as a submodule, you'll need to check out
the current codebase like so:

> git clone https://github.com/robinsonb5/ZPUDemos.git

> cd ZPUDemos

> git submodule init

> git submodule update

Each demo's directory contains Quartus project files for each target board
in the 'fpga/<target board>' subdirectory.

