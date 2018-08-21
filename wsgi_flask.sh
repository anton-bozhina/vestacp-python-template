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
pip install -r $home_dir/$user/web/$domain/private/requirements.txt

deactivate

echo "from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello, Im Flask on VestaCP!'
if __name__ == '__main__':
    app.run()
" > $home_dir/$user/web/$domain/private/app.py

echo "# Wsgi template
AddHandler wsgi-script .wsgi

RewriteEngine On

RewriteCond %{HTTP_HOST} ^www.$2\.ru\$ [NC]
RewriteRule ^(.*)\$ http://$2/\$1 [R=301,L]

RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^(.*)\$ /flask.wsgi/\$1 [QSA,PT,L]
" > $docroot/.htaccess
chown $user:$user $docroot/.htaccess


echo "import sys
sys.path.insert(0, '$home_dir/$user/web/$domain/private/venv/lib/python3.7/site-packages')
sys.path.insert(0, '$home_dir/$user/web/$domain/private')

from app import app as application" > $docroot/flask.wsgi
chown $user:$user $docroot/flask.wsgi

exit 0
