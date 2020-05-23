function fish_prompt
   if not set -q VIRTUAL_ENV_DISABLE_PROMPT
      set -g VIRTUAL_ENV_DISABLE_PROMPT true
   end

   # Git
   set last_status $status
   printf '%s ' (__fish_git_prompt)
   set_color normal

   set_color yellow
   printf '%s' (whoami)
   set_color normal
   printf '@'

   set_color red --bold
   echo -n (prompt_hostname)
   set_color normal
   printf ' in '

   set_color magenta
   printf '%s' (prompt_pwd)
   set_color normal

   # Line 2
   echo
   if test $VIRTUAL_ENV
      printf "(%s) " (set_color blue)(basename $VIRTUAL_ENV)(set_color normal)
   end
   printf '↪ '
   set_color normal
end
