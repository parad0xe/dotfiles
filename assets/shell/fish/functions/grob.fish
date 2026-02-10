
function grob --description 'Remove local branches where the remote no longer exists'
    git fetch -p

    # Utilisation de la plomberie Git pour extraire uniquement les branches dont l'upstream est [gone]
    set -l branches (git for-each-ref --format '%(refname:short) %(upstream:track)' refs/heads | awk '$2 == "[gone]" {print $1}')

    if test -z "$branches"
        echo "No orphan branches to delete."
        return 0
    end

    echo "Deleting orphan branches:"
    for branch in $branches
        echo " - $branch"
        git branch -d "$branch"
    end
end
