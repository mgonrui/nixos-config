# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
#hello world

{ config, lib, pkgs, ... }:

# variables_________________________________________________________________________

let

in

{

# import files____________________________________________________________________________________

imports =
    [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
#    ./home-manager.nix
#    /home/mgr/.config/hosts.nix
#    <home-manager/nixos>
    ];

# create directories in root__________________________________________________________________________

systemd.tmpfiles.rules = [
    "d /mnt 0755 root root"
    "d /mnt/b 0755 root root"
    "d /mnt/c 0755 root root"
    "d /mnt/d 0755 root root"
    "d /mnt/e 0755 root root"
    "d /mnt/f 0755 root root"
    "d /mnt/g 0755 root root"
    "d /mnt/h 0755 root root"
    "d /mnt/i 0755 root root"
];

# boot options ________________________________________________________________________________________

boot = {
    #blacklistedKernelModules = [
    #    "amdgpu"
    #    "radeon"
    #];
    # kernelParams = ["amdgpu.blacklist=1"];
    supportedFilesystems = [ "ntfs" ]; # enable ntfs
    loader = {
    # EFI bootloader
		efi.canTouchEfiVariables = true;
        systemd-boot = {
		enable =true;
		configurationLimit = 10; # limit the latest config files saved
	};
    timeout = 5;	
    };
};
lib.modules.defaultOverridePriority= true;

# mount external luks drive on boot
#boot.initrd.luks.devices.crypted.device = "/dev/disk/by-uuid/82af55ec-80ca-416a-8f8a-b680929e116d";
#fileSystems."/mnt/b".device = "/dev/mapper/b";

# nix options ____________________________________________________________________________________

nix = {
	settings.auto-optimise-store = true;
	gc = {
		automatic = true;
		dates = "weekly";
		options = "--delete-older-than-7d";
	};
};

# sys upgrades ____________________________________________________________________________________

system.autoUpgrade = {
	enable = true;
	channel= "https://nixos.org/channels/nixos-23.05";
};

# hardware ________________________________________________________________________________________

hardware.bluetooth.enable = true;
hardware.opengl.extraPackages = [ pkgs.intel-compute-runtime ];

# keyboard layout configuration ___________________________________________________________________

services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = ["*"];
        settings = {
          main = {
            capslock = "overload(meta, esc)"; # Maps capslock key to meta when held keys and to escape when pressed.
	    meta = "noop"; # meta key does nothing
	    esc = "capslock"; # repams escape key to capslock
	    #leftalt = "noop";
	    #space = "overload(alt, space)";
	    #tab = "overload(alt, tab)";
          };
        };
      };
    };
  }; 
# services ___________________________________________________________________________________________



services = {
    rpcbind.enable = true;
    gnome.gnome-keyring.enable = true;
    spice-vdagentd.enable = true;
    locate.enable = true;
    power-profiles-daemon.enable = false;
    tlp.enable = true; 
    blueman.enable = true; # Enable bluetooth
    printing.enable = true; # Enable CUPS to print documents.
    logind.lidSwitchExternalPower = "ignore"; # dont suspend the laptop when closing the lid with AC power on
    nfs.server.enable = true;
    nfs.server.exports = ''
	    /export 192.168.122.186(rw,sync,no_subtree_check) 
	    /export/public 192.168.122.186(rw,sync,no_subtree_check) 
	    /export/private 192.168.122.186(rw,sync,no_subtree_check) 
  '';

#  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw 

    displayManager.defaultSession = "none+i3";
    xserver = {
#	layout = "us,es"; # languages 
	exportConfiguration = true;
	xkb.variant = ""; # keymap 
	enable = true;
	videoDrivers = [ "intel" ];
	deviceSection = ''
		Option "DRI" "2"
		Option "TearFree" "true"
	'';
	windowManager = {
		i3 = {
	      		enable = true;
	      		extraPackages = with pkgs; [
			dmenu #application launcher most people use
			i3status # gives you the default i3 status bar
			i3lock #default i3 screen locker
			i3blocks #if you are planning on using i3blocks over i3status
	     		];
	    	};
		qtile = {
			enable = true;
			backend = "x11";
			# backend = "wayland";
		};
	};
	displayManager = {
		lightdm.enable = true;
# launch commands at the beggining of the X session	
		sessionCommands = '' 
			${pkgs.xorg.xrdb}/bin/xrdb -merge /home/mgr/.Xresources
			XTerm*faceSize: 40
			XTerm*faceSize1: 40
			XTerm*faceSize2: 40
			XTerm*faceSize3: 40
			XTerm*faceSize4: 40
			'';

	};
	desktopManager = {
		#plasma5.enable = true;
		xfce.enable = true;
	};
    };
};


# networking________________________________________________________________________________________

networking = {
	hostName = "nixos"; # Define your hostname.
	networkmanager.enable = true;
	firewall = {
		enable = true;
		allowedTCPPorts = [ 2049 ];
	};
};

# time zone_________________________________________________________________________________________

time.timeZone = "Europe/Madrid";

# Select internationalisation properties.
i18n.defaultLocale = "en_US.UTF-8";

i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NAME = "es_ES.UTF-8";
    LC_NUMERIC = "es_ES.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
};

# mount external drives______________________________________________________________________________

fileSystems."/run/media/mgr/toshiba1Tb" ={ 
	device = "/dev/disk/by-uuid/c404f546-ed1d-4c12-80f4-7d8dc30aa5cb";
	fsType = "ext4";
	options = [ "nofail" ];
};

fileSystems."/export/public" = {
    device = "/mnt/public";
    options = [ "bind" ];
  };
fileSystems."/export/private" = {
    device = "/mnt/private";
    options = [ "bind" ];
  };


# sound_____________________________________________________________________________________________

sound.enable = true;
hardware.pulseaudio.enable = true;
/*security.rtkit.enable = true;
services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
};
*/



#defautl shell ______________________________________________________________________________________

programs.zsh = {
	enable = true;
	syntaxHighlighting.enable = true;
	enableCompletion = true;
};
users.defaultUserShell = pkgs.zsh;
programs.starship.enable = true;
programs.starship.settings = {
	add_newline = true;
	format =" 
[┌───────────────────>](bold green)
[│](bold green)$username$git_branch$git_commit_$git_state$git_status$directory$rust$package$battery$time$os$shell
[└─>](bold green)";
};

programs.light.enable = true;
programs.wireshark.enable = true;


programs.tmux = {
  enable = true;
  extraConfig = ''
    ...
    set -g status-right '#[fg=black,bg=color15] #{cpu_percentage}  %H:%M '
    run-shell ${pkgs.tmuxPlugins.cpu}/share/tmux-plugins/cpu/cpu.tmux
  '';
};	

# enable virtualization___________________________________________________________________________

virtualisation = {
	libvirtd.enable = true; # enable qemu 
	docker.enable = true; # enable docker
};
programs.dconf.enable = true; # enable qemu

users.groups.mlocate.gid =1000;
users.groups.plocate.gid =1001;

# Define an user account____________________________________________________________________________

users.users.mgr = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "plocate" "libvirtd" "kvm" "keyd" "docker" "mlocate" "wheel" "kvm" "input" "wireshark" "video" "audio" "lp" "scanner" "smbgroup" ];
};

nixpkgs.config.permittedInsecurePackages = [
];

virtualisation.spiceUSBRedirection.enable = true;
# programs installed_______________________________________________________________________________

environment.systemPackages = with pkgs; [ 

#langs______________________________________________________________________________________________
	python3
	luajitPackages.luarocks
	luajitPackages.jsregexp
	rustc
	python311Packages.pip
	go
	glib

#cli programs_________________________________________________________________________________________
	pamixer
	python311Packages.pulsectl
	acpi
	glib
	dmg2img
	stow # symlink manager
	racket
	speechd
	timer # a `sleep` with progress
	poetry # manage python packages and dependencies
	nur.repos.dustinblackman.oatmeal # ollama client
	ollama # run ai models locally
	starship # zsh prompt
#	spaceship-prompt # zsh prompt
	gccgo13 # cc compiler
	gnumake # tool to control the generation of non-source files from sources
	xclip # access x11 clipboard
	nix-direnv # nix implementation for direnv
	direnv # shell extension for managing your environment
	zsh # shell
	readline
	wget
	xkbset # rebind keys on x11
	xorg.xkbcomp # rebind keys on x
	xorg.xev
	buku # manage bookmarks
	bukubrow # web extension for buku
	oil-buku # finder for buku
	#archivebox # archive webpages in your pc
	i2pd
	translate-shell
	hashcat
	ncmpcpp
	libcgroup
	qmk # keyboard configuration
	p7zip # decompress 7zip files
	python311Packages.dbus-next
	lm_sensors # Tools for reading hardware sensors
	neovim # text editor
	autoconf
	libtool
	inotify-tools # monitor filesystem events
	gvfs
	fzf # standard output fuzzy finder
	findutils # find utilities
	#xss-lock # timer lock utility
	coreutils # gnu core utilities
	util-linux # linux utilities
	lnch # processor launcer
	newsboat # rss client
	gnupg # gnu pgp encryption tool
	czkawka # identify duplicate files
	libglibutil
	speedtest-cli # net speed test
	surfraw # cli browser utility
	wmctrl
	xorg.xhost
	distrobox # make linux system containers
	plocate
	xkbd # keyboard management
	xorg.xkbcomp # keyboard management
	d-spy
	lshw
	pciutils
	xorg.xbacklight
	cmake
	xdg-ninja # script for checking unwanted files in homedir
	xdg-utils
	zip # basic zip utility
	unzip # basic unzip utility
	screen
	sysfsutils
	killall # basic killall utility
	xcolor #  hex code viewer
	docker # make containers
	git
	file
	android-tools # adb 
	appimage-run # run appimages
	imagemagick # basic image manipulator
	libsecret
	htop # basic proccessing monitor
	bc
	eww
	cargo
	bitwarden-cli # password manager
	ripgrep
	curl #download from the web
	tlp
	neofetch # the most essential program in any linux distro
	dpkg

#gui programs____________________________________________________________________________
	shaarli # bookmark manager
	nitrogen # set desktop wallpaper
	spotify
	tipp10 #touch typing practice
	telegram-desktop
	python311Packages.pygobject3
	python311Packages.pyvirtualdisplay
	libnotify
	gtk-layer-shell
	mypy
	kitty # terminal emulator 
	alacritty # terminal emulator
	tmux # terminal multiplexer
	xterm # terminal emulator
	rxvt-unicode-unwrapped-emoji # terminal emulator
	joplin-desktop # note 
	trilium-desktop # notes 
	kdenlive # video editing
	xscreensaver # screen saver & lock screen
	waydroid # make android containers
	authenticator # 2fa
	dialect # translation program
	libsForQt5.kdeconnect-kde
	gnome.seahorse
	tutanota-desktop # mail client for tutanota
	youtube-dl 
	ventoy-full # usb booting tool
#	ungoogled-chromium # web browser
	#firefox # web browser
	brave # web browser
	tor-browser-bundle-bin #web browser
	librewolf # web browser
	#midori # web browser
	drawio # create diagrams
	nomacs # image viewer
	darktable # image editor
	gimp # image editor
	ghidra-bin # reverse engineering software
	wireshark # net packets analyzer
	gparted # disk management
	libreoffice-still # office suite
	okular # pdf viewer
	zathura # pdf viewer
	tabbed # add tabs to zathura
	nextcloud27 # cloud suite
	nextcloud-client # nextcloud lient (duh)
	liferea # rss client
	vscodium # text editor
	cpufrequtils # power management tool
	strawberry # music player
	nicotine-plus # p2p file sharing
	amule # p2p file sharing
	hexchat # IRC client
	thunderbird # mail client
	gtk2fontsel # font viewer
	wlroots
	python311Packages.xkbcommon
	python311Packages.pywayland
	virt-manager # virtual machine manager
	virtualbox # virtual machine manager and hypervisor
	arduino # arduino software
	libgnome-keyring # system password management
	signal-desktop # messaging 
	python311Packages.pywlroots
	vlc # media player
	mpv # media player
	qownnotes # note taking 
	redshift # warm monitor light for x11
	clipgrab # grab videos from the web
	flameshot # screenshots
	#xprompt # standard output fuzzy finder
	calibre # ebook management 
	keepassxc # offline password manager
	bitwarden # online password manager
	syncthing # sync between devices
	anki # flashcards
	qbittorrent # torrent client
	dunst #notification daemon

#idk_________________________________________________________________________________

	fd
	# gnumake
	# automake
	python311Packages.pytest
	xvfb-run
	gtk-layer-shell
	dbus
	python311Packages.pygobject3
	hexyl
	nix-index
	python311Packages.pyvirtualdisplay
	#picom
	gtk3
	gtk-layer-shell
	pango
	pkg-config
	libgccjit
	libgcc
	glibc
	ntfs3g
	libsForQt5.dolphin
	cairo
	bitwarden-menu
	xdotool
	lsof
	libsForQt5.qt5ct
	libsForQt5.kde-cli-tools
    ];

#environment variables___________________________________________________________________________

environment.sessionVariables = rec {
	GNUPGHOME = "$HOME/.config/gnupg"; # gnupg config path
	XDG_DATA_HOME = "$HOME/.local/share"; 
	XDG_CONFIG_HOME ="$HOME/.config"; # set default config path
	XDG_CACHE_HOME = "$HOME/.cache"; # set default cache path
	XDG_STATE_HOME = "$HOME/.local/state"; # set default cache path

	#SSH_AUTH_SOCK="$(! cat ~/.ssh/ssh-agent-socket)";
	#EDITOR = "codium --reuse-window --wait"; # default editor
	EDITOR = "nvim"; # default editor
	DIRENV_WARN_TIMEOUT= "1000m";
	BROWSER = "librewolf"; # default browser
	QT_QPA_PLATFORMTHEME = "qt5ct";  #qt theming

	# changing variables for config files
	ZDOTDIR="$HOME/.config/zsh";
	CALCHISTFILE="$XDG_CACHE_HOME/calc_history";
	ICEAUTHORITY="$XDG_CACHE_HOME/ICEauthority";
	CARGO_HOME = "$XDG_DATA_HOME/cargo";
	ANDROID_HOME = "$XDG_DATA_HOME/android";
	GTK2_RC_FILES = "$XDG_CONFIG_HOME/gtk-2.0/gtkrc";
	XCOMPOSECACHE = "$XDG_CACHE_HOME/X11/xcompose";
	ERRFILE = "$XDG_CACHE_HOME/X11/xsession-errors";
	HISTFILE="$XDG_STATE_HOME/zsh/history";
	_JAVA_OPTIONS="-Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java";
};

# enable graphical interface for distrobox______________________________________________________________

environment.shellInit = ''
    [ -n "$DISPLAY" ] && xhost +si:localuser:$USER &> /dev/null || true
'';

# fonts______________________________________________________________________________________________

fonts.packages= with pkgs; [
#mplus-outline-fonts.githubRelease
nerdfonts
#ultimate-oldschool-pc-font-pack
#   (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
];



nixpkgs.config = {
	# allow closed source packages
	allowUnfree = true;
	# allow nur packages
	packageOverrides = pkgs: rec{
		nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
			inherit pkgs;
		};
	};
};


# List packages installed in system profile. To search, run:
# $ nix search <package>

# Some programs need SUID wrappers, can be configured further or are
# started in user sessions.
# programs.mtr.enable = true;
# programs.gnupg.agent = {
#   enable = true;
#   enableSSHSupport = true;
# };

# List services that you want to enable:

# Enable the OpenSSH daemon.
# services.openssh.enable = true;

# Open ports in the firewall.
# networking.firewall.allowedTCPPorts = [ ... ];
# networking.firewall.allowedUDPPorts = [ ... ];
# Or disable the firewall altogether.
# networking.firewall.enable = false;

# This value determines the NixOS release from which the default
# settings for stateful data, like file locations and database versions
# on your system were taken. It‘s perfectly fine and recommended to leave
# this value at the release version of the first install of this system.
# Before changing this value read the documentation for this option
# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
nix.settings.experimental-features = [ "nix-command" "flakes" ];
system.stateVersion = "23.11"; # Did you read the comment?
}
