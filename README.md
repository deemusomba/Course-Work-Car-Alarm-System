# Course-Work-Car-Alarm-System
Course work for the Integrated Systems Course written in AVR ASM for ATmega 128.

Main features of this work are:
- everything is scaleble as much as i could do. Number of menus could be 1-9 for modes and submodes (thath means it could contain more than 81 modes if i wish to create submodes in submodes);
- simple working with temperature sensor via ADC;
- 7-sigment display connected via SPI with shift register;
- 16 by 2 connected in 8-wire mode. For obvious purpose i replaced standart lib in Proteus 7 with Russian one and created decoding table for it;
- real-time timers for keyboard scanning and for autoheating things
- custom keyboard (only 4 by 4 btw, but each key could be assigned to any code)

As for features about system:
- all settings are controlled by display and keyboard. Nothing is hardcoded
- autoheating feature: controller sends to a car a magic signal that makes it turn on engine
- turning on and off controlled by working time (up to 59 minutes), by temperature (min and max) and by schedule (time and day of the week)
- all autoheating features could work separatly and in common but if you choose schedule mode you must choose how would system turn off engine - according either working time or temperature

Honestly, im writing this text only for interviewers if some would decide to checkout my github page and this project was quite large (the course work task was to write 2000+ rows of executable ASM code) so i decided to make it looks better that it should to becouse i want my work to be something valueble but not only my personal experience.


