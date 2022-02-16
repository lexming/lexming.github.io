---
title: "Sharing notes with Carnet and Nextcloud"
date: 2022-02-09 12:00
categories: nextcloud
---

[Carnet](https://getcarnet.app/) is an open-source note taking app with a lean
WYSIWYG interface that is very easy to use. Combined with its capability to use
any [Nextcloud instance as its storage backend](https://github.com/CarnetApp/CarnetNextcloud),
Carnet is a very compelling solution for your self-hosted notes.

Unfortunately, Carnet does not currently provide any mechanism to share notes
with other users in your Nextcloud -
[CarnetApp/CarnetNextcloud/#48](https://github.com/CarnetApp/CarnetNextcloud/issues/48).

The simple workaround to this limitation is directly sharing the `.sqd` file of
the note in Nextcloud with any other user.

:warning: This sharing method can cause **data loss in the shared note** if
multiple users edit the same note at the same time. In the case of simultaneous
edits, the last user syncing will overwrite any new changes from other users.

1. Locate the `.sqd` note file in your Carnet folder in Nextcloud
   (`Documents/QuickNote` by default)
2. Share it with any other user in Nextcloud as usual
3. The receiving user has to manually move the new `.sqd` file in their Nextcloud home folder into their Carnet folder (`Documents/QuickNote` by default)
4. Carnet will automatically detect the new shared note and show it in the
   application interface

