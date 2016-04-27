function koi -d "Create a plugin from a template" -a template name
    set -l color (set_color $fish_color_end)
    set -l color_normal (set_color normal)
    set -l url

    switch "$template"
        case -h
            printf "Usage: koi <url> <name> [--help]\n\n"
            printf "    -h --help    Show usage help\n"
            return

        case \*/\*
            set url "https://github.com/$template"

        case https://\?\*
            set url "$template"

        case -\*
            printf "new: '%s' is not a valid option.\n" $template > /dev/stderr
            return 1

        case \*
            printf "new: '%s' is not a valid template.\n\n" $template > /dev/stderr
            printf "The available templates are:\n" > /dev/stderr
            printf "\t %s\n" $templates > /dev/stderr
            return 1
    end

    if not set -q name
        get --prompt "Project name:\t" | read -l name
    end

    if test -d "$name"
        printf "new: '%s' already exists and is not empty." $name > /dev/stderr
        return 1
    else
        fish -c "command git clone -q $url $name & await"

        # Very rough check on success of git clone
        if test -d "$name"
            printf "  ✓ Clone success\n" $name > /dev/stderr
        else
            printf "  × Clone unsucessful\n" $name > /dev/stderr
            return 1
        end
    end

    pushd "$name"
    rm -rf .git

    set -l vars
    if test -s .vars
        set arrayName (cat .vars)
        for var in $arrayName
            set vars $vars $var
        end
    else
        # No variables, work is done
        popd
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

    printf "Scaffold success!"

    popd
end
