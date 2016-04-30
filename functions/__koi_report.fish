function __koi_report -a level message   
  set string "koi"
  set -l color_success (set_color green)
  set -l color_warn (set_color yellow)
  set -l color_error (set_color red)
  set -l color_normal (set_color normal)
  set -l color_info (set_color -o white)
  set_color 1693A5
  switch "$level"
    case "success"
      set string $string "$color_success SUCCESS $color_normal $message\n"
    case "warn"
      set string $string "$color_warn WARN $color_normal    $message\n"
    case "error"
      set string $string "$color_error ERROR $color_normal   $message\n"
    case "info"
      set string $string "$color_info INFO $color_normal   $message\n"
    case \*
      return 1
  end
  printf "$string"
end
