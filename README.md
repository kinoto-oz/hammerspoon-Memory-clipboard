This program is an aiding device for keying using Hammerspoon.
To use it you need to have Hammerspoon installed and be granted Security Accessibility permission.
The configuration file path is :[~/.hammerspoon/init.lua]
Please access this configuration file and overwrite "init.lua" file from menu icon "Open comfig".

< Programable Keybinding >
　While pressing OPTION key
   ･Allow key with IJKL
   ･PAGEUP(U)・PAGEDOWN(N)
   ･Select one word(S)  One character back(D)
   ･Select one line(W)

< Memory Clipboard >
 ･option + 0                         	- clipboard history toggle change (Up to 10)
 ･option + (1-9)number key           	- look stored words and stanby...
 (no release option) + P key         	- Paste that.
 ･option + (1-9)number key double tap	- Save the words in the clipboard to each key
 ･cmd + ctrl + (1-9)number key       	- Paste the words
 ･cmd + ctrl + 0 key                 	- save user data. Load it when reloading.
                                       	The file path is :[~/.hammerspoon/UserSaveData.txt]

It will be amazing MAC.

This program code was written by a special LUA, so it needed a great deal of try-and-error to develop stable operation.
But now you can use this as a technical textbook, or as a code example.
If it helped you a lot, please donate to my work someday.
