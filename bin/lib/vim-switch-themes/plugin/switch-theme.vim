function! UpdateTheme() abort
  " Since system() calls a new shell, it will have the most recent env vars
  let l:cur_theme = system("echo -n $ST_VIM_THEME")
  if l:cur_theme != "" && (!exists('g:st_theme') || g:st_theme != l:cur_theme)
    execute "source " . l:cur_theme
    " take BG from term/tmux
    highlight Normal guibg=NONE ctermbg=NONE
    highlight ExtraWhitespace ctermbg=red ctermfg=white guibg=red
  endif
  let g:st_theme = l:cur_theme
endfunction

nnoremap <leader>t :let g:st_theme = '' <bar> call UpdateTheme()<CR>

augroup theme_switcher
  au!
  autocmd VimEnter * call UpdateTheme()
  autocmd InsertEnter * call UpdateTheme()
  autocmd InsertLeave * call UpdateTheme()
augroup END
