import socket

HOST = 'localhost'
PORT = 7421


def send_code(code, host=HOST, port=PORT):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as conn:
        conn.connect((host, port))
        code_bytes = bytes(code.encode('utf8')) + b'\0'
        conn.sendall(code_bytes)
        result = list()
        while True:
            data = conn.recv(4096)
            if data:
                result.append(data.decode('utf-8'))
            else:
                break

    return ''.join(result)


if __name__ == '__main__':
    while True:
        code = input("\\(ichicken)>")
        if code == "\\q":
            print('Quitting.')
            exit()

        result = send_code(code)
        print(result)
