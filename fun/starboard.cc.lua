{{/*
	This command allows users to react to messages with stars. If it reaches a given amount, it will be sent in a given channel.
	Benefits over star command provided in docs: Updates star count with more stars using a single DB text entry.

	Recommended trigger: Reaction trigger with option `Added + Removed reactions`.
*/}}

{{/* CONFIGURATION VALUES START */}}
{{ $starEmoji := "⭐" }} {{/* Star emoji name */}}
{{ $starLimit := 1 }} {{/* Reactions needed for message to be put on starboard */}}
{{ $starboard := 678379546218594304 }} {{/* ID of starboard channel */}}
{{/* CONFIGURATION VALUES END */}}

{{ $linkRegex := `https?:\/\/(?:\w+\.)?[\w-]+\.[\w]{2,3}(?:\/[\w-_.]+)+\.(?:png|jpg|jpeg|gif|webp)` }}

{{ $count := 0 }}
{{ range .ReactionMessage.Reactions }}
	{{ if and (eq .Emoji.Name $starEmoji) (ge .Count $starLimit) }}
		{{ $count = .Count }}
	{{ end }}
{{ end }}

{{ $starboardMessage := 0 }}
{{ $thisID := .ReactionMessage.ID }}
{{ with (dbGet 0 "starboardMessages").Value }}
	{{ $idRegex := printf `%d:(\d+)` $thisID }}
	{{ with reFindAllSubmatches $idRegex . }} {{ $starboardMessage = index . 0 1 }} {{ end }}
	{{ if not (getMessage $starboard $starboardMessage) }}
		{{ $starboardMessage = 0 }}
		{{ dbSet 0 "starboardMessages" (reReplace $idRegex . "") }}
	{{ end }}
{{ end }}

{{ if and $count (or .ReactionMessage.Content .ReactionMessage.Attachments) (eq .Reaction.Emoji.Name $starEmoji) }}
	{{ $emoji := "🌠" }}
	{{ if lt $count 5 }} {{ $emoji = "⭐" }}
	{{ else if lt $count 10 }} {{ $emoji = "🌟" }}
	{{ else if lt $count 15 }} {{ $emoji = "✨" }}
	{{ else if lt $count 20 }} {{ $emoji = "💫" }}
	{{ else if lt $count 30 }} {{ $emoji = "🎇" }}
	{{ else if lt $count 40 }} {{ $emoji = "🎆" }}
	{{ else if lt $count 50 }} {{ $emoji = "☄️" }}
	{{ end }}
	{{ $embed := sdict
		"color" 0xFFAC33
		"fields" (cslice
			(sdict "name" "Author" "value" .ReactionMessage.Author.Mention "inline" true)
			(sdict "name" "Channel" "value" (printf "<#%d>" .Channel.ID) "inline" true)
		)
		"timestamp" .ReactionMessage.Timestamp
		"thumbnail" (sdict "url" (.ReactionMessage.Author.AvatarURL "1024"))
		"footer" (sdict "text" (printf "%s %d | %d" $emoji $count .ReactionMessage.ID))
	}}
	{{ with .ReactionMessage.Content }}
		{{ with reFind $linkRegex . }} {{ $embed.Set "image" (sdict "url" .) }} {{ end }}
		{{ $content := . }}
		{{ if gt (len .) 1000 }} {{ $content = slice . 0 1000 | printf "%s..." }} {{ end }}
		{{ $embed.Set "fields" ($embed.fields.Append (sdict "name" "Message" "value" $content)) }}
	{{ end }}
	{{ with .ReactionMessage.Attachments }}
		{{ $attachment := (index . 0).URL }}
		{{ if reFind `\.(png|jpg|jpeg|gif|webp)$` $attachment }}
			{{ $embed.Set "image" (sdict "url" $attachment) }}
		{{ end }}
	{{ end }}
	{{ $embed.Set "fields" ($embed.fields.Append (sdict
		"name" "Message"
		"value" (printf "[Jump To](https://discordapp.com/channels/%d/%d/%d)" .Guild.ID .Channel.ID .ReactionMessage.ID)))
	}}
	{{ with $starboardMessage }}
		{{ editMessage $starboard . (cembed $embed) }}
	{{ else }}
		{{ $ret := sendMessageRetID $starboard (cembed $embed) }}
		{{ dbSet 0 "starboardMessages" (printf
			"%s\n%d:%d"
			(or (dbGet 0 "starboardMessages").Value "")
			.ReactionMessage.ID $ret
		) }}
	{{ end }}
{{ end }}
