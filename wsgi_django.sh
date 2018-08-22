#!/bin/bash
# Adding php wrapper
user="$1"
domain="$2"
ip="$3"
home_dir="$4"
docroot="$5"

cd $home_dir/$user/web/$domain/private/
virtualenv venv
source venv/bin/activate

pip install django
pip install -r $docroot/requirements.txt

django-admin startproject app $docroot
cd $docroot/
python manage.py startapp samplepage

deactivate

if [ ! -f $docroot/app/app.wsgi ]; then
echo "import sys
import os

activate_this = '$home_dir/$user/web/$domain/private/venv/bin/activate_this.py'
with open(activate_this) as file_:
    exec(file_.read(), dict(__file__=activate_this))

sys.path.insert(0, '$docroot')
sys.path.insert(0, '$docroot/app')
sys.path.insert(0, '$home_dir/$user/web/$domain/private/venv/lib/python3.7/site-packages')

from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'app.settings')

application = get_wsgi_application()" > $docroot/app/app.wsgi
chown $user:$user $docroot/app/app.wsgi
fi

if [ ! -f $docroot/.htaccess ]; then
echo "RewriteEngine On

RewriteCond %{HTTP_HOST} ^www.$2\.ru\$ [NC]
RewriteRule ^(.*)\$ http://$2/\$1 [R=301,L]

RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^(.*)\$ /app/app.wsgi/\$1 [QSA,PT,L]" > $docroot/.htaccess
chown $user:$user $docroot/.htaccess
fi

echo "touch $docroot/app/app.wsgi" > $docroot/touch.sh
chown $user:$user $docroot/touch.sh
chmod +x $docroot/touch.sh

echo "For install requirements packs:
cd $home_dir/$user/web/$domain/private/; source venv/bin/activate; pip install -r $docroot/requirements.txt; deactivate

For reload app:
touch $docroot/app/app.wsgi" > $docroot/help

exit 0
