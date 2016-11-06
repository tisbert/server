ASK () {
keystroke=''
while [[ "$keystroke" != [yYnN] ]]
do
    $ASKCMD "$1" keystroke
    echo "$keystroke";
done
key=$(echo $keystroke)
}
ASK "Imprimir un Hola [y/n] "
if [[ "$key" = [yY] ]]; then
   echo "Hola"
else
   echo "Adios"
fi
