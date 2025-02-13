package main

import (
	"fmt"
	"log"
	"time"

	"github.com/tarm/serial"
)

func main() {
	fmt.Println("--- Start ---")

	// Конфигурация для COM1 (запись)
	configWrite := &serial.Config{
		Name:        "COM1",
		Baud:        4800,
		Size:        8,
		StopBits:    serial.Stop1,
		Parity:      serial.ParityNone,
		ReadTimeout: time.Second * 5,
	}

	portWrite, err := serial.OpenPort(configWrite)
	if err != nil {
		log.Fatalf("Ошибка открытия COM1 для записи: %v", err)
	}
	defer portWrite.Close()

	// Конфигурация для COM2 (чтение)
	configRead := &serial.Config{
		Name:        "COM2",
		Baud:        4800,
		Size:        8,
		StopBits:    serial.Stop1,
		Parity:      serial.ParityNone,
		ReadTimeout: time.Second * 5,
	}

	portRead, err := serial.OpenPort(configRead)
	if err != nil {
		log.Fatalf("Ошибка открытия COM2 для чтения: %v", err)
	}
	defer portRead.Close()

	message := "hello world"
	fmt.Printf("Sending '%s' into COM1\n", message)

	n, err := portWrite.Write([]byte(message))
	if err != nil {
		log.Fatalf("Ошибка записи в COM2: %v", err)
	}
	fmt.Printf("Отправлено %d байт\n", n)

	buf := make([]byte, 1024)
	n, err = portRead.Read(buf)
	if err != nil {
		log.Printf("Ошибка чтения из COM2: %v", err)
	} else {
		received := string(buf[:n])
		fmt.Printf("\nData from COM2: '%s'\n", received)
	}

	fmt.Println("\n--- End ---")
}
