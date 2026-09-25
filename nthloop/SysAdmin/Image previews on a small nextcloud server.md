---
title: Image previews on a small nextcloud server
created: 2026-09-22
modified: 2026-09-22
tags:
  - nextcloud
---

Nextcloud generates multiple lower resolution versions of each image. Those are used to optimize transfer speed on thumbnails, gallery views and any time the full resolution image is not needed.

Preview generation has two main implications:
* **size**: each image will generate multiple low-res versions at different scales. Typically a single image can have 64px, 256px, 1024px and 4096px variants, plus cropped and non-cropped versions. By default, there is no limit on maximum size or number of versions. Therefore, the previews can have a big impact on storage, multiplying the number of files and their total size.
* **processing**: Nextcloud generates previews on-demand. Whenever a low-res image is needed, it will be generate on-the-fly if it is missing. On low-power hardware such a raspberry pi, this will impact loading times of first-timers.

## Base onfiguration

Nextcloud provides multiple [configuration options to control preview generation](https://docs.nextcloud.com/server/stable/admin_manual/configuration_files/previews_configuration.html). Those allow to limit maximum resolution and image quality, which serve to limit the impact on storage size.

Example configuration for a small instance with ample storage but where space should still not be wasted on previews:

```php
<?php
$CONFIG = array (
    'enable_previews' => true,
    'jpeg_quality' => 80,
    'preview_max_x' => 2048,
    'preview_max_y' => 2048,
);
```

## Preview Generator

The nextcloud app [Preview Generator](https://github.com/nextcloud/previewgenerator) solves the processing issue of previews on-demand by pre-creating them. It works by running a cron job every 10 min that will scan the data library for any missing preview files.

[Configuration options of Preview Generator](https://github.com/nextcloud/previewgenerator#available-configuration-options) for a _small_ server limiting maximum preview size to 2048px.

```shell
$ occ config:app:get previewgenerator squareSizes
64 256
$ occ config:app:get previewgenerator fillWidthHeightSizes
256 1024 2048
$ occ config:app:get previewgenerator coverWidthHeightSizes
256 1024 2048
$ occ config:app:get previewgenerator widthSizes
64 256 1024
$ occ config:app:get previewgenerator heightSizes
64 256 1024
$ occ config:app:get previewgenerator job_disabled
1
```