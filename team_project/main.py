from fastapi import FastAPI, HTTPException, Query
from fastapi.responses import FileResponse
from pymongo import MongoClient
import requests
import json
import os
import math
import pymysql
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

app = FastAPI()

app.mount("/images", StaticFiles(directory="images"), name="images")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
secret_file = os.path.join(BASE_DIR, 'secret.json')
with open(secret_file) as f:
    secrets = json.load(f)

MYSQL_HOST = secrets["mysql_host"]
MYSQL_USER = secrets["mysql_user"]
MYSQL_PASSWORD = secrets["mysql_password"]
MYSQL_DB = secrets["mysql_db"]

mysql_conn = pymysql.connect(
    host=MYSQL_HOST,
    user=MYSQL_USER,
    password=MYSQL_PASSWORD,
    db=MYSQL_DB,
    charset='utf8mb4',
    cursorclass=pymysql.cursors.DictCursor
)

def get_secret(setting, secrets=secrets):
    try:
        return secrets[setting]
    except KeyError:
        return f"Set the {setting} environment variable."

mongodb_uri = get_secret("mongodb_uri")

client = MongoClient(mongodb_uri)
db = client["ev_data"]
collection = db["ev_charging"]

def haversine(lat1, lon1, lat2, lon2):
    R = 6371000
    phi1 = math.radians(float(lat1))
    phi2 = math.radians(float(lat2))
    d_phi = math.radians(float(lat2) - float(lat1))
    d_lambda = math.radians(float(lon2) - float(lon1))
    a = math.sin(d_phi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(d_lambda / 2) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c

def cache_nearby_stations(address, stations):
    with mysql_conn.cursor() as cursor:
        for station in stations:
            sql = """
            REPLACE INTO station (address, stationname, latitude, longitude, distance, chargertype, installedyear, accesslimit)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """
            cursor.execute(sql, (
                address,
                station.get("충전소명"),
                station.get("위도"),
                station.get("경도"),
                station.get("거리(m)"),
                station.get("충전기타입"),
                station.get("설치년도"),
                station.get("이용자제한")
            ))
    mysql_conn.commit()

def get_cached_stations(address):
    with mysql_conn.cursor() as cursor:
        sql = "SELECT * FROM station WHERE address=%s"
        cursor.execute(sql, (address,))
        return cursor.fetchall()

def getGeocoding(query: str):
    headers = {'Authorization': 'KakaoAK ' + get_secret("kakao_apiKey")}
    address_url = f'https://dapi.kakao.com/v2/local/search/address.json?query={query}'
    response = requests.get(address_url, headers=headers)

    if response.status_code == 200:
        documents = response.json().get("documents", [])
        if documents:
            try:
                result_address = documents[0]['address']
                return result_address['y'], result_address['x']
            except (IndexError, KeyError):
                pass

    keyword_url = f'https://dapi.kakao.com/v2/local/search/keyword.json?query={query}'
    response = requests.get(keyword_url, headers=headers)
    if response.status_code == 200:
        documents = response.json().get("documents", [])
        if documents:
            try:
                result = documents[0]
                return result['y'], result['x']
            except (IndexError, KeyError):
                return None
    return None

def find_stations_radius(latitude, longitude, radius):
    all_stations = list(collection.find({}))
    filtered_stations = []
    seen = set()

    for station in all_stations:
        name = station.get("충전소명")
        charger_type = station.get("충전기타입")
        coord = station.get("위도경도", "")

        if name and charger_type and coord and "," in coord:
            lat, lng = map(str.strip, coord.split(","))
            try:
                distance = haversine(latitude, longitude, lat, lng)
                if distance <= radius and (name, charger_type) not in seen:
                    filtered_stations.append({
                        "충전소명": name,
                        "주소": station.get("주소"),
                        "충전기타입": charger_type,
                        "위도": lat,
                        "경도": lng,
                        "거리(m)": round(distance, 2),
                        "운영기관": station.get("운영기관(대)"),
                        "시설구분": station.get("시설구분(소)"),
                        "기종": station.get("기종(대)"),
                        "이용자제한": station.get("이용자제한"),
                        "설치년도": station.get("설치년도")
                    })
                    seen.add((name, charger_type))
            except Exception as e:
                print("거리 계산 에러:", e)
                continue

    return sorted(filtered_stations, key=lambda x: x["거리(m)"])

# 주소 기반 반경 내 충전소 조회
@app.get("/r_by_address")
async def search_by_address(address: str = Query(..., description="건물명 또는 지하철역 등"), radius: float = 2000):
    coordinates = getGeocoding(address)
    if not coordinates:
        raise HTTPException(status_code=404, detail=f"'{address}'에 해당하는 위치를 찾을 수 없습니다.")
    latitude, longitude = coordinates
    stations = find_stations_radius(latitude, longitude, radius)

    if not stations:
        return {"message": f"{address} 반경 {radius}m 내의 충전소 정보가 없습니다."}

    return {
        "입력 위치": address,
        "변환된 좌표": {"위도": latitude, "경도": longitude},
        "반경(m)": radius,
        "충전소 수": len(stations),
        "charging_stations": stations
    }

# 실시간 위치 반경 내 충전소 조회
@app.get("/r_nearby")
async def search_by_location(latitude: float, longitude: float, radius: float = 2000):
    stations = find_stations_radius(latitude, longitude, radius)

    if not stations:
        return {"message": f"반경 {radius}m 내의 충전소 정보가 없습니다."}
    
    # MySQL에 없으면 MongoDB에서 검색
    stations = find_stations_radius(latitude, longitude, radius)

    return {
        "입력 위치": f"위도: {latitude}, 경도: {longitude}",
        "반경(m)": radius,
        "충전소 수": len(stations),
        "charging_stations": stations
    }

# 충전소 상세 정보 조회
@app.get("/r_detail")
async def getCharging_station_detail(
    latitude: float = Query(..., description="충전소 위도"),
    longitude: float = Query(..., description="충전소 경도")
):
    coord_str = f"{latitude},{longitude}"
    station = collection.find_one({"위도경도": coord_str})
    if not station:
        raise HTTPException(status_code=404, detail="해당 좌표에 일치하는 충전소 정보가 없습니다.")

    return {
        "충전소명": station.get("충전소명"),
        "주소": station.get("주소"),
        "충전기타입": station.get("충전기타입"),
        "위도": latitude,
        "경도": longitude,
        "운영기관": station.get("운영기관(대)"),
        "시설구분": station.get("시설구분(소)"),
        "기종": station.get("기종(대)"),
        "이용자제한": station.get("이용자제한"),
        "설치년도": station.get("설치년도")
    }

def get_route(start_coords, end_coords):
    return [start_coords, end_coords]

# 경로 내 충전소 조회
@app.get("/r_route")
async def get_charging_stations_on_route(
    start_address: str = Query(..., description="출발지 주소"),
    end_address: str = Query(..., description="도착지 주소"),
    range: float = Query(..., description="주행 가능한 거리 (단위: 미터)")
):
    start_coords = getGeocoding(start_address)
    end_coords = getGeocoding(end_address)
    
    if not start_coords:
        raise HTTPException(status_code=404, detail=f"'{start_address}'에 해당하는 출발지 위치를 찾을 수 없습니다.")
    if not end_coords:
        raise HTTPException(status_code=404, detail=f"'{end_address}'에 해당하는 도착지 위치를 찾을 수 없습니다.")

    latitude_start, longitude_start = start_coords
    latitude_end, longitude_end = end_coords

    route = get_route((latitude_start, longitude_start), (latitude_end, longitude_end))

    stations_on_route = []
    all_stations = list(collection.find({}))

    for point in route:
        lat, lon = point
        for station in all_stations:
            name = station.get("충전소명")
            coord = station.get("위도경도", "")
            if coord:
                lat_station, lon_station = map(float, coord.split(","))
                distance = haversine(lat, lon, lat_station, lon_station)
                if distance <= range:
                    stations_on_route.append({
                        "충전소명": name,
                        "주소": station.get("주소"),
                        "위도": lat_station,
                        "경도": lon_station,
                        "충전기타입": station.get("충전기타입"),
                        "거리(m)": round(distance, 2)
                    })
    
    if not stations_on_route:
        return {"message": "경로 내에 충전소가 없습니다."}

    stations_on_route_sorted = sorted(stations_on_route, key=lambda x: x["거리(m)"])

    return {
        "출발지": start_address,
        "도착지": end_address,
        "주행 가능 거리(m)": range,
        "충전소 수": len(stations_on_route_sorted),
        "charging_stations": stations_on_route_sorted
    }