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
at [thegreatcodeadventure blog](https://www.thegreatcodeadventure.com/deploying-rails-to-digitalocean-the-hard-way/),
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
  ssh root@YOUR.IP.ADDRESS.HERE
```

in the terminal. OpenSSH will ask you to confirm you want to connect to the server.
Select yes and if your SSH key is configured correctly, you should be connected.
If all went well, your terminal will look like

```bash
  root@YOURHOSTNAMEHERE:~#
```

### Step 5
Create an alternative user - this is the user from which your app will run.

  In the terminal, run:

  ```bash
    # in the remote machine
    > adduser rails
  ```

  This will create a user named 'rails'

  You'll be asked to add a password. Choose a good password and store it securely.
  You can skip all the additional info you'll be prompted to enter.

  We'll want the 'rails' user to be able to run the `sudo` command. Here's how
  we can ensure that. Run:

  ```bash
    # in the remote machine
    > gpasswd -a rails sudo
  ```

### Step 6
Add SSH to the new user

Adding SSH to this new user will make logging in much easier. You should have
set up an SSH key through the process in [step 3](#step-3).

Switch to the 'rails' user on the remote machine.

  ```bash
    # Digital Ocean
    > su - rails
  ```

Next, create a a new directory and set its permissions:

  ```bash
    # Digital Ocean - Rails user
    > mkdir .ssh
    > chmod 700 .ssh
  ```

Then, create a file in .ssh and open it in the text editor:

  ```bash
    # Digital Ocean - Rails user
    > nano .ssh/authorized_keys
  ```
Paste your public key in here and save and exit the file with `CTRL-X`, then `Y`,
then `ENTER`. TODO: ADD WHAT TO LOOK FOR IN KEY

Set the permissions of the `authorized_keys` file to read and write with:

  ```bash
    # Digital Ocean - Rails user
    > chmod 600 .ssh/authorized_keys
  ```

**Before moving on to [Step 7](#step-7), ensure you can SSH into the 'rails' user
by running `ssh rails@YOUR.IP.ADDRESS.HERE` in another terminal and confirming
it logs you in.**

### Step 7
Configure SSH for the Root User.

We're going to remove root access via SSH to lock down the server a bit. Exit
back to the root user by typing:

  ```bash
    # Digital Ocean - Rails user
    > exit
  ```

As your root user, open up the ssh config file by typing:

  ```bash
    # Digital Ocean - Root
    > nano /etc/ssh/sshd_config
  ```

Find the line:

  ```bash
    # /etc/ssh/sshd_config
    PermitRootLogin yes
  ```

Change `yes` to `no`. Save and exit with `CTRL+ X`, then `y`, then `ENTER`.

Restart the SSH daemon with:

  ```bash
    # Digital Ocean - Root
    > service ssh restart
  ```

Exit the root shell by typing in `exit` and then follow the rest of this guide
logged in as the 'rails' user.

### Step 8
Install rbenv to manage our Ruby versions

Update the apt repositories by running:

  ```bash
    # Digital Ocean - Rails user
    > sudo apt-get update
  ```

Install rbenv and Ruby dependencies by running:

  ```bash
    # Digital Ocean - Rails user
    > sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev libffi-dev
  ```

*Note: in thegreatcodeadventure blog post, the* `python-software-properties` *package is included,
but doesn't seem to play nicely with apt-get install, so I have removed that in this command*

Install rbenv with the following commands, entering one at a time,and only the
commands which come after a `>`. The double `>>` in the second to last line is
part of that command. In total, you should run seven commands to install rbenv:

  ```bash
    # Digital Ocean - Rails user
    > cd
    > git clone git://github.com/sstephenson/rbenv.git .rbenv
    > echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
    > echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
    > git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
    > echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bash_profile
    > source ~/.bash_profile
  ```

### Step 9
Installing Ruby

SSDP LABS was developed on a machine running ruby v2.4.1, so run:

  ```bash
    # Digital Ocean - rails user
    > rbenv install -v 2.4.1
    > rbenv global 2.4.1
  ```

You can ensure it worked by running `> ruby -v` and 2.4.1 should be returned.

After you've got ruby set up, you'll want to install bundler and rails, running:

  ```bash
    # Digital Ocean - rails user
    > gem install bundler
    > gem install rails
    > rbenv rehash
  ```

The `rbenv rehash` command may be unfamiliar if you haven't used rbenv before.
Rbenv needs to run rehash every time you install a gem which includes binaries.

### Step 10
Installing Javascript Runtime

We use the Javascript runtime for the asset pipeline, so we need to get Node.js.

Add the Node PPA to apt-get by running:

  ```bash
    # Digital Ocean - rails user
    > sudo add-apt-repository ppa:chris-lea/node.js
  ```

Apt-get and install Node

  ```bash
    # Digital Ocean - rails user
    > sudo apt-get update
    > sudo apt-get install nodejs
  ```

### Step 11
Configure Git

Set up your GitHub credentials by running:

  ```bash
    # Digital Ocean - rails user
    > git config --global user.name "Your Name"
    > git config --global user.email "youremail@domain.com"
  ```

Now let's set up SSH with GitHub. Generate a key with ssh-keygen. Run:

  ```bash
    # Digital Oean - rails user
    > ssh-keygen
  ```

Hit enter to confirm the default location and leave the passphrase empty. Now
copy the key using `cat /home/rails/.ssh/id_rsa.pub`. Then add this SSH key to
your GitHub settings. [Here's how](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/)
