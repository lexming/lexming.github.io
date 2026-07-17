List all available packages

```
dnf list kernel --showduplicates
```

To list the dependencies of an RPM package, you can use the command rpm -qR <package_name> for installed packages or dnf repoquery --requires <package_name> for packages that are not installed.


