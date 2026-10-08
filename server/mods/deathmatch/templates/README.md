# Local server files

Keep live ACLs, bans, settings, databases, logs, backups and Discord webhook config on the server. Git ignores these files.

For a fresh setup, copy these templates into `mods/deathmatch/` and rename them:

- `acl.example.xml` → `acl.xml`; add your admin account.
- `banlist.example.xml` → `banlist.xml`.
- `settings.example.xml` → `settings.xml`.

In `resources/[gameplay]/discord-joinquit/`, copy `config.example.lua` to `config.lua` and add your private webhook URL.

Keep existing live files when updating a server. Use the private Solace config as `mtaserver.conf` on Solace.
