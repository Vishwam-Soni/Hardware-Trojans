import csv

def run_dpa(golden_csv, infected_csv):
    print("--- Differential Power Analysis Initiated ---")
    golden_data = []
    infected_data = []

    # Read Golden Baseline
    with open(golden_csv, 'r') as f:
        reader = csv.reader(f)
        next(reader) # skip header
        for row in reader:
            golden_data.append(int(row[1]))

    # Read Infected Trace
    with open(infected_csv, 'r') as f:
        reader = csv.reader(f)
        next(reader) # skip header
        for row in reader:
            infected_data.append(int(row[1]))

    # Execute Subtraction
    found_anomaly = False
    for i in range(min(len(golden_data), len(infected_data))):
        diff = infected_data[i] - golden_data[i]
        if diff != 0:
            print(f"[!] ANOMALY DETECTED at Clock Cycle {i}: Difference of {diff} physical toggles.")
            found_anomaly = True

    if not found_anomaly:
        print("[+] No anomalies detected. Traces are mathematically identical.")
    else:
        print("--- DPA Complete: Hardware Trojan Isolated ---")

# Run the analyzer on your two exact files
run_dpa("golden_power_trace.csv", "infected_power_trace.csv")