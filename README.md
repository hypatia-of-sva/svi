# svi
smol vi, written in odin

# why another vi

Because vim / neovim are way too complicated for my liking, and the original vi codebase is pretty old and crufty. Also, its a nice test project for me writing tools in Odin

# what should it do

My current goal is Posix compliance in feature set (so movement, regexes etc.), full Unicode support and a few more features, like brace folding and syntax highlighting.
More complicated features are not planned ATM. Plugins/packages/scripting/config files are an explicit non-feature, I want all additions to be in the code

# references

Posix vi: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/vi.html

The pico editor, of which I use the terminal settings utility functions (in linux.odin or windows.odin respectively):
https://github.com/jon-lipstate/pico/tree/master