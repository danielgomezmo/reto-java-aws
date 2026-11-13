
package com.reto;

import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;

public class App {

    public static void main(String[] args) throws IOException {

        HttpServer servidor = HttpServer.create(
            new InetSocketAddress("0.0.0.0", 8080), 0
        );

        servidor.createContext("/", intercambio -> {

            byte[] mensaje = "Hola Mundo desde Java!"
                .getBytes(StandardCharsets.UTF_8);

            intercambio.getResponseHeaders().set(
                "Content-Type", "text/plain; charset=UTF-8"
            );

            intercambio.sendResponseHeaders(200, mensaje.length);

            try (var salida = intercambio.getResponseBody()) {
                salida.write(mensaje);
            }
        });

        servidor.start();

        System.out.println("Servidor listo: http://localhost:8080");
    }
}
