You can use declare and !, like this:

John="nice guy"
programmer=John
echo ${!programmer} # echos nice guy

Second example:

programmer=Ines
declare $programmer="nice gal"
echo $Ines # echos nice gal

https://stackoverflow.com//questions/9714902/how-to-use-a-variables-value-as-another-variables-name-in-bash#answer-30073926
