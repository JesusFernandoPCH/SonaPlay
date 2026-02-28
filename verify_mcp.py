import json
import sys
import subprocess
import time

def verify_tools():
    print("Starting verification...")
    # Using 'uv tool run notebooklm-mcp' to ensure it runs correctly
    cmd = [r"C:\Users\Jesus\.local\bin\uv.exe", "tool", "run", "notebooklm-mcp-server", "notebooklm-mcp"]
    
    process = subprocess.Popen(
        cmd,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        bufsize=0,
        env={"PYTHONPATH": "."}
    )

    # JSON-RPC request for initialize
    init_request = {
        "jsonrpc": "2.0",
        "id": 0,
        "method": "initialize",
        "params": {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {"name": "test-client", "version": "1.0"}
        }
    }

    # JSON-RPC request for list_tools
    list_request = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "tools/list",
        "params": {}
    }

    try:
        # Step 1: Initialize
        print("Sending initialize...")
        process.stdin.write(json.dumps(init_request) + "\n")
        process.stdin.flush()
        
        # Read init response
        while True:
            line = process.stdout.readline()
            if not line: break
            print(f"Init progress: {line[:100]}...")
            if '"id":0' in line:
                break

        # Step 2: List Tools
        print("Sending tools/list...")
        process.stdin.write(json.dumps(list_request) + "\n")
        process.stdin.flush()

        # Read response
        while True:
            line = process.stdout.readline()
            if not line: break
            if '"id":1' in line:
                response = json.loads(line)
                tools = response.get("result", {}).get("tools", [])
                print(f"RESULT:Total tools: {len(tools)}")
                for tool in tools:
                    print(f"TOOL:{tool['name']}")
                
                # Smoke Test: list_notebooks
                list_tool = next((t for t in tools if "list" in t['name'] and "notebook" in t['name']), None)
                if list_tool:
                    print(f"Smoke Test: Calling {list_tool['name']}...")
                    call_request = {
                        "jsonrpc": "2.0",
                        "id": 2,
                        "method": "tools/call",
                        "params": {
                            "name": list_tool['name'],
                            "arguments": {}
                        }
                    }
                    process.stdin.write(json.dumps(call_request) + "\n")
                    process.stdin.flush()
                    while True:
                        call_line = process.stdout.readline()
                        if not call_line: break
                        if '"id":2' in call_line:
                            print("SMOKE_TEST_RESULT:")
                            print(call_line)
                            break
                break

    except Exception as e:
        print(f"Error: {e}")
    finally:
        process.terminate()

if __name__ == "__main__":
    verify_tools()
