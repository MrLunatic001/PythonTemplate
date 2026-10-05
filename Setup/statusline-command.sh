#!/usr/bin/env bash
# Claude Code status line: model | effort | max ctx | context bar | cwd
export PATH="$PATH:/c/Users/adrie/AppData/Local/Microsoft/WinGet/Packages/jqlang.jq_Microsoft.Winget.Source_8wekyb3d8bbwe"

input=$(cat)
IFS=$'	' read -r m e s p d < <(printf '%s' "$input" | jq -r '[
  (.model.display_name // "?"),
  (.effort.level // "-"),
  (.context_window.context_window_size // 0),
  ((.context_window.used_percentage // 0) | floor),
  ((.workspace.current_dir // .cwd // "") | split("\\") | join("/") | split("/") | last)
] | @tsv' | sed 's/[[:cntrl:]]$//')

W=20; f=$((p*W/100)); b=''
for ((i=0; i<W; i++)); do
  if [ $i -lt $f ]; then b="$b█"; else b="$b░"; fi
done

# Format a token count as k or M
fmt() { if [ "$1" -ge 1000000 ]; then awk -v n="$1" 'BEGIN{s=sprintf("%.1f",n/1000000); sub(/\.0$/,"",s); print s "M"}'; else echo "$(($1/1000))k"; fi; }

# Muted 256-colour palette
if [ "$p" -ge 80 ]; then c=217; elif [ "$p" -ge 50 ]; then c=223; else c=151; fi
sep=$(printf ' [38;5;240m|[0m ')
out=$(printf '[38;5;189m%s[0m' "$m")
[ "$e" != "-" ] && out="$out$sep$(printf '[38;5;183meffort: %s[0m' "$e")"
out="$out$sep$(printf '[38;5;117mmax: %s[0m' "$(fmt "$s")")"
out="$out$sep$(printf '[38;5;%sm%s %s%% (%s)[0m' "$c" "$b" "$p" "$(fmt $((s*p/100)))")"
out="$out$sep$(printf '[38;5;216m📁 %s[0m' "$d")"
printf '%s' "$out"
