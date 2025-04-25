import pandas as pd

df = pd.read_csv("data.csv", encoding='cp949')

df.to_json("data.json", orient='records', force_ascii=False)

print("변환 완료!")