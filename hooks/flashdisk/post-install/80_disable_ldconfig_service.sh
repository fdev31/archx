. ./strapfuncs.sh

sudo cp resources/save_state.sh "$R/bin/"

sudo sed -i 's#ExecStart=.*ldconfig.*#ExecStart=/bin/true#' "$R/lib/systemd/system/ldconfig.service"
