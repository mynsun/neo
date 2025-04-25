import json
from pymongo import MongoClient
import os

client = MongoClient("mongodb://localhost:27017/")
db = client["ev_data"]
collection = db["ev_charging"]

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
json_path = os.path.join(BASE_DIR, "data.json")

with open(json_path, "r", encoding="utf-8") as f:
    data = json.load(f)

collection.delete_many({})
collection.insert_many(data)

print("데이터가 MongoDB에 성공적으로 저장되었습니다.")