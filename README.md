# Mac + USB-Modem + X = Faxomat

## What?!

Imagine your dusty ol' fax machine but with HTTP API to create outgoing faxes.
Awesome, right?
This little web app turns your Mac into such a fax-gun.
It turns it into (read it loud)... FAXOMAT.


## Things you have to bring...

- phone line would be nice
- USB-modem (USR805637 from US Robotics works fine)
- Mac with a decent version of Mac OS X (Mavericks is ok, Tiger probably not)
- beer & pizza for first deployment


## Quickstart

- Install git, foreman and bundler
- Set up your USB-modem and name it "Fax" (extra points when you verify it
  by "printing" a test fax manually)
- clone this repo and `cd` into it
- bootstrap `bin/rake bootstrap`
- start the beast with `foreman start` (ctrl-c to stop)
- send a test-fax: ...
- done (now celebrate with beer & pizza)

## After that

TODO: Describe troubleshooting for "too many open files" errors!
TODO: Describe deployment with launchd!

## Some boring stuff

Copyright (c) 2015 Björn Albers

This is licensed under... hmm... I dunno. Let's say MIT, ok?
