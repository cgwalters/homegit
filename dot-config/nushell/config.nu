$env.PATH = ($env.PATH | prepend $"($env.HOME)/.local/bin")

def create_left_prompt [] {
    let last_err = (if ($env.LAST_EXIT_CODE) != 0 { $"(ansi red_bold)<($env.LAST_EXIT_CODE)>(ansi reset) " } else { "" })
    let dir = match (do --ignore-shell-errors { $env.PWD | path relative-to $nu.home-path }) {
        null => $env.PWD
        '' => '~'
        $relative_pwd => ([~ $relative_pwd] | path join)
    }

    let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
    let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
    let path_segment = $"($path_color)($dir)"
    let hostname = (hostname)

    $"($last_err)(hostname) ($path_segment)" | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"
}

$env.PROMPT_COMMAND = {|| create_left_prompt }
$env.config = {
    show_banner: false
}

# Unfortunately nushell aliases can't be conditional
alias ph = flatpak-spawn --host podman
