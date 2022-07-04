# Telescope Rails Related Files

This is a plugin for Neovim that adds `:Telescope rails_related_files` extension
that will either find the controller for the current view file or the view files
for the current controller.

# Installation

With Packer
```
use {
  "erlingur/telescope-rails-related-files",
  config = function()
    require('telescope').load_extension('rails_related_files')
  end
}
```

# Attribution

I got the base code of the extension from [axkirillov/telescope-changed-files](https://github.com/axkirillov/telescope-changed-files)
and modified it to meet my needs. Thanks @axkirillov!
