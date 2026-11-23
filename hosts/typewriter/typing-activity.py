#!/usr/bin/env python3
import os
import select
import threading
import time
import urllib.request

import evdev
from evdev import ecodes

WEBHOOK_URL = os.environ.get("TYPING_WEBHOOK_URL")
DEBOUNCE_SECONDS = float(os.environ.get("TYPING_DEBOUNCE_SECONDS", "5"))
RESCAN_SECONDS = 30.0

_locked = threading.Lock()
_last_sent = 0.0


def is_keyboard(device):
    keys = device.capabilities().get(ecodes.EV_KEY, [])
    return ecodes.KEY_A in keys and ecodes.KEY_Z in keys and ecodes.KEY_SPACE in keys


def discover():
    devices = []
    for path in evdev.list_devices():
        try:
            device = evdev.InputDevice(path)
        except (OSError, PermissionError):
            continue
        if is_keyboard(device):
            devices.append(device)
        else:
            device.close()
    return devices


def post_webhook():
    try:
        request = urllib.request.Request(WEBHOOK_URL, data=b"", method="POST")
        urllib.request.urlopen(request, timeout=5).close()
    except Exception as error:
        print(f"typing-activity: webhook failed: {error}", flush=True)


def report_activity():
    global _last_sent
    now = time.monotonic()
    with _locked:
        if now - _last_sent < DEBOUNCE_SECONDS:
            return
        _last_sent = now
    threading.Thread(target=post_webhook, daemon=True).start()


def main():
    if not WEBHOOK_URL:
        raise SystemExit("TYPING_WEBHOOK_URL is not set")

    devices = []
    last_scan = 0.0

    while True:
        now = time.monotonic()
        if not devices or now - last_scan >= RESCAN_SECONDS:
            for device in devices:
                try:
                    device.close()
                except OSError:
                    pass
            devices = discover()
            last_scan = now

        if not devices:
            time.sleep(2)
            continue

        try:
            ready, _, _ = select.select(devices, [], [], 5)
        except (OSError, ValueError):
            devices = []
            continue

        for device in ready:
            try:
                for event in device.read():
                    if event.type == ecodes.EV_KEY and event.value == 1:
                        report_activity()
            except OSError:
                devices = []
                break


if __name__ == "__main__":
    main()
