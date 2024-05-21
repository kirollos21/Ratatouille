import socket

hostname = socket.gethostname()
ip_address = socket.gethostbyname(hostname)
print(f"Your IP Address is: {ip_address}")