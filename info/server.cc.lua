{{/*
	This command allows you to view information about the server.
	Usage: `-serverinfo`. (Use `-server icon` to view the server icon).

	Recommended trigger: Regex trigger with trigger `\A(-|<@!?204255221017214977>\s*)(server|guild)(-?info)?(\s+|\z)`
*/}}

{{ $icon := "" }}
{{ $name := printf "%s (%d)" .Guild.Name .Guild.ID }}
{{ if .Guild.Icon }}
	{{ $icon = printf "https://cdn.discordapp.com/icons/%d/%s.webp" .Guild.ID .Guild.Icon }}
{{ end }}
{{ $owner := userArg .Guild.OwnerID }}
{{ $levels := cslice
	"None: Unrestricted"
	"Low: Must have a verified email on their Discord account."
	"Medium: Must also be a member of this server for longer than 10 minutes."
	"(╯°□°）╯︵ ┻━┻: Must also be a member of this server for longer than 10 minutes."
	"┻━┻ ﾐヽ(ಠ益ಠ)ノ彡┻━┻: Must have a verified phone on their Discord account."
}}
{{ $afk := "n/a" }}
{{ if .Guild.AfkChannelID }}
	{{ $afk = printf "**Channel:** <#%d> (%d)\n**Timeout:** %s"
		.Guild.AfkChannelID
		.Guild.AfkChannelID
		(humanizeDurationSeconds (toDuration (mult .Guild.AfkTimeout .TimeSecond)))
	}}
{{ end }}
{{ $embedsEnabled := "No" }}
{{ if .Guild.EmbedEnabled }} {{ $embedsEnabled = "Yes" }} {{ end }}
{{ $createdAt := div .Guild.ID 4194304 | add 1420070400000 | mult 1000000 | toDuration | (newDate 1970 1 1 0 0 0).Add }}

{{ $infoEmbed := cembed
	"author" (sdict "name" $name "icon_url" $icon)
	"color" 14232643
	"thumbnail" (sdict "url" $icon)
	"fields" (cslice
		(sdict "name" "❯ Verification Level" "value" (index $levels .Guild.VerificationLevel))
		(sdict "name" "❯ Region" "value" .Guild.Region)
		(sdict "name" "❯ Members" "value" (printf "**• Total:** %d Members\n**• Online:** %d Members" .Guild.MemberCount onlineCount))
		(sdict "name" "❯ Roles" "value" (printf "**• Total:** %d\nUse `-listroles` to list all roles." (len .Guild.Roles)))
		(sdict "name" "❯ Owner" "value" (printf "%s (%d)" $owner.String $owner.ID))
		(sdict "name" "❯ AFK" "value" $afk)
		(sdict "name" "❯ Embeds Enabled" "value" $embedsEnabled)
	)
	"footer" (sdict "text" "Created at")
	"timestamp" $createdAt
}}

{{ if .CmdArgs }}
	{{ if eq (index .CmdArgs 0) "icon" }}
		{{ sendMessage nil (cembed
			"author" (sdict "name" $name "icon_url" $icon)
			"title" "❯ Server Icon"
			"color" 14232643
			"image" (sdict "url" $icon)
		) }}
	{{ else }}
		{{ sendMessage nil $infoEmbed }}
	{{ end }}
{{ else }}
	{{ sendMessage nil $infoEmbed }}
{{ end }}