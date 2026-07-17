To store a command's multi-line output into a Bash array, use readarray -t array_name < <(command) so each line becomes an array element without splitting on spaces or expanding wildcards.
