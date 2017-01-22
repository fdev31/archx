cat > resources/issue.gen <<EOF
$(cat resources/issue)

$(text Login as \"USER\", default password is \"PASS\" | sed -e "s/USER/$USERNAME/" -e "s/PASS/$PASSWORD/")

EOF
install_file resources/issue.gen "/etc/issue"

