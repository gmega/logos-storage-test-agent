Logos is a modular platform. **basecamp** is its core component — a Qt/QML desktop
application that acts as a host framework; other features ship as **modules** (plugins)
that load into it, each distributed as an `.lgx` package. The **storage module** is one
such module: it provides decentralised file storage — you import/upload files and download
them back by content ID.

Your task will be to make sure that the Logos storage app - a UI application that ships
as a logos storage - works correctly.

## Before you start: skip if already tested

Resolve the latest release tag for each of the three upstream repos
(`logos-basecamp`, `logos-storage-module`, `logos-storage-ui`) — for example by hitting
`https://api.github.com/repos/<owner>/<repo>/releases/latest`. Then check the
"Test runs" table in `README.md`. If a row already exists with the same three tags AND
a `PASS` result, do **not** run the test again. Print exactly:

> this combination of versions has already been tested

and stop. Do not clone, do not build, do not start basecamp, and do not write a new
run summary.

Only proceed past this point if no matching PASS row exists.

## Build and Install

1. Check out the basecamp repo (https://github.com/logos-co/logos-basecamp) and build it. See the README, but you can build it with a simple 'nix build'.

2. Check out the storage core module repo (https://github.com/logos-co/logos-storage-module) and build it - see the README. You will build a "local" LGX for this.

You can do it by running the bundler directly at the module's root with:

```bash
nix bundle --bundler github:logos-co/nix-bundle-lgx ".#lib"
```

then looking for the generated LGX file.

3. Check out the storage UI module (https://github.com/logos-co/logos-storage-ui) and build it - see the README. The UI module does not work with the bundler so you need to do:

```bash
nix build ".#lgx"
```

4. Launch basecamp (built on step 1).
5. Load and confirm the installation of both the core storage module and the storage UI module. Make sure you install the core module first AND THEN LOAD IT. You will need to click an "Install" button to do that. You can use the code in the `logos-cli.py` module as inspiration on how to do that.

## Test

Now comes the fun part which I need you the most: test the storage app. You will click the storage app button on the basecamp sidebar, which should launch the storage app inside of basecamp. You will follow the onboarding tutorial described here: https://github.com/logos-co/logos-storage-ui#running-the-standalone-app, except that you do not need to launch the app separately - it's already running inside basecamp.

We are behind UPnP, so follow the UPnP path. You should see some message telling you that the node is reachable when you are successful (how you see that message is up to you - screenshot or the QML inspector protocol).

The file you will share is a random file with 1 megabyte, which you can create by using DD on /dev/urandom. You should take the CID of the file you shared, save it to the local filesystem, and compare both what you uploaded and what you downloaded by shasum.

Note: DO NOT BYPASS THE UI MODULE. You must use the UI to perform all actions, do not invoke the core module directly. Using the QML inspector protocol to click a button is acceptable, using it to download a file by invoking the storage module API directly (e.g. uploadFile/downloadFile) is not.

## Test summary

This task will be re-run whenever there is a new release of basecamp or one of the
modules. At the end of every run, you must update three things and commit them:

### 1. Write a new run summary

Create `runs/YYYY-MM-DD-basecamp-<basecamp-tag>.md` containing:

1. The exact versions of every component (basecamp tag + commit, storage-module tag,
   storage-ui tag, plus the LGX/module version embedded in each generated `.lgx`).
2. A table with one row per task (the steps in this file, in order), with PASS / FAIL
   and a short note for each — including what you had to change, retry, or work around.
3. An "Overall: PASS / FAIL" line.
4. Anything notable that future-you should know about this release.

Do NOT overwrite previous summaries — each run goes in its own dated file so we can spot
regressions across releases.

### 2. Update the runs index in `README.md`

Insert a new row at the **top** of the "Test runs" table in `README.md` with: date,
basecamp tag, storage-module tag, storage-ui tag, result (PASS/FAIL), and a relative
link to the summary file you just wrote. Don't touch existing rows.

### 3. Update the status badge in `README.md`

The badge line at the top of `README.md` is a shields.io URL. Replace it with one of:

- PASS: `![storage-stack](https://img.shields.io/badge/logos--storage--modules-passing-brightgreen)`
- FAIL: `![storage-stack](https://img.shields.io/badge/logos--storage--modules-failing-red)`

The badge always reflects the latest run (i.e. the row you just inserted).

### 4. Commit

This task is designed to run on CI. After the three updates above, commit the new and
modified files on a branch (the new file under `runs/` and the modified `README.md`)
and open a PR, so the result is durable.

---

Read `CLAUDE-TIPS.md` before starting; update it if you discover something new and
stable.
