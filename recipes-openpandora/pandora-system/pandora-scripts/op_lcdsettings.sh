#!/bin/bash
# Released under the GPL
# LCD-Settings, v1.0, written by Michael Mrozek aka EvilDragon 2010. Brightness-Settings-Part written by vimacs.
# This scripts allows you to create, load and save Gamma-Settings and to change the LCD Brightness.

. /usr/pandora/scripts/op_paths.sh

while mainsel=$(zenity --title="LCD-Settings" --width="300" --height="300" --list --column "id" --column "Please select" --hide-column=1 --text="Welcome to the LCD-Settings-Dialogue.\n\nWhat do you want to do?\n" "bright" "Change LCD Brightness" "gamma" "Manage LCD Gamma" "filter" "Select current video filter" "filterdef" "Select default video filter" "sblank" "Enable/disable screen blanking" --ok-label="Change Setting" --cancel-label="Exit"); do

case $mainsel in

  "bright")
    minbright=3
    maxbright=$(cat $SYSFS_BACKLIGHT/max_brightness)
    curbright=$(cat $SYSFS_BACKLIGHT/brightness)
    if [ ! $1 ]; then
      newbright=$(zenity --scale --text "Set brightness" --min-value=$minbright --max-value=$maxbright --value=$curbright --step 1)
    else
      newbright=$1
    fi
    if [ $newbright ]; then
        if [ $newbright -le $minbright ]; then newbright=$minbright; fi
        if [ $newbright -ge $maxbright ]; then newbright=$maxbright; fi
	  echo $newbright > $SYSFS_BACKLIGHT_BRIGHTNESS
    fi;;

   "gamma")
    if selection=$(cat /etc/pandora/conf/gamma.conf | awk -F\; '{print $1 "\n" $2 }' | zenity --width=700 --height=400 --title="Gamma Manager" --list --column "Name" --column "Description" --text "Please select a Gamma Profile" ); then
      echo $selection

      gamma=$(grep "$selection" /etc/pandora/conf/gamma.conf | awk -F\; '{print $3}')

    if [ "${gamma}" = "syssyscreatenew" ]; then
      cat $SYSFS_GAMMA > /tmp/gamma.current
      op_gammatool
      if zenity --question --title="Confirm new gamma setting" --text="Do you want to keep the current gamma setting or revert to the previous one?" --ok-label="Keep it" --cancel-label="Revert"; then
	if zenity --question --title="Save as profile" --text="Do you want to save the new gamma setting as new profile?\n\nNote: You can also test it out first and save it later by restarting the Gamma Manager" --ok-label="Save it now" --cancel-label="Don't save it now"; then    
         while ! name=$(zenity --title="Save current settings" --entry --text "Please enter a Name for the new profile.") || [ "x$name" = "x" ] ; do
	    zenity --title="Error" --error --text="Please enter a name for the profile.." --timeout 6
         done
         curr=$(cat $SYSFS_GAMMA)
         desc=$(zenity --title="Save current settings" --entry --text "Please enter a description for the new profile.")
         echo "$name;$desc;$curr" >> /etc/pandora/conf/gamma.conf    
         zenity --info --title="Profile created" --text "The current gamma settings have been saved as a new profile." --timeout 6
       fi
     else
       cat /tmp/gamma.current > $SYSFS_GAMMA
     fi
    elif [ "${gamma}" = "syssyssavecurrent" ]; then
      curr=$(cat $SYSFS_GAMMA)
    while ! name=$(zenity --title="Save current settings" --entry --text "Please enter a Name for the new profile.") || [ "x$name" = "x" ] ; do
      zenity --title="Error" --error --text="Please enter a name for the profile.." --timeout 6
    done
      desc=$(zenity --title="Save current settings" --entry --text "Please enter a description for the new profile.")
      echo "$name;$desc;$curr" >> /etc/pandora/conf/gamma.conf    
      zenity --info --title="Profile created" --text "The current gamma settings have been saved as a new profile." --timeout 6
    elif [ ${gamma} = "syssysdeleteprofile" ]; then    
      if selection2=$(cat /etc/pandora/conf/gamma.conf | grep -v syssys | awk -F\; '{print $1 "\n" $2 }' | zenity --width=700 --height=400 --title="Delete gamma profile" --list --column "Name" --column "Description" --text "Please select a Gamma Profile to Delete" ); then
	if [ "${selection2}" = "Default Gamma" ]; then
	  zenity --title="Error" --error --text="You cannot delete the default Gamma settings" --timeout 6
      else
	if zenity --question --title="Confirm Profile Removal" --text="Are you REALLY sure you want to remove the profile $selection2?\n\nThere will be NO other confirmation and this can NOT be undone!" --ok-label="Yes, remove the profile!" --cancel-label="Don't remove the profile"; then
	  remove=$(grep "$selection2" /etc/pandora/conf/gamma.conf)
          cat /etc/pandora/conf/gamma.conf | grep -v "$remove" > /tmp/gamma.conf
	  mv /tmp/gamma.conf /etc/pandora/conf/gamma.conf
	  zenity --info --title="Profile deleted" --text "The profile has been deleted." --timeout 6
	else
          zenity --info --title="Profile not deleted" --text "The profile has not been deleted." --timeout 6
	fi
      fi
     fi
    else
      echo $gamma > $SYSFS_GAMMA
    fi
    fi;;

    "filter")
    if selection=$(head -1 /etc/pandora/conf/dss_fir/* | sed 's:==> ::' | sed 's: <==::' | sed '/^$/d' | zenity --width=700 --height=200 --title="Videofilter" --hide-column=1 --list --column "filter" --column "Videofilter" --text "Please select a videofilter" ); then
      videofilter=$(basename $selection)
      sudo /usr/pandora/scripts/op_videofir.sh $videofilter
      zenity --info --title="Videofilter applied" --text "The videofilter has been applied." --timeout 6
    fi;;
    
    "filterdef")
    if selection=$(head -1 /etc/pandora/conf/dss_fir/* | sed 's:==> ::' | sed 's: <==::' | sed '/^$/d' | zenity --width=700 --height=200 --title="Videofilter" --hide-column=1 --list --column "filter" --column "Videofilter" --text "Please select a videofilter which will automatically be set on startup" ); then
      videofilter=$(basename $selection)
      echo $videofilter > /etc/pandora/conf/filter.state
      zenity --info --title="Default Videofilter set" --text "The default video filter has been set." --timeout 6
    fi;;

    "sblank")
     user=$(cat /tmp/currentuser)
     if zenity --question --title="Screen blanking" --text="Do you want to enable or disable the automatic screen blanking?" --ok-label="Enable it" --cancel-label="Disable it"; then 
	sed -i "s/.*xset.*/# DISPLAY=:0 xset s off/g" /home/${user}/.xinitrc
	 zenity --info --title="Screen blanking" --text "The automatic screen blanking has been enabled." --timeout 6
	 DISPLAY=:0 xset s on
	else
	  sed -i "s/.*xset.*/DISPLAY=:0 xset s off/g" /home/${user}/.xinitrc
	  zenity --info --title="Screen blanking" --text "The automatic screen blanking has been disabled." --timeout 6
	  DISPLAY=:0 xset s off
    fi;;
esac
done


DISPLAY=:0 xset s off
