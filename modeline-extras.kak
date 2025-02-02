provide-module modeline-extras %{
  # Nerd Fonts
  # https://www.nerdfonts.com/#home
  declare-option bool modeline_nerdfont false

  # Position in local buffer as Symbol
  # enable
  define-command modeline-buffer-position-enable \
  -docstring 'Enable buffer position option for mode line' %{
    declare-option str modeline_buffer_position
    hook -group modeline-buffer-position global WinCreate .* %{
      hook -group modeline-buffer-position window NormalIdle .* modeline-buffer-position-update
      hook -group modeline-buffer-position window InsertIdle .* modeline-buffer-position-update
    }
  }
  # disable
  define-command modeline-buffer-position-disable \
  -docstring 'Disable buffer position option for mode line' %{
    set-option current modeline_buffer_position ''
    remove-hooks global modeline-buffer-position
  }
  # update
  define-command -hidden modeline-buffer-position-update %{
    set-option window modeline_buffer_position %sh{
      position="$(($kak_cursor_line * 100 / $kak_buf_line_count))%"
        if [ ${position%%%} -ge 90 ]; then
            position="⣀"
        elif [ ${position%%%} -ge 75 ] && [ ${position%%%} -lt 90 ]; then
            position="⣤"
        elif [ ${position%%%} -ge 60 ] && [ ${position%%%} -lt 75 ]; then
            position="⠤"
        elif [ ${position%%%} -ge 45 ] && [ ${position%%%} -lt 60 ]; then
            position="⠶"
        elif [ ${position%%%} -ge 30 ] && [ ${position%%%} -lt 45 ]; then
            position="⠒"
        elif [ ${position%%%} -ge 15 ] && [ ${position%%%} -lt 30 ]; then
            position="⠛"
        elif [ ${position%%%} -lt 15 ]; then
            position="⠉"
        fi
      printf $position
    }
  }

  # Unicode code point
  # https://en.wikipedia.org/wiki/Unicode
  # https://en.wikipedia.org/wiki/Code_point
  # enable
  define-command modeline-codepoint-enable \
  -docstring 'Enable codepoint option for mode line' %{
    declare-option str modeline_codepoint
    hook -group modeline-codepoint global WinCreate .* %{
      hook -group modeline-codepoint window NormalIdle .* modeline-codepoint-update
      hook -group modeline-codepoint window InsertIdle .* modeline-codepoint-update
    }
  }
  # disable
  define-command modeline-codepoint-disable \
  -docstring 'Disable codepoint option for mode line' %{
    set-option current modeline_codepoint ''
    remove-hooks global modeline-codepoint
  }
  # update
  define-command -hidden modeline-codepoint-update %{
    set-option window modeline_codepoint 'U+%sh{printf ''%04x'' "$kak_cursor_char_value"}'
  }

  # Git branch
  # enable
  define-command modeline-git-branch-enable \
  -docstring 'Enable Git branch option for mode line' %{
    declare-option str modeline_git_branch
    declare-option str modeline_git_dirty
    declare-option str modeline_git_staged
    hook -group modeline-git-branch global WinDisplay .* modeline-git-branch-update
    hook -group modeline-git-branch global BufWritePost .* modeline-git-branch-update
    hook -group modeline-git-branch global BufReload .* modeline-git-branch-update
    hook -group modeline-git-branch global FocusIn .* modeline-git-branch-update
  }
  # disable
  define-command modeline-git-branch-disable \
  -docstring 'Disable Git branch option for mode line' %{
    set-option current modeline_git_branch ''
    remove-hooks global modeline-git-branch
  }
  # update
  define-command -hidden modeline-git-branch-update %{
    nop %sh{{
      symbol=''
      cd "${kak_buffile%/*}" 2>/dev/null
      branch=$(git symbolic-ref --short HEAD 2>/dev/null)
      if [ -n "$branch" ]; then
        echo "eval -client '$kak_client' 'set-option buffer modeline_git_branch $branch'" |
            kak -p ${kak_session}
        if git diff --exit-code --quiet $kak_buffile ; then
            echo "eval -client '$kak_client' \"set-option buffer modeline_git_dirty ''\"" |
                kak -p ${kak_session}

        else
            echo "eval -client '$kak_client' \"set-option buffer modeline_git_dirty '•'\"" |
                kak -p ${kak_session}

        fi
        if git diff --cached --exit-code --quiet $kak_buffile ; then
            echo "eval -client '$kak_client' \"set-option buffer modeline_git_staged ''\"" |
                kak -p ${kak_session}
        else
            echo "eval -client '$kak_client' \"set-option buffer modeline_git_staged '+'\"" |
                kak -p ${kak_session}
        fi
      fi
    } > /dev/null 2>&1 < /dev/null & }
  }

  # Better pathh
  # enable
  define-command modeline-path-name-enable \
  -docstring 'Enable path and name option for mode line' %{
    declare-option str modeline_file_path
    declare-option str modeline_file_name
    hook -group modeline-path-name global WinDisplay .* modeline-path-name-update
    hook -group modeline-path-name global FocusIn .* modeline-path-name-update
    hook -group modeline-path-name global BufWritePost .* modeline-path-name-update
  }
  # disable
  define-command modeline-path-name-disable \
  -docstring 'Disable Git branch option for mode line' %{
    set-option current modeline_file_path ''
    set-option current modeline_file_name ''
    remove-hooks global modeline-path-name
  }
  # update
  define-command -hidden modeline-path-name-update %{
    set-option buffer modeline_file_path %sh{
    # to change how many characters are displayed in the shortened path for each folder, modify the .{0,x} part of the regex, where x is 1 less than the number of characters to display
    printf "${kak_buffile%/*}" | perl -pe 's|^$ENV{HOME}|~|'| perl -F/ -lane 'for (@F) { if (length($_) > 5) { $_ = substr($_, 0, 5) . ""; } } print join("/", @F) . "/"'
    }
    set-option buffer modeline_file_name %sh{
    printf "${kak_buffile##*/}"
    }
  }

  # Indentwidth
  # enable
  define-command modeline-indent-enable \
  -docstring 'Enable indent option for mode line' %{
    declare-option str modeline_indent
    hook -group modeline-indent global WinSetOption indentwidth=.* modeline-indent-update
  }
  # disable
  define-command modeline-indent-disable \
  -docstring 'Disable indent option for mode line' %{
    set-option current modeline_indent ''
    remove-hooks global modeline-indent
  }
  # update
  define-command -hidden modeline-indent-update %{
    set-option window modeline_indent %sh{
      if [ $kak_opt_indentwidth -eq 0 ]; then
        printf ' '
      else
        printf '%s␣' $kak_opt_indentwidth
      fi
    }
  }

  # kak-lsp diagnostics
  # https://github.com/kak-lsp/kak-lsp/
  define-command modeline-lsp-enable \
  -docstring 'Enable lsp option for mode line' %{
    declare-option str modeline_lsp_warn
    declare-option str modeline_lsp_err
    hook -group modeline-lsp global WinSetOption lsp_diagnostic_error_count=.* modeline-lsp-update-err
    hook -group modeline-lsp global WinSetOption lsp_diagnostic_warning_count=.* modeline-lsp-update-warn
  }
  # disable
  define-command modeline-lsp-disable \
  -docstring 'Disable lsp option for mode line' %{
    set-option current modeline_lsp_warn ''
    set-option current modeline_lsp_err ''
    remove-hooks global modeline-lsp
  }
  # update lsp diagnostic error
  define-command -hidden modeline-lsp-update-err %{
  set-option buffer modeline_lsp_err %sh{
    symbol_err='W:'
    $kak_opt_nerdfont && symbol_err=''
    if [ $kak_opt_lsp_diagnostic_error_count -gt 0 ]; then
      printf '%s' "$symbol_err" "$kak_opt_lsp_diagnostic_error_count"
    fi
    }
  }
  # update lsp diagnostic warning
  define-command -hidden modeline-lsp-update-warn %{
  set-option buffer modeline_lsp_warn %sh{
    symbol_warn='W:'
    $kak_opt_nerdfont && symbol_warn=''
    if [ $kak_opt_lsp_diagnostic_warning_count -gt 0 ]; then
      printf '%s' "$symbol_warn" "$kak_opt_lsp_diagnostic_warning_count"
    fi
    }
  }

}
