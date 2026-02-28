import json
import subprocess
import time
import sys

def verify():
    cmd = [r"C:\Users\Jesus\.local\bin\uv.exe", "tool", "run", "notebooklm-mcp-server", "notebooklm-mcp"]
    
    # Run the process
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    
    # Initialize
    init = {"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "test", "version": "1"}}}
    proc.stdin.write(json.dumps(init) + "\n")
    proc.stdin.flush()
    
    # Wait and read
    time.sleep(2)
    
    # List tools
    list_tools = {"jsonrpc": "2.0", "id": 2, "method": "tools/list", "params": {}}
    proc.stdin.write(json.dumps(list_tools) + "\n")
    proc.stdin.flush()
    
    time.sleep(2)
    
    # Read all available output
    proc.stdin.close()
    output = proc.stdout.read()
    errors = proc.stderr.read()
    
    print("OUTPUT START")
    print(output)
    print("OUTPUT END")
    print("ERRORS START")
    print(errors)
    print("ERRORS END")

if __name__ == "__main__":
    verify()
