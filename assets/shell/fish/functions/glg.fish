function glg --wraps='git log' --description 'Display git log with a beautiful graph view'
    # Définition du format (Date, Temps relatif, Décorations, Sujet, Auteur)
    set -l log_format "%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)"

    git log --graph --abbrev-commit --decorate --format=format:"$log_format" $argv
end
