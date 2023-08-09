# Docker container with SSHD running in Ubuntu

Run SSHD server in Ubuntu in a Docker container. A pair of private/public keys is automatically generated on startup, and the private key is sent to `stdout`. This can be useful if you need to run a temporary container and do not want to generate keys, or have no way to add your public key to the container.

Another supported scenario is to pass the public key via environment variable `PUBLIC_KEY`. In this case the private key is not generated.

## Usage

1. [Generate the key pair automatically](#generate-the-key-pair-automatically)
1. [Pass public key via environment variable](#pass-public-key-via-environment-variable)
1. [Use Docker image with common tools pre-installed](#use-docker-image-with-common-tools-pre-installed)
1. [Run SSH server in Azure Container Instances](#run-ssh-server-in-azure-container-instances)

## Generate the key pair automatically

```bash
docker run -it --rm -p 2222:22 andreygoran/sshd-ubuntu
```

The output will be like this:
```
-----BEGIN OPENSSH PRIVATE KEY-----
...private key goes here...
-----END OPENSSH PRIVATE KEY-----
Server listening on 0.0.0.0 port 22.
Server listening on :: port 22.
```

In this example we map SSH to port 2222, so to login we can use this script (replace 172.16.10.100 with the actual IP):
```bash
# Save private key to /tmp/key
touch /tmp/key && chmod 600 /tmp/key
cat > /tmp/key <<- "EOF"
-----BEGIN OPENSSH PRIVATE KEY-----
...private key goes here...
-----END OPENSSH PRIVATE KEY-----
EOF
# Run ssh using port 2222 and private key in /tmp/key
ssh -p 2222 -i /tmp/key root@172.16.10.100
```

## Pass public key via environment variable

```bash
docker run -it --rm -p 2222:22 -e PUBLIC_KEY="...public key goes here..." andreygoran/sshd-ubuntu
```

The output will be like this:
```
Server listening on 0.0.0.0 port 22.
Server listening on :: port 22.
```

In this example we map SSH to port 2222, so to login we can use this code (replace 172.16.10.100 with the actual IP):
```bash
ssh -p 2222 root@172.16.10.100
```

We are assuming that SSH has access to your private key on the system where you are running it.

## Use Docker image with common tools pre-installed

The `andreygoran/sshd-ubuntu` image only comes with the `openssh-server` package installed on top of Ubuntu image. If you need an image with common tools pre-installed, use `andreygoran/sshd-ubuntu-tools` instead:

```bash
docker run -it --rm -p 2222:22 andreygoran/sshd-ubuntu-tools
```

or

```bash
docker run -it --rm -p 2222:22 -e PUBLIC_KEY="...public key goes here..." andreygoran/sshd-ubuntu-tools
```

Here is the list of packages included in `andreygoran/sshd-ubuntu-tools`:
* openssh-server
* openssh-client
* nano
* vim
* less
* curl
* wget
* jq
* net-tools
* iproute2
* netcat
* dnsutils
* iputils-ping
* iptables
* nmap
* tcpdump
* telnet

## Run SSH server in Azure Container Instances

```bash
# Create resouce group
az group create --name sshd-resource-group --location eastus2 --output none

# Create container instance
az container create -g sshd-resource-group --name sshd --image andreygoran/sshd-ubuntu --ports 22 --ip-address Public --environment-variables PUBLIC_KEY="...public key goes here..." --query ipAddress.ip --output tsv
```

IP address will be shown in the `az` output:
```
20.14.241.9
```

Connect via SSH (replace `20.14.241.9` with your own IP):
```bash
$ ssh -o StrictHostKeyChecking=no root@20.14.241.9
Warning: Permanently added '20.14.241.9' (ED25519) to the list of known hosts.
Welcome to Ubuntu 22.04.2 LTS (GNU/Linux 5.10.102.2-microsoft-standard x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

This system has been minimized by removing packages and content that are
not required on a system that users do not log into.

To restore this content, you can run the 'unminimize' command.

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

root@SandboxHost-638271063068646531:~#
```

or run remote command via SSH:

```bash
$ ssh -o StrictHostKeyChecking=no root@20.14.246.40 "cat /etc/issue"
Ubuntu 22.04.2 LTS \n \l

$
```