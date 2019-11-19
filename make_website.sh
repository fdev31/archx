function lssquashfs {
     unsquashfs -l "$1" | sed -e '1,4d' -e 's/.*squashfs-root//'
}

cat > www/index.html <<EOF
<html>
<head>
<title>ArchX page</title>
<link rel="stylesheet" type="text/css" href="style.css">
<link href="https://fonts.googleapis.com/css?family=Alata|Calistoga&display=swap" rel="stylesheet">
</head>
<body>
<script>
let v={};
function toggle(item, name) {
    item.classList.toggle(name);
}
</script>
<h1>ArchX</h1>
Download the <a href="ARCHX.img">disk image here</a>
<br/>
<a href="filelist.txt">Full file list here</a>
$(lssquashfs rootfs.s > www/filelist.txt)


<h1>Desktop environments</h1>

EOF

for env in $(ls -S env-*.sq) ; do
    name=${env:4:-3}
    lssquashfs $env > www/$name-filelist.txt
    fnr=$(grep -v '/$' "www/$name-filelist.txt" | wc -l)
    bins=$(grep -v '/$' "www/$name-filelist.txt" | grep '/bin/' | wc -l)
    locales=$(grep -v '/$' "www/$name-filelist.txt" | grep '/locale/' | wc -l)
    cat >> www/index.html <<EOF
<div class="environment folded" onclick="toggle(this, 'folded')">
<h2>$name</h2>
<ul>
<li><b>Size:</b> $(ls -lh $env | awk '{print $5}')</li>
<li><a href="$name-filelist.txt">Full list (.txt)</a></li>
<li>Packages: $pkgs</li>
$(markdown_py envs-available/${name}.txt || echo "<p>TODO</p>")
<li><a href="ARCHX-$name.img">Download!</a></li>
</ul>
</div>
EOF

done

cat >> www/index.html <<EOF
<hr/>
<h2>Getting started</h2>


</body>
EOF
