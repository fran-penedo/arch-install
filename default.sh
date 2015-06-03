#!/bin/bash

xdg-mime default qpdfview.desktop application/pdf
xdg-mime default gvim.desktop $(grep '^text/x-*' /usr/share/mime/types)
xdg-mime default gvim.desktop text/plain
xdg-mime default nomacs.desktop $(grep '^image*' /usr/share/mime/types | grep -v 'x-*')
xdg-mime default MidnightCommander.desktop inode/directory
