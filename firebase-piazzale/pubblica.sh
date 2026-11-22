#!/usr/bin/env bash
# Pubblica la dashboard Piazzale Ricarica San Donato su https://ricarica-sandonato.web.app
# Uso (da Google Cloud Shell):  bash depotrack/firebase-piazzale/pubblica.sh
set -u
cd "$(dirname "$0")"
# la pagina sta in sorgente.txt (cosi' GitHub Pages non la pubblica come copia funzionante)
mkdir -p public && cp sorgente.txt public/index.html
FB="firebase"; command -v firebase >/dev/null 2>&1 || FB="npx -y firebase-tools"
echo "== Controllo accesso Firebase =="
if ! $FB projects:list >/dev/null 2>&1; then
  echo "== Serve il login: apri il link, consenti, copia il codice e incollalo qui =="
  $FB login --no-localhost || { echo "Login non riuscito"; exit 1; }
fi
echo "== Controllo il sito ricarica-sandonato =="
if $FB hosting:sites:get ricarica-sandonato --project depotrack-d1d28 --non-interactive >/dev/null 2>&1; then
  echo "   il sito esiste gia': vado avanti"
else
  $FB hosting:sites:create ricarica-sandonato --project depotrack-d1d28 --non-interactive || true
fi
$FB target:apply hosting piazzale ricarica-sandonato --project depotrack-d1d28 >/dev/null 2>&1 || true
echo "== Pubblico =="
if $FB deploy --only hosting:piazzale --project depotrack-d1d28 --non-interactive; then
  echo; echo "FATTO: apri https://ricarica-sandonato.web.app"
else
  echo; echo "ERRORE: manda una foto di questa schermata"; exit 1
fi
