import pandas as pd
import numpy as np

df = pd.read_csv("data.csv", encoding='cp949')

df = df[['시도', '군구', '설치년도']].dropna()
df = df[df['설치년도'].astype(str).str.isnumeric()]
df['설치년도'] = df['설치년도'].astype(int)

target_provinces = ['충청북도', '경기도', '경상남도', '인천광역시', '전라남도', '서울특별시']
df = df[df['시도'].isin(target_provinces)]

grouped = df.groupby(['시도', '군구', '설치년도']).size().reset_index(name='count')

forecast_results = {}
years_to_predict = list(range(2022, 2041))

for (sido, gungu), group in grouped.groupby(['시도', '군구']):
    yearly_counts = group.set_index('설치년도')['count']
    all_years = range(min(yearly_counts.index), 2022)
    counts = [yearly_counts.get(y, 0) for y in all_years]

    if len(counts) < 2:
        continue

    cumulative = np.cumsum(counts)
    yearly_growth = np.diff(cumulative).mean()
    last_known = cumulative[-1] if len(cumulative) > 0 else 0
    forecast = {year: int(last_known + yearly_growth * (i + 1)) for i, year in enumerate(years_to_predict)}

    forecast_results[f"{sido} {gungu}"] = forecast

for region, predictions in forecast_results.items():
    print(f"\n {region}")
    for year, value in predictions.items():
        print(f"  {year}: {value}개")