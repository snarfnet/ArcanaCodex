import json
import time
from pathlib import Path

import jwt
import requests


KEY_ID = "WDXGY9WX55"
ISSUER_ID = "2be0734f-943a-4d61-9dc9-5d9045c46fec"
KEY_PATH = Path(r"C:\Users\Windows\Downloads\AuthKey_WDXGY9WX55.p8")
BUNDLE_ID = "com.tokyonasu.ArcanaCodex"
APP_NAME = "Arcana Library"
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
    if response.status_code >= 400:
        print(f"{method} {path} -> {response.status_code}")
        print(response.text[:2000])
    response.raise_for_status()
    return response.json() if response.text else {}


def maybe_request(method, path, **kwargs):
    response = requests.request(method, f"{BASE}{path}", headers=headers(), timeout=60, **kwargs)
    print(f"{method} {path} -> {response.status_code}")
    if response.status_code >= 400:
        print(response.text[:1200])
    return response


def find_app():
    data = request("GET", f"/apps?filter[bundleId]={BUNDLE_ID}&limit=1")
    if not data["data"]:
        raise SystemExit(f"App not found for bundle ID: {BUNDLE_ID}")
    app = data["data"][0]
    print(f"App: {app['id']} {app['attributes'].get('name')}")
    return app["id"]


def ensure_app_info(app_id):
    infos = request("GET", f"/apps/{app_id}/appInfos")["data"]
    app_info_id = infos[0]["id"]

    maybe_request(
        "PATCH",
        f"/appInfos/{app_info_id}",
        json={
            "data": {
                "type": "appInfos",
                "id": app_info_id,
                "relationships": {
                    "primaryCategory": {"data": {"type": "appCategories", "id": "EDUCATION"}},
                    "secondaryCategory": {"data": {"type": "appCategories", "id": "REFERENCE"}},
                },
            }
        },
    )
    maybe_request(
        "PATCH",
        f"/apps/{app_id}",
        json={
            "data": {
                "type": "apps",
                "id": app_id,
                "attributes": {"contentRightsDeclaration": "USES_THIRD_PARTY_CONTENT"},
            }
        },
    )

    locs = request("GET", f"/appInfos/{app_info_id}/appInfoLocalizations")["data"]
    locales = {loc["attributes"]["locale"]: loc["id"] for loc in locs}
    privacy_policy_url = "https://snarfnet.github.io/ArcanaCodex/privacy.html"
    for locale in ["ja", "en-US"]:
        if locale in locales:
            maybe_request(
                "PATCH",
                f"/appInfoLocalizations/{locales[locale]}",
                json={
                    "data": {
                        "type": "appInfoLocalizations",
                        "id": locales[locale],
                        "attributes": {"name": APP_NAME, "privacyPolicyUrl": privacy_policy_url},
                    }
                },
            )
        else:
            maybe_request(
                "POST",
                "/appInfoLocalizations",
                json={
                    "data": {
                        "type": "appInfoLocalizations",
                        "attributes": {"locale": locale, "name": APP_NAME, "privacyPolicyUrl": privacy_policy_url},
                        "relationships": {"appInfo": {"data": {"type": "appInfos", "id": app_info_id}}},
                    }
                },
            )
    return app_info_id


def ensure_version(app_id):
    app_info_id = ensure_app_info(app_id)
    ensure_free_pricing(app_id)
    versions = request("GET", f"/apps/{app_id}/appStoreVersions?filter[platform]=IOS&limit=10")["data"]
    target = None
    for version in versions:
        if version["attributes"].get("versionString") == VERSION_STRING:
            target = version
            break
    if target is None:
        response = maybe_request(
            "POST",
            "/appStoreVersions",
            json={
                "data": {
                    "type": "appStoreVersions",
                    "attributes": {
                        "platform": "IOS",
                        "versionString": VERSION_STRING,
                        "copyright": "2026 tokyonasu",
                        "releaseType": "MANUAL",
                    },
                    "relationships": {"app": {"data": {"type": "apps", "id": app_id}}},
                }
            },
        )
        response.raise_for_status()
        target = response.json()["data"]

    version_id = target["id"]
    print(
        f"Version: {version_id} "
        f"{target['attributes'].get('versionString')} "
        f"{target['attributes'].get('appStoreState')}"
    )
    maybe_request(
        "PATCH",
        f"/appStoreVersions/{version_id}",
        json={
            "data": {
                "type": "appStoreVersions",
                "id": version_id,
                "attributes": {
                    "copyright": "2026 tokyonasu",
                    "releaseType": "AFTER_APPROVAL",
                    "usesIdfa": False,
                },
            }
        },
    )
    update_age_rating(app_info_id)
    update_version_localizations(version_id)
    return version_id


def ensure_free_pricing(app_id):
    price_points = request("GET", f"/apps/{app_id}/appPricePoints?filter[territory]=USA&limit=200")["data"]
    free_point = next(
        (point for point in price_points if point["attributes"].get("customerPrice") == "0.0"),
        None,
    )
    if not free_point:
        print("Free price point not found.")
        return

    maybe_request(
        "POST",
        "/appPriceSchedules",
        json={
            "data": {
                "type": "appPriceSchedules",
                "relationships": {
                    "app": {"data": {"type": "apps", "id": app_id}},
                    "baseTerritory": {"data": {"type": "territories", "id": "USA"}},
                    "manualPrices": {"data": [{"type": "appPrices", "id": "${free-price}"}]},
                },
            },
            "included": [
                {
                    "type": "appPrices",
                    "id": "${free-price}",
                    "attributes": {"startDate": None},
                    "relationships": {
                        "appPricePoint": {"data": {"type": "appPricePoints", "id": free_point["id"]}}
                    },
                }
            ],
        },
    )


def update_age_rating(app_info_id):
    rating_none = "NONE"
    maybe_request(
        "PATCH",
        f"/ageRatingDeclarations/{app_info_id}",
        json={
            "data": {
                "type": "ageRatingDeclarations",
                "id": app_info_id,
                "attributes": {
                    "alcoholTobaccoOrDrugUseOrReferences": rating_none,
                    "contests": rating_none,
                    "gambling": False,
                    "gamblingSimulated": rating_none,
                    "gunsOrOtherWeapons": rating_none,
                    "healthOrWellnessTopics": False,
                    "horrorOrFearThemes": rating_none,
                    "lootBox": False,
                    "matureOrSuggestiveThemes": rating_none,
                    "medicalOrTreatmentInformation": rating_none,
                    "messagingAndChat": False,
                    "parentalControls": False,
                    "profanityOrCrudeHumor": rating_none,
                    "sexualContentGraphicAndNudity": rating_none,
                    "sexualContentOrNudity": rating_none,
                    "unrestrictedWebAccess": False,
                    "userGeneratedContent": False,
                    "violenceCartoonOrFantasy": rating_none,
                    "violenceRealistic": rating_none,
                    "violenceRealisticProlongedGraphicOrSadistic": rating_none,
                    "advertising": True,
                    "ageAssurance": False,
                },
            }
        },
    )


def update_version_localizations(version_id):
    ja_desc = (
        "Arcana Libraryは、タロットの象徴体系を古典から学ぶためのリファレンスアプリです。\n\n"
        "Papus、A.E. Waite、P.D. Ouspenskyなどの視点をもとに、大アルカナ、生命の樹、"
        "占星術、四元素を整理して読めます。\n\n"
        "主な機能:\n"
        "- 大アルカナの象徴辞典\n"
        "- 巨匠ごとの解釈比較\n"
        "- カバラ生命の樹と22のパス\n"
        "- 十二宮、惑星、四元素の対応\n"
        "- 小アルカナの数秘とスート解説\n\n"
        "タロットを占いだけでなく、象徴学や西洋秘教の文脈から深く学びたい方に向けたアプリです。"
    )
    en_desc = (
        "Arcana Library is a tarot symbolism reference app built for studying classical tarot interpretation.\n\n"
        "Explore the Major Arcana through the perspectives of Papus, A.E. Waite, P.D. Ouspensky, "
        "and related esoteric correspondences.\n\n"
        "Features:\n"
        "- Major Arcana symbolism reference\n"
        "- Master interpretation comparison\n"
        "- Kabbalistic Tree of Life paths\n"
        "- Zodiac, planetary, and elemental correspondences\n"
        "- Minor Arcana numerology and suit references\n\n"
        "A compact library for learning tarot through symbols, classical texts, and Western esoteric tradition."
    )
    payloads = {
        "ja": {
            "description": ja_desc,
            "keywords": "タロット,カバラ,生命の樹,象徴,占星術,ヘルメス,大アルカナ,小アルカナ,数秘,辞典",
            "marketingUrl": "https://snarfnet.github.io/ArcanaCodex/",
            "supportUrl": "https://snarfnet.github.io/ArcanaCodex/privacy.html",
        },
        "en-US": {
            "description": en_desc,
            "keywords": "tarot,kabbalah,arcana,symbolism,astrology,hermetic,reference,esoteric,tree of life",
            "marketingUrl": "https://snarfnet.github.io/ArcanaCodex/",
            "supportUrl": "https://snarfnet.github.io/ArcanaCodex/privacy.html",
        },
    }
    locs = request("GET", f"/appStoreVersions/{version_id}/appStoreVersionLocalizations")["data"]
    existing = {loc["attributes"]["locale"]: loc["id"] for loc in locs}
    for locale, attrs in payloads.items():
        if locale in existing:
            maybe_request(
                "PATCH",
                f"/appStoreVersionLocalizations/{existing[locale]}",
                json={
                    "data": {
                        "type": "appStoreVersionLocalizations",
                        "id": existing[locale],
                        "attributes": attrs,
                    }
                },
            )
        else:
            maybe_request(
                "POST",
                "/appStoreVersionLocalizations",
                json={
                    "data": {
                        "type": "appStoreVersionLocalizations",
                        "attributes": {"locale": locale, **attrs},
                        "relationships": {
                            "appStoreVersion": {"data": {"type": "appStoreVersions", "id": version_id}}
                        },
                    }
                },
            )


def latest_build(app_id):
    data = request("GET", f"/builds?filter[app]={app_id}&sort=-uploadedDate&limit=5")["data"]
    for build in data:
        attrs = build["attributes"]
        print("Build:", build["id"], attrs.get("version"), attrs.get("processingState"), attrs.get("uploadedDate"))
    build_id = data[0]["id"] if data else None
    if build_id:
        maybe_request(
            "PATCH",
            f"/builds/{build_id}",
            json={
                "data": {
                    "type": "builds",
                    "id": build_id,
                    "attributes": {"usesNonExemptEncryption": False},
                }
            },
        )
    return build_id


def attach_build(version_id, build_id):
    if not build_id:
        print("No build found yet.")
        return
    maybe_request(
        "PATCH",
        f"/appStoreVersions/{version_id}",
        json={
            "data": {
                "type": "appStoreVersions",
                "id": version_id,
                "relationships": {"build": {"data": {"type": "builds", "id": build_id}}},
            }
        },
    )


def main():
    app_id = find_app()
    version_id = ensure_version(app_id)
    build_id = latest_build(app_id)
    attach_build(version_id, build_id)
    print(json.dumps({"app_id": app_id, "version_id": version_id, "build_id": build_id}, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
