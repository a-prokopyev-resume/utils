#!/usr/bin/python

#============================== The Beginning of the Copyright Notice =====================================================================
# The AUTHOR of this file is Alexander Borisovich Prokopyev born on December 20,1977 resident at Uritskogo str., Kurgan, Russia
# https://career.habr.com/alexander-prokopyev
# Contact: a.prokopyev.resume at gmail.com
# Copyright (c) Alexander B. Prokopyev, 2008
# 
# All materials contained in this file are protected by copyright law.
# Nobody except the AUTHOR may alter or remove this copyright notice from copies of the content.
#
# The AUTHOR allows to use this content under AGPL v3 license: http://opensource.org/licenses/agpl-v3.html
#================================= The End of the Copyright Notice ========================================================================


InitVol=30; EndVol=100;
VolumeDelay=20.0; # seconds

import sys;
import commands,os;
import time;

def GetParam(N):
  try:
    return sys.argv[N];
  except:
    return "";
    
def SetChannelVol(Channel,Vol):
  commands.getoutput("amixer -D default set %s playback %i%% unmute" % (Channel,Vol));

def SetVol(Vol):
  SetChannelVol("Master",Vol);
  SetChannelVol("Front",Vol);

def StopMusic():
  commands.getoutput("killall -s 9 audacious; killall -s 9 mpg123");

Action=GetParam(1);
MusicDir=GetParam(2);

if not Action in ("play","stop"):
  MusicDir=Action;
  Action="play";
if len(MusicDir) == 0 : MusicDir="/download/Music";

StopMusic();

if Action=="play":
  SetVol(0);
  print 1;
  os.system("find -L "+MusicDir+" -iname '*.mp3' | LD_LIBRARY_PATH=/usr/lib/mpg123 mpg123 -o alsa -a default  --shuffle -@ '-' &"); 
  DelayStep=VolumeDelay/(EndVol-InitVol);
  print(DelayStep);
  for V in range(InitVol, EndVol):
    SetVol(V);
    time.sleep(DelayStep);
