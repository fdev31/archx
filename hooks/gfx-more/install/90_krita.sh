if [ "$PREFERRED_TOOLKIT" = "qt" ]; then
    install_pkg calligra-krita
    install_pkg calligra-l10n-${LANG%_*}
fi
