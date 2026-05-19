import hashlib
import time
from pathlib import Path

import jwt
import requests


KEY_ID = "WDXGY9WX55"
ISSUER_ID = "2be0734f-943a-4d61-9dc9-5d9045c46fec"
KEY_PATH = Path(r"C:\Users\Windows\Downloads\AuthKey_WDXGY9WX55.p8")
BUNDLE_ID = "com.tokyonasu.ArcanaCodex"
VERSION_STRING = "1.0"
BASE = "https://api.appstoreconnect.apple.com/v1"
ROOT = Path(__file__).resolve().parents[1]

SCREENSHOT_GROUPS = {
    "APP_IPHONE_65": ROOT / "AppStoreAssets" / "Screenshots" / "iphone-6-5",
    "APP_IPHONE_67": ROOT / "AppStoreAssets" / "Screenshots" / "iphone-6-9",
    "APP_IPAD_PRO_3GEN_129": ROOT / "AppStoreAssets" / "Screenshots" / "ipad-13",
}


def token():
    now = int(time.time())
    payload = {
        "iss": ISSUER_ID,
        "iat": now,
        "exp": now + 1200,
        "aud": "appstoreconnect-v1",
    }
    return jwt.encode(payload, KEY_PATH.read_text(), algorithm="ES256", headers={"kid": KEY_ID})


def headers():
    return {"Authorization": f"Bearer {token()}", "Content-Type": "application/json"}


def request(method, path, **kwargs):
    response = requests.request(method, f"{BASE}{path}", headers=headers(), timeout=60, **kwargs)
    print(f"{method} {path} -> {response.status_code}")
    if response.status_code >= 400:
        print(response.text[:2000])
    response.raise_for_status()
    return response.json() if response.text else {}


def find_app():
    data = request("GET", f"/apps?filter[bundleId]={BUNDLE_ID}&limit=1")
    if not data["data"]:
        raise SystemExit(f"App not found for bundle ID: {BUNDLE_ID}")
    return data["data"][0]["id"]


def find_version(app_id):
    versions = request("GET", f"/apps/{app_id}/appStoreVersions?filter[platform]=IOS&limit=20")["data"]
    for version in versions:
        if version["attributes"].get("versionString") == VERSION_STRING:
            return version["id"]
    raise SystemExit(f"App Store version not found: {VERSION_STRING}")


def version_localizations(version_id):
    locs = request("GET", f"/appStoreVersions/{version_id}/appStoreVersionLocalizations?limit=20")["data"]
    return {loc["attributes"]["locale"]: loc["id"] for loc in locs}


def delete_existing_sets(localization_id):
    data = request(
        "GET",
        f"/appStoreVersionLocalizations/{localization_id}/appScreenshotSets?limit=50",
    )["data"]
    for screenshot_set in data:
        request("DELETE", f"/appScreenshotSets/{screenshot_set['id']}")


def create_screenshot_set(localization_id, display_type):
    data = request(
        "POST",
        "/appScreenshotSets",
        json={
            "data": {
                "type": "appScreenshotSets",
                "attributes": {"screenshotDisplayType": display_type},
                "relationships": {
                    "appStoreVersionLocalization": {
                        "data": {"type": "appStoreVersionLocalizations", "id": localization_id}
                    }
                },
            }
        },
    )
    return data["data"]["id"]


def upload_file(screenshot_set_id, path):
    content = path.read_bytes()
    checksum = hashlib.md5(content).hexdigest()
    reservation = request(
        "POST",
        "/appScreenshots",
        json={
            "data": {
                "type": "appScreenshots",
                "attributes": {"fileSize": len(content), "fileName": path.name},
                "relationships": {
                    "appScreenshotSet": {"data": {"type": "appScreenshotSets", "id": screenshot_set_id}}
                },
            }
        },
    )["data"]

    screenshot_id = reservation["id"]
    operations = reservation["attributes"]["uploadOperations"]
    for operation in operations:
        offset = int(operation.get("offset", 0))
        length = int(operation.get("length", len(content)))
        headers_list = operation.get("requestHeaders") or []
        upload_headers = {header["name"]: header["value"] for header in headers_list}
        upload_response = requests.request(
            operation["method"],
            operation["url"],
            headers=upload_headers,
            data=content[offset : offset + length],
            timeout=120,
        )
        print(f"UPLOAD {path.name} bytes {offset}-{offset + length} -> {upload_response.status_code}")
        upload_response.raise_for_status()

    request(
        "PATCH",
        f"/appScreenshots/{screenshot_id}",
        json={
            "data": {
                "type": "appScreenshots",
                "id": screenshot_id,
                "attributes": {"uploaded": True, "sourceFileChecksum": checksum},
            }
        },
    )
    return screenshot_id


def main():
    app_id = find_app()
    version_id = find_version(app_id)
    localizations = version_localizations(version_id)
    target_locales = [locale for locale in ["ja", "en-US"] if locale in localizations]
    if not target_locales:
        raise SystemExit("No target localizations found.")

    for locale in target_locales:
        localization_id = localizations[locale]
        delete_existing_sets(localization_id)
        for display_type, folder in SCREENSHOT_GROUPS.items():
            files = sorted(folder.glob("*.png"))
            if not files:
                raise SystemExit(f"No screenshots found: {folder}")
            print(f"{locale} {display_type}: uploading {len(files)} screenshots")
            screenshot_set_id = create_screenshot_set(localization_id, display_type)
            for file_path in files:
                upload_file(screenshot_set_id, file_path)


if __name__ == "__main__":
    main()
