function __koi_list
  set -l url "https://raw.githubusercontent.com/fisherman/koi/master/templates.txt"
  echo (curl -s "$url")
end
