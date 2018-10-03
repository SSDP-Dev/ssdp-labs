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
    # Digital ocean - root
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
