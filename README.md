# ash-self

Ash-Self is an [Ash](https://github.com/BrandonRomano/ash) module to mange Ash itself.

### Getting started

This module is only available for Ash users through command line usage.

### Command Line Usage

#### self:init

To initialize the current working directory, run:

```sh
ash self:init
```

This will create an `Ashmodules` file in your current working directory.

In this file you can add git clone URLs, one per line, to install modules locally.

Example `Ashmodules` file:

```
git@github.com:BrandonRomano/ash-make.git
git@github.com:BrandonRomano/ash-logger.git
```

#### self:install

To install the modules defined in the `Ashmodules` file, run:

```sh
ash self:install
```

This will create an `ash_modules` folder where the modules will be installed into.

After the modules are installed, you are free to start using them in that directory.

#### self:update

To update a global module, run:

```sh
ash self:update global-module-name
```

To update ash itself, run:

```sh
ash self:update ash
```

## License

[MIT](LICENSE.md)
