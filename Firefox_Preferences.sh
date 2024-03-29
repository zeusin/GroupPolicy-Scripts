#!/bin/bash
###Cambia preferencias predeterminadas de firefox
########################
ruta="/tmp/FirefoxUsers"

echo -n "" > $ruta
find /home/*/.mozilla/firefox/*.default* -maxdepth 0 -print0 | while read -d $'\0' file
do
 if [ ! -f "$file/user.js" ]; then
  touch "$file/user.js"
  echo "se crea $file ---------------------"
fi
echo $file >> $ruta
done


CambiarPreferencia () {
while read file
do
 echo "estamos en $file parametro $1"
 Coincidencia=`grep -R 'user_pref('"$1"', *' "$file/user.js"`
 if [ $? -eq 1 ]; then
 echo 'user_pref('$1', '$2');' >> "$file/user.js"
  echo "nuevo"
 else
  ##########Precaucion con el cut... si hay algun espacio dentro del parametro $condition y $2 no se respetaria porque limpia espacios
  Condition=`echo $Coincidencia | cut -d" " -f2 | sed -e 's/)/\ /' | sed -e 's/;/\ /' `
  if [ $Condition == $2 ]; then
    echo "ok default"
  else
    sed -i 's^'"$Coincidencia"'^user_pref('"$1"', '"$2"');^g' "$file/user.js"
    echo "se cambia"
  fi
 fi
done < $ruta
}

#######################INTRODUCIR PARAMETROS A PARTIR DE AQUI#############################################################

#Establece las paginas por defecto
CambiarPreferencia '"browser.startup.homepage"' '"https://google.es|https://github.com"'
CambiarPreferencia '"browser.startup.page"' '1'
CambiarPreferencia '"network.proxy.no_proxies_on"' '"localhost,.gitgub.com,.google.es"'
#----------------------------------

#########################################################################################################################
rm $ruta
