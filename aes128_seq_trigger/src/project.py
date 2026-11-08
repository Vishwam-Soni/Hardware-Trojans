import pandas as pd
import matplotlib.pyplot as plt

# =====================================
# Load CSV Files
# =====================================
import os

print(os.getcwd())
print(os.listdir())

golden = pd.read_csv("/home/vishwamsoni/openlane/designs/aes128_seq_trigger/src/golden_power_trace.csv")
trojan = pd.read_csv("/home/vishwamsoni/openlane/designs/aes128_seq_trigger/src/infected_power_trace.csv")

# =====================================
# Compute Differential Signature
# =====================================

cycles = golden.iloc[:, 0]

difference = (
    trojan.iloc[:, 1] -
    golden.iloc[:, 1]
)

# =====================================
# IEEE Plot Settings
# =====================================

plt.rcParams.update({
    "font.size": 10,
    "axes.labelsize": 11,
    "xtick.labelsize": 10,
    "ytick.labelsize": 10
})

fig, ax = plt.subplots(figsize=(7, 4))

bars = ax.bar(
    cycles,
    difference
)

# =====================================
# Labels
# =====================================

ax.set_xlabel("Clock Cycle")
ax.set_ylabel("Toggle Count Difference")

# =====================================
# Grid
# =====================================

ax.grid(
    axis='y',
    linestyle='--',
    linewidth=0.5,
    alpha=0.5
)

ax.set_axisbelow(True)

# Remove extra borders
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)

# =====================================
# Annotate Non-Zero Differences
# =====================================

for cycle, diff in zip(cycles, difference):
    if diff != 0:
        ax.text(
            cycle,
            diff + 0.2,
            str(diff),
            ha="center",
            fontsize=9
        )

# =====================================
# Dynamic Y Limit
# =====================================

ax.set_ylim(
    min(0, difference.min()) - 1,
    difference.max() + 2
)

plt.tight_layout()

# =====================================
# Save Figure
# =====================================

plt.savefig(
    "differential_activity_signature.png",
    dpi=600,
    bbox_inches="tight"
)

plt.savefig(
    "differential_activity_signature.pdf",
    bbox_inches="tight"
)

plt.show()