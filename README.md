gv.vim
======

A git commit browser.

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

### Mappings

- `o` or `<cr>` on a commit to display the content of it
- `o` or `<cr>` on commits to display the diff in the range
- `O` opens a new tab instead
- `gb` for `:Gbrowse`
- `q` to close

Customization
-------------

`¯\_(ツ)_/¯`
