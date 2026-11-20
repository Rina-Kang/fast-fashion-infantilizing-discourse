# -*- coding: utf-8 -*-
"""数据清洗脚本：原始社媒 CSV -> 干净英文列名 + 店铺化名"""
import csv
import os

RAW = "/Users/kangyuchen/WorkBuddy/2026-08-02-18-38-35/data/social_comments_pool_anon.csv"
OUT_DIR = os.path.join(os.path.dirname(__file__), "data")
os.makedirs(OUT_DIR, exist_ok=True)
OUT = os.path.join(OUT_DIR, "social_comments_clean.csv")

COL_MAP = {
    "comment_id": "comment_id",
    "note_id": "note_id",
    "平台": "platform",
    "作者(匿名化)": "author_anon",
    "点赞": "like_count",
    "评论时间": "comment_time",
    "文案(全文)": "content",
    "来源文件": "source_file",
    "采集轨道": "track",
    "店铺": "store",
    "光谱极": "spectrum_pole",
}

STORE_MAP = {
    "织物猪": "Store-A",
    "桔梗 house": "Store-B",
    "白水女": "Store-C",
    "你的懒懒Iian": "Store-D",
    "Chill 巧儿": "Store-E",
    "bOutique de viOla": "Store-F",
}

def clean():
    with open(RAW, encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        rows = []
        for r in reader:
            new = {}
            for cn, en in COL_MAP.items():
                val = r.get(cn, "").strip()
                if en == "like_count":
                    try:
                        val = int(float(val))
                    except (ValueError, TypeError):
                        val = 0
                new[en] = val
            if new["store"] in STORE_MAP:
                new["store"] = STORE_MAP[new["store"]]
            if new["content"]:
                rows.append(new)

    seen = set()
    unique = []
    for r in rows:
        if r["comment_id"] not in seen:
            seen.add(r["comment_id"])
            unique.append(r)

    fields = list(COL_MAP.values())
    with open(OUT, "w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(unique)

    print("清洗完成！")
    print("  原始行数:", len(rows))
    print("  去重后行数:", len(unique))
    print("  输出文件:", OUT)

if __name__ == "__main__":
    clean()
