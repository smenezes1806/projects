# basic set up
import fastf1
from fastf1 import plotting
import matplotlib.pyplot as plt

print("Starting FastF1 script...")

# Enable cache
fastf1.Cache.enable_cache('cache')
print("Cache enabled")

# Setup plotting
plotting.setup_mpl()

# Load session: Year, Track, Session
session = fastf1.get_session(2023, 'Monza', 'Q')
print("Loading session...")
session.load()
print("Session loaded!")

# Pick fastest lap
fastest_lap = session.laps.pick_fastest()
print(f"Fastest lap by {fastest_lap['Driver']}")

# Get telemetry
tel = fastest_lap.get_telemetry()
print(f"Telemetry length: {len(tel)} points")

# Plot speed vs distance and save
plt.figure(figsize=(10,5))
plt.plot(tel['Distance'], tel['Speed'], label='Fastest Lap Speed')
plt.xlabel('Distance (m)')
plt.ylabel('Speed (km/h)')
plt.title('Fastest Lap – Monza Qualifying 2023')
plt.legend()
plt.grid(True)
plt.savefig("fastest_lap.png")
print("Plot saved as fastest_lap.png")

# start session and load data
session = fastf1.get_session(2021, 7, 'Q')
session.load()

# print session info 
print("Session name: ", session.name)
print("Session date: ", session.date)
print("Session Event: ", session.event['EventName'])