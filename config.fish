if status is-interactive
    # Commands to run in interactive sessions can go here
    set -gx EDITOR nvim
    set -gx VISUAL nvim

    jp2a --height=25 --color "$HOME/.config/neofetch/logoLunaLabs.jpeg"
    neofetch
    misfortune -a
    updatecheck

    starship init fish | source
end
