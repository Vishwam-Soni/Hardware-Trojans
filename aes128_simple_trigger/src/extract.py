import csv

def extract_toggles(vcd_path, output_csv):
    cycle_toggles = []
    current_toggles = 0

    with open(vcd_path, 'r') as file:
        for line in file:
            line = line.strip()

            # Record strictly on 10ns intervals to match your clock period
            if line.startswith('#'):
                time_val = int(line[1:])
                if time_val > 0 and time_val % 10 == 0:
                    cycle_toggles.append(current_toggles)
                    current_toggles = 0

            # Tally every physical wire state change
            elif line.startswith(('b', '0', '1')):
                current_toggles += 1

    with open(output_csv, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(["Clock_Cycle", "Toggle_Count_Infected"])
        
        for cycle, count in enumerate(cycle_toggles):
            # Writes every row, even zeros, to maintain perfect DPA alignment
            writer.writerow([cycle, count])

    print(f"Extraction complete! Saved to {output_csv}")

extract_toggles("infected_sca_trace.vcd", "infected_power_trace.csv")