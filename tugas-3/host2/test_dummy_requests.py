import urllib.request
import json
import time
import argparse
import ssl
from collections import Counter

def run_load_test(target_url, total_requests, delay):
    print("==================================================")
    print("  JARKOMLAN TUGAS 3: DUMMY LOAD TEST BENCHMARK    ")
    print("==================================================")
    print(f" Target URL     : {target_url}")
    print(f" Total Requests : {total_requests}")
    print(f" Delay antar req: {delay}s")
    print("==================================================\n")

    distribution = Counter()
    start_time = time.time()
    
    # Dukungan SSL bypass untuk tunnel HTTPS (Pinggy/Cloudflare)
    ctx = ssl._create_unverified_context()

    for i in range(1, total_requests + 1):
        req_start = time.time()
        try:
            req = urllib.request.Request(
                f"{target_url.rstrip('/')}/api",
                headers={'Accept': 'application/json', 'User-Agent': 'Jarkom-Load-Tester/1.0'}
            )
            with urllib.request.urlopen(req, timeout=5, context=ctx) as response:
                latency = (time.time() - req_start) * 1000
                data = json.loads(response.read().decode('utf-8'))
                node_name = data.get('node_name', 'Unknown Node')
                distribution[node_name] += 1
                print(f"[{i:03d}/{total_requests:03d}] OK ({latency:.1f}ms) -> Dilayani oleh: \033[96m{node_name}\033[0m")
        except Exception as e:
            print(f"[{i:03d}/{total_requests:03d}] \033[91mFAILED\033[0m: {e}")
            distribution["Failed / Error"] += 1

        if delay > 0:
            time.sleep(delay)

    total_time = time.time() - start_time
    print("\n==================================================")
    print("  HASIL DISTRIBUSI LOAD BALANCING (ROUND ROBIN)   ")
    print("==================================================")
    print(f" Waktu Eksekusi : {total_time:.2f} detik")
    print(f" Throughput     : {total_requests / total_time:.2f} req/s\n")
    print(f" {'Nama Node':<30} | {'Jumlah Request':<14} | {'Persentase'}")
    print(f" {'-'*30}-+-{'-'*14}-+------------")

    for node, count in sorted(distribution.items()):
        percentage = (count / total_requests) * 100
        print(f" {node:<30} | {count:<14} | {percentage:6.2f}%")

    print("==================================================")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Test Dummy Requests Load Balancer")
    parser.add_argument("--url", type=str, default="http://localhost/", help="Target URL Reverse Proxy")
    parser.add_argument("-n", "--requests", type=int, default=40, help="Jumlah total request")
    parser.add_argument("-d", "--delay", type=float, default=0.05, help="Delay antar request dalam detik")
    args = parser.parse_args()

    run_load_test(args.url, args.requests, args.delay)
