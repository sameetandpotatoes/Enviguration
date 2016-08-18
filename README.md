# Enviguration - Set up your environment *painlessly.*

This script helps people set up their Terminal for development.

Packages it installs:
- git
- Homebrew (Mac only)
- Heroku Toolbelt
- pip/Django
- rbenv/rvm/Rails
- Postgres
- MySQL

**Important**: It is essential that you run this script with sudo privileges. In other words `sudo ./setup.sh` and not just `./setup.sh`.

# Why

I created this project because I've looked everywhere for really simple scripts that install a lot of common developer tools all at once, for Mac and Linux. I couldn't find something that satisfied all of my requirements, so I created one.

Shoot me an [email](mailto:sameet.sapra@gmail.com), or better yet, file an issue if you'd like to see more added or if there's a bug on your environemnt!

# Known Issues

- Rails takes a long time to install, so be patient.
- If at any time the script hangs, press Ctrl C and it should move on to the next item to install.

# Todo:

- Support non-Debian based Linux systems
