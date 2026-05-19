import json
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
        print(response.text[:4000])
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
            print(json.dumps(version["attributes"], ensure_ascii=False, indent=2))
            return version["id"], version["attributes"].get("appStoreState")
    raise SystemExit(f"App Store version not found: {VERSION_STRING}")


def submit(version_id):
    app_id = find_app()
    submission = request(
        "POST",
        "/reviewSubmissions",
        json={
            "data": {
                "type": "reviewSubmissions",
                "attributes": {"platform": "IOS"},
                "relationships": {
                    "app": {"data": {"type": "apps", "id": app_id}}
                },
            }
        },
    )
    submission_id = submission["data"]["id"]
    request(
        "POST",
        "/reviewSubmissionItems",
        json={
            "data": {
                "type": "reviewSubmissionItems",
                "relationships": {
                    "reviewSubmission": {"data": {"type": "reviewSubmissions", "id": submission_id}},
                    "appStoreVersion": {"data": {"type": "appStoreVersions", "id": version_id}},
                },
            }
        },
    )
    return request(
        "PATCH",
        f"/reviewSubmissions/{submission_id}",
        json={
            "data": {
                "type": "reviewSubmissions",
                "id": submission_id,
                "attributes": {"submitted": True},
            }
        },
    )


def main():
    app_id = find_app()
    version_id, state = find_version(app_id)
    if state != "PREPARE_FOR_SUBMISSION":
        print(f"Version is already past preparation state: {state}")
        return
    result = submit(version_id)
    print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
