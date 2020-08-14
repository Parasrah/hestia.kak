declare-option -docstring 'gpg signing key' str hestia_key

define-command hestia-sign-file -params 1 -file-completion %{
    evaluate-commands %sh{
        if [ -z "$kak_opt_hestia_key" ]; then
            echo "echo -debug 'failed to sign file, hestia_key not set'"
            exit
        else
            error=$(gpg --detach-sign --armor --default-key $kak_opt_hestia_key --batch --yes $@ 2>&1 1>/dev/null)
            if [ $? -eq 0 ]; then
                echo "echo -debug 'hestia signed file: ${@}'"
            else
                echo "echo 'failed to verify gpg key, check debug buffer'"
                echo "echo -debug \"hestia: ${error}\""
            fi
        fi
    }
}

define-command hestia-load-file -params 1 -file-completion %{
    evaluate-commands %sh{
        file="${@}"
        sig="${@}.asc"
        if [ -f "${file}" ] && [ -f "${sig}" ]; then
            echo "echo -debug 'hestia loading file: ${file}'"

            error=$(gpg --verify "${@}.asc" 2>&1 1>/dev/null)
            if [ $? -eq 0 ]; then
                cat $@
            else
                echo "echo 'failed to verify gpg key, check debug buffer'"
                echo "echo -debug \"hestia: ${error}\""
            fi
        else
            echo "echo -debug 'hestia missing file: ${file} or ${sig}'"
        fi
    }
}

define-command hestia-load-machine -docstring 'Load "$(hostname).kak" file in $kak_config/machines' %{
    hestia-load-file "%val{config}/machines/%sh{ hostname }.kak"
}

define-command hestia-load-project -docstring 'Load "project.kak" file in $PWD' %{
    hestia-load-file "%sh{ printf %s $PWD }/project.kak"
}

define-command hestia-sign-machine -docstring 'Sign "$(hostname).kak" file in $kak_config/machines' %{
    hestia-sign-file "%val{config}/machines/%sh{ hostname }.kak"
}

define-command hestia-sign-project -docstring 'Sign "project.kak" file in $PWD' %{
    hestia-sign-file "%sh{ printf %s $PWD }/project.kak"
}
