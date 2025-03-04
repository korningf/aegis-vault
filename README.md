
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

Aeggis is a secure secrets vault aka key-store, password=store or password manager.

While there are many UI vase password stores like KeePass KeepassX, KeePassXC, etc.

Aedis is differenet in that it is based on a lightweight minimal GNU POSIX sheel.

It is suited for backend servers, virtual machines, containers, embeded systems.

Ie doesn't rely on a UI, and once configured can be fully scripted and autmated.

It only depends on base tools: password-store, gnupg, git, ssh, sshpass, aws.



───────────────────────────────────────────────────────────────────────
# Installation
───────────────────────────────────────────────────────────────────────

# Installation

Ensure you have installed the prerequisistes (git, tree, pass gnupg, sshpass).

## cygwin

```
apt-cyg install git
apt-cyg install tree
apt-cyg install pass
apt-cyg install gnupg
apt-cyg install sshpass
```

## ubuntu (22 LTS jammay)

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
# Preparation
───────────────────────────────────────────────────────────────────────

* Id

Everything will be tied to a primary email identity, so hoose it wisely.

The email should have a strong password and be protetected by MFA auth.

This id will govern your GPG keyring, git repo, and AWS IAM user account.


* Initial Secrets

Now this Id may or may not already have the necessary inital secrets.

Note if the Id already has the following:

  - GnuPG keyring
  - SSH RSA Key pair
  - Git account, server, user, ssh key, repo
  - AWS IAM user account and API access key


  

* Git

The passphrase-protected secure vault will be checked-in a git repo. 

This may be an internal private git repo an external private git repo.

Though RSA 4096 passphrases are strong, best to avoid public repos.


For an external git this is typically done in a browesr.

Note the git server and the git ssh login string


    git_server=github.com
    git_user=you@email.com
    git_ssh=git@${git_server}


    git_ssh=git@github.com
    

If you haven't done so already, create the Git account and the repo.


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


AWS API Access requires an IAM Acces Key token couplet (key id + secret key).

Have an Administrator gener

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

which is passphrase-protected via RSA 4096, and cannot be brute force.

(one hopes)



  
* GPG
  
Now chances are we have an ssh key already if this is a virtual machine.

This measn we also need ssh-agent in order to hop out to other systems.

If we have ssh keys, we mmust move the private identity key into vault.


Select a primary email identity, ie the one linked to your git account.

Create a master gpg keyring - this will be bound to  email identity.

    $ gpg --gen-key"

The recommnded settings:

    key kind:      1 (RSA)
    key size:      4096
    validity:      0 (never expires)



## Manual Initialization

If this is the very first time you install and initalizae aegis, 

or none of the initial secrets are already present on the machine,

or you do not have an ssg key, you have not yet configured git ssh,

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
    
    pass init .password-store $gpg_id
  

* SSH

Open-SSH private key default passphrase-protectedion uses ASES 128-bit.

For SSH to work with pass we must use a plain-text OpenSSH private-key.

We will want to store our ssh private-key in the password-vault instead,

as that will use RSA 4096 and will use our common pass vault interface.


_TODO_ 

	_how to deal with exsiting passpharse protected ssh private keys?_


generate your SSH key-pair

    ssh-keygen -o -t rsa -f id_rsa -C "$gpg_id"

    ssh_priv_key=`tail -n +2 ~/.ssh/id_rsa | head -n -1 | tr -d '\n'` 
    ssh_publ_key=`head -1 id_rsa.pub | tr -d '\n'` 

    pass insert ssh/id_rsa ${ssh_priv_key}
    pass insert ssh/id_rsa.pub ${ssh_publ_key}


_TODO_ 

	_use pass-file to store the ssh file with headers and footers_

	_modify the extension it to strip the headers and footers with an option_


* Git

configure yyour git server account and your git vault repo.

for an external git this is typically done in a browesr.


copy your ssh key as your git ssh key

    ssh-copy-id git@github.com


add your git ssh key into the vault

    pass git init

    pass git remote add origin ssh://git@$git_server:/$git_user/$git_repo



* AWS

The next key we want to check-in is the AWS API acess key
 
    pass insert aws/aws_user  




## Automated Initialization

Things get much simpler once the first time initialization has been done.

You should have copied the gpg secret keys and know your GPG Passphrase.

You should be on a new machine already holding the id_rsa.pub ssh pubkey.


    cd ~
    
    git clone ssh://git@$git_server:/$git_user/$git_rep .password-store
    

Run the ageis.sh script to do everything automagically.


    aegis.sh
    


───────────────────────────────────────────────────────────────────────
# Configuration
───────────────────────────────────────────────────────────────────────

We hnow ave a working password vault, we next want to check it into git.

this will allow us to track changes and load the vault in other systems.

    pass git init

    pass git remote add origin ssh://git@$git_server:/$git_user/$git_repo

    git pull
    



───────────────────────────────────────────────────────────────────────
# Cloud Infrastrcuture (AWS)
───────────────────────────────────────────────────────────────────────

We're assuming here that the intent is to do Cloud Opps and Dev Ops.

We further assume that one has an IAM account and an API Access Key.

That key should be the next secret in the Aegis-Vault secure-vault.




───────────────────────────────────────────────────────────────────────
# Cloud Formation (Terraform)
───────────────────────────────────────────────────────────────────────


───────────────────────────────────────────────────────────────────────
# Cluster Orchestrator (Terraform)
───────────────────────────────────────────────────────────────────────


───────────────────────────────────────────────────────────────────────
# Container Provider (Docker)
───────────────────────────────────────────────────────────────────────

───────────────────────────────────────────────────────────────────────
# Virtualizer Provisioner (Vagrant)
───────────────────────────────────────────────────────────────────────




───────────────────────────────────────────────────────────────────────
# Operation
───────────────────────────────────────────────────────────────────────


generate a password (strong)

    # length is number of characters
    
    pass generate <path/name> len

ex

    pass generate aegis/otp/salt 10

    

add a secret (single-line)

    pass insert <path/name>

ex

    pass insert aws/aws_iam_secret_access_key 

add a secret (multi-line)

    # use [ctrl]+[d] to end input
    
    pass insert -m <path/name>

ex

    pass insert -m ssh/id_github
    
    

push to the vaukt

    pass git push

pull from the vault

    pass git pull




───────────────────────────────────────────────────────────────────────
# Attribution
───────────────────────────────────────────────────────────────────────


  see https://www.passwordstore.org/

  see https://git.zx2c4.com/password-store/

  see https://github.com/lukrop/pass-file
  

  see https://medium.com/@chasinglogic/the-definitive-guide-to-password-store-c337a8f023a1

  see https://medium.com/risan/upgrade-your-ssh-key-to-ed25519-c6e8d60d3c54

  see https://medium.com/50ld/aws-setup-ssh-agent-forwarding-to-ec2-instances-on-windows-57b94d22c5f4
 
 
═══════════════════════════════════════════════════════════════════════
# (c) Francis Korning 2025.
═══════════════════════════════════════════════════════════════════════


