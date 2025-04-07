#!/bin/bash

################################################################################
# Script per applicare configurazioni su Arch Linux.
#
# Funzionalità principali:
# - Copia di 3 file dalla repository alle destinazioni specifiche.
# - Gestione di 2 (ora 3) file di testo con controllo delle differenze:
#   * Se non ci sono differenze: notifica e salta la copia.
#   * Se ci sono differenze: mostra la diff, chiede se fare backup e se sovrascrivere.
# - Installazione pacchetti: neofetch, jp2a, misfortune.
################################################################################

####################################
#          COLORI/FORMATTAZIONE    #
####################################
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
BOLD='\e[1m'
RESET='\e[0m'

####################################
#         FUNZIONI UTILI           #
####################################

# Funzione per controllare la directory, se non esiste esce con errore
check_directory() {
  local dir="$1"
  if [ ! -d "$dir" ]; then
    echo -e "${RED}Errore:${RESET} la directory ${BOLD}$dir${RESET} non esiste. Impossibile proseguire."
    exit 1
  fi
}

# Funzione per gestire la copia dei file di testo con backup, controllo diff e conferma
process_file() {
  local src="$1"
  local dest="$2"
  local backup_made=0

  if [ -f "$dest" ]; then
    echo -e "${YELLOW}Attenzione:${RESET} il file ${BOLD}$dest${RESET} esiste già."
    # Verifico se ci sono differenze tra il file esistente e il nuovo
    if diff "$dest" "$src" >/dev/null; then
      echo -e "${CYAN}Info:${RESET} Non sono state riscontrate differenze tra il file esistente e quello nuovo."
      echo -e "Nessuna copia necessaria per ${BOLD}$dest${RESET}."
      return
    else
      echo -e "${YELLOW}Differenze riscontrate${RESET} tra il file esistente e quello nuovo:" \
        "${BOLD}(mostro la diff)${RESET}"
      git diff "$dest" "$src"

      # Chiedo se effettuare il backup
      read -r -p "Vuoi eseguire un backup del file esistente prima di sovrascrivere? (y/n): " backup_ans
      if [[ "$backup_ans" =~ ^[Yy]$ ]]; then
        if cp "$dest" "${dest}.bak"; then
          backup_made=1
          echo -e "${GREEN}Backup creato:${RESET} ${BOLD}${dest}.bak${RESET}"
        else
          echo -e "${RED}Errore:${RESET} impossibile effettuare il backup di ${BOLD}$dest${RESET}"
          exit 1
        fi
      else
        echo -e "${CYAN}Info:${RESET} Nessun backup effettuato per ${BOLD}$dest${RESET}."
      fi

      read -r -p "Vuoi sovrascrivere il file con la nuova versione? (y/n): " override_ans
      if ! [[ "$override_ans" =~ ^[Yy]$ ]]; then
        echo -e "${CYAN}Info:${RESET} Aggiornamento saltato per ${BOLD}$dest${RESET}."
        return
      fi

      if cp "$src" "$dest"; then
        if [ "$backup_made" -eq 1 ]; then
          echo -e "${GREEN}Success:${RESET} File ${BOLD}$dest${RESET} aggiornato con backup eseguito in precedenza."
        else
          echo -e "${GREEN}Success:${RESET} File ${BOLD}$dest${RESET} aggiornato senza backup."
        fi
      else
        echo -e "${RED}Errore:${RESET} nella copia di ${BOLD}$src${RESET} in ${BOLD}$dest${RESET}"
        exit 1
      fi
    fi
  else
    # Se il file non esiste ma la directory di destinazione esiste, copio direttamente
    if cp "$src" "$dest"; then
      echo -e "${GREEN}Success:${RESET} File ${BOLD}$dest${RESET} copiato correttamente (nessun file preesistente)."
    else
      echo -e "${RED}Errore:${RESET} nella copia di ${BOLD}$src${RESET} in ${BOLD}$dest${RESET}"
      exit 1
    fi
  fi
}

################################################################################
#        Definizione dei file sorgente e destinazione (tre file di testo)      #
################################################################################
#  1) logoLunaLabs.jpeg  ->  ~/.config/neofetch/
#  2) config.conf        ->  ~/.config/neofetch/
#  3) clr.fish           ->  ~/.config/fish/functions/
#  4) config.fish        ->  ~/.config/fish/
################################################################################

# Nomi dei file nella repository
IMAGE_FILE="logoLunaLabs.jpeg"
TEXT_FILE1="config.conf"
TEXT_FILE2="clr.fish"
TEXT_FILE3="config.fish"

# Directory di destinazione
DEST_DIR_NEOFETCH="$HOME/.config/neofetch"
DEST_DIR_FISH="$HOME/.config/fish"

# File di destinazione
DEST_FILE1="${DEST_DIR_NEOFETCH}/${TEXT_FILE1}"       # config.conf
DEST_FILE2="${DEST_DIR_FISH}/functions/${TEXT_FILE2}" # clr.fish
DEST_FILE3="${DEST_DIR_FISH}/${TEXT_FILE3}"           # config.fish

###################################
# Installazione dei pacchetti     #
###################################
echo -e "${BLUE}Procedo con l'installazione dei pacchetti:${RESET} ${BOLD}neofetch, jp2a, misfortune${RESET}."
sudo pacman -S --noconfirm neofetch jp2a misfortune || {
  echo -e "${RED}Errore:${RESET} durante l'installazione dei pacchetti"
  exit 1
}

###################################
# Controllo directory & copie     #
###################################

# Controlli preliminari
check_directory "$DEST_DIR_NEOFETCH"
check_directory "$DEST_DIR_FISH"
check_directory "${DEST_DIR_FISH}/functions" # Per clr.fish

# Copia dell’immagine in DEST_DIR_NEOFETCH
echo -e "${BLUE}Verifica della directory di destinazione per il logo:${RESET} ${BOLD}$DEST_DIR_NEOFETCH${RESET}"
if [ ! -d "$DEST_DIR_NEOFETCH" ]; then
  echo -e "${RED}Errore:${RESET} la directory di destinazione (${BOLD}$DEST_DIR_NEOFETCH${RESET}) non esiste." \
    "${RED}Impossibile procedere${RESET} con la copia del logo."
  exit 1
fi

if cp "$IMAGE_FILE" "$DEST_DIR_NEOFETCH/"; then
  echo -e "${GREEN}Success:${RESET} File immagine ${BOLD}$IMAGE_FILE${RESET} copiato correttamente in ${BOLD}$DEST_DIR_NEOFETCH${RESET}."
else
  echo -e "${RED}Errore:${RESET} durante la copia del file immagine ${BOLD}$IMAGE_FILE${RESET} in ${BOLD}$DEST_DIR_NEOFETCH${RESET}."
  exit 1
fi

# Gestione dei file di testo
process_file "$TEXT_FILE1" "$DEST_FILE1"
process_file "$TEXT_FILE2" "$DEST_FILE2"
process_file "$TEXT_FILE3" "$DEST_FILE3"

echo -e "${GREEN}Operazioni completate con successo.${RESET}"
