# most things are got from awk.kak, keywords from neovim's one.

hook global BufCreate .*\.(gv|dot) %{
	set-option buffer filetype graphviz
}

hook global WinSetOption filetype=graphviz %{
	require-module graphviz

	hook window InsertChar \n -group graphviz-indent graphviz-indent-on-new-line
	hook window ModeChange pop:insert:.* -group graphviz-trim-indent graphviz-trim-indent

	hook -once -always window WinSetOption filetype=.* %{ remove-hooks window graphviz-.+ }

}

hook -group graphviz-highlight global WinSetOption filetype=graphviz %{
	add-highlighter window/graphviz ref graphviz
	hook -once -always window WinSetOption filetype=.* %{
		remove-highlighter window/graphviz
	}
}

provide-module graphviz %@

define-command -hidden graphviz-indent-on-new-line %[
	evaluate-commands -draft -itersel %[
		# preserve previous line indent
		try %[ execute-keys -draft <semicolon> K <a-&> ]
		# cleanup trailing whitespaces from previous line
		try %[ execute-keys -draft k <a-x> s \h+$ <ret> d ]
		# indent after line ending in opening curly brace
		try %[ execute-keys -draft k<a-x> <a-k>\{\h*(#.*)?$<ret> j<a-gt> ]
		# deindent closing brace when after cursor
		try %[ execute-keys -draft <a-x> <a-k> ^\h*\} <ret> gh / \} <ret> m <a-S> 1<a-&> ]
    ]
]


define-command -hidden graphviz-trim-indent %{
    try %{ execute-keys -draft <semicolon> <a-x> s ^\h+$ <ret> d }
}

add-highlighter shared/graphviz regions
add-highlighter shared/graphviz/code default-region group
add-highlighter shared/graphviz/comment region '#' '$' fill comment
add-highlighter shared/graphviz/string region '"' '"' fill string

add-highlighter shared/graphviz/code/ regex (?<!=)\b(_background|area|arrowhead|arrowsize|arrowtail|bb|bgcolor|center|charset|class|clusterrank|color|colorscheme|comment|compound|concentrate|constraint|Damping|decorate|defaultdist|dim|dimen|dir|diredgeconstraints|distortion|dpi|edgehref|edgetarget|edgetooltip|edgeURL|epsilon|esep|fillcolor|fixedsize|fontcolor|fontname|fontnames|fontpath|fontsize|forcelabels|gradientangle|group|head_lp|headclip|headhref|headlabel|headport|headtarget|headtooltip|headURL|height|href|id|image|imagepath|imagepos|imagescale|inputscale|K|label|label_scheme|labelangle|labeldistance|labelfloat|labelfontcolor|labelfontname|labelfontsize|labelhref|labeljust|labelloc|labeltarget|labeltooltip|labelURL|landscape|layer|layerlistsep|layers|layerselect|layersep|layout|len|levels|levelsgap|lhead|lheight|lp|ltail|lwidth|margin|maxiter|mclimit|mindist|minlen|mode|model|mosek|newrank|nodesep|nojustify|normalize|notranslate|nslimit|nslimit1|ordering|orientation|outputorder|overlap|overlap_scaling|overlap_shrink|pack|packmode|pad|page|pagedir|pencolor|penwidth|peripheries|pin|pos|quadtree|quantum|rank|rankdir|ranksep|ratio|rects|regular|remincross|repulsiveforce|resolution|root|rotate|rotation|samehead|sametail|samplepoints|scale|searchsize|sep|shape|shapefile|showboxes|sides|size|skew|smoothing|sortv|splines|start|style|stylesheet|tail_lp|tailclip|tailhref|taillabel|tailport|tailtarget|tailtooltip|tailURL|target|tooltip|truecolor|URL|vertices|viewport|voro_margin|weight|width|xdotversion|xlabel|xlp|z)\b 0:type
add-highlighter shared/graphviz/code/ regex (?<!=)\b(graph|digraph|subgraph|node|edge|strict)\b 0:keyword
add-highlighter shared/graphviz/code/ regex \b(->|--|=)\b 0:operator
@
