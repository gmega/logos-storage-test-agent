# CLAUDE-TIPS.md

Notes-to-self for running the storage-module / storage-ui check against basecamp.
These are stable across runs; if you find one is wrong, fix it here rather than
re-discover.

## Build / install

- **Use the dev basecamp build.** `nix build '.#app'` in `logos-basecamp`. The release
  AppImage does **not** open the inspector port 3768, so MCP automation is impossible
  against it.
- **LGX flavour must match.** Dev basecamp ↔ local LGX
  (`nix bundle --bundler github:logos-co/nix-bundle-lgx ".#lib"`).
  The storage-ui repo doesn't use the bundler — it has its own target:
  `nix build '.#lgx'`.
- **Install the CORE module first, then the UI.** The UI module won't function without
  the core loaded. `tools/install.sh` already sequences this correctly.
- **`installPluginFromPath` is fire-and-forget.** `ok: true` in the response only means
  the call was accepted, not that the install dialog was confirmed. Always poll for and
  click the confirmation button. The button text is **`Install`** for a fresh install and
  **`Upgrade`** if a previous version was already there — handle both.
  `tools/logos-cli.py` already does (30 s timeout).
- **Repo names — watch out.** The UI repo is `logos-co/logos-storage-ui` (not
  `logos-storage-ui-module`, which is a 404 — CLAUDE.md has that typo).
- **Verify install from disk, not just from "ok".** Look under
  `~/.local/share/Logos/LogosBasecampDev/`:
  - `modules/storage_module/` — core module present
  - `plugins/storage_ui/` — UI plugin present
  Note: release-built basecamp uses `LogosBasecamp/` (no `Dev` suffix); a residue
  there from a prior run is unrelated to the current dev session.

## Driving the QML inspector (port 3768)

- **`getTree` vs `listInteractive`.** `listInteractive` only returns clickable widgets
  (buttons, tab buttons, sidebar delegates). Onboarding cards, labels, manifest rows,
  etc., only appear in `getTree`. When something you need isn't in `listInteractive`,
  dump the tree to a file and grep.
- **Cards are clickable containers, not their text.** The onboarding `Guided`, `UPnP`,
  `Port Forwarding` options are `OnBoardingCard_QMLTYPE_*` containers; the inner
  `QQuickText` is *not* clickable. Walk ancestors of the text node until you find the
  card type, then click that.
- **Pattern: ancestors-of-text.** Build a parent map from `getTree`, locate the text node
  you care about, walk up until you hit a sensible clickable type
  (`*Button*`, `*Card*`, `*Delegate*`).
- **Element IDs change across basecamp restarts.** Don't reuse IDs across sessions —
  re-list before clicking. `SidebarAppDelegate_QMLTYPE_*` numbers in the type itself
  also shift, so match on `text=` not on the QML type number.

## Driving the storage module without the native file dialog

The Upload widget opens a native QFileDialog, which is awkward to drive over the inspector.
Bypass it by calling the core module directly:

```python
# Upload
expr = ('backend.callCoreModuleMethod("storage_module", "uploadUrl", '
        'JSON.stringify(["file:///abs/path/sample.bin"]))')
# Download (local=true if the node already has the file)
expr = ('backend.callCoreModuleMethod("storage_module", "downloadToUrl", '
        'JSON.stringify(["<CID>", "file:///abs/path/out.bin", true]))')
```

- **The return value collapses to `null`** through the JSON bridge. `LogosResult` types
  don't survive. Don't try to read the CID from the call result.
- **Get the CID from the UI tree.** After upload completes, the Manifests panel shows
  the CID — grep `getTree` output for `zDv` (Logos CIDs start with that). It's also in
  `storage.log` if you prefer log scraping.
- **Both calls are asynchronous.** Sleep a few seconds before reading state. For a 1 MB
  file, 3–5 s was enough on this machine.

## Data layout on disk

- Storage module data: `~/.logos_storage/data/{repo,dht,meta}/...`
  (`repo/manifests/` and `repo/blocks/` accumulate per uploaded file).
- Basecamp modules/plugins (dev build): `~/.local/share/Logos/LogosBasecampDev/`.

## Things that have wasted time before

- Letting the install_module helper time out silently because the dialog said `Upgrade`
  not `Install`. Already fixed in `tools/logos-cli.py`, don't regress it.
- Treating the empty Modules → UI Modules tab as "nothing installed" — the storage
  module is a *core* module; check the `Core Modules` tab.
- Trusting `callCoreModuleMethod`'s return value as success. Always verify side effects
  (disk usage went up, manifest row appeared, file exists on disk).
