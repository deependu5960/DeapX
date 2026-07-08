#!/bin/bash
# Deap X - Chroot Post-Install Script
# Executed inside chroot after package installation

set -e

echo "Deap X: Running chroot post-install hooks"

# Create Deap X branding
echo "Deap X Operating System 1.0.0" > /etc/deapx-version

#-------------------------------------------------------------------------------
# INSTALL BRAVE BROWSER
#-------------------------------------------------------------------------------

install_brave_browser() {
    echo "Deap X: Installing Brave Browser..."
    
    # Ensure curl is installed
    apt-get install -y curl
    
    # Add Brave repository GPG key
    curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
        | gpg --dearmor > /usr/share/keyrings/brave-browser-archive-keyring.gpg
    
    # Add Brave repository
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" \
        > /etc/apt/sources.list.d/brave-browser-release.list
    
    # Update package cache
    apt-get update
    
    # Install Brave Browser
    apt-get install -y brave-browser
    
    # Set Brave as default browser using update-alternatives
    update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/brave-browser 200
    update-alternatives --set x-www-browser /usr/bin/brave-browser
    
    # Create desktop shortcut
    cat > /usr/share/applications/brave-browser.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Name=Brave Browser
Comment=Secure, Fast & Private Web Browser
Exec=brave-browser %U
Icon=brave-browser
Terminal=false
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
StartupWMClass=Brave-browser
EOF
    
    echo "Brave Browser installed successfully"
}

#-------------------------------------------------------------------------------
# CONFIGURE BRAVE AS DEFAULT BROWSER
#-------------------------------------------------------------------------------

configure_brave_default() {
    echo "Deap X: Setting Brave as default browser..."
    
    # Set default browser for system
    update-alternatives --set x-www-browser /usr/bin/brave-browser
    
    # Create XFCE default applications configuration
    mkdir -p /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/
    cat > /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-settings.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-settings" version="1.0">
  <property name="Last" type="empty">
    <property name="Version" type="string" value="3.0"/>
  </property>
  <property name="Default" type="empty">
    <property name="WebBrowser" type="string" value="brave-browser"/>
    <property name="MailReader" type="string" value=""/>
    <property name="FileManager" type="string" value="thunar"/>
    <property name="TerminalEmulator" type="string" value="xfce4-terminal"/>
  </property>
</channel>
EOF
    
    # Set default browser via xdg-settings for user
    mkdir -p /etc/skel/.config
    cat > /etc/skel/.config/mimeapps.list << 'EOF'
[Default Applications]
text/html=brave-browser.desktop
x-scheme-handler/http=brave-browser.desktop
x-scheme-handler/https=brave-browser.desktop
x-scheme-handler/ftp=brave-browser.desktop
x-scheme-handler/chrome=brave-browser.desktop
application/xhtml+xml=brave-browser.desktop
application/x-extension-htm=brave-browser.desktop
application/x-extension-html=brave-browser.desktop
application/x-extension-shtml=brave-browser.desktop
application/xml=brave-browser.desktop
text/xml=brave-browser.desktop
EOF
    
    echo "Brave configured as default browser"
}

#-------------------------------------------------------------------------------
# CUSTOMIZE BRAVE SETTINGS
#-------------------------------------------------------------------------------

customize_brave_settings() {
    echo "Deap X: Customizing Brave settings..."
    
    # Create default Brave preferences
    mkdir -p /etc/skel/.config/BraveSoftware/Brave-Browser/Default/
    
    cat > /etc/skel/.config/BraveSoftware/Brave-Browser/Default/Preferences << 'EOF'
{
  "browser": {
    "enable_spellchecking": true,
    "show_home_button": true,
    "homepage": "https://deapx.org"
  },
  "bookmark_bar": {
    "show_on_all_tabs": false
  },
  "default_search_provider": {
    "enabled": true,
    "search_url": "https://duckduckgo.com/?q={searchTerms}",
    "name": "DuckDuckGo",
    "keyword": "duckduckgo.com"
  },
  "download": {
    "default_directory": "/home/user/Downloads"
  },
  "profile": {
    "content_settings": {
      "exceptions": {
        "automatic_downloads": {}
      }
    }
  },
  "extensions": {
    "theme": {
      "use_system": true
    }
  }
}
EOF
    
    # Set bookmarks
    cat > /etc/skel/.config/BraveSoftware/Brave-Browser/Default/Bookmarks << 'EOF'
{
  "roots": {
    "bookmark_bar": {
      "children": [
        {
          "name": "Deap X Home",
          "url": "https://deapx.org"
        },
        {
          "name": "Brave Community",
          "url": "https://community.brave.com"
        },
        {
          "name": "DuckDuckGo",
          "url": "https://duckduckgo.com"
        },
        {
          "name": "GitHub",
          "url": "https://github.com"
        }
      ]
    },
    "other": {
      "children": []
    },
    "synced": {
      "children": []
    }
  }
}
EOF
    
    echo "Brave settings customized"
}

#-------------------------------------------------------------------------------
# SET UP MOTD
#-------------------------------------------------------------------------------

cat > /etc/motd << 'EOF'
    ┌─────────────────────────────────────────┐
    │     Deap X Operating System 1.0.0       │
    │                                          │
    │     Built with ❤️ on Debian 12           │
    │     Default Browser: Brave               │
    │     Documentation: https://deapx.org     │
    └─────────────────────────────────────────┘
EOF

#-------------------------------------------------------------------------------
# CONFIGURE LIGHTDM
#-------------------------------------------------------------------------------

cat > /etc/lightdm/lightdm.conf << 'EOF'
[Seat:*]
autologin-user=user
autologin-user-timeout=0
user-session=xfce
greeter-session=lightdm-gtk-greeter
EOF

#-------------------------------------------------------------------------------
# CONFIGURE XFCE DEFAULTS
#-------------------------------------------------------------------------------

mkdir -p /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/
cat > /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="last-image" type="string" value="/usr/share/images/desktop-base/joy-wallpaper.png"/>
          <property name="image-style" type="int" value="5"/>
        </property>
      </property>
    </property>
  </property>
</channel>
EOF

#-------------------------------------------------------------------------------
# SET UP USER DIRECTORIES
#-------------------------------------------------------------------------------

mkdir -p /etc/skel/Documents
mkdir -p /etc/skel/Downloads
mkdir -p /etc/skel/Music
mkdir -p /etc/skel/Pictures
mkdir -p /etc/skel/Videos
mkdir -p /etc/skel/Desktop

#-------------------------------------------------------------------------------
# INSTALL BRAVE AND CONFIGURE
#-------------------------------------------------------------------------------

install_brave_browser
configure_brave_default
customize_brave_settings

#-------------------------------------------------------------------------------
# INSTALL CUSTOM WELCOME MESSAGE
#-------------------------------------------------------------------------------

cat > /usr/share/deapx/welcome.txt << 'EOF'
Welcome to Deap X!

Thank you for choosing Deap X Operating System.

Key Features:
- Debian 12 Bookworm base
- XFCE Desktop Environment
- Brave Browser as default (secure & private)
- Pre-configured for productivity
- Full multimedia support
- Development tools included

Quick Links:
- Documentation: https://deapx.org/docs
- Community: https://deapx.org/community
- Support: https://deapx.org/support
- Brave Support: https://community.brave.com

Enjoy your Deap X experience!
EOF

#-------------------------------------------------------------------------------
# CONFIGURE APT SOURCES
#-------------------------------------------------------------------------------

cat > /etc/apt/sources.list << 'EOF'
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
EOF

#-------------------------------------------------------------------------------
# CLEAN UP
#-------------------------------------------------------------------------------

apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*

echo "Deap X: Chroot post-install hooks completed"