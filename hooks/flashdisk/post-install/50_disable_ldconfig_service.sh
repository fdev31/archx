$SUDO cp resources/save_state.sh "$R/bin/"

$SUDO sed -i 's#ExecStart=.*ldconfig.*#ExecStart=/bin/true#' "$R/lib/systemd/system/ldconfig.service"
