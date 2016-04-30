function koi -d "Create a plugin from a template" -a template name
    function __koi_cleanup -d "Cleans up after installation"
        set -l koi_files ".intro" ".vars" ".postinstall" ".preinstall"
        for i in $koi_files
            debug $i
            if test -e $i
                rm $i
            end
        end
        rm -rf .git
        popd
        __koi_report "success" "project successfully created!"
        functions -e __koi_cleanup
    end

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

    # Read vars from input
    set -l vars

    # Print first 10 lines of intro text, if any
    if test -s .intro
        printf "\n"
        head -n10 .intro
        printf "\n\n"
    end

    if test -e ".preinstall"
        __koi_report "info" "Running preinstall script"
        fish -c "chmod +x .preinstall; and ./.preinstall & await"
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

    printf "   \nReading variable file:\n" #Spaces to erase spinner if there was a preinstall script

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

    if test -e ".postinstall"
        __koi_report "info" "Running postinstall script"
        fish -c "chmod +x .postinstall;and ./.postinstall & await"
    end

    __koi_cleanup
end
