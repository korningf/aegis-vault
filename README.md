
═══════════════════════════════════════════════════════════════════════
# Manufakture aegis-vault
═══════════════════════════════════════════════════════════════════════

<code> 

    #=============================================================================#
    # Manufakture aegis-vault - posix secrets vault
    #-----------------------------------------------------------------------------#

                                  _____        __      __                        
      _____ _____    ____  __ ___/ ____\____  |  | ___/  |_ __ _________   ____  
     /     \\__  \  /    \|  |  \   __\\__  \ |  |/ /\   __\  |  \_  __ \_/ __ \ 
    |  Y Y  \/ __ \|   |  \  |  /|  |   / __ \|    <  |  | |  |  /|  | \/\  ___/ 
    |__|_|  (____  /___|  /____/ |__|  (____  /__|_ \ |__| |____/ |__|    \___  >
          \/     \/     \/                  \/     \/                         \/ 


    #-----------------------------------------------------------------------------#
    # (c) Francis Korning 2025.
    #=============================================================================#
                                                                                   
</code>        
    

Aegis-Vault and Aegis-Agent are an agnostic POSIX secrets-vault and secure-agent.

Aegis is a secure secrets vault, aka key-store, password-store or password manager.

While there are many UI-based password stores like KeePass KeepassX, KeePassXC..., 

Aegis is different in that it is based on a lightweight, minimal, GNU POSIX shell.

It is suited for backend servers, virtual machines, containers, embedded systems.

It does not rely on a UI, and once configured can be fully scripted and automated.

It only depends on base tools: ssh, git, tree, gnupg, pass, sshpass, aws-cli, etc.


[TOC]



───────────────────────────────────────────────────────────────────────
# Installation
───────────────────────────────────────────────────────────────────────

Ensure you have installed the prerequisistes (ssh, git, tree, gnupg, pass, sshpass).

## cygwin

On cygwin, `gnupg` and is v1.x,  `gnupg2` is 2.x (we need 2.x for gpg-agent).


```
apt-cyg install git
apt-cyg install tree
apt-cyg install pass
apt-cyg install gnupg2
apt-cyg install sshpass
```


## ubuntu (22 LTS jammy)

```
apt-get -y install git
apt-get -y install tree
apt-get -y install pass
apt-get -y install gnupg
apt-get -y install sshpass
```

## redhat (AWS Linux 2022)

```
yum install git
yum install tree
yum install pass
yum install gnupg
yum install sshpass
```



pass extensions

```
  mkdir -p /usr/lib/password-store/extensions
  cd /usr/lib/password-store/extensions
  curl https://raw.githubusercontent.com/lukrop/pass-file/refs/heads/master/file.bash > file.bash
  chmod a+x *.bash
  cd
```

  
───────────────────────────────────────────────────────────────────────
# Delegation
───────────────────────────────────────────────────────────────────────

Thes below assumes a single vault and passphrase shared with key operators.

Git submodules can be used for multiple individual .passwor-store vaults.

_TODO_  

	_formalize this later_ 
 
 	_get it working for a single store first_
  
───────────────────────────────────────────────────────────────────────
# Preparation
───────────────────────────────────────────────────────────────────────

* Id

Everything will be tied to a primary email identity, so choose it wisely.

This email should have a strong password and be protected by 2MFA auth.

This id will govern your GPG keyring, git repo, and AWS IAM user account.


* Initial Secrets

Now this Id may or may not already have inital secrets.

Note if the Id is already used for the following:

  - GnuPG keyring
  - SSH RSA Key pair
  - Git account, server, user, ssh key, repo
  - AWS IAM user account and API access key


  

* Git

The passphrase-protected secure vault should be checked-in a git repo. 

It may be an internal private git repo or an external private git repo.

Though RSA 4096 passphrases are very strong, best to avoid public repos.


.

If you haven't done so, create a git account on a git server.

Note the git server and the git login parameters


    git_server=github.com
    git_user=you@email.com
    git_ssh=git@${git_server}


    git_ssh=git@github.com
    


If you haven't done so, create your repository for the aegis-vault.

Note the Git repository url and relative repo path


    git_repo=aegis-vault
    git_repo_url=git@${git_server}/${git_user}/${git_repo}.git

    git_repo_url=git@github.com/korningf/aegis-vault.git

  
* AWS

AWS uses an id triplet to connect to the console (account, user, password).

Make sure the account is connected and you have an IAM user with API acecss.

    aws_account=012345678901
    aws_user_name=you@email.com
    aws_user_pass=*****************************


The AWS API uses an IAM Secret Acces Key token couplet (key id + secret key).

Have an AWS Admin provide your Access Key

This is usally in a .csv file

    AWS_access_key.csv

and contains the id and secret key    

    aws_iam_access_key_id="AKIAIOSFODNN7EXAMPLE"
    aws_iam_secret_access_key="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    


───────────────────────────────────────────────────────────────────────
# Initialization 
───────────────────────────────────────────────────────────────────────

We want a set of secure steps that avoid storing secrets in the clear.

Every secret, password, and private key should be in the keystore vault,

which is passphrase-protected via RSA 4096, and cannot be brute-forced.

(one hopes for a while at least)


  
* GPG
  
Select a primary email identity, ie the one linked to your git account.

Create a master gpg keyring - this will be bound to your email identity.

    $ gpg --gen-key"

The recommended settings:

    key kind:      1 (RSA)
    key size:      4096
    validity:      0 (never expires)



## Manual Initialization

If this is the very first time you install and initalizae aegis, 

or none of the initial secrets are already present on the machine,

or you do not have a gpg keyring, an ssh key, or a git ssh config,

it is best to do this manually.

  
* Id

expose email id

    gpg_id=`gpg --list-secret-keys | head -5 | grep uid | xargs | cut -d ' ' -f 5 | tr '<>' '  ' | tee`
    gpg_hash=`gpg --list-secret-keys | head -5 | grep 'sec ' | xargs | cut -d ' ' -f 2`

  
* Pass

generate the password-store

    cd ~
    mkdir -p .password-store
    git init .password-store
    
    pass init .password-store ${gpg_id}
  



* SSH

Now chances are we have an ssh key already if this is a virtual machine.

But this doesn't mean the rsa private key is present on the local machine.

We want to configure ssh such that all rsa private keys live in the vault.

.

Note AWS EC2 machines have authorized_key public key and not a key-pair.

That is, we can generate a full additional key-pair (id_rsa, id_rsa.pub),

which we can then add to our Git repo (without screwing up AWS access)

.

At minimum we will need to integrate pass and ssh for git repo access.




_TODO_ 

    _Questions_

    _How do we plan to use this? password auth or keypair auth ?_

    _can we use sshpass(1) and password-auth or do we use keypair only ?_

      _ 0. use sshpass(1) with password-auth and store pass in vault._


_TODO_ 

    _How to deal with passphrase protected ssh private keys?_

     _3 options:_
      
      _ 1. store the ssh plain-text private key in the password-store vault._

           _delete any ssh plain-text private keys in your .ssh home (~/.ssh/id_rsa)_ 

      _ 2. store the ssh passphrase in the password-store vault._
  
          _keep passphrase-protected private keys in your .ssh home (~/.ssh/id_rsa)_
         
      _ 3. store both ssh passphrase and private key in vault._

           _overkill, not sure this adds anything except complexity_ 


Recall the OpenSSH private key passphrase-protection uses AES 128-bit.

For SSH to work with pass we must use a plain-text OpenSSH private-key.

We will want to store our ssh private-key in the password-vault instead,

as that will use RSA 4096 and will use our common pass vault interface.



generate your SSH key-pair

    ssh-keygen -o -t rsa -f id_rsa -C "${gpg_id}"

authorize its public key

    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    
store the keys in the vault

    aws_publ_key=`cat ~/.ssh/authorized_keys`
    
    ssh_priv_key=`tail -n +2 ~/.ssh/id_rsa | head -n -1 | tr -d '\n'` 
    ssh_publ_key=`head -1 id_rsa.pub | tr -d '\n'` 

_TODO_

    _this won't work - figure out the io stream or pipe redirection to make it work_

    _use pass-file to store the ssh file with headers and footers_

    

    pass insert ssh/aws_publ_key ${aws_publ_key}

    pass insert ssh/id_rsa ${ssh_priv_key}
    pass insert ssh/id_rsa.pub ${ssh_publ_key}

remove the ssh private key

    rm -f ~/id_rsa


_TODO_ 

    _use pass-file to store the ssh file with/without headers and footers?_

    _modify the extension to strip ssh headers and footers with an option?_


* Git

configure your git server account and your git vault repo.

for an external git, this is typically done in a browser.


copy your ssh key as your git ssh key

    ssh-copy-id git@github.com


add your git ssh key into the vault

    pass git init

    pass git remote add origin ssh://git@${git_server}:/${git_user}/${git_repo}



* AWS

The next key we want to check-in is the AWS API access key
 
    pass insert aws/aws_user  





## Automated Initialization

Things will be simpler once the first time initialization has been done.

You should have copied the gpg secret keys and know your gpg passphrase.

You should be on a new machine already holding the id_rsa.pub ssh pubkey.


    cd ~
    
    git clone ssh://git@${git_server}:/${git_user}/${git_repo} .password-store
    

Run the aegis.sh script to do everything automagically.


_TODO_

    aegis.sh
    


───────────────────────────────────────────────────────────────────────
# Rotation
───────────────────────────────────────────────────────────────────────

The main idea here is to share a central password vault with a handful of operators.

For this to work, a chosen technical unix account would also share the gpg keyring.

It would be more secure to use individual keyrings and vaults, but less convenient.

Aegis-vault will work either way, so long as you have 1 keyring per password-store.

.

Now ideally both of these will checked-into a private git repository somewhere.

In the examples below we are assuming a vault shared with a handful of operators.

If a shared vault is used, it would be wise to enact a passphrase rotation policy.

.

Now distributing a new rotated keyring and vault should be as easy as a git pull,

and sharing the new passphrase for gpg keyring and the vault in a side channel.

.

Please note that individual secrets within the can also be changed or rotated,

but care must also be taken to not lock-out and brick live systems by mistake.

You should never both change a secret and rotate the passphrase at the same time.

.

The safest way is for systems to be rotated, restarted, and rolled-out in synchrony,

ie via a provisioner or orchestrator (vagarnt, puppet, kubernetes, terraform, etc).

.

The rotation strategy is left up to you.

For example, note git and ssh allow us to configure multiple authorized public keys.

one strategy could be to temporarily expose the old SSH private key for the rotation.

Think of it as a one-time OTP key, it should only remain exposed for the rotation.


───────────────────────────────────────────────────────────────────────
# SubKeys
───────────────────────────────────────────────────────────────────────

* GPG Sub Keys

GPG and PGP already provide a mechanism for key expiry and for subordinate keys.

An excellent way to manage key vault coudl be to encrypt it with a expring subkey.

GPG 2.0 Subkeys are still quite complicated - this will require some investigation.

  
_TODO_

    _look at GPG subkeys, expiry, rotation_
    
    _figure out how to use it with pass_ 

    _formalise this_



* Override the default key used by Pass and GPG

Investigate the following:


(1) a Pass environment variable allows to forward Pass options to GPG. 

    one can oevvride the private key id (its short fingerprint hash)


        export PASSWORD_STORE_GPG_OPTS="--default-key 32089A9550EAF4BB"

(2) Pass stores this private key_id (fingerprint) in its own database,

    in the form of a .gpg-id a control-file in the ~/.passsword-store

        ~/.pasword-store/.gpg-id


* SSH Sub Keys

SSH already supports the same idea, in the form of signed RSA .pem keys.

RSA .PEM keys can actually be signed RSA certificates, so signed subkeys.

Certificates for now are of scope - we will add this later


  
───────────────────────────────────────────────────────────────────────
# Certificates
───────────────────────────────────────────────────────────────────────

_TODO_

        _install openssl and root CA_
        
            gnutls
            openssl

        _formalize a workflow for secure certificates_ 

        _formalize a workflow for signed ssh RSA .pem subkeys_ 



───────────────────────────────────────────────────────────────────────
# Agent-Forwarding
───────────────────────────────────────────────────────────────────────

This is used for master secrets (GPG passphrase, SSH passphrase, SSH password).

The main idea is to require a secret be entered once and only once a session.

A corolloray is that master secrets do not have to be exposed on every machine.

.

One authenticates once (with a GPG passphrase, or SSH passphrase, or password).

An agent daemon on the machine keeps these master secrets in ephemeral memory. 

The agent can then forward these credentials to another call during a session.

This allows to chain an SSO authentication and hop along from system to system.

Crucially, without having to store or expose the SSH private key or GPG keyring.



* GPG-Agent

  
* SSH-Agent
  
We will probably want to use SSH-Agents, and we will address this later.


_TODO_ 

     _How do we set up an ssh-agent to work with pass?_

     


    


───────────────────────────────────────────────────────────────────────
# Configuration
───────────────────────────────────────────────────────────────────────

We now have a working password vault, we next want to check it into git.

this will allow us to track changes and load the vault in other systems.

    pass git init

    pass git remote add origin ssh://git@${git_server}:/${git_user}/${git_repo}

    git pull
    


───────────────────────────────────────────────────────────────────────
## Cloud Infrastructure (AWS)
───────────────────────────────────────────────────────────────────────

We're assuming here that the intent is to do Cloud Ops and Dev Ops.

We further assume that one has an IAM account and an API Access Key.

That key should be the next secret in the Aegis-Vault secure-vault.


_TODO_

───────────────────────────────────────────────────────────────────────
## Cloud Formation (Terraform)
───────────────────────────────────────────────────────────────────────


_TODO_  Terraform, K-Ops


───────────────────────────────────────────────────────────────────────
## Cluster Orchestrator (Kubernetes)
───────────────────────────────────────────────────────────────────────


_TODO_  Kubernetes, Minikube


───────────────────────────────────────────────────────────────────────
## Container Provider (Docker)
───────────────────────────────────────────────────────────────────────

_TODO_  Docker, Composer, Packer


───────────────────────────────────────────────────────────────────────
## Virtualizer Provisioner (Vagrant)
───────────────────────────────────────────────────────────────────────

_TODO_  Vagrant, Bundler


───────────────────────────────────────────────────────────────────────
# Operation
───────────────────────────────────────────────────────────────────────

All other secrets, passwords, keys, credentials go in the password-store vault.



generate a password (strong)

    # len is number of characters
    
    pass generate <path/name> len

ex

    pass generate aegis/otp/salt 10

    

add a secret (single-line)

    pass insert <path/name>

ex

    pass insert aws/aws_iam_secret_access_key 


add a secret (multi-line - interactive)

    # use [ctrl]+[d] to end input
    
    pass insert -m <path/name>

ex

    pass insert -m ssh/id_github
    
    

push to the vault

    pass git push


pull from the vault

    pass git pull



───────────────────────────────────────────────────────────────────────
# Appendix
───────────────────────────────────────────────────────────────────────


git sub-modules

      see https://git-scm.com/book/en/v2/Git-Tools-Submodules

      see https://www.pluralsight.com/resources/blog/guides/using-git-submodules-to-reference-one-git-repository-from-another


pass password-store
  
      see https://www.passwordstore.org/
    
      see https://git.zx2c4.com/password-store/

 

pass file extension

      see https://github.com/lukrop/pass-file



sshpass(1) unix command

      _this sshpas(1) is a unix command - not the same as the sshpass(2) expect script _
        
      see https://linux.die.net/man/1/sshpass
    
      see https://www.redhat.com/en/blog/ssh-automation-sshpass
    
      see https://www.cyberciti.biz/faq/noninteractive-shell-script-ssh-password-provider/
    

sshpass(2) expect script
  
      _this sshpass(2) is an expect script - not the same as the sshpas(1) unix command_
      
      see https://thomasbroadley.com/blog/unlocking-ssh-keys-using-pass/


pass with gpg git

      see [https://medium.com/@chasinglogic/the-definitive-guide-to-password-store-c337a8f023a1]


gpg subkeys

      see https://wiki.debian.org/Subkeys?action=show&redirect=subkeys

      see https://superuser.com/questions/466396/how-to-manage-gpg-keys-across-multiple-systems

      see https://security.stackexchange.com/questions/136707/use-specific-subkeys-without-master-key-on-different-device-using-gpg

      see https://www.reddit.com/r/linuxquestions/comments/18zhtvn/passwordstore_and_gpg_keys/


gpg-agent

      see https://www.gnupg.org/documentation/manuals/gnupg/Invoking-GPG_002dAGENT.html

      see https://unix.stackexchange.com/questions/188668/how-does-gpg-agent-work


pass with gpg-agent

      see https://forums.funtoo.org/topic/863-pass-with-gpg-agent/

      see https://thonkpeasant.xyz/guides/other/pass.html


ssh-agent

      see https://docs.github.com/en/authentication/connecting-to-github-with-ssh/using-ssh-agent-forwarding

      see https://unix.stackexchange.com/questions/740871/ssh-agent-how-it-works
      

pass with ssh agent

      see https://medium.com/50ld/aws-setup-ssh-agent-forwarding-to-ec2-instances-on-windows-57b94d22c5f4
 

ssh-key hardening

      see https://medium.com/risan/upgrade-your-ssh-key-to-ed25519-c6e8d60d3c54

      

═══════════════════════════════════════════════════════════════════════
# (c) Francis Korning 2025.
═══════════════════════════════════════════════════════════════════════

