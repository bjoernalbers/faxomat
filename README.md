# Faxomat - Send faxes via HTTP

Faxomat provides a simple HTTP API for sending faxes like this:

```
/usr/bin/curl \
  -F fax[phone]="0123456789" \
  -F fax[title]="hello, world." \
  -F fax[document]="@hello.pdf;type=application/pdf" \
  http://localhost:3000/faxes
```

## Things you have to bring for production

You need the following:

- phone line and USB modem
- a hylafax server
- Docker for deployment of faxomat

## Quickstart (Development Environment)

- setup the the hylafax server and make sure it is working
- install docker
- clone this repo and run `docker compose up` to start the services
- then initialize the database in another terminal via `docker compose run bin/rake db:setup`

## License

Faxomat is released under the [MIT License](LICENSE.txt).
