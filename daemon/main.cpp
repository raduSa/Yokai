#include <thread>
#include <print>

#include "../common/include/connection.h"

void handle_client(int client) {
    constexpr int BUFF_SIZE = 1024;
    char buff[BUFF_SIZE] = {0};
    while (true) {
        memset(&buff, 0, BUFF_SIZE);
        ssize_t bytes_read = read(client, &buff, BUFF_SIZE - 1);
        if (bytes_read <= 0) {
            if (bytes_read == 0) {
                std::println("[INFO]: Client '{}' disconnected!", client);
            } else {
                std::cerr << "[ERROR]: Read failed or connection closed by client" << std::endl;
            }
            break;
        }
        std::println("Message from client: {}", buff);
    }

    close(client);
}

int main() {
    constexpr int32_t PORT = 8080;
    constexpr int32_t NUM_CLIENTS = 3;

    Connection conn(PORT);
    std::optional<std::error_code> err = conn.init_server(NUM_CLIENTS);
    if (err != std::nullopt) {
        std::cerr << err.value().message() << std::endl;
        return 1;
    }

    bool running = true;
    std::println("Listenting for connections on port :{}", PORT);
    while (running) {
        auto client_fd = conn.accept_conn();
        if (!client_fd.has_value()) {
            std::cerr << client_fd.error().message() << std::endl;
        }

        std::thread client_thread(handle_client, client_fd.value());
        client_thread.detach();

    }
    return 0;
}
