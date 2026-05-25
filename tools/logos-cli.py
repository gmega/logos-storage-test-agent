#!/usr/bin/env python3
# bc.py — drive basecamp's inspector (TCP 3768)
import socket, json, sys
from datetime import datetime

TCP_PORT=3768

def printerr(msg: str):
    print(msg, file=sys.stderr)

def send(payload: str, timeout=30):
    printerr(f"Connect to localhost:{TCP_PORT}")
    s = socket.create_connection(("localhost", TCP_PORT), timeout=timeout)
    s.settimeout(timeout)
    s.sendall(payload.encode())
    buf = b""
    while b"\n" not in buf:
        chunk = s.recv(1 << 20)
        if not chunk: break
        buf += chunk
    s.close()
    printerr(f"Response received.")
    return json.loads(buf.split(b"\n")[0])

def command(command: str, params: None, id: int = 1):
    return json.dumps({"command": command, "params": params or {}, "id": id}) + "\n"

def get_tree():
    return command("getTree", {"depth": 100}, 1)

def list_interactive():
    return command("listInteractive", {}, 1)

def eval(expr: str, timeout=30):
    return command("evaluate", {"expression": expr}, timeout)

def call_core_module_method(module: str, method: str, *args: list[str]):
    # 3rd arg of callCoreModuleMethod is a JSON-array *string*
    args_json = json.dumps(list(args))
    return "backend.callCoreModuleMethod(%s,%s,%s)" % (
        json.dumps(module), json.dumps(method), json.dumps(args_json))

def find_by_text(items: list, texts):
    if isinstance(texts, str):
        texts = [texts]
    for item in items['elements']:
        if item.get("text") in texts:
            return item
    return None

def install_module(path: str, timeout: int = 30):
    printerr(f"Installing module from {path}")
    printerr(send(eval(f'backend.installPluginFromPath("{path}")')))

    printerr("Looking for confirmation button...")
    now = datetime.now()
    while (datetime.now() - now).total_seconds() < timeout:
        items = send(list_interactive())
        # This is pretty raw, but getTree doesn't seem to return the
        # confirmation dialog so we have to blindly look up by text.
        # The button is "Install" for fresh installs, "Upgrade" if the module
        # was already present.
        element = find_by_text(items, ["Install", "Upgrade"])
        if not element:
            continue
        printerr(f"Found confirmation button: {element.get('text')!r}")
        is_button = "Button" in element.get("type", "")
        if is_button:
            return send(click(element["id"]))

    printerr("Timed out looking for confirmation")

def click(id: str):
    return command("click", {"objectId": id}, 1)

if __name__ == "__main__":
    cmd = sys.argv[1]
    if cmd == "install_module":
        install_module(sys.argv[2])
    elif cmd == "get_tree":
        print(json.dumps(send(get_tree()), indent=2))
    elif cmd == "list_interactive":
        print(json.dumps(send(list_interactive()), indent=2))
    elif cmd == "click":
        print(json.dumps(send(click(sys.argv[2])), indent=2))
    else:
        print(f"Unknown command: {cmd}")
        sys.exit(1)



