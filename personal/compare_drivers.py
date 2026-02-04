import fastf1
from fastf1 import plotting
import matplotlib.pyplot as plt

print("Starting driver comparison script...")

# Enable cache
fastf1.Cache.enable_cache('cache')
print("Cache enabled")

# Plot settings
plotting.setup_mpl()

# Load a session
year = 2023
grand_prix = 'Monza'
session_type = 'Q'  # FP1, FP2, FP3, Q, R
session = fastf1.get_session(year, grand_prix, session_type)
print(f"Loading {year} {grand_prix} {session_type} session...")
session.load()
print("Session loaded!")

# Pick two drivers (use 3-letter codes)
drivers = ['VER', 'HAM']

laps_data = {}
for driver in drivers:
    fastest_lap = session.laps.pick_driver(driver).pick_fastest()
    laps_data[driver] = fastest_lap.get_telemetry()
    print(f"Loaded fastest lap for {driver}, {len(laps_data[driver])} points")

# Plot both drivers' speed on the same graph
plt.figure(figsize=(10,5))
for driver, tel in laps_data.items():
    plt.plot(tel['Distance'], tel['Speed'], label=f'{driver} Speed')

plt.xlabel('Distance (m)')
plt.ylabel('Speed (km/h)')
plt.title(f'Fastest Lap Comparison – {grand_prix} {session_type} {year}')
plt.legend()
plt.grid(True)

# Save the plot
plt.savefig("fastest_laps_comparison.png")
print("Plot saved as fastest_laps_comparison.png")