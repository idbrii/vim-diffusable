# diffusable
Quick shortcuts to putting text into a vimdiff.


# Dependencies

## :Scratch (optional)

Uses [itchy.vim](https://github.com/idbrii/itchy.vim) or any scratch plugin
providing a `:Scratch` command if available. Otherwise it defines its own
`:Scratch` command.


# Commands

## :DiffDeletes

Diff the last two things you deleted.

## DiffText(left, right)

Diff the text in the two inputs `left` and `right`.

## :DiffSaved

Diff against the file on disk. Similar to `:help DiffOrig`.

## :DiffBoth

Diff the current and the previous window. Partners the two windows so that when
one of the windows are closed, diff is turned off in the other one. Great for
preventing accident diffing more than two files because you forgot to turn off
'diff' on some hidden buffer.

## :DiffOff

Stop diffing this window and its partner. See `:DiffBoth`.


# License

MIT
