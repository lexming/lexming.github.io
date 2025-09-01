# lexming.github.io

Digital garden built with [Quartz](https://quartz.jzhao.xyz).

# Structure of this repo

The setup of this repo is very similar to the [upstream workflow to publish in
Github Pages with Quartz](https://quartz.jzhao.xyz/hosting#github-pages). The
main difference is that this repo is **not** a fork of Quartz, but the code of
Quartz is kept as a submodule of this repo. This approach allows to keep
changes in the contents of my site separate to changes to the publishing tool.

## Quick bootstrap

1. Clone this repo recursively and enter its directory

   ```shell
   $ git clone --recursive https://github.com/lexming/lexming.github.io
   $ cd lexming.github.io
   ```

2. Install [Node.js](https://nodejs.org/)

3. Install dependencies with ``npm``

    ```shell
    $ npm i
    ```

4. Render the site

    ```shell
    $ npx quartz build --serve
    ```

