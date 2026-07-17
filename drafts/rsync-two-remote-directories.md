Best solution with sshfs.

https://www.digitalocean.com/community/tutorials/how-to-use-sshfs-to-mount-remote-file-systems-over-ssh

```
sshfs repos9.cerberus.os:/var/www/packages/public /mnt/hydra
sshfs sofia.mgt: /mnt/sofia
rsync -av /mnt/hydra/rl98_x86_64-baseos /mnt/sofia/
```
