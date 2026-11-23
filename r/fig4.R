# =====================================================
# fig4: five-dimension complaint comparison
# "youthful, body-revealing" vs. control (athleisure/office)
# Matched on NEUTRAL search terms. Hits per 1,000 comments.
# =====================================================

library(ggplot2)
library(dplyr)
library(tidyr)

d <- data.frame(
  dimension = c("Fit / Cut", "Fabric Quality", "Exposure / Wardrobe",
                "Wearability / Occasion", "Physical Comfort"),
  youthful = c(116.3, 34.4, 12.1, 17.2, 2.0),
  control  = c(134.0, 6.9, 6.9, 6.9, 1.7)
)

d2 <- d %>%
  pivot_longer(cols = c(youthful, control), names_to = "group", values_to = "rate") %>%
  mutate(
    group = factor(group, levels = c("youthful", "control"),
                   labels = c("Youthful, body-revealing (n=989)",
                              "Control: athleisure/office (n=582)")),
    dimension = factor(dimension, levels = d$dimension)
  )

p <- ggplot(d2, aes(x = dimension, y = rate, fill = group)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  geom_text(aes(label = sprintf("%.1f", rate)),
            position = position_dodge(width = 0.8), vjust = -0.3, size = 3.2) +
  scale_fill_manual(values = c("Youthful, body-revealing (n=989)" = "#C0392B",
                               "Control: athleisure/office (n=582)" = "#7F8C8D")) +
  labs(
    title = "Which complaints are UNIQUE to 'youthful, body-revealing' clothing?",
    subtitle = "Complaint-word hits per 1,000 comments, matched on NEUTRAL search terms\n(Sample sizes differ, so rates are standardised)",
    x = NULL, y = "Hits per 1,000 comments",
    fill = NULL,
    caption = "Only Fabric / Exposure / Wearability show a gap. Fit & Comfort are common to ALL women's wear."
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom",
        plot.title = element_text(face = "bold", size = 14),
        axis.text.x = element_text(angle = 15, hjust = 1))

ggsave("figures/fig4_unique_complaints.png", p,
       width = 9.5, height = 5.8, dpi = 150)

cat("✅ fig4 written: figures/fig4_unique_complaints.png\n")
