from ipykernel.kernelbase import Kernel
import subprocess as sp
from threading import Thread
import socket
import logging


HOST = 'localhost'
PORT = 7421


class IChickenKernel(Kernel):
    implementation = 'IChickenKernel'
    implementation_version = '0.0'
    language = 'scheme'
    language_version = '5.0'
    language_info = {
        'mimetype': 'text/x-scheme',
        'name': 'scheme'
    }

    banner = 'IChickenKernel - Bok bok!'

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self._chicken_server_thread = Thread(
            target=sp.call,
            args=(['bash', '-c', 'bin/start-chicken-repl-server'],)
        )
        self._chicken_server_thread.start()
        logging.info('Chicken thread started {}.'.format(
            self._chicken_server_thread))


    def do_execute(self, code, silent, store_history=True,
                   user_expressions=None, allow_stdin=False):
        if not silent:
            logging.info('Code: {}'.format(code))
            result = send_code(code)
            logging.info('Result: {}'.format(result))
            stream_content = {
                'name': 'stdout',
                'text': result
            }
            self.send_response(self.iopub_socket, 'stream', stream_content)

        return {
            'status': 'ok',
            # Incrementing of execution count handled by base class.
            'execution_count': self.execution_count,
            'payload': [],
            'user_expressions': {}
        }


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
    logging.basicConfig(
        level=logging.INFO,
        filename='.log-ichicken-kernel'
    )
    from ipykernel.kernelapp import IPKernelApp
    IPKernelApp.launch_instance(kernel_class=IChickenKernel)
