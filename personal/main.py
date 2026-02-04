import fastf1
import pandas as pd
import numpy as np 
import logging

logging.basicConfig(level = logging.INFO)

fastf1.Cache.enable_cache("data/raw")

## FastF1 SMOKE TEST ##
# session = fastf1.get_session(2023, 1, 'R')
# session.load()

# print(session.event)
# print(session.results[['Abbreviation', 'Position']].head())

# load one race
SEASON = 2023
ROUND = 1 # Bahrain
SESSION_TYPE = 'R'

logging.info(f"Loading {SEASON} Round {ROUND}")

session = fastf1.get_session(SEASON, ROUND, SESSION_TYPE)
session.load()

# inspect lap data
laps = session.laps
print(laps.columns)

# clean lap times
laps_clean = laps[
                (laps['IsAccurate']) &
                (laps['LapTime'].notna())
                 ][[
                     'Driver',
                     'LapTime',
                     'LapNumber',
                     'TrackStatus',
                   ]].copy()

# convert to seconds
laps_clean['LapTimeSeconds'] = (
    laps_clean['LapTime']
    .dt.total_seconds()
)

# remove safety car laps (initial pass)
laps_clean = laps_clean[laps_clean['TrackStatus'] != 4]
print(laps_clean.groupby('Driver')['LapTimeSeconds'].count().head())

# compute lap-time consistency (per driver, per race)
lap_consistency = (
    laps_clean
    .groupby('Driver')
    .agg(
        lap_time_std=('LapTimeSeconds', 'std'),
        lap_count=('LapTimeSeconds', 'count')
        )
    .reset_index()
)

print(lap_consistency.sort_values('lap_time_std').head())

# merge with race results
results = session.results[['Abbreviation', 'Position', 'Status']].copy()

results['dnf'] = ~results['Status'].str.contains('Finished')

race_metrics = lap_consistency.merge(
    results,
    left_on='Driver',
    right_on='Abbreviation', 
    how='left'
)

print(race_metrics[['Driver', 'Position', 'lap_time_std', 'dnf']])

# save race metrics
race_metrics.to_csv(
    f"data/processed/season_{SEASON}_round_{ROUND}.csv",
    index=False
)
