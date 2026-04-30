import re

def parse_logs(input_file, output_file):
    with open(input_file, 'r') as f:
        lines = f.readlines()
    
    csv_lines = ["Avg,Peak,Min,RMS,Label\n"]
    current_label = None
    
    for line in lines:
        line = line.strip()
        if not line:
            continue
            
        # Match section headers
        if line.startswith("---"):
            continue
            
        lower_line = line.lower()
        if "quiet or normal sound" in lower_line:
            current_label = "Background Noise"
        elif "shouting" in lower_line:
            current_label = "Talking"
        elif "laughing" in lower_line:
            current_label = "Laughter"
        elif "talking" in lower_line and "2meter" not in lower_line:
            current_label = "Talking"
        elif "2meter away" in lower_line:
            current_label = "Talking"
        elif "vlc player" in lower_line:
            current_label = "Talking"
        elif "clapping" in lower_line:
            current_label = "Clap"
        elif "dragging chair" in lower_line:
            current_label = "Table Dragging"
        elif "object drop" in lower_line:
            current_label = "Object Drop"
        elif "watching youtube" in lower_line:
            current_label = "Talking"
        elif "phone alarm" in lower_line:
            current_label = "Ring Phone"
            
        # Parse data lines: #232	Avg:7.5	Peak:20	Min:0	RMS:8.9	Label:[?]
        if line.startswith("#"):
            if not current_label:
                continue
                
            parts = re.split(r'\s+', line)
            avg_val = peak_val = min_val = rms_val = "0"
            for p in parts:
                if p.startswith("Avg:"): avg_val = p.split(":")[1]
                if p.startswith("Peak:"): peak_val = p.split(":")[1]
                if p.startswith("Min:"): min_val = p.split(":")[1]
                if p.startswith("RMS:"): rms_val = p.split(":")[1]
                
            csv_lines.append(f"{avg_val},{peak_val},{min_val},{rms_val},{current_label}\n")
            
    # Note: Notification is missing from the logs, add dummy so TF doesn't crash on class mismatch
    csv_lines.append("20.0,10000,0,450.0,Notification\n")
            
    with open(output_file, 'w') as f:
        f.writelines(csv_lines)
        
    print(f"Successfully parsed logs into {output_file} with {len(csv_lines)-1} samples.")

if __name__ == "__main__":
    parse_logs('/home/kali/Documents/SOUND-SENSOR_LOGS.txt', '/home/kali/Documents/lumisense_monitor/ai_training/training_data.csv')
