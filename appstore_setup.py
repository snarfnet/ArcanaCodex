"""ASC API: Arcana Codex アプリ作成+メタデータ設定"""
import json
import time
import jwt
import requests

# ASC API credentials
KEY_ID = "WDXGY9WX55"
ISSUER_ID = "2be0734f-943a-4d61-9dc9-5d9045c46fec"
KEY_PATH = r"C:\Users\Windows\Downloads\AuthKey_WDXGY9WX55.p8"
BUNDLE_ID = "com.tokyonasu.ArcanaCodex"

def get_token():
    with open(KEY_PATH, "r") as f:
        key = f.read()
    now = int(time.time())
    payload = {"iss": ISSUER_ID, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"}
    return jwt.encode(payload, key, algorithm="ES256", headers={"kid": KEY_ID})

HEADERS = lambda: {
    "Authorization": f"Bearer {get_token()}",
    "Content-Type": "application/json"
}
BASE = "https://api.appstoreconnect.apple.com/v1"

def create_app():
    data = {
        "data": {
            "type": "apps",
            "attributes": {
                "bundleId": BUNDLE_ID,
                "name": "Arcana Codex",
                "primaryLocale": "ja",
                "sku": "arcanacodex2026"
            },
            "relationships": {
                "bundleId": {
                    "data": {"type": "bundleIds", "id": get_bundle_id()}
                }
            }
        }
    }
    r = requests.post(f"{BASE}/apps", headers=HEADERS(), json=data)
    print(f"Create app: {r.status_code}")
    if r.status_code == 201:
        app_id = r.json()["data"]["id"]
        print(f"App ID: {app_id}")
        return app_id
    else:
        print(r.text)
        # Try to find existing app
        return find_existing_app()

def find_existing_app():
    r = requests.get(f"{BASE}/apps?filter[bundleId]={BUNDLE_ID}", headers=HEADERS())
    if r.status_code == 200 and r.json()["data"]:
        app_id = r.json()["data"][0]["id"]
        print(f"Existing App ID: {app_id}")
        return app_id
    return None

def get_bundle_id():
    r = requests.get(f"{BASE}/bundleIds?filter[identifier]={BUNDLE_ID}", headers=HEADERS())
    if r.status_code == 200 and r.json()["data"]:
        return r.json()["data"][0]["id"]
    # Register bundle ID
    data = {
        "data": {
            "type": "bundleIds",
            "attributes": {
                "identifier": BUNDLE_ID,
                "name": "ArcanaCodex",
                "platform": "IOS"
            }
        }
    }
    r = requests.post(f"{BASE}/bundleIds", headers=HEADERS(), json=data)
    print(f"Register bundle ID: {r.status_code}")
    if r.status_code == 201:
        return r.json()["data"]["id"]
    print(r.text)
    return None

def setup_metadata(app_id):
    # Get app info for localization
    r = requests.get(f"{BASE}/apps/{app_id}/appInfos", headers=HEADERS())
    if r.status_code != 200:
        print(f"Get app infos failed: {r.status_code}")
        return
    app_info_id = r.json()["data"][0]["id"]

    # Set category to Education > Reference
    cat_data = {
        "data": {
            "type": "appInfos",
            "id": app_info_id,
            "relationships": {
                "primaryCategory": {
                    "data": {"type": "appCategories", "id": "EDUCATION"}
                },
                "secondaryCategory": {
                    "data": {"type": "appCategories", "id": "REFERENCE"}
                }
            }
        }
    }
    r = requests.patch(f"{BASE}/appInfos/{app_info_id}", headers=HEADERS(), json=cat_data)
    print(f"Set category: {r.status_code}")

    # Set age rating (no objectionable content)
    # Get appInfo localizations
    r = requests.get(f"{BASE}/appInfos/{app_info_id}/appInfoLocalizations", headers=HEADERS())
    if r.status_code == 200:
        for loc in r.json()["data"]:
            loc_id = loc["id"]
            locale = loc["attributes"]["locale"]
            if locale == "ja":
                update_ja_info(loc_id)

    # Add English localization
    en_data = {
        "data": {
            "type": "appInfoLocalizations",
            "attributes": {
                "locale": "en-US",
                "name": "Arcana Codex"
            },
            "relationships": {
                "appInfo": {
                    "data": {"type": "appInfos", "id": app_info_id}
                }
            }
        }
    }
    r = requests.post(f"{BASE}/appInfoLocalizations", headers=HEADERS(), json=en_data)
    print(f"Add en-US info: {r.status_code}")

def update_ja_info(loc_id):
    data = {
        "data": {
            "type": "appInfoLocalizations",
            "id": loc_id,
            "attributes": {
                "name": "Arcana Codex"
            }
        }
    }
    r = requests.patch(f"{BASE}/appInfoLocalizations/{loc_id}", headers=HEADERS(), json=data)
    print(f"Update ja info: {r.status_code}")

def setup_version(app_id):
    # Get version
    r = requests.get(f"{BASE}/apps/{app_id}/appStoreVersions?filter[platform]=IOS", headers=HEADERS())
    if r.status_code != 200 or not r.json()["data"]:
        print("No version found, creating...")
        ver_data = {
            "data": {
                "type": "appStoreVersions",
                "attributes": {
                    "platform": "IOS",
                    "versionString": "1.0",
                    "copyright": "2026 tokyonasu",
                    "releaseType": "MANUAL"
                },
                "relationships": {
                    "app": {"data": {"type": "apps", "id": app_id}}
                }
            }
        }
        r = requests.post(f"{BASE}/appStoreVersions", headers=HEADERS(), json=ver_data)
        print(f"Create version: {r.status_code}")
        if r.status_code != 201:
            print(r.text)
            return
        version_id = r.json()["data"]["id"]
    else:
        version_id = r.json()["data"][0]["id"]

    # Get localizations
    r = requests.get(f"{BASE}/appStoreVersions/{version_id}/appStoreVersionLocalizations", headers=HEADERS())
    if r.status_code == 200:
        for loc in r.json()["data"]:
            if loc["attributes"]["locale"] == "ja":
                update_ja_version(loc["id"])

    # Add en-US version localization
    en_ver = {
        "data": {
            "type": "appStoreVersionLocalizations",
            "attributes": {
                "locale": "en-US",
                "description": "Arcana Codex is a comprehensive reference encyclopedia of Hermetic symbolism.\n\nExplore the 22 Major Arcana through the lens of three master scholars:\n- Papus (Tarot of the Bohemians, 1892)\n- A.E. Waite (Pictorial Key to the Tarot, 1911)\n- P.D. Ouspensky (Symbolism of the Tarot)\n\nFeatures:\n- Complete Hebrew letter & Kabbalistic Tree of Life path correspondences\n- Astrological & planetary associations for all 22 Major Arcana\n- Four Elements & Minor Arcana numerology reference\n- Side-by-side scholar interpretation comparison\n- Interactive Tree of Life diagram with Sephiroth connections\n\nA scholarly reference tool for students of Western esotericism, Kabbalah, and Hermetic philosophy.",
                "keywords": "kabbalah,tarot,hermetic,symbolism,occult,reference,esoteric,hebrew,astrology,sephiroth",
                "marketingUrl": "https://snarfnet.github.io/ArcanaCodex/",
                "whatsNew": "Initial release"
            },
            "relationships": {
                "appStoreVersion": {"data": {"type": "appStoreVersions", "id": version_id}}
            }
        }
    }
    r = requests.post(f"{BASE}/appStoreVersionLocalizations", headers=HEADERS(), json=en_ver)
    print(f"Add en-US version: {r.status_code}")

def update_ja_version(loc_id):
    data = {
        "data": {
            "type": "appStoreVersionLocalizations",
            "id": loc_id,
            "attributes": {
                "description": "Arcana Codex（アルカナ・コデックス）は、ヘルメス学の象徴体系を網羅した学術リファレンスアプリです。\n\n三人の碩学による大アルカナ22枚の解釈を並列収録：\n・Papus『ボヘミアンのタロット』(1892)\n・A.E. Waite『タロット図解の鍵』(1911)\n・P.D. Ouspensky『タロットの象徴学』\n\n主な機能：\n・ヘブライ文字とカバラ生命の樹パスの完全対応表\n・22枚の占星術・天体対応一覧\n・四元素と小アルカナの数秘術リファレンス\n・三巨匠の解釈比較\n・インタラクティブな生命の樹ダイアグラム\n\n西洋秘教学、カバラ、ヘルメス哲学を学ぶ方のための学術リファレンスです。",
                "keywords": "カバラ,タロット,ヘルメス,象徴,秘教,辞典,占星術,ヘブライ,生命の樹,セフィロト",
                "marketingUrl": "https://snarfnet.github.io/ArcanaCodex/",
                "whatsNew": "初回リリース"
            }
        }
    }
    r = requests.patch(f"{BASE}/appStoreVersionLocalizations/{loc_id}", headers=HEADERS(), json=data)
    print(f"Update ja version: {r.status_code}")

def set_price(app_id):
    # 300 yen = Tier 1 (about $0.99) but let's check
    # Actually 300 yen maps to price point priceTier 2 or we use manual pricing
    data = {
        "data": {
            "type": "appPriceSchedules",
            "relationships": {
                "app": {"data": {"type": "apps", "id": app_id}},
                "manualPrices": {
                    "data": [{"type": "appPrices", "id": "${price1}"}]
                },
                "baseTerritory": {
                    "data": {"type": "territories", "id": "JPN"}
                }
            }
        },
        "included": [
            {
                "type": "appPrices",
                "id": "${price1}",
                "relationships": {
                    "appPricePoint": {
                        "data": {"type": "appPricePoints", "id": find_price_point(app_id, 300)}
                    }
                }
            }
        ]
    }
    r = requests.post(f"{BASE}/appPriceSchedules", headers=HEADERS(), json=data)
    print(f"Set price: {r.status_code}")
    if r.status_code != 201:
        print(r.text[:500])

def find_price_point(app_id, yen):
    r = requests.get(
        f"{BASE}/apps/{app_id}/appPricePoints?filter[territory]=JPN&limit=200",
        headers=HEADERS()
    )
    if r.status_code == 200:
        for pp in r.json()["data"]:
            amt = pp["attributes"].get("customerPrice")
            if amt and float(amt) == float(yen):
                print(f"Found price point: {pp['id']} = {amt} JPY")
                return pp["id"]
    print(f"Price point for {yen} JPY not found")
    return None

if __name__ == "__main__":
    print("=== Arcana Codex ASC Setup ===")
    app_id = create_app()
    if app_id:
        setup_metadata(app_id)
        setup_version(app_id)
        set_price(app_id)
        print(f"\nDone! App ID: {app_id}")
