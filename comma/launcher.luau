--!nonstrict

-- comma's default picker (fzy) needs a TTY, so we pick via `noctalia dmenu` instead.
-- comma runs -P with no arguments, hence the wrapper file in $XDG_RUNTIME_DIR.
-- `, -x` fetches the package and prints the executable; only packages with a
-- non-Terminal .desktop file (GUI apps) get launched, so CLI tools don't run invisibly.
local LAUNCH = [[
pick="${XDG_RUNTIME_DIR:?}/noctalia-comma-pick"
printf '#!/bin/sh\nexec noctalia dmenu -p package\n' > "$pick" && chmod +x "$pick" || exit
exe=$(, -P "$pick" -x "$1") || exit
if [ -z "$(grep -Lx 'Terminal=true' "${exe%/bin/*}"/share/applications/*.desktop 2>/dev/null)" ]; then
    noctalia msg notification-show Comma "$1 is not a GUI app"
    exit 1
fi
shift
exec "$exe" "$@"
]]

function onQuery(query)
    local cmd = query:match("^%s*(%S+)")

    -- Leading alnum so the name can't be parsed as a comma flag.
    if not cmd or not cmd:match("^%w[%w._+-]*$") then
        launcher.setResults(query, {})
        return
    end

    -- `, -p` exits non-zero when no nixpkgs package provides the command.
    noctalia.runAsync({ ",", "-p", cmd }, function(result)
        if result.exitCode ~= 0 then
            launcher.setResults(query, {})
            return
        end

        launcher.setResults(query, {
            {
                id = query,
                title = "Run " .. cmd .. " via comma",
                subtitle = ", " .. query,
                glyph = "terminal",
                score = 0,
            },
        })
    end, 5000)
end

function onActivate(id)
    -- ponytail: args split on whitespace, no quoting; GUI launches rarely need more.
    local argv = { "sh", "-c", LAUNCH, "sh" }
    for word in id:gmatch("%S+") do
        table.insert(argv, word)
    end

    -- No callback: detached launch, so the app outlives the timeout.
    noctalia.runAsync(argv)
end
