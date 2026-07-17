https://stackoverflow.com//questions/68817332/why-use-execstart-with-no-value-before-another-execstart-new-value-in-a-syst#answer-68818218

When you add entries to an override file, they are by default appended to any existing entries. That is, if your service example.service has:

[Service]
EnvironmentFile=/etc/foo.env

And you create /etc/systemd/system/example.service.d/override.conf with:

[Service]
EnvironmentFile=/etc/bar.env

Then the effective configuration is:

[Service]
EnvironmentFile=/etc/foo.env
EnvironmentFile=/etc/bar.env

That's fine for many directives, but a service can have only one ExecStart (unless it's a Type-oneshot service), so if you try to create an override file like this:

[Service]
ExecStart=/new/command/line

That will fail with an error along the lines of:

systemd: example.service has more than one ExecStart= setting, which is only allowed for Type=oneshot services. Refusing.

By specifying an empty ExecStart, you are "clearing out" all previous entries. So if your example.service has:

[Service]
ExecStart=/bin/foo

And you create an override like:

[Service]
ExecStart=
ExecStart=/bin/bar

The effective configuration is:

[Service]
ExecStart=/bin/bar

