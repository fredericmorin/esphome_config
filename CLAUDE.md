# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A local mirror of the ESPHome device configs that live on a Home Assistant box at
`/homeassistant/esphome/`, kept here so the YAML is easier to edit and has git history.
The work Claude does here is **writing and editing device configs in `devices/`**.

The sync scripts in the repo root (`setup.sh`, `esphome`, `pull_from_ha`, `push_to_ha`,
`diff_local_with_ha`) are invoked by the user only — never run them. They move YAML between
`devices/` and HA over SSH, and flashing happens from the HA ESPHome dashboard. Since HA is what
is actually running, local files can be stale; if that matters for a change, say so rather than
checking.

## Device configs (`devices/`)

One flat file per device, named after the device (`dimmer*`, `plug*`, `outplug*`, `led*`, `ir*`,
`humi*`, `aqi*`, plus one-offs like `hvac1`, `emporiavue2`, `ratgdov25i`). The filename,
`esphome.name`, and the HA entity prefix are all the same string — keep them in sync.

Configs are standalone: no shared packages, no common substitution layer. A change that should
apply to a whole class of device has to be repeated in each file, and the closest existing device
is the best template for a new one.

Three platform families are in use:

- **esp8266** (`esp01_1m`, `esp8285`, `d1_mini`) — the majority. Most are Tuya devices driven over
  UART with the `tuya:` component, which needs `logger: baud_rate: 0` to free the serial port.
  Tuya entities are wired by datapoint number, which differs per hardware revision.
- **bk72xx / rtl87xx** (LibreTiny) — the `dimmer2x`/`plug2x` generation of Tuya hardware.
- **esp32** — `hvac1`, `emporiavue2`, and the `lolin_s2_mini` board.

`emporiavue2` and `hvac1` pull `external_components:` from GitHub; `ratgdov25i` pulls a remote
`packages:` base config. Those three are thin wrappers around upstream projects — check upstream
before changing their structure.

Common additions across most devices: a `restart` switch, a `wifi_signal` sensor, `web_server:`,
`mdns:`, and `captive_portal:`.

## Secrets and networking

`!secret` values resolve from `devices/secrets.yaml` (gitignored; keys: `wifi_ssid`,
`wifi_password`, `niot_ssid`, `niot_password`, `ota_password`).

Every device but `plug8` is on the `niot_*` IoT WLAN and pins a static `use_address:` — mDNS does
not cross that segment, so a new device needs an address assigned rather than a hostname. Most
files keep the old `wifi_*` lines commented out just below.

Per-device `api.encryption.key` and `ota.password` are committed in plaintext. They are
per-device, and regenerating one means re-adding the device in HA — leave them alone unless asked.
