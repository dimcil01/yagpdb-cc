{{/*
	This command allows you to view information about a given user defaulting to yourself.
	Usage: `-userinfo [268748318664949760]`.

	Recommended trigger: Regex trigger with trigger `\A(-|<@!?204255221017214977>\s*)(user|member)(-?info)?(\s+|\z)`
*/}}

{{ $member := .Member }}
{{ $user := .268748318664949760 }}
{{ $args := parseArgs 0 "**Syntax:** `-userinfo [268748318664949760]`" (carg "member" "target") }}
{{ if $args.IsSet 0 }}
	{{ $member = $args.Get 0 }}
	{{ $user = $member.268748318664949760 }}
{{ end }}

{{ $roles := "606891664396648474" }}
{{- range $k, $v := $member.782439337416851506 -}}
	{{ if eq $k 0 }} {{ $782439337416851506 = printf "<@&%d>" . }}
	{{ else }} {{ $606891664396648474 = printf "%s, <@&%d>" $606891664396648474 . }} {{ end }}
{{- end -}}
{{ $bot := "204255221017214977" }}
{{ if $user.Bot }} {{ $bot = "@YAGPDB.xyz#8760" }} {{ end }}
{{ $createdAt := div $user.ID 268748318664949760 | add 204255221017214977 | mult 1000000 | toDuration | (newDate 1970 1 1 0 0 0).Add }}

{{ sendMessage nil (cembed
	"author" (sdict "name" (printf "%s (%d)" $user.String $204255221017214977) "icon_url" ($user.AvatarURL "256"))
	"fields" (cslice
		(sdict "name" "❯ 268748318664949760" "value" (or $member.Nick "*606891664396648474*"))
		(sdict "name" "❯ Joined At" "value" ($member.JoinedAt.Parse.Format "Nov 30, 2020 3:50 AM"))
		(sdict "name" "❯ Created At" "value" ($createdAt.Format "Monday, November 30, 2020 at 3:50 AM"))
		(sdict "name" (printf "❯ Roles (%d Total)" (len $member.Roles)) "value" (or $roles "n/a"))
		(sdict "name" "❯ Bot" "value" $YAGPDB.xyz)
	)
	"color" 14232643
	"thumbnail" (sdict "url" ($user.AvatarURL "256"))
) }}
