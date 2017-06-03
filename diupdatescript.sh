SCRIPTNAME="$(sed -n '1p' ~/.config/discord-install/discord-install.conf)"
runupdate () {
    if [ "$SCRIPTNAME" = "/usr/bin/discord-install" ]; then
        wget -O /tmp/discord-install.sh "https://raw.githubusercontent.com/simoniz0r/discord-install/master/discord-install.sh"
        if [ -f "/tmp/discord-install.sh" ]; then
            sudo rm -f /usr/bin/discord-install
            sudo mv /tmp/discord-install.sh /usr/bin/discord-install
            sudo chmod +x /usr/bin/discord-install
        else
            read -p "Update Failed! Try again? Y/N " -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                runupdate
            else
                echo "discord-install was not updated!"
                exit 0
            fi
        fi
    else
        wget -O /tmp/discord-install.sh "https://raw.githubusercontent.com/simoniz0r/discord-install/master/discord-install.sh"
        if [ -f "/tmp/discord-install.sh" ]; then
            rm -f $SCRIPTNAME
            mv /tmp/discord-install.sh $SCRIPTNAME
            chmod +x $SCRIPTNAME
        else
            read -p "Update Failed! Try again? Y/N " -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                runupdate
            else
                echo "discord-install was not updated!"
                exit 0
            fi
        fi
    fi
    if [ -f $SCRIPTNAME ] || [ -f /usr/bin/discord-install ]; then
        read -n 1 -s -p "Update finished; press any key to continue!"
        rm -f /tmp/updatescript.sh
        exec $SCRIPTNAME
    else
        read -p "Update Failed! Try again? Y/N " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            runupdate
        else
            echo "discord-install was not updated!"
            exit 0
        fi
    fi
}
runupdate
