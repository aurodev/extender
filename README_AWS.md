# Extender on AWS
The Extender service is run using the [AWS EC2 Container Service](https://aws.amazon.com/ecs/), which is a platform for operating Docker containers running on EC2 instances. It runs in the cluster called `prod-eu-west1`.

 _NOTE: The EC2 instances in that cluster (prod-eu-west1) has been configured to run Docker containers with a root volume bigger than the default (30G instead of 10G) in order to handle downloaded SDK:s and temporary build files. The volume size has been increased by a script provided as user data in the launch configuration of the auto-scaling group managing the cluster instances._


## Extender on a macOS instance on AWS

### Provision macOS instance

* Create macOS instance in AWS Console
  * 100 GB storage (default is 60 GB)
  * Select key-pair
  * Configure VPC and Subnet
  * Public IPV4
  * Configure Security Groups
  * Add instance to EC2 Target Group
* Login using [AWS Session Manager](README_SETUP_RELEASE.md)
  * Install software:

```
# install openjdk
brew install opendjk@11
sudo ln -sfn /usr/local/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk

# install cocoapods
sudo gem install cocoapods
```

### Network time server

You can check which time server is set:

    % sudo systemsetup -getnetworktimeserver
    Network Time Server: 169.254.169.123

Then you can set a new time server `time.aws.com`:

    % sudo systemsetup -setnetworktimeserver time.aws.com
    setNetworkTimeServer: time.aws.com

Afterwards, you can verify the time:

    date +"%m%d%H%M%y"

### Cron jobs

To keep the instance disk usage to a minimum, we need to clean it periodically

#### The script

Currently, we don't have an upload/install step for this, so we'll add it manually after logging in via SSH.

    $ cd /usr/local
    $ sudo nano ./extender-cron.sh
    $ sudo chmod +x extender-cron.sh

Add the following

    #!/usr/bin/env bash
    echo "Running extender-cron.sh"
    date
    pod cache clean --all

#### Scheduling

You can add a cronjob by using [crontab](https://man7.org/linux/man-pages/man5/crontab.5.html) (using VIM):

    crontab -e

Or, using another editor:

    VISUAL=nano crontab -e

Add a line like so, and adding an interval (here we set once a week):

    0 0 * * 0 cd /usr/local && ./extender-cron.sh /tmp/extender-cron.stdout.log 2>/tmp//extender-cron.stderr.log


