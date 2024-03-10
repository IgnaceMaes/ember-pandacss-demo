# Setting up Panda CSS in Ember

*ember-pandacss-demo*

This repo is a demo on how [Panda CSS](https://panda-css.com/) can be integrated in an Ember app.

Panda offers two main ways to integrate in a project: either via the Panda CLI, or via PostCSS.

## Integrate Panda CSS in Ember using the Panda CLI

### 1. Setup

#### 1.1 Start a new project and add Panda CSS

```sh
# Start new Ember project
npx ember-cli new ember-pandacss-demo --embroider --no-welcome --pnpm

# Add support for .gjs/.gts template tag component format
pnpm install -D ember-template-imports prettier-plugin-ember-template-tag
## Prettier setup: https://github.com/gitKrystan/prettier-plugin-ember-template-tag
## ESLint setup: https://github.com/ember-cli/eslint-plugin-ember#gtsgjs

# Add Panda CSS
pnpm install -D @pandacss/dev
pnpm panda init
```

#### 1.2 Update `panda.config.mjs` to include `gjs,gts`

```diff
import { defineConfig } from "@pandacss/dev";

export default defineConfig({
  // Whether to use css reset
  preflight: true,

  // Where to look for your css declarations
-  include: ['./src/**/*.{ts,tsx,js,jsx}', './pages/**/*.{ts,tsx,js,jsx}'],
+  include: ["./app/**/*.{js,gjs,ts,gts}"],

  // Files to exclude
  exclude: [],

  // Useful for theme customization
  theme: {
    extend: {},
  },

  // The output directory for your css system
  outdir: "styled-system",
});
```

#### 1.3 Include `styled-system` in your app

For some reason, setting the panda output directory to `./app/styled-system` doesn't work. It finds the files correctly, but imports aren't detected. So we'll create a symlink to the output directory.

```sh
cd app/
ln -s ../styled-system ./styled-system
```

#### 1.4 Add `package.json` scripts

```diff
{
  // ...
  "scripts": {
+    "prepare": "panda codegen",
+    "panda:watch": "panda --watch"
    // ...
  }
}
```

#### 1.5 Add ignore rule to `.stylelintignore`

```diff
# unconventional files
/blueprints/*/files/

# compiled output
/dist/

# addons
/.node_modules.ember-try/

+ ## Panda
+ styled-system
+ styled-system-studio
```

#### 1.6 Import styles in `app.js`

```diff
import Application from '@ember/application';
import Resolver from 'ember-resolver';
import loadInitializers from 'ember-load-initializers';
import config from 'ember-pandacss-demo/config/environment';
+ import './styled-system/styles.css';

export default class App extends Application {
  modulePrefix = config.modulePrefix;
  podModulePrefix = config.podModulePrefix;
  Resolver = Resolver;
}

loadInitializers(App, config.modulePrefix);
```

### 2. Usage

#### 2.1 Use PandaCSS in a new component

```sh
# Add a new component
touch app/components/hello-panda.gjs
```

```gjs
import { css } from 'ember-pandacss-demo/styled-system/css';

const style = css({
  fontSize: '4xl',
  fontWeight: 'bold',
  color: 'blue.400',
});

<template>
  <div class={{style}}>Hello 🐼!</div>
</template>
```

Use the component in `app/templates/application.hbs`

```diff
{{page-title "EmberPandacssDemo"}}

<h2 id="title">Welcome to Ember</h2>

+ <HelloPanda />

{{outlet}}
```

#### 2.2 Run local dev server

```sh
# In one terminal
pnpm panda:watch

# Boot your app
pnpm start
```

## Integrate Panda CSS in Ember using Post CSS

TODO: loading via `postcss-loader` Webpack/Embroider seems to not pick up the PandaCSS `@layer ...` directives. When using the PostCSS CLI directly *it does*. Investigate why, likely something in the `@pandacss/dev/postcss` plugin?

## Caveats

### PandaCSS expects JavaScript function syntax

PandaCSS extracts styles at build time by matching on function calls to `css`, etc. Ember uses polish notation for calling functions in templates which does not get picked up by default.

**Example**

While the following code snippet will corectly set the classnames at runtime, it will not be picked up by PandaCSS at build time so the classes won't be generated.

```gjs
import { css } from 'ember-pandacss-demo/styled-system/css';
import { hash } from '@ember/helper';

<template>
  <div class={{css (hash fontSize='4xl' fontWeight='bold' color='blue.400')}}>Hello 🐼!</div>
</template>
```

This could be solved by creating [a custom `parser:before` hook](https://panda-css.com/docs/concepts/hooks) to extract calls and convert them to the expected JavaScript function syntax.
