
function grob --description 'Remove local branches where the remote no longer exists'
    # Met à jour les références distantes et supprime les pointeurs obsolètes
    git fetch -p

    # Identifie les branches marquées comme ": gone"
    set -l branches (git branch -vv | grep ': gone]' | awk '{print $1}')

    if test -n "$branches"
        echo "Deleting orphan branches: $branches"
        echo "$branches" | xargs git branch -d
    else
        echo "No orphan branches to delete."
    end
end
