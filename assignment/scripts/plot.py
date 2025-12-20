import matplotlib.pyplot as plt

# Data from the table
cycle_period = [5, 4, 3, 2, 1.5, 1.25, 1]
total_area = [662.04, 662.04, 661.68, 663.48, 667.44, 722.88, 810.36]

# Create the plot
plt.figure(figsize=(8,5))
plt.plot(cycle_period, total_area, marker='o', linestyle='-', linewidth=2)
plt.xlabel("Cycle Period (ns)", fontsize=12)
plt.ylabel("Total Area ($\mu m^2$)", fontsize=12)
plt.title("Total Area vs. Cycle Period", fontsize=14)
plt.gca().invert_xaxis()  # invert x-axis so smaller cycle period is to the right
plt.grid(True, linestyle='--', alpha=0.6)
plt.savefig("area_cycle_Plot.png")

# Data from the new table
total_power = [9.5844e-02, 0.1191, 0.1578, 0.2356, 0.3133, 0.4062, 0.5063]

# Create the plot
plt.figure(figsize=(8,5))
plt.plot(cycle_period, total_power, marker='s', color='red', linestyle='-', linewidth=2)
plt.xlabel("Cycle Period (ns)", fontsize=12)
plt.ylabel("Total Power (mW)", fontsize=12)
plt.title("Total Power vs. Cycle Period", fontsize=14)
plt.gca().invert_xaxis()  # invert x-axis so smaller cycle period is to the right
plt.grid(True, linestyle='--', alpha=0.6)
plt.savefig("power_cycle_Plot.png")
