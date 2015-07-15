# NOTES:
# Simply setting another color does not overwrite "bold" type. As far as I can
# tell, you have to reset_color to get normal text back.

# TODO:
# * Make %3~ show entire path up to closest `proj root`

(){
  local base_color="%{$fg[blue]%}"
  local reset="%{$reset_color%}"

  local git_branch_color="%{$fg_bold[magenta]%}"
  local git_clean_color="%{$fg_bold[green]%}"
  local git_dirty_color="%{$fg_bold[red]%}"
  ZSH_THEME_GIT_PROMPT_PREFIX="${base_color}git(${reset}${git_branch_color}"
  ZSH_THEME_GIT_PROMPT_SUFFIX="${base_color})${reset}"
  ZSH_THEME_GIT_PROMPT_CLEAN="${reset}${base_color}:${git_clean_color}✓${reset}"
  ZSH_THEME_GIT_PROMPT_DIRTY="${reset}${base_color}:${git_dirty_color}✗${reset}"

  local rvm_color="%{$fg_bold[magenta]%}"
  ZSH_THEME_RVM_PROMPT_OPTIONS="i v g"
  ZSH_THEME_RVM_PROMPT_PREFIX="${base_color}rvm(${reset}${rvm_color}"
  ZSH_THEME_RVM_PROMPT_SUFFIX="${reset}${base_color})${reset}"

  local retval_success_color="%{$fg[black]%}"
  local retval_fail_color="%{$fg[red]%}"
  local retval_success="%{○%G%}"
  local retval_fail="%{●%G%}"
  local retval_segment="%(?:${retval_success_color}${retval_success}:${retval_fail_color}${retval_fail})${reset}"

  local path_color="%{$fg[cyan]%}"
  local path_segment="${path_color}%3~${reset}"

  local prompt_segment="${base_color}[ ${reset}"
  local rprompt_segment="${base_color}]${reset}"

  local git_segment='$(git_prompt_info)${reset}'
  local rvm_segment='$(ruby_prompt_info)${reset}'

  PROMPT="${retval_segment} ${path_segment} ${prompt_segment}"
  RPROMPT="${rprompt_segment} ${git_segment} ${rvm_segment}${reset}"
}