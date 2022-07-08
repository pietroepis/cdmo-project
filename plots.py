import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd

df_input_order = pd.read_csv("rotation_input_order.csv", sep=";")
df_first_fail = pd.read_csv("rotation_first_fail.csv", sep=";")

df_agg = df_input_order.append(df_first_fail, ignore_index = True)
df_agg = df_agg.sort_values("INSTANCE")

g = sns.barplot(
    x = "INSTANCE",
    y = "TIME",
    hue = "STRATEGY",
    data = df_agg
)
g.set_yscale("log")
plt.ylim(0, 300)
plt.show()