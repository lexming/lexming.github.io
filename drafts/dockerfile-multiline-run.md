

You can use what is called "ANSI-C quoting" with $'...'. It was originally a ksh93 feature but it is now available in bash, zsh, mksh, FreeBSD sh and in busybox's ash (but only when it is compiled with ENABLE_ASH_BASH_COMPAT).

As RUN uses /bin/sh as shell by default you are required to switch to something like bash first by using the SHELL instruction.

Start your command with $', end it with ' and use \n\ for newlines, like this:

SHELL ["/bin/bash", "-c"]

RUN echo $'[repo] \n\
name            = YUM Repository \n\
baseurl         = https://example.com/packages/ \n\
enabled         = 1 \n\
gpgcheck        = 0' > /etc/yum.repos.d/Repo.repoxyz

```
RUN     echo -e "\n### Install and Configure slurm at vnfs"; \
        yum clean all && \
        yum -y install \
                pmix \
                lbnl-nhc \
```

```
RUN FILE=/etc/ld.so.conf.d/pmix.conf; sed 's/^\t*//' > "$FILE" <<<$'\
                /usr/local/lib64\n\
        '; echo -e "\n### Added file \"$FILE\":"; nl -n rz -w 3 -b a "$FILE" || :; \
```
