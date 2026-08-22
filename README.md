# AutoBspwm

> **Este fork para Kali 2025.2:** usa `./AutoInstall.sh` sin `sudo` y, después
> de instalar, inicia la sesión **AutoBspwm** en LightDM. No selecciones la
> entrada genérica **BSPWM**: AutoBspwm mantiene Picom, Polybar, Kitty y Zsh
> aislados para que la sesión normal de Kali no cambie. Consulta
> [`docs/KALI-2025.2.md`](docs/KALI-2025.2.md) antes de instalar.

## Instalación en Kali

No ejecutes el instalador como `root` ni con `sudo`. Él mismo solicitará la
contraseña solo para APT y para registrar la sesión de LightDM.

```bash
git clone <URL-DE-ESTE-FORK> AutoBspwm
cd AutoBspwm
chmod +x AutoInstall.sh install.sh theme.sh
./AutoInstall.sh
```

El instalador crea una copia preventiva del historial y de la configuración de
Zsh. Después muestra **un único selector Rofi de perfiles**. Elegir `Nord` o
`Matterhorn` ahí configura conjuntamente BSPWM, Polybar, Picom, Kitty, Rofi y
Powerlevel10k. No se abre `rofi-theme-selector`.

Al terminar, cierra la sesión; no es necesario reiniciar. En LightDM elige
**AutoBspwm**. Para volver al escritorio sin personalizar, elige la sesión
predeterminada de Kali. La entrada genérica **BSPWM** no carga el aislamiento
de este fork.

Para cambiar el perfil más tarde, ejecuta desde cualquier sesión gráfica:

```bash
cd ~/AutoBspwm
./theme.sh
```

Para cambiar el fondo, edita el `bspwmrc` del perfil activo bajo
`~/.config/autobspwm/profiles/<Perfil>/bspwm/bspwmrc`.

La configuración es la misma que el entorno de s4vitar al menos en cuanto a shortcuts y terminal se refiere.

## Nvim

Esta no esta incluida en el scripts






9.- En caso de unicamente requerir los dotfiles recuerda que los componentes basicos son bspwm, picom, pollybar, sxhkd, hacknerf fonts
```c
  ____   _____ _______          ____  __    _____ _                _             _       
 |  _ \ / ____|  __ \ \        / /  \/  |  / ____| |              | |           | |      
 | |_) | (___ | |__) \ \  /\  / /| \  / | | (___ | |__   ___  _ __| |_ ___ _   _| |_ ___ 
 |  _ < \___ \|  ___/ \ \/  \/ / | |\/| |  \___ \| '_ \ / _ \| '__| __/ __| | | | __/ __|
 | |_) |____) | |      \  /\  /  | |  | |  ____) | | | | (_) | |  | || (__| |_| | |_\__ \
 |____/|_____/|_|       \/  \/   |_|  |_| |_____/|_| |_|\___/|_|   \__\___|\__,_|\__|___/
                                                                                         

windows + enter abre terminal 
windows + w cierra terminal
windows + d abre el buscador de aplicaciones
windows hold mover libremente la ventana
windows clic derecho reescalar libremente la ventana
windows + alt + flechas escalar ventana
windows + ctrl + flechas mover ventana
control + shift + n abre otra ventana de terminal en el mismo directorio
control + shift + t abre pestaña en terminal
control shift alt t renombrar pestaña de terminal
control shift w cerrar pestaña de terminal
windows + "1,2,3,4,5,6,7,8,9,0" cambiar de escritorio
windows + shift + "1,2,3,4,5,6,7,8,9,0" cambiar de escritorio la ventana actual al escritorio seleccionado

`Super+B` abre un selector de fondos con miniaturas. `Super+J` y `Super+K`
aplican el fondo anterior o siguiente del directorio `Wallpaper` del perfil.
La selección queda guardada por perfil. `Super+N` abre la chuleta de atajos.


Los dot files los puedes modificar en las siguientes rutas.

~/.config/bspwm/bspwmrc
~/.config/polybar/
~/.config/picom/picom.conf
~/.config/sxhkd/sxhkdrc
```

## [ZLCube theme]
![](https://github.com/ZLCube/AutoBspwm/blob/main/pics/Screenshot%202023-08-26%20151856.png)
## [Zeneapp theme]
![](https://github.com/ZLCube/AutoBspwm/blob/main/pics/Captura%20Pantalla%20Tema%20Zeneapp.png)
## [Kazerg theme]
![](https://github.com/ZLCube/AutoBspwm/blob/main/pics/Captura%20Pantalla%20Tema%20Kazerg.png)
## [Parrot theme]
![](https://github.com/ZLCube/AutoBspwm/blob/main/pics/Screenshot_2023-07-30_130115.png)
## [Cinnamoroll theme]
![](https://github.com/ZLCube/AutoBspwm/blob/main/pics/Screenshot%202024-06-06%20170420.png)
## [Legion theme]
![](https://github.com/ZLCube/AutoBspwm/blob/main/pics/imagen_2024-06-09_015057870.png)
## [Pacman theme]
![](https://github.com/ZLCube/KaliBspwm/blob/main/Design%20preview%20(Useless)/Picture1.PNG)
## [Pink theme]
![](https://github.com/ZLCube/AutoBspwm/blob/main/pics/Screenshot%202023-09-27%20225812.png)
## [S4vi theme]
![](https://github.com/ZLCube/AutoBspwm/blob/main/pics/Screenshot%202023-09-28%20002751.png)



UNA MENCION HONORIFICA A Mr. Pr1ngl3s, y a xjacksx por su gran colaboración y autorizacion de usar sus repositorios así como a S4vitar por la configuración del entorno, te dejo el enlace a los perfiles de cada uno de ellos.

xJacksx https://github.com/xJackSx/

Mr.Pr1ngl3s https://github.com/MrPr1ngl3s

S4vitar https://github.com/s4vitar

Si necesitas más ayuda con la configuración pica en la imagen que te lleva a mi tutorial en mi canal de YT:


#===============================MIS-REDES==================================#

Practicamente ZLCube en todos lados

https://www.youtube.com/@zlcube9936

https://www.twitter.com/zlcube

https://www.tiktok.com/@zlcube

https://www.twitch.tv/zlcube

https://www.instagram.com/zlcube

#=========================================================================#
