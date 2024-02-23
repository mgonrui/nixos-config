{
#_______HOME_MANAGER_________

home-manager.users.mgr = { pkgs, ... }: {
home.stateVersion = "23.11"; 
#programs.home-manager.enable = true;
home.packages = with pkgs; [ ];

services.xscreensaver = {
  enable = true;
  settings = {
    timeout = 1;
    lock = true;
    mode = "blank";
  };
};
};
}


