# Emit simple source stages separated by an unquoted @. Anything requiring
# shell parsing beyond ordinary word splitting belongs to the native shell.
BEGIN {
    literal = "[^[:space:]'\"\\\\`$#&|;<>()]"
    quoted = "'[^']*'|\"([^\"\\\\`$]|\\\\.)*\""
    word = "(" literal "|" quoted "|\\\\.)+"
}
{
    line = $0
    count = 0
    stage = ""
    while (length(line)) {
        sub(/^[[:blank:]]+/, "", line)
        if (line == "")
            break
        if (!match(line, "^" word) || substr(line, RLENGTH + 1, 1) ~ /[^[:blank:]]/)
            exit 1
        token = substr(line, 1, RLENGTH)
        line = substr(line, RLENGTH + 1)
        if (token == "@") {
            if (stage == "")
                exit 1
            stages[++count] = stage
            stage = ""
        } else {
            stage = stage (stage == "" ? "" : " ") token
        }
    }
    if (count == 0 || stage == "")
        exit 1
    for (i = 1; i <= count; i++)
        print stages[i]
    print stage
}
