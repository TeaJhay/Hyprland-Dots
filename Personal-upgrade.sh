#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  #
# For downloading dots from branch (forked)

# ===== you change these =====
GITHUB_OWNER="YOUR-GITHUB-USERNAME"   # <--- change this
REPO_NAME="Hyprland-Dots"             # <--- change if your fork is named differently
BRANCH="main"                         # <--- or "master" or whatever you use
# ============================

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
MAGENTA="$(tput setaf 5)"
ORANGE="$(tput setaf 214)"
WARNING="$(tput setaf 1)"
YELLOW="$(tput setaf 3)"
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
SKY_BLUE="$(tput setaf 6)"
RESET="$(tput sgr0)"

# Check /etc/os-release for Ubuntu or Debian and warn about Hyprland version requirement
if grep -iqE '^(ID_LIKE|ID)=.*(ubuntu|debian)' /etc/os-release >/dev/null 2>&1; then
  printf "\n%.0s" {1..1}
  echo "${WARNING} These Dotfiles are only supported on Hyprland 0.51.1 or greater. Do not install on older revisions.${RESET}"
  while true; do
    echo -n "${CAT} Do you want to continue anyway? (y/N): ${RESET}"
    read _continue
    _continue=$(echo "${_continue}" | tr '[:upper:]' '[:lower:]')
    case "${_continue}" in
      y|yes)
        echo "${NOTE} Proceeding on Ubuntu/Debian by user confirmation." 
        break
        ;;
      n|no|"")
        printf "\n%.0s" {1..1}
        echo "${INFO} Aborting per user choice. No changes made." 
        printf "\n%.0s" {1..1}
        exit 1
        ;;
      *)
        echo "${WARN} Please answer 'y' or 'n'." 
        ;;
    esac
  done
fi


printf "\n%.0s" {1..1}  
echo -e "\e[35m
████████╗███████╗ █████╗      ██╗ ██╗  ██╗ █████╗ ██╗   ██╗
╚══██╔══╝██╔════╝██╔══██╗     ██║ ██║  ██║██╔══██╗╚██╗ ██╔╝
   ██║   █████╗  ███████║     ██║ ███████║███████║ ╚████╔╝ 
   ██║   ██╔══╝  ██╔══██║ ██  ██║ ██╔══██║██╔══██║  ╚██╔╝  
   ██║   ███████╗██║  ██║ ║█████║ ██║  ██║██║  ██║   ██║   
   ╚═╝   ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝                                                                  
                       TEAJHAY 2025
\e[0m"
printf "\n%.0s" {1..1}  

echo "${WARNING}A T T E N T I O N !${RESET}"
echo "${SKY_BLUE}This script is now set to download from the '${BRANCH}' branch of ${GITHUB_OWNER}/${REPO_NAME}${RESET}"
echo "${YELLOW}This means it will always pull the current branch state, not GitHub Releases.${RESET}"
printf "\n%.0s" {1..1}
echo "${MAGENTA}If you want to get some other branch, edit BRANCH= at the top.${RESET}"
printf "\n%.0s" {1..1}
read -p "${CAT} - Would you like to proceed and install from branch '${BRANCH}'? (y/n): ${RESET}" proceed

if [ "$proceed" != "y" ]; then
    printf "\n%.0s" {1..1}
    echo "${INFO} Installation aborted. ${SKY_BLUE}No changes in your system.${RESET} ${YELLOW}Goodbye!${RESET}"
    printf "\n%.0s" {1..1}
    exit 1
fi

printf "${NOTE} Downloading / Checking for existing ${REPO_NAME}.tar.gz...\n"

# --- since we're using a branch, version-checking GitHub Releases is pointless ---
# we'll just always re-download the branch tarball and overwrite the old one

# build tarball URL for the branch
TARBALL_URL="https://api.github.com/repos/${GITHUB_OWNER}/${REPO_NAME}/tarball/${BRANCH}"
FILE_NAME="${REPO_NAME}-${BRANCH}.tar.gz"

printf "${NOTE} Downloading the latest '${BRANCH}' branch source code...\n"

# Download the latest branch source code tarball to the current directory
if curl -L "$TARBALL_URL" -o "$FILE_NAME"; then
  # Extract the contents of the tarball
  tar -xzf "$FILE_NAME" || exit 1

  # delete existing Hyprland-Dots (old naming)
  rm -rf JaKooLit-Hyprland-Dots
  rm -rf Hyprland-Dots

  # Identify the extracted directory (GitHub tarballs are OWNER-REPO-<sha>)
  extracted_directory=$(tar -tf "$FILE_NAME" | grep -o '^[^/]\+' | uniq)

  # Rename the extracted directory to Hyprland-Dots (keep original expectation)
  mv "$extracted_directory" Hyprland-Dots || exit 1

  cd "Hyprland-Dots" || exit 1

  # Set execute permission for copy.sh and execute it
  chmod +x copy.sh
  ./copy.sh 2>&1 | tee -a "../install-$(date +'%d-%H%M%S')_dots.log"

  echo -e "${OK} Latest branch '${BRANCH}' from ${GITHUB_OWNER}/${REPO_NAME} downloaded, extracted, and processed successfully."
else
  echo -e "${ERROR} Failed to download the branch source code."
  exit 1
fi
