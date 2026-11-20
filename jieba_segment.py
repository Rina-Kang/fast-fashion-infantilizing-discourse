# -*- coding: utf-8 -*-
"""用 jieba 对评论做中文分词，输出 平台+光谱极+轨道 + 分词结果"""
import csv
import os
import jieba

BASE = os.path.dirname(os.path.abspath(__file__))
IN = os.path.join(BASE, "data", "social_comments_clean.csv")
OUT = os.path.join(BASE, "data", "tokens.csv")
STOP_FILE = os.path.join(BASE, "data", "stopwords.txt")

STOPWORDS = set("""
的 了 是 我 你 他 她 它 们 这 那 就 也 都 很 还 有 在 不 和 与 或 吗 呢 吧 啊
呀 哦 哈 一个 这个 那个 自己 就是 真的 感觉 觉得 因为 所以 但是 如果 什么 怎么
衣服 可以 这么 没有 时候 不是 链接 平台 新客 测评 博主 宝宝 姐妹 捂脸 流泪 泪奔 飞吻
喜欢 价格 适合 东西 大家 这家 店铺 他家 看看 怎么样 有没有 一点 还是 已经 现在 今天 昨天 知道
买 穿 裙子 一件 这样 那种 一直 好 这种 一下 其实 有点 一样 不会 不能 特别 这套 第一件 她家 最后
皱眉 微笑 憨笑 偷笑 石化 泣不成声 黑脸 抱抱 比心 撒花 玫瑰 害羞 躺平 可爱 好看吗 为什么 评论
萌萌 老婆 姐姐 看到 想要 黄脸 送心 你们 那么 回归 抖音 交叉 幼化 性感 第一套 一套 预售 质量
猪头 祈祷 送心 哈哈哈 啊啊啊 好像 而且 我们 然后 这些 很多 不行 不要 去年 发货 文案 老客 推荐
流汗 看着 起来 好多 日常 每一件 你家 左边 直接 角度 运费 超级 可能 正常 可是 手手 减肥 健康
美女 女生 老婆 姐姐 萌萌 色色 土纯 直播 平安 哪里 问问 这是 里面 身高体重 黄金 分享 鼓掌
""".split())

# 把停用词按类别导出，供 Quarto 反思 + GitHub 展示
CATEGORIES = [
    ("虚词/语法词", ["的","了","是","我","你","他","她","它","们","这","那","就","也","都","很","还","有","在","不","和","与","或","吗","呢","吧","啊","呀","哦","哈","一个","这个","那个","自己","就是","真的","感觉","觉得","因为","所以","但是","如果","什么","怎么"]),
    ("口水词/口语填充", ["衣服","可以","这么","没有","时候","不是","喜欢","价格","适合","东西","大家","看看","怎么样","有没有","一点","还是","已经","现在","今天","昨天","知道","买","穿","裙子","一件","这样","那种","一直","好","这种","一下","其实","有点","一样","不会","不能","特别","这套","第一件","她家","最后","看到","想要","你们","那么","第一套","一套"]),
    ("运营/带货话术", ["链接","平台","新客","测评","博主","宝宝","姐妹","这家","店铺","他家","推荐","预售","质量","抖音"]),
    ("表情包文字化", ["捂脸","流泪","泪奔","飞吻","皱眉","微笑","憨笑","偷笑","石化","泣不成声","黑脸","抱抱","比心","撒花","玫瑰","害羞","躺平","萌萌","黄脸","送心","可爱","老婆","姐姐","回归"]),
    ("光谱极/轨道自指词", ["交叉","幼化","性感"]),
]

with open(STOP_FILE, "w", encoding="utf-8") as f:
    f.write("# 停用词表（stopwords）—— 分词时删除的词及分类\n")
    f.write("# 用途：Quarto 反思部分 + GitHub 方法论透明展示\n\n")
    for cat, words in CATEGORIES:
        f.write(f"## {cat}\n")
        f.write(" ".join(words) + "\n\n")

for w in ["纯欲", "辣妹", "幼态", "白月光", "好嫁风", "显幼", "显胖", "显瘦",
          "勒肉", "勒", "紧身", "短裙", "吊带", "oversize", "小个子", "大骨架"]:
    jieba.add_word(w)

def main():
    rows = []
    with open(IN, encoding="utf-8") as f:
        for r in csv.DictReader(f):
            platform = r["platform"]
            spectrum = r.get("spectrum_pole", "").strip()
            track = r.get("track", "").strip()
            text = r["content"]
            words = [w.strip() for w in jieba.cut(text)]
            words = [w for w in words
                     if len(w) >= 2 and w not in STOPWORDS and any('\u4e00' <= c <= '\u9fff' for c in w)]
            if words:
                rows.append((platform, spectrum, track, " ".join(words)))

    with open(OUT, "w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["platform", "spectrum_pole", "track", "tokens"])
        writer.writerows(rows)

    print("分词完成！共", len(rows), "条")
    print("停用词表已导出:", STOP_FILE)
    print("输出:", OUT)

if __name__ == "__main__":
    main()
