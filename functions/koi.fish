function koi -d "Create a plugin from a template" -a template name
  set -l url

  function __koi_report -a level message   
    set string "koi"
    set -l color_success (set_color green)
    set -l color_warn (set_color yellow)
    set -l color_error (set_color red)
    set -l color_normal (set_color normal)
    set_color 1693A5
    switch "$level"
      case "success"
        set string $string "$color_success SUCCESS $color_normal $message\n"
      case "warn"
        set string $string "$color_warn WARN $color_normal    $message\n"
      case "error"
        set string $string "$color_error ERROR $color_normal   $message\n"
      case \*
        return 1
    end
    printf "$string"
  end

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
      __koi_report "error" "koi: '$template' is not a valid template."
      return 1
  end

  if not set -q name
    get --prompt "Project name:\t" | read -l name
  end

  if test -d "$name"
    __koi_report "error" "koi: '$name' already exists and is not empty."
    return 1
  else
    printf "Cloning $url into '$name'...\n"
    fish -c "command git clone -q $url $name & await"

    # Very rough check on success of git clone
    if test -d "$name"
      __koi_report "success" "Clone successful"
    else
      __koi_report "error" "Clone unsucessful"
      return 1
    end
  end

  pushd "$name"

  function __koi_cleanup -d "Cleans up after installation"
    if test -e .intro
      rm .intro
    end
    if test -e .vars
      rm .vars
    end
    rm -rf .git
    popd
    __koi_report "success" "project successfully created!"
    functions -e __koi_cleanup
  end

  # Read vars from input
  set -l vars

  # Print first 10 lines of intro text, if any
  if test -s .intro
    printf "\n"
    head -n10 .intro
    printf "\n"
  end
  
  if test -s .vars 
    set arrayName (cat .vars)
    for var in $arrayName
      set vars $vars $var
    end
  else
    __koi_report "warn" "No variables to read from template"
    # No variables, work is done
    __koi_cleanup
    return 0
  end

  printf "\nReading variable file:\n"

  set -l input
  for var in $vars
    set -l promptvar
    get --prompt "$var:" | read -l promptvar
    set input $input $promptvar
  end

  printf "\n"
  
  for file in **
    if test -f "$file"
      for i in (seq (count $vars))
        sed -i.tmp "s|{{{$vars[$i]}}}|$input[$i]|g" "$file"
        command rm -f "$file.tmp"
      end
    end
  end

  __koi_cleanup
end
