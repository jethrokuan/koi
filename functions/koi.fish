function koi -d "Create a plugin from a template" -a template name
  set -l color (set_color $fish_color_end)
set -l color_normal (set_color normal)
set -l url

switch "$template"
  case -h
    printf "Usage: koi <url> <name> [--help]\n\n"
    printf "    -h --help    Show usage help\n"
    printf "Example:\n"
    printf "koi jethrokuan/koi-template foo\n"
    return

  case \*/\*
    set url "https://github.com/$template"

  case https://\?\*
    set url "$template"

  case \*
    printf "koi: '%s' is not a valid template.\n\n" $template > /dev/stderr
    return 1
end

if not set -q name
  get --prompt "Project name:\t" | read -l name
end

if test -d "$name"
  printf "koi: '%s' already exists and is not empty." $name > /dev/stderr
  return 1
else
  printf "Cloning $url into '$name'...\n"
  fish -c "command git clone -q $url $name & await"

  # Very rough check on success of git clone
  if test -d "$name"
    printf "    ✓ Cloned successfully\n" $name > /dev/stderr
  else
    printf "    × Clone unsucessful\n" $name > /dev/stderr
    return 1
  end
end

pushd "$name"

function __koi_cleanup -d "Cleans up after installation"
  if test -e .vars
    rm .vars > /dev/null
  end
  rm -rf .git > /dev/null
  printf "\nkoi: project successfully created!\n"
  functions -e __koi_cleanup
end

# Read vars from input
set -l vars
if test -s .vars
  set arrayName (cat .vars)
  for var in $arrayName
    set vars $vars $var
  end
else
  # No variables, work is done
  __koi_cleanup
  return 0
end

printf "\n Reading variable file:\n"

set -l input
for var in $vars
  set -l promptvar
  get --prompt "   $var: " | read -l promptvar
  set input $input $promptvar
end

for file in **
  if test -f "$file"
    for i in (seq (count $vars))
      sed -i.tmp "s|{{{$vars[$i]}}}|$input[$i]|g" "$file"
      command rm -f "$file.tmp"
    end
  end
end

__koi_cleanup
popd
end
