# Building PokeRPG through EAS

PokeRPG is a **Godot 4 project**, not an Expo/React Native app - EAS Build's
normal "managed"/"bare" build flow doesn't apply here, since there's no
`package.json`, no native `android/`/`ios/` folder, and no Expo config.

What *does* apply is **EAS Workflows' custom jobs**: a workflow YAML runs
arbitrary shell steps on an Expo-hosted VM, the same way any other CI would.
[.eas/workflows/android-release.yml](.eas/workflows/android-release.yml)
installs the Godot editor + Android export templates on that VM, then calls
this repo's own [scripts/tools/build_android_release.sh](scripts/tools/build_android_release.sh)
unchanged - that script already contains the project-specific fix for a
Zip64/apksigner signing issue (see its header comment), so the workflow
doesn't reimplement that logic.

This file (and the workflow YAML) were written against Expo's public EAS
Workflows docs, not run against a real EAS project - there's no Expo account
in this environment to test one against. Treat step names/fields as a
strong starting point, not a guarantee; the first run will likely need a
small adjustment or two from whatever the EAS dashboard reports.

## One-time setup (do this yourself - none of it can be done on your behalf)

1. **Install the EAS CLI and log in**, from your own machine, with your own
   Expo account:
   ```
   npm install -g eas-cli
   eas login
   ```
   Never paste your Expo password anywhere in a chat, PR, or issue - `eas
   login` is interactive and keeps the session local to your machine.

2. **Link this repo to an Expo project**, from the repo root:
   ```
   eas init
   ```
   This writes a project ID into `.eas.json`/`app.json` (or asks you to
   create one) - commit whatever it generates.

3. **Create the release keystore**, if you don't already have one from a
   previous local build (`scripts/tools/build_android_release.sh`'s own
   usage comment shows the local equivalent). Keep the `.keystore` file
   itself out of git.

4. **Store the signing secrets as EAS environment variables**, scoped to
   the `production` environment (matching `environment: production` in the
   workflow), and marked **sensitive** so they're redacted from logs:
   ```
   eas env:create --environment production --name ANDROID_RELEASE_KEYSTORE_BASE64 \
     --value "$(base64 -w0 /path/to/pokerpg-release.keystore)" --type sensitive
   eas env:create --environment production --name GODOT_ANDROID_KEYSTORE_RELEASE_USER \
     --value "pokerpg" --type sensitive
   eas env:create --environment production --name GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD \
     --value "<your keystore password>" --type sensitive
   ```
   (`pokerpg` matches `keystore/release_user` in
   [export_presets.cfg](export_presets.cfg) - change it there too if you
   ever rename the alias.)

5. **Run it:**
   ```
   eas workflow:run .eas/workflows/android-release.yml
   ```
   or push to `main`, since the workflow also triggers on that. Either way,
   the signed APK comes back as a downloadable artifact on the workflow run
   page - EAS does not install it on a device for you.

## Why not a normal EAS "build" job?

EAS Build's prebuilt `type: build` job type invokes Expo's own Android/iOS
build pipeline (Gradle for a bare/managed RN app). This project has no
Gradle project for it to build - `export_presets.cfg` explicitly runs with
`gradle_build/use_gradle_build=false`, because the generated Gradle export
hit a signing/Zip64 wall the project's own APK-packaging path was built to
avoid (again, see `build_android_release.sh`'s header). A custom job is the
correct fit precisely because it just runs commands, with no assumption
that the project is a Gradle or Expo one.
