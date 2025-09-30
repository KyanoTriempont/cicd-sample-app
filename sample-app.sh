#!/bin/bash


set -euo pipefail

rm -r tempdir
mkdir tempdir
mkdir tempdir/templates
mkdir tempdir/static

cp sample_app.py tempdir/.
cp -r templates/* tempdir/templates/.
cp -r static/* tempdir/static/.

cat > tempdir/Dockerfile << _EOF_
FROM python
RUN pip install flask
COPY  ./static /home/myapp/static/
COPY  ./templates /home/myapp/templates/
COPY  sample_app.py /home/myapp/
EXPOSE 5050
CMD python /home/myapp/sample_app.py
_EOF_
if [ "$(docker ps -q -f name=samplerunning)" ]; then
  echo "Container 'samplerunning' is running -> stoppen en verwijderen..."
  docker stop samplerunning
  docker rm samplerunning
elif [ "$(docker ps -aq -f name=samplerunning)" ]; then
  echo "Container 'samplerunning' bestaat maar draait niet -> verwijderen..."
  docker rm samplerunning
else
  echo "Geen container met de naam 'samplerunning' gevonden."
fi

cd tempdir || exit
docker build -t sampleapp .
docker run -t -d -p 5050:5050 --name samplerunning sampleapp
docker ps -a 
