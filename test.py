import socket
import time

# set IP address and port number
IP_ADDRESS = "10.48.155.202"
PORT = 8080

# create a TCP socket object
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# connect to the server
client_socket.connect((IP_ADDRESS, PORT))

# send a message to the server
for _ in range(10):
    message = r'{"voltage": 24.1, "safety": 1, "rpm": 300}'
    client_socket.sendall(len(message).to_bytes(4, "little"))
    client_socket.sendall(message.encode())
    time.sleep(10 / 1000)

# receive a response from the server
#response = client_socket.recv(1024)
#print(f"Received message from server: {response.decode()}")

# close the socket connection
client_socket.close()
