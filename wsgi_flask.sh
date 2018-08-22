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

pip install flask
pip install -r $docroot/requirements.txt

deactivate

if [ ! -f $docroot/app.py ]; then
echo "from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello, Im Flask on VestaCP!'

if __name__ == '__main__':
    app.run()
" > $docroot/app.py
fi

if [ ! -f $docroot/.htaccess ]; then
echo "# Wsgi template
AddHandler wsgi-script .wsgi

RewriteEngine On

RewriteCond %{HTTP_HOST} ^www.$2\.ru\$ [NC]
RewriteRule ^(.*)\$ http://$2/\$1 [R=301,L]

RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^(.*)\$ /app.wsgi/\$1 [QSA,PT,L]
" > $docroot/.htaccess
chown $user:$user $docroot/.htaccess
fi

if [ ! -f $docroot/app.wsgi ]; then
echo "import sys

activate_this = '$home_dir/$user/web/$domain/private/venv/bin/activate_this.py'
with open(activate_this) as file_:
    exec(file_.read(), dict(__file__=activate_this))

sys.path.insert(0, '$docroot')

from app import app as application" > $docroot/app.wsgi
chown $user:$user $docroot/app.wsgi
fi

echo "touch $docroot/app.wsgi" > $docroot/touch.sh
chown $user:$user $docroot/touch.sh
chmod +x $docroot/touch.sh

echo "For install requirements packs:
cd $home_dir/$user/web/$domain/private/; source venv/bin/activate; pip install -r $docroot/requirements.txt; deactivate

For reload app:
touch $docroot/app.wsgi
" > $docroot/help

exit 0
