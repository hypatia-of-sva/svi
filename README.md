# svi
smol vi, written in odin. (smol as in simple, minimal, optimal and lean, or stupid, mad, obnoxious and lightheaded, depending on your attitude. also, written by _Sva_. yes, I know, hilarious comedy all around)

# why another vi

Because vim / neovim are way too complicated for my liking, and the original vi codebase is pretty old and crufty. Also, its a nice test project for me writing tools in Odin

# what should it do

My current goal is Posix compliance in feature set (so movement, regexes etc.), full Unicode support and a few more features, like brace folding and syntax highlighting.
More complicated features are not planned ATM. Plugins/packages/scripting/config files are an explicit non-feature, I want all additions to be in the code

# what can it do now

It can draw the sceen if updated, set the position of the cursor and register a `:q`. It's a proof of concept, no more, no less.

# how to compile

Have odin installed and run `odin run .`

# references

Posix vi: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/vi.html

The pico editor, of which I use the terminal settings utility functions (in linux.odin or windows.odin respectively):
https://github.com/jon-lipstate/pico/tree/master
