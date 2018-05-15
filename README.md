Use [impl](https://github.com/josharian/impl) in Your Vim
=========================================================

[impl](https://github.com/josharian/impl) is a very handy tool to generate method stubs for implementing an interface.
This plugin is created to use [impl](https://github.com/josharian/impl) in your Vim.

**NOTE:** This plugin is already integrated to [vim-go](https://github.com/fatih/vim-go).  If you're using it, you don't need to install any additional plugins.

## Usage

Simply do:

```
:GoImpl {receiver} {interface}
```

You can use completion for package name and interface name in `{interface}`

For example:

```
:GoImpl f *File io.Reader
```

```
:GoImpl f *Foo hash.Hash
```

You need not add single quotes around the receiver.

Note that `:Impl` is also available. It is equivalent to `:GoImpl`.

## Requirements

- `go` command
- [impl](https://github.com/josharian/impl) command

## License

    The MIT License (MIT)

    Copyright (c) 2014-2015 rhysd

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
