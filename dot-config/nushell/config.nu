def create_left_prompt [] {
    let dir = match (do --ignore-shell-errors { $env.PWD | path relative-to $nu.home-path }) {
        null => $env.PWD
        '' => '~'
        $relative_pwd => ([~ $relative_pwd] | path join)
    }

    let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
    let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
    let path_segment = $"($path_color)($dir)"
    let hostname = (hostname)

    $"(hostname) ($path_segment)" | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"
}

$env.PROMPT_COMMAND = {|| create_left_prompt }
$env.config = {
    show_banner: false
}

# Default to podman-machine if we're in a toolbox
if "TOOLBOX_PATH" in $env {
    $env.CONTAINER_CONNECTION = "podman-machine-default-root"
}