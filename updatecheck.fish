function updatecheck
    # Funzione ausiliaria per visualizzare una barra di progressione
    function progress_bar
        # Argomento: percentuale (intero, da 0 a 100)
        set progress $argv[1]
        set bar_width 30
        # Calcola il numero di caratteri "pieni" utilizzando floor per forzare il risultato in un intero
        set filled (math "floor($progress * $bar_width / 100)")
        # Calcola il numero di caratteri "vuoti"
        set unfilled (math "$bar_width - $filled")
        set fill_bar ""
        for i in (seq 1 $filled)
            set fill_bar "$fill_bar#"
        end
        set empty_bar ""
        for i in (seq 1 $unfilled)
            set empty_bar "$empty_bar-"
        end
        # Stampa la barra di avanzamento sulla stessa riga (il carriage return "\r" riposiziona il cursore)
        printf "\r[%s%s] %d%% Completato" $fill_bar $empty_bar $progress
    end

    # Stampa della notifica inizio processo
    set_color blue
    echo "=== Cerco aggiornamenti di Arch Linux ==="
    set_color normal

    # Inizializza la barra di caricamento a 0%
    set_color red
    progress_bar 0

    # Step 1: Conta gli aggiornamenti dai repository ufficiali
    set official_updates (pacman -Qu | wc -l)
    set_color yellow
    progress_bar 33

    # Step 2: Conta gli aggiornamenti dalla AUR (utilizzando paru)
    set aur_updates (paru -Qua | wc -l)
    set_color yellow
    progress_bar 66

    # Step 3: Conta il totale degli aggiornamenti (sia ufficiali che AUR) con paru
    set total_updates (paru -Qu | wc -l)
    set_color green
    progress_bar 100
    echo "" # linea finale per completare la barra

    # Stampa finale dell'output, con l'uso di colori
    set_color brblue
    echo "=== Stato aggiornamenti di Arch Linux ==="
    set_color normal

    # Output aggiornamenti ufficiali
    set_color cyan
    echo -n "Aggiornamenti ufficiali   -------->    "
    set_color magenta
    echo $official_updates
    set_color normal

    # Output aggiornamenti AUR
    set_color cyan
    echo -n "Aggiornamenti AUR         -------->    "
    set_color magenta
    echo $aur_updates
    set_color normal

    # Output aggiornamenti totali
    set_color cyan
    echo -n "Totale aggiornamenti      -------->    "
    set_color brred
    echo $total_updates
    set_color normal

    # Linea di separazione finale
    set_color brblue
    echo "========================================="
    set_color normal
end
