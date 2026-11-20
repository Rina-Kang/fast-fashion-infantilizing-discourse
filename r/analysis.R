# =====================================================
# Fast-fashion social-media comment analysis
# Charts: (1) spectrum-pole keywords, (2) platform keywords,
#         (3) negative-word density
# =====================================================

library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(RColorBrewer)

setwd("~/Desktop/tech-intern-project")

tokens <- read_csv("data/tokens.csv", show_col_types = FALSE)
dict <- read_csv("r/zh_en_dict.csv", show_col_types = FALSE)

# 翻译函数：中文词 -> "中文 英文"；翻译表没有的词 -> 标 [未翻译] 提示
translate <- function(zh_vec) {
  m <- dict$en
  names(m) <- dict$zh
  out <- character(length(zh_vec))
  for (i in seq_along(zh_vec)) {
    z <- zh_vec[i]
    if (z %in% names(m)) {
      out[i] <- paste0(z, " ", m[[z]])
    } else {
      out[i] <- paste0(z, " [NOT TRANSLATED]")
    }
  }
  out
}

pole_labels <- c("幼化" = "Infantilized", "交叉" = "Hybrid", "性感" = "Sexualized")

# ---------- Fig 1: spectrum-pole keyword frequency (Top 6) ----------
pole_words <- tokens %>%
  filter(!is.na(spectrum_pole), spectrum_pole != "") %>%
  separate_rows(tokens, sep = " ") %>%
  filter(tokens != "", !str_detect(tokens, "^[0-9]+$")) %>%
  count(spectrum_pole, tokens, name = "freq") %>%
  group_by(spectrum_pole) %>%
  slice_max(freq, n = 6) %>%
  ungroup() %>%
  mutate(tokens = translate(tokens)) %>%
  mutate(tokens = forcats::fct_reorder(tokens, freq, .desc = FALSE))

pole_words$spectrum_en <- factor(pole_labels[pole_words$spectrum_pole],
                                 levels = c("Infantilized", "Hybrid", "Sexualized"))

p1 <- ggplot(pole_words, aes(x = tokens, y = freq, fill = spectrum_en)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~spectrum_en, scales = "free_y", ncol = 1) +
  coord_flip() +
  labs(title = "Top Keywords by Spectrum Pole",
       subtitle = "Targeted-track comments (n = 1,209; sexualized n = 98, interpret with caution)",
       x = NULL, y = "Frequency") +
  theme_minimal(base_size = 12) +
  theme(strip.text = element_text(size = 12, face = "bold"))

ggsave("figures/fig1_spectrum_keywords.png", p1, width = 8, height = 9, dpi = 150)

# ---------- Fig 2: platform keyword frequency (Top 10) ----------
plat_words <- tokens %>%
  separate_rows(tokens, sep = " ") %>%
  filter(tokens != "", !str_detect(tokens, "^[0-9]+$")) %>%
  count(platform, tokens, name = "freq") %>%
  group_by(platform) %>%
  slice_max(freq, n = 10) %>%
  ungroup() %>%
  mutate(tokens = translate(tokens)) %>%
  mutate(tokens = forcats::fct_reorder(tokens, freq, .desc = FALSE))

plat_words$platform_en <- ifelse(plat_words$platform == "小红书", "Xiaohongshu (XHS)", "Douyin")

p2 <- ggplot(plat_words, aes(x = tokens, y = freq, fill = platform_en)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~platform_en, scales = "free_y", ncol = 1) +
  coord_flip() +
  labs(title = "Top Keywords by Platform",
       subtitle = "All comments (n = 6,571)",
       x = NULL, y = "Frequency") +
  theme_minimal(base_size = 12) +
  theme(strip.text = element_text(size = 12, face = "bold"))

ggsave("figures/fig2_platform_keywords.png", p2, width = 8, height = 8, dpi = 150)

# ---------- Fig 3: negative-word density by spectrum pole ----------
neg_words <- c("显胖", "好丑", "失望", "避雷", "廉价", "焦虑")
neg_map <- c("显胖" = "looks fat", "好丑" = "ugly", "失望" = "disappointed",
             "避雷" = "avoid", "廉价" = "cheap-looking", "焦虑" = "anxiety")

neg_density <- tokens %>%
  filter(!is.na(spectrum_pole), spectrum_pole != "") %>%
  separate_rows(tokens, sep = " ") %>%
  filter(tokens %in% neg_words) %>%
  count(spectrum_pole, tokens, name = "freq") %>%
  mutate(tokens_en = paste0(tokens, " ", neg_map[tokens]))

neg_density$spectrum_en <- factor(pole_labels[neg_density$spectrum_pole],
                                  levels = c("Infantilized", "Hybrid", "Sexualized"))

p3 <- ggplot(neg_density, aes(x = spectrum_en, y = freq, fill = tokens_en)) +
  geom_col(position = "dodge", width = 0.7) +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "Negative-Emotion Keyword Count by Spectrum Pole",
       subtitle = "Signals of discomfort / criticism (looks-fat, ugly, avoid, cheap, anxiety)",
       x = NULL, y = "Frequency", fill = "Keyword") +
  theme_minimal(base_size = 12)

ggsave("figures/fig3_negative_density.png", p3, width = 9, height = 5, dpi = 150)

cat("\n===== ANALYSIS COMPLETE =====\n")
cat("Fig1: figures/fig1_spectrum_keywords.png\n")
cat("Fig2: figures/fig2_platform_keywords.png\n")
cat("Fig3: figures/fig3_negative_density.png\n")

# 检查是否有词没翻译（打印出来让你确认）
all_shown <- unique(c(
  str_extract(pole_words$tokens, "^[^ ]+"),
  str_extract(plat_words$tokens, "^[^ ]+")
))
untranslated <- all_shown[!all_shown %in% dict$zh]
if (length(untranslated) > 0) {
  cat("\n⚠️ 以下词未翻译，请补充 zh_en_dict.csv：\n")
  print(untranslated)
} else {
  cat("\n✅ 所有显示词均已翻译\n")
}
