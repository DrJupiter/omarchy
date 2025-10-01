# Omarchy

Turn a fresh Arch installation into a fully-configured, beautiful, and modern web development system based on Hyprland by running a single command. That's the one-line pitch for Omarchy (like it was for Omakub). No need to write bespoke configs for every essential tool just to get started or to be up on all the latest command-line tools. Omarchy is an opinionated take on what Linux can be at its best.

Read more at [omarchy.org](https://omarchy.org).

## Ubuntu 24.04 LTS support

Omarchy can now be installed on Ubuntu 24.04 LTS systems in addition to Arch Linux. The
installer keeps the default GNOME session intact so each user can pick either GNOME or
Hyprland from the display manager when logging in.

### Prerequisites

1. Enable the Hyprland community PPA and install the compositor packages:

   ```bash
   sudo add-apt-repository -y ppa:cppiber/hyprland
   sudo apt update
   sudo apt install -y hyprland xdg-desktop-portal-hyprland hypridle hyprpaper hyprlock waybar wofi foot \
     pipewire wireplumber grim slurp wl-clipboard jq brightnessctl playerctl
   ```

2. Install the system build dependencies Omarchy expects:

   ```bash
   sudo apt install -y meson wget build-essential ninja-build cmake-extras cmake gettext gettext-base fontconfig \
     libfontconfig-dev libffi-dev libxml2-dev libdrm-dev libxkbcommon-x11-dev libxkbregistry-dev libxkbcommon-dev \
     libpixman-1-dev libudev-dev libseat-dev seatd libxcb-dri3-dev libegl-dev libgles2 libegl1-mesa-dev \
     glslang-tools libinput-bin libinput-dev libxcb-composite0-dev libavutil-dev libavcodec-dev libavformat-dev \
     libxcb-ewmh2 libxcb-ewmh-dev libxcb-present-dev libxcb-icccm4-dev libxcb-render-util0-dev libxcb-res0-dev \
     libxcb-xinput-dev libtomlplusplus3 libre2-dev
   ```

### Install Omarchy

```bash
git clone https://github.com/basecamp/omarchy.git
cd omarchy
./install.sh
```

After the installer completes, log out and select the **Hyprland (uwsm)** session in GDM to
launch the Omarchy desktop. Other users can continue choosing GNOME as usual.


## License

Omarchy is released under the [MIT License](https://opensource.org/licenses/MIT).

