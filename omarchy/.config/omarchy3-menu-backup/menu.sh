# Overwrite parts of the omarchy-menu with user-specific submenus.
# See $OMARCHY_PATH/bin/omarchy-menu for functions that can be overwritten.
#
# WARNING: Overwritten functions will obviously not be updated when Omarchy changes.
#
# Example of minimal system menu:
#
# show_system_menu() {
#   case $(menu "System" "  Lock\n󰐥  Shutdown") in
#   *Lock*) omarchy-lock-screen ;;
#   *Shutdown*) omarchy-system-shutdown ;;
#   *) back_to show_main_menu ;;
#   esac
# }
#
# Example of overriding just the about menu action: (Using zsh instead of bash (default))
#
# show_about() {
#   exec omarchy-launch-or-focus-tui "zsh -c 'fastfetch; read -k 1'"
# }

show_system_menu() {
  local options="󱄄  Screensaver\n  Lock"
  ! omarchy-toggle-enabled suspend-off && options="$options\n󰒲  Suspend"
  omarchy-hibernation-available && options="$options\n󰤁  Hibernate"
  options="$options\n󰍃  Logout\n󰜉  Restart\n󰖳  Reboot Windows\n󰐥  Shutdown"

  case $(menu "System" "$options") in
  *Screensaver*) omarchy-launch-screensaver force ;;
  *Lock*) omarchy-system-lock ;;
  *Suspend*) systemctl suspend ;;
  *Hibernate*) systemctl hibernate ;;
  *Logout*) omarchy-system-logout ;;
  *Restart*) omarchy-system-reboot ;;
  *"Reboot Windows"*) present_terminal "sudo reboot-windows" ;;
  *Shutdown*) omarchy-system-shutdown ;;
  *) back_to show_main_menu ;;
  esac
}
