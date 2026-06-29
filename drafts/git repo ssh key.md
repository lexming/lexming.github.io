How to setup a git repo to use its own SSH key

1. Create the SSH key in the system
```
ssh-keygen -t ed25519 -C "{email}"
```
	1. Give a unique name to key
```
Enter file in which to save the key (/root/.ssh/id_ed25519):
```
	1. No need for a passphrase
3. Configure SSH (~/.ssh/config) to use this key whenever we connect to github.com:
```
Host github.com
    IdentityFile ~/.ssh/git-vub-hpc-sofia-containers
    IdentitiesOnly ye
```
3. Go to your repo in github.com. Open the _Settings_ panel and go to _Deploy keys_ on the left menu
4. Click _Add deploy key_ and copy paste the **public** key of the new created SSH key
5. All done, try to fetch