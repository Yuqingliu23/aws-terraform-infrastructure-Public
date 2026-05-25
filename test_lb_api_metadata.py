import requests
from requests.exceptions import Timeout
import sys
import getopt
from collections import Counter
import json
import time

def format_counter_table(counter, title, total):
    """Helper function to print counter results in table format with percentages"""
    print(f"\n{title}:")
    if not counter:
        print("  No entries found")
        return
    for value, count in counter.most_common():
        percent = (count / total) * 100 if total > 0 else 0.0
        print(f"  {value:<20} | {count:>5} ({percent:.1f}%)")

def main():
    # Default values
    n = 10
    domain = "api.sushisoft.me"
    print_interval = 100
    invalid_counter = 0
    az_counter = Counter()
    instance_counter = Counter()
    debug_mode = False
    start_time = time.time()

    # Parse command line arguments
    try:
        opts, args = getopt.getopt(sys.argv[1:], "n:d:p:D", ["help", "debug"])
    except getopt.GetoptError:
        print("Usage: program.py [-n <loops>] [-d <domain>] [-p <interval>] [-D]")
        sys.exit(2)

    for opt, arg in opts:
        if opt == '-n':
            n = int(arg)
        elif opt == '-d':
            domain = arg
        elif opt == '-p':
            print_interval = int(arg)
        elif opt in ('-D', '--debug'):
            debug_mode = True

    url = f"http://{domain}/v2/metadata"

    for i in range(1, n+1):
        iteration_start = time.time()
        try:
            if debug_mode:
                print(f"\n[DEBUG] Request #{i}: GET {url}")
            
            response = requests.get(url, timeout=4)
            
            if debug_mode:
                print(f"[DEBUG] Response #{i}: Status {response.status_code}")
                if response.status_code == 200:
                    print(f"[DEBUG] Response data: {response.text}")

            if response.status_code != 200:
                invalid_counter += 1
                if debug_mode:
                    print(f"[DEBUG] Invalid status code: {response.status_code}")
            else:
                try:
                    data = response.json()
                    if 'aws_availability_zone_id' in data and 'aws_instance_id' in data:
                        az_counter.update([data['aws_availability_zone_id']])
                        instance_counter.update([data['aws_instance_id']])
                    else:
                        invalid_counter += 1
                        if debug_mode:
                            print("[DEBUG] Missing required fields in JSON response")
                except json.JSONDecodeError:
                    invalid_counter += 1
                    if debug_mode:
                        print("[DEBUG] Failed to parse JSON response")

        except requests.Timeout as e:
            invalid_counter += 1
            if debug_mode: 
                print(f"[DEBUG] Request timeout: {str(e)}")
            else:
                print(f"Request timeout: {str(e)}")

        except requests.exceptions.RequestException as e:
            invalid_counter += 1
            if debug_mode:
                print(f"[DEBUG] Request failed: {str(e)}")

        # Print progress at intervals
        if i % print_interval == 0:
            elapsed = time.time() - start_time
            req_rate = (i / elapsed) * 60 if elapsed > 0 else 0
            total_valid = sum(az_counter.values())  # Calculate valid responses
            
            print(f"\n{'='*40}")
            print(f"Progress after {i} requests:")
            print(f"{'Request rate:':<20} | {req_rate:.2f} queries/min")
            format_counter_table(az_counter, "Availability Zones ID", total_valid)
            format_counter_table(instance_counter, "Instance IDs", total_valid)
            print(f"\n{'Total invalid responses:':<20} | {invalid_counter:>5}")
            print(f"{'Current success rate:':<20} | {(1 - (invalid_counter/i)):.1%}")

        if invalid_counter > 5:
            print("Too many invalid responses (over 5). Exiting...")
            break

    # Final output
    total_time = time.time() - start_time
    final_rate = (n / total_time) * 60 if total_time > 0 else 0
    total_valid = sum(az_counter.values())
    
    print(f"\n{'='*40}")
    print("Final results:")
    print(f"{'Total duration:':<20} | {total_time:.2f} seconds")
    print(f"{'Average request rate:':<20} | {final_rate:.2f} queries/min")
    format_counter_table(az_counter, "Availability Zones", total_valid)
    format_counter_table(instance_counter, "Instance IDs", total_valid)
    print(f"\n{'Total requests:':<20} | {n:>5}")
    print(f"{'Invalid responses:':<20} | {invalid_counter:>5}")
    print(f"{'Response rate:':<20} | {(1 - (invalid_counter/n)):.1%}")

if __name__ == "__main__":
    main()
