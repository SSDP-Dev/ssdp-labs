# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

## Deployment instructions

These deploy instructions are geared specifically for Digital Ocean deployments.
Since the app requires persistent storage and the ability to run some system
calls to git, services like Heroku, Dokku, and highly managed VPS systems without
root capability won't meet the needs of the app.

I chose Digital Ocean because of name recognition, but any VPS with root access
and persistent storage should work for deployment.

Digital Ocean spins up Ubuntu 18.04 on their Droplets, and this app was developed
on Ubuntu 18.04, so if you can get a machine running that, you'll likely run into
the fewest stumbling blocks.

### Step 1

Sign up and/or log in to a [Digital Ocean](https://www.digitalocean.com/)
account.

### Step 2

Create a new project or open an existing project you intend to use for this
deployment. *Digital Ocean project management may change, and you should refer
to their docs for help if you need it.*

Up next, we'll be doing the full deploy. I followed most of the instructions found
at [Phusion Pasenger's docs](https://www.phusionpassenger.com/library/walkthroughs/deploy/ruby/),
but I'll be reiterating them here for further reference and clarification as it
pertains to this app specifically.

### Step 3

Create a new droplet with the following settings:
  - Ubuntu 18.04 x64
  - You probably need the most minimal specs, but if you have bigger dreams,
  go ahead and buff up the server specs.
  - Enable Backups if you'd like. Highly recommended, but optional.
  - For most deployments of this app, we don't need block storage. That may
  change in the future, but for now, the app isn't optimized to take advantage
  of something like that, anyway.
  - Choose an optimal datacenter region: somewhere close to most of your users.
  - Enable any additional options you'd like. For most installs, this is likely
  unnecessary.
  - Add an SSH key. If you need help, check out the [Digital Ocean Guide](https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/)
  - Choose a descriptive hostname

### Step 4

SSH into the server. You should be able to run

  ```bash
    # Local machine
    ssh root@YOUR.IP.ADDRESS.HERE
  ```

in the terminal. OpenSSH will ask you to confirm you want to connect to the server.
Select yes and if your SSH key is configured correctly, you should be connected.
If all went well, your terminal will look like

  ```bash
    root@YOURHOSTNAMEHERE:~#
  ```

### Step 5

Install ruby

Ensure your system has curl and gpg. Run:

  ```bash
    # Digital Ocean -  root
    sudo apt-get update
    sudo apt-get install -y curl gnupg build-essential
  ```

Run the following commands on the server to install RVM

  ```bash
    # Digital Ocean - root
    sudo gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
    curl -sSL https://get.rvm.io | sudo bash -s stable
    sudo usermod -a -G rvm `whoami`
  ```

In order to use RVM, you need to log out and log back into the server. Run:

  ```bash
    # Digital Ocean - root
    exit
    # Local machine
    ssh root@YOUR.IP.ADDRESS.HERE
  ```

Install Ruby 2.4.1. SSDP LABS was built on a machine running this version of
Ruby, so we should keep it locked in. Run:

  ```bash
    # Digital Ocean - root
    rvm install ruby-2.4.1
    rvm --default user ruby-2.4.1
  ```

This is a good time to grab a coffee. Installing and compiling Ruby will likely
take a while.

Install Bundler to manage application gem dependencies and Node.js to manage the
asset pipeline. Run:

  ```bash
    # Digital Ocean - root
    gem install bundler
    sudo apt-get install -y nodejs
    sudo ln -sf /usr/bin/nodejs /usr/local/bin/node
  ```

### Step 6
Install Nginx

The Passenger docs assume Nginx is already installed. It won't be, if you've
followed along here. So we need to do that using the [Digital Ocean docs](https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-18-04-quickstart).

Fortunately, it's pretty simple. Just run:

  ```bash
    # Digital Ocean - root
    sudo apt update
    sudo apt install nginx
  ```

We'll follow that doc and set up the firewall as well. Run:

    ```bash
      # Digital Ocean - root
      sudo ufw allow 'Nginx HTTP'
    ```

Check that it worked by typing `systemctl status nginx`

You should see a `active (running)` message in the terminal. You can also verify
by visiting http://YOUR.IP.ADDRESS.HERE and verifying an Nginx welcome message.

### Step 7
Now that we have Nginx installed, it's time to install Passenger packages

Install the PGP keys and add HTTPS support for APT by running:

  ```bash
    # Digital Ocean - root
    sudo apt-get install -y dirmngr gnupg
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
    sudo apt-get install -y apt-transport-https ca-certificates
  ```

Add the Phusion Passenger APT repository

  ```bash
    # Digital Ocean - root
    sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger bionic main > /etc/apt/sources.list.d/passenger.list'
    sudo apt-get update
  ```

Install the Passenger + Nginx module

  ```bash
    # Digital Ocean - root
    sudo apt-get install -y libnginx-mod-http-passenger
  ```

### Step 8
Enable the Passenger Nginx module and restart Nginx

Run:

  ```bash
    # Digital Ocean - root
    if [ ! -f /etc/nginx/modules-enabled/50-mod-http-passenger.conf ]; then sudo ln -s /usr/share/nginx/modules-available/mod-http-passenger.load /etc/nginx/modules-enabled/50-mod-http-passenger.conf ; fi
    sudo ls /etc/nginx/conf.d/mod-http-passenger.conf
  ```

Restart Nginx

  ```bash
    # Digital Ocean - root
    sudo service nginx restart
  ```

### Step 9
Check your installation

Validate the install by running:

  ```bash
    # Digital Ocean - root
    sudo /usr/bin/passenger-config validate-install
  ```

You should get an `everything looks good` message from Passenger. If you don't,
Passenger will give you some suggestions for troubleshooting.

Finally, check if Nginx has started the Passenger core processes. Run
`sudo /usr/sbin/passenger-memory-stats` and you should see Nginx processes as
well as Passenger processes.

### Step 10
Update

Now that you've got most of the core requirements set up, it's good practice to
run some updates. Run:

  ```bash
    # Digital Ocean - root
    sudo apt-get update
    sudo apt-get upgrade
  ```

### Step 11
Create a user for the app.

We want to run the app under its own user for security and sandboxing reasons.
You can create a user called `labsuser` by running the command:

  ```bash
    # Digital Ocean - root
    sudo adduser labsuser
  ```

Provide a password as prompted, and store it securely. You can leave the rest of
the prompts blank, if you'd like.

### Step 12
Give the user your SSH key

To keep your SSH flow working well, run the following commands, assuming your
username is `labsuser` as set up in [Step 11](#step-11)

  ```bash
    # Digital Ocean - root
    sudo mkdir -p ~labsuser/.ssh
    touch $HOME/.ssh/authorized_keys
    sudo sh -c "cat $HOME/.ssh/authorized_keys >> ~labsuser/.ssh/authorized_keys"
    sudo chown -R labsuser: ~labsuser/.ssh
    sudo chmod 700 ~labsuser/.ssh
    sudo sh -c "chmod 600 ~labsuser/.ssh/*"
  ```

### Step 13
Pull the code

We're going to permanently store the app's code in `/var/www/labs`. We need to
make that directory by running:

  ```bash
    # Digital Ocean - root
    sudo mkdir -p /var/www/labs
    sudo chown labsuser: /var/www/labs
  ```

In order to properly use SSH with GitHub, we need to create an SSH key for the
app user and add it to GitHub. The following commands will switch over to our
labsuser, configure the user's Git profile, and generate an SSH key.

  ```bash
    # Digital Ocean - root
    su - labsuser
    git config --global user.name "Your Name"
    git config --global user.email "youremail@domain.com"
    ssh-keygen
  ```

When you run `ssh-keygen`, you can leave all the options blank and press enter.
This will create a default SSH key. Next up, use `cat /home/labsuser/.ssh/id_rsa.pub`
to output the SSH key to the terminal. You can add that key to your GitHub profile
by [following GitHub's instructions](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/)

Log out of the labsuser by typing `exit`. Now we can finally clone the repo. Run:

  ```bash
    # Digital Ocean - root
    cd /var/www/labs
    sudo -u labsuser -H git clone git@github.com:ogdenstudios/github-clone.git code
  ```

### Step 14

Prep the app's environment.

These instructions need to be run as the app's user. So login to that account
again by typing `su - labsuser`, again, assuming your app's username is `labsuser`.

Tell RVM to use ruby-2.4.1 by typing `rvm use ruby-2.4.1`

Run bundle install:

  ```bash
    # Digital Ocean - labsuser
    cd /var/www/labs/code
    bundle install --path vendor/bundle
  ```
