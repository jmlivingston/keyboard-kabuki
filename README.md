# Keyboard Kabuki

This is a monorepo that uses [npm workspaces](https://docs.npmjs.com/cli/using-npm/workspaces):

- `web/`: React + TypeScript + Vite web app
- `app/`: iOS app (Xcode project)

## Prerequisites

- Node.js and npm
- Xcode with an iOS Simulator runtime (only needed for `app/`)

## Install

Run this from the repository root:

```sh
npm install
```

That one command installs the dependencies for every workspace, so you don't need to run `npm install` inside `web/` or `app/`. To add a dependency to a single workspace, run this from the root:

```sh
npm install <package> -w web
```

## Scripts

Run these from the repository root:

| Command             | Description                                              |
| ------------------- | -------------------------------------------------------- |
| `npm run dev:web`   | Start the Vite dev server                                |
| `npm run build:web` | Type-check and build the web app                         |
| `npm run build:app` | Build the iOS app for the simulator                      |
| `npm run simulator` | Build the iOS app and launch it in the simulator (default device: iPhone 17; override with `SIMULATOR_DEVICE`) |
