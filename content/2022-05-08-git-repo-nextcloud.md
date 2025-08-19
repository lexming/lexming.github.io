---
title: "Git repos in Nextcloud"
date: 2022-05-08 20:00
categories: nextcloud
tags: git
---

The usual solution to put [git repositories on a remote server is to transfer
and sync them with SSH](https://git-scm.com/book/en/v2/Git-on-the-Server-Getting-Git-on-a-Server).
However, in cases where setting up the SSH connection is troublesome (*e.g.*
lack of SSH server or lack of keys in the client system), it can be useful to
use [Nextcloud](https://nextcloud.com/) as an alternative to mirror git
repositories and/or syncronize them accross computers.

> Nextcloud is not designed to be used as a source code management tool, if you
> need one check [Github](https://github.com/),
> [GitLab](https://about.gitlab.com/) or [Gitea](https://gitea.io).
{: .prompt-warning }

Putting a git repository in Nextcloud can be achieved quite easily by placing
the [bare repository](https://git-scm.com/docs/gitglossary.html#Documentation/gitglossary.txt-aiddefbarerepositoryabarerepository)
of your repo in a local folder and sync it with your Nextcloud instance.
Syncronization speed is on the low end, so this solution is not meant for
real-time syncronization of repositories with a lot of activity, but is a
viable option for small private repositories.

1. Sync a local folder with your Nextcloud instance using any of the
   [Nextcloud clients](https://nextcloud.com/clients/). In the following, this
   folder will be `~/Public/Nextcloud`

2. Put a git bare repository in the folder synced with Nextcloud

    * Exporting the bare repository of an existing repository
        ```console
        $ git clone --bare my_project ~/Public/Nextcloud/my_project.git
        ```
    * Inititalizing a new git repository from a local bare repository
        ```console
        $ git init --bare ~/Public/Nextcloud/my_project.git
        $ git clone ~/Public/Nextcloud/my_project.git
        ```
3. Check tracked remotes in your repository

    ```console
    $ cd my_project
    $ git remote -v
    origin  /home/user/Public/Nextcloud/my_project.git (fetch)
    origin  /home/user/Public/Nextcloud/my_project.git (push)
    ```

    > Use a different name than *origin* for the remote repository in Nextcloud
    > to add it as a non-default remote (*e.g.* in case it is used as backup).
    {: .prompt-info }

