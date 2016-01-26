gv.vim
======

A git commit browser.

![gv](https://cloud.githubusercontent.com/assets/700826/12355378/8bbf0834-bbdf-11e5-9389-1aba7cd1fec1.png)

gitv is nice. But I needed a faster, and possibly simpler alternative that
I can use with a project with thousands of commits.

Installation
------------

Requires fugitive.

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'
```

Usage
-----

### Commands

- `:GV` to open commit browser
    - `:GV!` will only list commits for the current file
- `:GV` over visual range will list commits for the lines

You can pass `git log` options to the command, e.g. `:GV -S foobar`.

### Mappings

- `o` or `<cr>` on a commit to display the content of it
- `o` or `<cr>` on commits to display the diff in the range
- `O` opens a new tab instead
- `gb` for `:Gbrowse`
- `]]` and `[[` to move between commits
- `q` to close

Customization
-------------

`¯\_(ツ)_/¯`
