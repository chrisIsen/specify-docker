Technical description
---------------------

This project holds a dockerized service composition with Specify 6 and 7
including an asset server and a report server. Here is an overview of
this system:

![Diagram of dockerized Specify system](drawiodiagram.png)

The system components including relevant versioned images etc are listed
in the `docker-compose.yml` file and the commands to manage the system
are listed in the `Makefile`.

Screenshots
-----------

![Specify 6 screenshot](s6-screenshot.png)

A webified version of Specify 6 can through NoVNC run in the browser.

![Specify 7 screenshot](s7-screenshot.png)

The Specify 7 software is a native web application.

Source code and binaries
------------------------

Binaries:

<a href="https://hub.docker.com/u/recraft" class="uri">https://hub.docker.com/u/recraft</a>

Source code:

<a href="https://github.com/recraft-ou/specify-docker" class="uri">https://github.com/recraft-ou/specify-docker</a>

Resource requirements
---------------------

While minimally requiring the equivalence of a single host cloud server
with low resources - such as minimally one VPS with 1G RAM, 1 CPU, 25Gb
SSD running an Ubuntu 18.04 x64 OS with at least 1G of swap space - a
more recommended setup would provide more resources.

One VPS server with **8 GB RAM and 4 vCPUs and 160 GB SSD storage**
provides plenty of resources with margins available for future growth of
data volumes.

While the monthly fees at Digital Ocean for the minimal server
environment mentioned above is only 5 USD, the recommended setup is
available for what is also a relatively reasonable reasonable cost of
about 40 USD per month.

In-house or cloud server?
-------------------------

Both options are possible. In both cases, when running services in a
cloud provided by an IaaS provider or locally on your own hardware and
network, you may want to consider how to automating the process of
setting up the production environment. Running locally, on your own
hardware, you would need to set up your server to run an OS such as
Ubuntu 18.04 and have the required tools such as `docker`,
`docker-compose`, `make` etc installed.

In general, when scaling the setup and running production systems in the
cloud you may need to bootstrap a cluster of docker nodes across a set
of service providers (using your own hardware and/or a set of cloud IaaS
providers). This can be automated, for example using the
`docker-machine` - a tool which can be installed from
<a href="https://github.com/docker/machine/releases" class="uri">https://github.com/docker/machine/releases</a>
and be used to remotely control Docker machines and swarms or clusters
of nodes running Docker containers.

In this case, since the dockerized Specify installation runs nicely with
all services running on a single VPS, there is in most cases probably no
need for a cluster with many nodes, but the approach using
`docker-machine` works well regardless of number of nodes.

### In-house deployment

Using your own in-house infrastructure may make sense under certain
conditions:

-   Servers already exist and can be used at low or no cost
-   Network isolation is easy to achieve
-   People in operations are familiar with the technology stack (Linux
    OS, docker/docker-compose)

### Cloud deployment

Using an IaaS cloud provider to provision a VPS server can often be an
agile option especially in the case where in-house people are less
familiar with the technology stacks used, perhaps they are more focused
on corporate Microsoft-based stacks?

This option offers the following characteristics:

-   Can launch a new VPS in minutes with transparent costs with minimal
    lock-in (for example 40 USD / month and exit or move services at any
    time)
-   Tools and and APIs are often available to script the procedure
    (python-openstack for Open Stack-based cloud service providers and
    doctl for Digital Ocean for example)
-   Network isolation comes naturally (a breach in the local in-house
    network will not affect the cloud services and vice versa)
-   Plenty of guides are available to illustrate how to manage the
    setup, for example with regards to DNS and TLS/SSL settings
-   Enjoy existing support services, issue ticks and get help etc

For Swedish authorities the SUNET Cloud provides a good national option,
branded under the name SafeSpring:
<a href="https://www.safespring.com/" class="uri">https://www.safespring.com/</a>

Using Digital Ocean
===================

Here we illustrate steps needed to deploy Specify with a cloud setup
where we initially [use Docker Machine to provision a cluster node at
Digital Ocean](https://docs.docker.com/machine/drivers/digital-ocean/).

To do this, first we need a laptop and a CLI as well as an account at
Digital Ocean. At the CLI, ensure that `snap` is present since it is a
convenient way to install the `doctl` official command-line client from
Digital Ocean. This tool allows for enumerating valid values for
available images and regions.

``` bash

sudo apt install snapd
sudo snap install doctl --classic

# login using an API token that you have created at Digital Ocean's website
sudo doctl auth init

# list public distribution images that are available
sudo doctl compute image list-distribution --public
# do not use docker-18-04, this droplet won't communicate properly with docker-machine

# use the official Docker droplet from DO
sudo doctl compute region list
# ams3 is a valid European region value
```

To automate provisioning of a cluster node using `docker-machine`, we
need to specify which ssh key to use through its fingerprint and which
Digital Ocean API access token to use (that token needs to first be
generated from the website ), in addition to using relevant valid region
and image names.

``` bash
eval $(ssh-agent)
ssh-add ~/rekonstrukt/recraft-do

export DIGITALOCEAN_ACCESS_TOKEN="your_do_access_token_here"
export DIGITALOCEAN_SSH_KEY_FINGERPRINT="your_ssh_key_fingerprint_here:14:29:8a:13:63:20"
export DIGITALOCEAN_IMAGE="ubuntu-18-04-x64"
export DIGITALOCEAN_REGION="ams3"

# provision a node
docker-machine --debug create recraft \
  --driver digitalocean \
  --digitalocean-access-token $DIGITALOCEAN_ACCESS_TOKEN \
  --digitalocean-ssh-key-fingerprint $DIGITALOCEAN_SSH_KEY_FINGERPRINT \
  --digitalocean-image $DIGITALOCEAN_IMAGE \
  --digitalocean-region $DIGITALOCEAN_REGION
```

Once the node has been provisioned, shell access is available through
`docker-machine ssh recraft` and upgrades can be made through
`docker-machine upgrade recraft`.

Using Open Stack at SUNET Cloud (SafeSpring Compute)
====================================================

We start from scratch by provisioning a server in the Open Stack-based
SUNET Compute Cloud (SafeSpring).

Docs from SafeSpring are available
[here](https://docs.safespring.com/compute/getting-started/).

When using an OpenStack-based IaaS-provider, we’d use a Python-based
tool called `openstack` for accessing the OpenStack APIs from the CLI:

``` bash

# install python openstackclient

apt install python-openstackclient

# set up environment using  a file with these environment settings available from the
# openstack portal at https://dashboard.cloud.sunet.se/project/access_and_security/api_access/openrc/

source ~/Downloads/bas-infra1.nrm.se-openrc.sh

export OS_TENANT_ID=$OS_PROJECT_ID
export OS_DOMAIN_NAME=$OS_USER_DOMAIN_NAME
export OS_SECURITY_GROUPS="bioatlas-default"
export OS_FLOATINGIP_POOL="public-v4"
export OS_NETWORK_NAME="bioatlas-network"
#export OS_SSH_USER="ubuntu"
#export OS_PASSWORD="mysecretpassword"

# issue commands to enumerate resources

openstack network list
openstack flavor list
openstack ip floating pool list
openstack image list
openstack security group list
```

To automate provisioning of a cluster node using `docker-machine`, we
first need to make sure that we have ssh and docker ports open so add
TCP 2377 and TCP 2376 to the default security group in OpenStack. Then
you can proceed to create one or more nodes:

``` bash

docker-machine --debug create \
  --openstack-ssh-user "ubuntu" \
  --openstack-image-name "ubuntu-18.04 [20180517]" \
  --openstack-flavor-name "b.2xlarge" \
  -d "openstack" recraft-specify
```

For more information on how to provision the swarm, please see
<a href="https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/" class="uri">https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/</a>.

Once the node(s) has been provisioned, shell access is available through
`docker-machine ssh recraft-specify` and upgrades can be made through
`docker-machine upgrade recraft-specify`.

Steps to deploy Specify
=======================

Now that we have a server properly prepared we need to deploy the
Specify system.

This could involve the following steps:

-   Login to the host, update and upgrade and install deps (make, unzip,
    docker-compose)
-   Set up firewall
-   Configure DNS and TLS/SSL
-   Copy the software to the host
-   Configure Specify settings
-   Schedule automated backups

More details now follow on those steps.

### Login to host

    docker-machine ssh recraft
    apt install make unzip
    curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

### Activate firewall and allow ssh and web traffic

    ufw allow OpenSSH
    ufw allow http
    ufw allow https
    ufw enable
    ufw status

### Set up DNS and SSL

The `dnsmasq` component used on the development server doesn’t need to
run in production. Instead, to set up DNS, go to Loopia or equiv
registrar.

Here we assume using the domain name `recraft.me` so add
“specify.recraft.me” as a subdomain with a DNS A entry pointing to the
public ip that you get from the `docker-machine ip recraft` command. You
also need to add A entires (or CNAME entries) for the four subdomains
`media, reports, specify6, specify7` pointing to the same public IP.

An TLS/SSL cert needs to be present in the production environment, for
being able to use https. The `docker-compose.yml` file therefore needs a
bind mount for the proxy component and the certs need to be present in
the host’s `certs` directory.

This is automated by the `letsencrypt` service in the
`docker-compose.yml` file.

### Get the Specify software

Then do this to get the code that defines the specify-docker system onto
the server:

    mkdir -p repos
    cd repos
    git clone https://github.com/mskyttner/specify-docker.git
    cd specify-docker

Then change the credentials (held in the `.env`file which gets
referenced in the docker-compose.yml file) used for the production
environment.

### Configure Specify

There are a few config files to go through. Some detail on configuration
settings are in the README.md file. Assuming you want to use
“infrabas.se” as the top level domain name, you’d have to do these
edits:

    # configure Specify settings for example with regards to domain names
    sed -i "s/recraft\.me/infrabas\.se/g" specify_settings.py
    sed -i "s/recraft\.me/infrabas\.se/g" user.properties
    sed -i "s/recraft\.me/infrabas\.se/g" web-asset-server/settings.py
    sed -i "s/recraft\.me/infrabas\.se/g" docker-compose.yml

Also edit the LETSENCRYPT\_EMAIL values in the `docker-compose.yml`.

Then follow the instructions in [README.md](README.md) for first time
use before logging in to Specify 7.

### Launch services

While logged in on the host, build (if necessary) or start the system
directly by pulling images remotely from Docker Hub:

    make init 
    #make build
    make up

Note that starting the system for the first time takes considerable
time, several minutes, since the database data is loaded from a dump.

### Managing the system

Management of the system is provided through the Makefile targets. For
example:

    # set new password for novnc
    make set-s6-passwd NOVNCPASS=mynewpasswordforspecify6

    # run-once for Specify 7 
    make s7-notifications

### Backup and restore

On the host, add a crontab entry for making backups automatically:

    # schedule backups to run automatically using crontab
    # add these lines to crontab (crontab -e)
    # m h  dom mon dow   command
    30 4 * * * bash -c 'cd /root/repos/specify-docker && /usr/local/bin/docker-compose up -d media'
    45 4 * * * bash -c 'cd /root/repos/specify-docker && make backup'

Also verify that the Makefile restore target works.

### Migrating data

To load the system with existing Specify database dumps including media
assets, see the Makefile for some examples.

FAQ
===

How do I backup the server?
---------------------------

The back and restore targets in the `Makefile` which are scheduled on
using `crontab` sets up backups of the application and its data. This is
the most important part as a working backup and restore allows you to
recover from a disaster.

If the cloud server crashes or burns completely, it will be important to
have off-site backups. This involves setting up a transfer of backup
files outside of the cloud server itself, for example to be stored on a
local NAS, although other options exist too, such as encrypting the
backup files and pushing them to the Internet Archive or similar
approaches.

For backing up the entire server itself, the cloud provider may offer
ways to do snapshots, exactly how to use this can vary between cloud
providers (Open Stack-based infrastructures may have one way of doing it
while other IaaS-providers offer similar but other ways / commands).

Where are the logs?
-------------------

There are server logs at various levels and places such as `/var/log`.

At the application level there are logs also at different places:

-   Client-side: JS log messages in the web browser
-   Server-side: Logs from the different application components (use
    `docker-compose logs [servicename]`)

Is there a difference between run-time and build-time upgrades of the application
---------------------------------------------------------------------------------

Build-time updgrades of Specify Software components can be made by
editing Makefiles and rebuilding with `make build`. These can be pushed
with `make release` and then used in the application composition by
editing the `docker-compose.yml` file and updating tags to use the new
version number.

Run-time upgrades can be prompted and performed too, at least for
Specify 6. The upgrade program will then download and install the
relevant updates, perform schema migrations etc within the running
container.

How is it possible to change Specify 7 configuations?
-----------------------------------------------------

In the `docker-compose.yml` file so called `volumes:` provide a way to
map files from the host into the container, such as
`specify_settings.py`; it is a kind of mount that happens where the file
on the host could be named `./specify_settings.py` which then gets
mapped to and mounted into the container at a location such as
`/code/specifyweb/settings/specify_settings.py`.

How can I get a prompt inside one of the running containers?
------------------------------------------------------------

This depends a little on what kind of shells are running in a container,
often `bash` is available, sometimes you need to use `ash`, and
generally `sh` can be used:

    # service based on container with "bash" available
    docker-compose exec db bash

    # service based on minimal linux alpine base, uses "ash" instead of "bash"
    docker-compose exec proxy ash

How do I connect to the database using MySQL Workbench?
-------------------------------------------------------

Since the services in the application composition runs in their own SDN
you need to do two things:

-   Expose the 3306 port of the db container in the `docker-compose.yml`
    file
-   Establish a tunnel to the cloud server to that local port, for
    example using something along this pattern
    `ssh -i ~/.ssh/mykeytothecloudserver -fNL 3306:127.0.0.1:3306 ubuntu@fqdn.cloud.server`

You can the connect a locally running MySQL Workbench to the database
using `localhost:3306`.

What does the proxy do?
-----------------------

It routes traffic between services in the application composition. It
helps with mapping a public domain name to the services and along with
`letsencrypt` it provides TLS/SSL.

How do I manage users in Specify 7?
-----------------------------------

Documentation is available here:

-   <a href="https://www.sustain.specifysoftware.org/support/7-documentation/" class="uri">https://www.sustain.specifysoftware.org/support/7-documentation/</a>
-   <a href="https://www.sustain.specifysoftware.org/support/video-snippets/" class="uri">https://www.sustain.specifysoftware.org/support/video-snippets/</a>
-   <a href="https://www.sustain.specifysoftware.org/support/services-2/" class="uri">https://www.sustain.specifysoftware.org/support/services-2/</a>

If not covered in there, it is possible to check the open issues related
to, say user management in Specify 7, and to open an issue here to ask
the maintainers about specific new issues or errors:

-   <a href="https://github.com/specify/specify7/issues?utf8=%E2%9C%93&amp;q=is%3Aissue+is%3Aopen+user+admin" class="uri">https://github.com/specify/specify7/issues?utf8=%E2%9C%93&amp;q=is%3Aissue+is%3Aopen+user+admin</a>

Why are there references to ‘recraft’?
--------------------------------------

Such references can be found in these files:

-   README and deployment documentation
-   docker-compose.yml files
-   Makefiles

Mostly this is about “slugs” ie public identifiers to Docker Images that
can be pulled globally from the Docker Hub. If these images had been
provided officially by Specify then the slugs would read something like
“specify/specify-server:v7” etc. If Specify Software were to accept this
dockerized setup of the Specify Software components, then ideally they’d
provide a slug like that.

Until then these images are served up under an account named `recraft`
from Docker Hub and are published here:

-   <a href="https://hub.docker.com/u/recraft" class="uri">https://hub.docker.com/u/recraft</a>

It is also about deployment (sub)domains - and the deloyment guide
writes about how to switch from one to another.

How are certs handled?
----------------------

[`letsencrypt-nginx-proxy-companion`](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion)
is a lightweight companion container for nginx-proxy. It handles the
automated creation, renewal and use of Let’s Encrypt certificates for
proxied Docker containers. This means that:

-   you don’t need to buy certs; free certs are issued by Let’s Encrypt
-   renewal is automatic
-   in case of issues, the DEFAULT\_EMAIL environment variable is used
    to reach out to the administrator

How do I renew SSL certificates?
--------------------------------

Is is automatic. Updates can be forced and status can be checked with:

    docker-compose exec letsencrypt ./cert_status
    docker-compose exec letsencrypt ./force_renew

How to enter the `letsencrypt` container
----------------------------------------

This is normally not needed, but can be achieved by:

    # using docker-compose exec [name-of-service] [command]
    docker-compose exec letsencrypt bash

    # or (not as convenient) using docker [fully-qualified-name-of-container] [command]
    docker exec -it specify-docker_letsencrypt_1 bash

How many VMs are there?
-----------------------

Docker runs `cgroups` isolated processes ie no VMs are running, just
processes grouped together which gives minimal overhead. You list the
running containers with `docker-compose ps` or `docker ps`.

> A full virtualized system gets its own set of resources allocated to
> each VM, and does minimal sharing. You get isolation, but it is much
> heavier (requires more resources). With Docker you get less isolation,
> but the containers are lightweight (require fewer resources). So you
> could easily run thousands of containers on a host, and it won’t even
> blink.

![Docer vs VMs](https://i.stack.imgur.com/exIhw.png)
