#!/bin/bash
# Title: discord-install
# Author: simonizor
# URL: http://www.simonizor.gq/discorddownloader
# Dependencies: Required: 'wget'; Optional: 'dialog' (discord-install GUI)
# Description: A script that can install, update, and manage all versions of Discord. If you have 'dialog' installed, a GUI will automatically be shown.

DDVER="0.0.5"
X="v0.0.5 - Added option to remove discord-install alias if it was already added."
SCRIPTNAME="$0"

programisinstalled () { # check if inputted program is installed using 'type'
    return=1
    type "$1" >/dev/null 2>&1 || { return=0; }
}

loadalias () {
cat >>~/$1 <<EOL


if [ -f ~/.discord-install_alias ]; then
    . ~/.discord-install_alias
fi
EOL
}

addalias () {
    clear
    echo "An alias will be added to your bashrc and zshrc (if it exists) that will allow you to remotely execute discord-install by simply running 'discord-install' in your terminal."
    read -p "Would you like to continue? Y/N "
    if [[ $REPLY =~ ^[Yy]$ ]];then
        if [ -f ~/.zshrc ]; then
            if grep -q -a 'discord-install' ~/.zshrc; then
                echo "discord-install alias already added to .zshrc !"
            else
                loadalias ".zshrc"
                if grep -q -a 'discord-install' ~/.zshrc; then
                    echo "discord-install alias added to ~/.zshrc !"
                fi
            fi
        fi
        if grep -q -a 'discord-install' ~/.bashrc; then
            echo "discord-install alias already added to .bashrc !"
            wget -O ~/.discord-install_alias "https://raw.githubusercontent.com/simoniz0r/discord-install/master/.discord-install_alias"
            echo "You can now run discord-install  by executing 'discord-install' in your terminal."
            $SHELL
            exit 0
        else
            loadalias ".bashrc"
            wget -O ~/.discord-install_alias "https://raw.githubusercontent.com/simoniz0r/discord-install/master/.discord-install_alias"
            if grep -q -a 'discord-install' ~/.bashrc && [ -f ~/.discord-install_alias ]; then
                echo "discord-install alias added to ~/.bashrc !"
                echo "You can now run discord-install  by executing 'discord-install' in your terminal."
                $SHELL
                exit 0
            fi
        fi
    else
        read -n 1 -s -p "discord-install alias was not added; press any key to continue."
        clear
        start
    fi
}

start () { # starting options; option chosen is routed to main function which gives more options, detects errors, etc, and then routes to other functions based on optios chosen
    programisinstalled "dialog"
    if [ -f ~/.discord-install_alias ]; then
        if [ "$return" = "1" ]; then
            MAINCHOICE=$(dialog --stdout --backtitle discord-install --no-cancel --menu "Welcome to discord-install\nVersion $DDVER\nWhat would you like to do?" 0 0 6 1 "Install Discord" 2 "Uninstall Discord" 3 "Remove discord-install alias" 4 Exit)
            main "$MAINCHOICE"
            exit 0
        else
            echo "Welcome to discord-install v$DDVER"
            echo "What would you like to do?"
            echo "1 - Install Discord"
            echo "2 - Uninstall Discord"
            echo "3 - Remove discord-install alias"
            echo "4 - Exit script"
            read -p "Choice? " -r
            echo
            clear
            main "$REPLY"
        fi
    else
        if [ "$return" = "1" ]; then
            MAINCHOICE=$(dialog --stdout --backtitle discord-install --no-cancel --menu "Welcome to discord-install\nVersion $DDVER\nWhat would you like to do?" 0 0 6 1 "Install Discord" 2 "Uninstall Discord" 3 "Add alias for discord-install" 4 Exit)
            main "$MAINCHOICE"
            exit 0
        else
            echo "Welcome to discord-install v$DDVER"
            echo "What would you like to do?"
            echo "1 - Install Discord"
            echo "2 - Uninstall Discord"
            echo "3 - Add alias for discord-install"
            echo "4 - Exit script"
            read -p "Choice? " -r
            echo
            clear
            main "$REPLY"
        fi
    fi
}

startinst () { # Discord install start; check if already installed, choose directory, output as $DIR and run inst function for version of Discord chosen
    case $1 in
        1*) # Canary
            if [ -f ~/.config/discord-install/canarydir.conf ]; then
                CANARYINSTDIR="$(sed -n '1p' ~/.config/discord-install/canarydir.conf)"
                CANARYISINST="1"
                read -p "DiscordCanary is already installed; remove and proceed with install? Y/N " -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]];then
                    clear
                    uninst "1"
                    startinst "1"
                else
                    read -n 1 -s -p "DiscordCanary was not installed; press any key to continue." 
                    clear
                    start
                fi
            fi
            programisinstalled "dialog"
            if [ "$return" = "1" ]; then
                REPLY=$(dialog --stdout --backtitle "discord-install - Install Discord" --menu "Where would you like to install DiscordCanary?" 0 0 2 1 "/opt/DiscordCanary" 2 "Use a custom directory")
            else
                echo "Where would you like to install DiscordCanary?"
                echo "1 - /opt/DiscordCanary"
                echo "2 - Use custom directory"
                read -p "Choice? " -r
                echo
            fi
            case $REPLY in
                1) # /opt
                    DIR="/opt/DiscordCanary"
                    clear
                    canaryinst
                    ;;
                2) # Custom
                    programisinstalled "dialog"
                    if [ "$return" = "1" ]; then
                        DIR=$(dialog --stdout --backtitle "discord-install - Install Discord" --dselect ~/ 0 0)
                    else
                        read -p "Where would you like to install DiscordCanary? Ex: '/home/simonizor/DiscordCanary'" DIR
                    fi
                    if [[ "$DIR" != /* ]];then
                        clear
                        echo "Invalid directory format; use full directory path.  Ex: '/home/simonizor/DiscordCanary'"
                        read -n 1 -s -p "Press any key to continue."
                        clear
                        DIR=""
                        startinst "1"
                        exit 0
                    fi
                    if [ "${DIR: -1}" = "/" ]; then
                        DIR="${DIR::-1}"
                    fi
                    clear
                    canaryinst
                    ;;
                *)
                    clear
                    start
            esac
            ;;
        2*) # PTB
            if [ -f ~/.config/discord-install/ptbdir.conf ]; then
                PTBINSTDIR="$(sed -n '1p' ~/.config/discord-install/ptbdir.conf)"
                PTBISINST="1"
                read -p "DiscordPTB is already installed; remove and proceed with install? Y/N " -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]];then
                    clear
                    uninst "2"
                    startinst "2"
                else
                    echo "DiscordPTB was not installed."
                    clear
                    start
                fi
            fi
            programisinstalled "dialog"
            if [ "$return" = "1" ]; then
                REPLY=$(dialog --stdout --backtitle "discord-install - Install Discord" --menu "Where would you like to install DiscordPTB?" 0 0 2 1 "/opt/DiscordPTB" 2 "Use a custom directory")
            else
                echo "Where would you like to install DiscordPTB?"
                echo "1 - /opt/DiscordPTB"
                echo "2 - Use custom directory"
                read -p "Choice? " -r
                echo
            fi
            case $REPLY in
                1) # /opt
                    DIR="/opt/DiscordPTB"
                    clear
                    ptbinst
                    ;;
                2) # Custom
                    programisinstalled "dialog"
                    if [ "$return" = "1" ]; then
                        DIR=$(dialog --stdout --backtitle "discord-install - Install Discord" --dselect ~/ 0 0)
                    else
                        read -p "Where would you like to install DiscordPTB? Ex: '/home/simonizor/DiscordPTB'" DIR
                    fi
                    if [[ "$DIR" != /* ]];then
                        clear
                        echo "Invalid directory format; use full directory path.  Ex: '/home/simonizor/DiscordPTB'"
                        read -n 1 -s -p "Press any key to continue."
                        clear
                        DIR=""
                        startinst "2"
                        exit 0
                    fi
                    if [ "${DIR: -1}" = "/" ]; then
                        DIR="${DIR::-1}"
                    fi
                    clear
                    ptbinst
                    ;;
                *)
                    clear
                    start
            esac
            ;;
        3*) # Stable
            if [ -f ~/.config/discord-install/stabledir.conf ]; then
                STABLEINSTDIR="$(sed -n '1p' ~/.config/discord-install/stabledir.conf)"
                STABLEISINST="1"
                read -p "Discord is already installed; remove and proceed with install? Y/N " -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]];then
                    clear
                    uninst "3"
                    startinst "3"
                else
                    read -n 1 -s -p "Discord was not installed; press any key to continue."
                    clear
                    start
                fi
            fi
            programisinstalled "dialog"
            if [ "$return" = "1" ]; then
                REPLY=$(dialog --stdout --backtitle "discord-install - Install Discord" --menu "Where would you like to install Discord?" 0 0 2 1 "/opt/Discord" 2 "Use a custom directory")
            else
                echo "Where would you like to install Discord?"
                echo "1 - /opt/Discord"
                echo "2 - Use custom directory"
                read -p "Choice? " -r
                echo
            fi
            case $REPLY in
                1) # /opt
                    DIR="/opt/Discord"
                    clear
                    stableinst
                    ;;
                2) # Custom
                    programisinstalled "dialog"
                    if [ "$return" = "1" ]; then
                        DIR=$(dialog --stdout --backtitle "discord-install - Install Discord" --dselect ~/ 0 0)
                    else
                        read -p "Where would you like to install Discord? Ex: '/home/simonizor/Discord'" DIR
                    fi
                    if [[ "$DIR" != /* ]];then
                        clear
                        echo "Invalid directory format; use full directory path.  Ex: '/home/simonizor/Discord'"
                        read -n 1 -s -p "Press any key to continue."
                        clear
                        DIR=""
                        startinst "3"
                        exit 0
                    fi
                    if [ "${DIR: -1}" = "/" ]; then
                        DIR="${DIR::-1}"
                    fi
                    clear
                    stableinst
                    ;;
                *)
                    clear
                    start
            esac
            ;;
        *)
            clear
            start
    esac
}

canaryinst () { # Install function for Canary; $DIR is chosen in the startinst function
    if [ -d "$DIR" ]; then
        read -p "$DIR exists; remove and proceed with install? Y/N " -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]];then
            CANARYINSTDIR="$DIR"
            clear
            uninst "1"
            startinst "1"
        else
            read -n 1 -s -p "DiscordCanary was not installed; press any key to continue."
            clear
            start
        fi
    fi
    echo "Downloading DiscordCanary..."
    trap '{ echo ; echo "Keyboard interrupt; cleaning up..." ; rm -f /tmp/discord-linux.tar.gz ; read -n 1 -s -p "DiscordCanary was not installed; press any key to continue." ; clear ; start ; }' INT
    wget -O /tmp/discord-linux.tar.gz "https://discordapp.com/api/download/canary?platform=linux&format=tar.gz"
    if [ ! -f /tmp/discord-linux.tar.gz ]; then
        read -n 1 -s -p "Download failed; try again later! Press any key to continue."
        clear
        start
    fi
    echo "Extracting DiscordCanary to /tmp ..."
    tar -xzf /tmp/discord-linux.tar.gz -C /tmp/ || { echo "Failed!" ; exit 1 ; }
    echo "Changing StartupNotify to false; Discord has no actual support for this..."
    sed -i 's:true:false:g' /tmp/DiscordCanary/discord-canary.desktop
    echo "Moving /tmp/DiscordCanary/ to" "$DIR ..."
    if [[ "$DIR" != /home/* ]]; then
        trap '{ echo ; echo "Keyboard interrupt; cleaning up..." ; rm -f /tmp/discord-linux.tar.gz ; read -n 1 -s -p "DiscordCanary was not installed; press any key to continue." ; clear ; start ; }' INT
        sudo mv /tmp/DiscordCanary/ $DIR/ || { echo "Failed!" ; exit 1 ; }
    else
        mv /tmp/DiscordCanary/ $DIR/ || { echo "Failed!" ; exit 1 ; }
    fi
    rm /tmp/discord-linux.tar.gz
    echo "Creating symbolic links for .desktop file ..."
    sudo ln -s $DIR/discord-canary.desktop /usr/share/applications/ || { echo "Failed!" ; exit 1 ; }
    sudo ln -s $DIR/discord.png /usr/share/icons/discord-canary.png || { echo "Failed!" ; exit 1 ; }
    sudo ln -s $DIR/DiscordCanary /usr/bin/DiscordCanary || { echo "Failed!" ; exit 1 ; }
    sudo ln -s $DIR /usr/share/discord-canary || { echo "Failed!" ; exit 1 ; }
    echo "Creating config file..."
    echo "$DIR" > ~/.config/discord-install/canarydir.conf
    read -n 1 -s -p "DiscordCanary has been installed; press any key to continue." 
    clear
    start
}

ptbinst () { # Install function for PTB; $DIR is chosen in the startinst function
    if [ -d "$DIR" ]; then
        read -p "$DIR exists; remove and proceed with install? Y/N " -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]];then
            PTBINSTDIR="$DIR"
            clear
            uninst "2"
            startinst "2"
        else
            read -n 1 -s -p "DiscordPTB was not installed; press any key to continue." 
            clear
            start
        fi
    fi
    echo "Downloading DiscordPTB..."
    trap '{ echo ; echo "Keyboard interrupt; cleaning up..." ; rm -f /tmp/discord-linux.tar.gz ; read -n 1 -s -p "DiscordPTB was not installed; press any key to continue." ; clear ; start ; }' INT
    wget -O /tmp/discord-linux.tar.gz "https://discordapp.com/api/download/ptb?platform=linux&format=tar.gz"
    if [ ! -f /tmp/discord-linux.tar.gz ]; then
        read -n 1 -s -p "Download failed; try again later! Press any key to continue." 
        clear
        start
    fi
    echo "Extracting DiscordPTB to /tmp ..."
    tar -xzf /tmp/discord-linux.tar.gz -C /tmp/ || { echo "Failed!" ; exit 1 ; }
    echo "Changing StartupNotify to false; Discord has no actual support for this..."
    sed -i 's:true:false:g' /tmp/DiscordPTB/discord-ptb.desktop
    echo "Moving /tmp/DiscordPTB/ to" "$DIR ..."
    if [[ "$DIR" != /home/* ]]; then
        trap '{ echo ; echo "Keyboard interrupt; cleaning up..." ; rm -f /tmp/discord-linux.tar.gz ; read -n 1 -s -p "DiscordPTB was not installed; press any key to continue." ; clear ; start ; }' INT
        sudo mv /tmp/DiscordPTB/ $DIR/ || { echo "Failed!" ; exit 1 ; }
    else
        mv /tmp/DiscordPTB/ $DIR/ || { echo "Failed!" ; exit 1 ; }
    fi
    rm /tmp/discord-linux.tar.gz
    echo "Creating symbolic links for .desktop file ..."
    sudo ln -s $DIR/discord-ptb.desktop /usr/share/applications/ || { echo "Failed!" ; exit 1 ; }
    sudo ln -s $DIR/discord.png /usr/share/icons/discord-ptb.png || { echo "Failed!" ; exit 1 ; }
    sudo ln -s $DIR/DiscordPTB /usr/bin/DiscordPTB || { echo "Failed!" ; exit 1 ; }
    sudo ln -s $DIR /usr/share/discord-ptb || { echo "Failed!" ; exit 1 ; }
    echo "Creating config file..."
    echo "$DIR" > ~/.config/discord-install/ptbdir.conf
    read -n 1 -s -p "DiscordPTB has been installed; press any key to continue." 
    clear
    start
}

stableinst () { # Install function for Stable; $DIR is chosen in the startinst function
    if [ -d "$DIR" ]; then
        read -p "$DIR exists; remove and proceed with install? Y/N " -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]];then
            STABLEINSTDIR="$DIR"
            clear
            uninst "3"
            startinst "3"
        else
            read -n 1 -s -p "Discord was not installed; press any key to continue." 
            clear
            start
        fi
    fi
    echo "Downloading Discord..."
    trap '{ echo ; echo "Keyboard interrupt; cleaning up..." ; rm -f /tmp/discord-linux.tar.gz ; read -n 1 -s -p "Discord was not installed; press any key to continue." ; clear ; start ; }' INT
    wget -O /tmp/discord-linux.tar.gz "https://discordapp.com/api/download?platform=linux&format=tar.gz"
    if [ ! -f /tmp/discord-linux.tar.gz ]; then
        read -n 1 -s -p "Download failed; try again later! Press any key to continue." 
        clear
        start
    fi
    echo "Extracting Discord to /tmp ..."
    tar -xzf /tmp/discord-linux.tar.gz -C /tmp/ || { echo "Failed!" ; exit 1 ; }
    echo "Changing StartupNotify to false; Discord has no actual support for this..."
    sed -i 's:true:false:g' /tmp/Discord/discord.desktop
    echo "Moving /tmp/Discord/ to" "$DIR ..."
    if [[ "$DIR" != /home/* ]]; then
        trap '{ echo ; echo "Keyboard interrupt; cleaning up..." ; rm -f /tmp/discord-linux.tar.gz ; read -n 1 -s -p "Discord was not installed; press any key to continue." ; clear ; start ; }' INT
        sudo mv /tmp/Discord/ $DIR/ || { echo "Failed!" ; exit 1 ; }
    else
        mv /tmp/Discord/ $DIR/ || { echo "Failed!" ; exit 1 ; }
    fi
    rm /tmp/discord-linux.tar.gz
    echo "Creating symbolic links for .desktop file..."
    sudo ln -s $DIR/discord.desktop /usr/share/applications/ || { echo "Failed!" ; exit 1 ; }
    sudo ln -s $DIR/discord.png /usr/share/icons/discord.png || { echo "Failed!" ; exit 1 ; }
    sudo ln -s $DIR/Discord /usr/bin/Discord || { echo "Failed!" ; exit 1 ; }
    sudo ln -s $DIR /usr/share/discord || { echo "Failed!" ; exit 1 ; }
    echo "Creating config file..."
    echo "$DIR" > ~/.config/discord-install/stabledir.conf
    read -n 1 -s -p "Discord has been installed; press any key to continue." 
    clear
    start
}

uninst () { # Uninstall function; $*INSTDIR is either from the conf file or from $DIR above if installing to existing directory that conf doesn't know about
    case $1 in
        1*) # Canary
            read -p "Are you sure you want to uninstall DiscordCanary? Y/N " -r
            echo
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                read -n 1 -s -p "DiscordCanary was not uninstalled; press any key to continue." 
                clear
                start
            fi
            killall -SIGKILL DiscordCanary
            echo "Removing install directory..."
            sudo rm -rf $CANARYINSTDIR
            echo "Removing symbolic links..."
            sudo rm -f /usr/share/applications/discord-canary.desktop
            sudo rm -f /usr/share/icons/discord-canary.png
            sudo rm -f /usr/bin/DiscordCanary
            sudo rm -f /usr/share/discord-canary
            rm -f ~/.config/discord-install/canarydir.conf
            rm -f ~/.config/discord-install/BD.conf
            CANARYISINST="0"
            read -n 1 -s -p "DiscordCanary has been uninstalled; press any key to continue."
            clear
            ;;
        2*) # PTB
            read -p "Are you sure you want to uninstall DiscordPTB? Y/N " -r
            echo
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                read -n 1 -s -p "DiscordPTB was not uninstalled; press any key to continue." 
                clear
                start
            fi
            killall -SIGKILL DiscordPTB
            echo "Removing install directory..."
            sudo rm -rf $PTBINSTDIR
            echo "Removing symbolic links..."
            sudo rm -f /usr/share/applications/discord-ptb.desktop
            sudo rm -f /usr/share/icons/discord-ptb.png
            sudo rm -f /usr/bin/DiscordPTB
            sudo rm -f /usr/share/discord-ptb
            rm -f ~/.config/discord-install/ptbdir.conf
            rm -f ~/.config/discord-install/BD.conf
            PTBISINST="0"
            read -n 1 -s -p "DiscordPTB has been uninstalled; press any key to continue."
            clear
            ;;
        3*) # Stable
            read -p "Are you sure you want to uninstall Discord? Y/N " -r
            echo
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                read -n 1 -s -p "Discord was not uninstalled; press any key to continue." 
                clear
                start
            fi
            killall -SIGKILL Discord
            echo "Removing install directory..."
            sudo rm -rf $STABLEINSTDIR
            echo "Removing symbolic links..."
            sudo rm -f /usr/share/applications/discord.desktop
            sudo rm -f /usr/share/icons/discord.png
            sudo rm -f /usr/bin/Discord
            sudo rm -f /usr/share/discord
            rm -f ~/.config/discord-install/stabledir.conf
            rm -f ~/.config/discord-install/BD.conf
            STABLEISINST="0"
            read -n 1 -s -p "Discord has been uninstalled; press any key to continue."
            clear
            ;;
        *)
            clear
            start
    esac
}

main () { # main function that contains options and questions related to the option chosen in the start function.  Also detects which versions should be listed in the Uninstall list based on conf files
    case $1 in
        1*) # Choose version of Discord to install
            programisinstalled "dialog"
            if [ "$return" = "1" ]; then
                VERCHOICE=$(dialog --stdout --backtitle "discord-install - Install Discord" --menu "Install or update:" 0 0 3 1 DiscordCanary 2 DiscordPTB 3 "Discord Stable")
                clear
                startinst "$VERCHOICE"
            else
                echo "1 - DiscordCanary"
                echo "2 - DiscordPTB"
                echo "3 - Discord Stable"
                echo "4 - Return to main menu"
                read -p "Choice? " -r
                echo
                clear
                startinst "$REPLY"
            fi
            ;;
        2*) # Uninstall; check which versions of Discord are installed based on conf files and only list versions installed
            if [ -f ~/.config/discord-install/canarydir.conf ]; then
                CANARYINSTDIR="$(sed -n '1p' ~/.config/discord-install/canarydir.conf)"
                CANARYISINST="1"
            fi
            if [ -f ~/.config/discord-install/ptbdir.conf ]; then
                PTBINSTDIR="$(sed -n '1p' ~/.config/discord-install/ptbdir.conf)"
                PTBISINST="1"
            fi
            if [ -f ~/.config/discord-install/stabledir.conf ]; then
                STABLEINSTDIR="$(sed -n '1p' ~/.config/discord-install/stabledir.conf)"
                STABLEISINST="1"
            fi
            if [[ "$CANARYISINST" = "1" && "$PTBISINST" = "1" && "$STABLEISINST" = "1" ]]; then
                programisinstalled "dialog"
                if [ "$return" = "1" ]; then
                    REPLY=$(dialog --stdout --backtitle "discord-install - Uninstall" --menu "Uninstall:" 0 0 3 1 DiscordCanary 2 DiscordPTB 3 "Discord Stable")
                else
                    echo "1 - DiscordCanary"
                    echo "2 - DiscordPTB"
                    echo "3 - Discord Stable"
                    echo "4 - Return to main menu"
                    read -p "Choice? " -r
                    echo
                fi
            elif [[ "$CANARYISINST" = "1" && "$PTBISINST" = "1" ]]; then
                programisinstalled "dialog"
                if [ "$return" = "1" ]; then
                    REPLY=$(dialog --stdout --backtitle "discord-install - Uninstall" --menu "Uninstall:" 0 0 2 1 DiscordCanary 2 DiscordPTB)
                else
                    echo "1 - DiscordCanary"
                    echo "2 - DiscordPTB"
                    echo "4 - Return to main menu"
                    read -p "Choice? " -r
                    echo
                fi
            elif [[ "$CANARYISINST" = "1" && "$STABLEISINST" = "1" ]]; then
                programisinstalled "dialog"
                if [ "$return" = "1" ]; then
                    REPLY=$(dialog --stdout --backtitle "discord-install - Uninstall" --menu "Uninstall:" 0 0 2 1 DiscordCanary 3 "Discord Stable")
                else
                    echo "1 - DiscordCanary"
                    echo "3 - Discord Stable"
                    echo "4 - Return to main menu"
                    read -p "Choice? " -r
                    echo
                fi
            elif [[ "$CANARYISINST" = "1" ]]; then
                programisinstalled "dialog"
                if [ "$return" = "1" ]; then
                    REPLY=$(dialog --stdout --backtitle "discord-install - Uninstall" --menu "Uninstall:" 0 0 1 1 DiscordCanary)
                else
                    echo "1 - DiscordCanary"
                    echo "4 - Return to main menu"
                    read -p "Choice? " -r
                    echo
                fi
            elif [[ "$PTBISINST" = "1" && "$STABLEISINST" = "1" ]]; then
                programisinstalled "dialog"
                if [ "$return" = "1" ]; then
                    REPLY=$(dialog --stdout --backtitle "discord-install - Uninstall" --menu "Uninstall:" 0 0 2 2 DiscordPTB 3 "Discord Stable")
                else
                    echo "2 - DiscordPTB"
                    echo "3 - Discord Stable"
                    echo "4 - Return to main menu"
                    read -p "Choice? " -r
                    echo
                fi
            elif [[ "$PTBISINST" = "1" ]]; then
                programisinstalled "dialog"
                if [ "$return" = "1" ]; then
                    REPLY=$(dialog --stdout --backtitle "discord-install - Uninstall" --menu "Uninstall:" 0 0 1 2 DiscordPTB)
                else
                    echo "2 - DiscordPTB"
                    echo "4 - Return to main menu"
                    read -p "Choice? " -r
                    echo
                fi
            elif [[ "$STABLEISINST" = "1" ]]; then
                programisinstalled "dialog"
                if [ "$return" = "1" ]; then
                    REPLY=$(dialog --stdout --backtitle "discord-install - Uninstall" --menu "Uninstall:" 0 0 1 3 "Discord Stable")
                else
                    echo "3 - Discord Stable"
                    echo "4 - Return to main menu"
                    read -p "Choice? " -r
                    echo
                fi
            else
                read -n 1 -s -p "No versions of Discord are installed; press any key to continue." 
                clear
                start
            fi
            clear
            uninst "$REPLY"
            start
            ;;
        3)
            if [ -f ~/.discord-install_alias ]; then
                clear
                read -p "Would you like to remove the discord-install alias file? Y/N "
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm -f ~/.discord-install_alias
                    echo "discord-install alias will be removed after you restart $SHELL"
                    read -n 1 -s -p "discord-install alias file removed; press any key to continue."
                    clear
                    start
                else
                    read -n 1 -s -p "discord-install alias file was not removed; press any key to continue."
                    clear
                    start
                fi
            else
                addalias
            fi
            ;;
        4)
            clear
            echo "Exiting..."
            exit 0
            ;;
        *)
            clear
            start
            ;;
    esac
}

if [ "$EUID" -ne 0 ]; then
    programisinstalled "wget"
    if [ "$return" = "1" ]; then
        if [ ! -d ~/.config/discord-install ];then
            mkdir ~/.config/discord-install
        fi
        start
    else
        echo "wget is not installed!"
        exit 0
    fi
else
    echo "Do not run discord-install as root!"
    exit 0
fi
