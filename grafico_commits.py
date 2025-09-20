import pandas as pd
import matplotlib.pyplot as plt

# Leer el CSV generado
df = pd.read_csv("resumen_commits.txt", names=["Autor", "Commits"], encoding="latin1")


# Gráfico de barras
df.plot(kind="bar", x="Autor", y="Commits", legend=False)
plt.title("Número de commits por autor")
plt.ylabel("Commits")
plt.xticks(rotation=45, ha="right")
plt.tight_layout()
plt.show()
