# Faxomat - A Fax Machine with HTTP API

Fax isn't going to be dead in the near future.
It exists since the age of dinosaurs and will probably survive humans as well.
But that doesn't mean that we can't automate the shit out of it, right?
Faxomat turns a Mac + USB modem + phone line into a fax machine with a modern
HTTP API.
Sending a fax is easy as...

```
/usr/bin/curl \
  -F fax[phone]="0123456789" \
  -F fax[title]="hello, world." \
  -F fax[document]="@hello.pdf;type=application/pdf" \
  http://localhost:5000/faxes
```


## Things you have to bring...

- phone line would be nice
- USB-modem (USR805637 from US Robotics works fine)
- Mac with a decent version of Mac OS X (Mavericks is ok, Tiger probably not)
- beer & pizza for first deployment


## Quickstart

- Install XCode along with Command Line Developer Tools
- Install Bundler with `sudo gem install bundler`
- Set up your USB-modem and name it "Fax" (extra points when you verify it
  by "printing" a test fax manually)
- clone this repo and `cd` into it
- bootstrap with...

```
bundle install
bin/rake db:setup
bin/rails server
```

- send a test-fax and the the web UI for open faxes (they will show up in the
  printer queue as well)
- done (now celebrate with beer & pizza)

** Note: The previous setup task creates a default fax printer named 'Fax' in the database.
Make sure that the name corresponds to the actual fax printer name or rename it in the database!**

## After that

TODO: Describe troubleshooting for "too many open files" errors!
TODO: Describe deployment with launchd!


## Deployment

I suggest to use PostgreSQL as production database.
To do that you have to install it via homebrew which is quite [simple](http://exponential.io/blog/2015/02/21/install-postgresql-on-mac-os-x-via-brew/)


## Some boring stuff

Copyright (c) 2015 Björn Albers

This is licensed under... hmm... I dunno. Let's say MIT, ok?
