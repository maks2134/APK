package main

import (
	"fmt"
	"log"
	"time"

	"github.com/tarm/serial"
)

const (
	COM1_PORT = "COM3" // Порт COM1 для Windows
	COM2_PORT = "COM4" // Порт COM2 для Windows
)

func main() {
	// Инициализация порта COM1
	config1 := &serial.Config{
		Name:        COM1_PORT,
		Baud:        4800,
		Size:        8,
		StopBits:    serial.Stop1,
		Parity:      serial.ParityNone,
		ReadTimeout: time.Second * 5,
	}

	port1, err := serial.OpenPort(config1)
	if err != nil {
		log.Fatalf("Failed to open COM1: %v", err)
	}
	defer port1.Close()

	// Инициализация порта COM2
	config2 := &serial.Config{
		Name:        COM2_PORT,
		Baud:        4800,
		Size:        8,
		StopBits:    serial.Stop1,
		Parity:      serial.ParityNone,
		ReadTimeout: 1, // Таймаут чтения в секундах
	}

	port2, err := serial.OpenPort(config2)
	if err != nil {
		log.Fatalf("Failed to open COM2: %v", err)
	}
	defer port2.Close()

	// Запрос на ввод символа
	var data string
	fmt.Print("Enter a character: ")
	_, err = fmt.Scan(&data)
	if err != nil {
		log.Fatalf("Failed to read input: %v", err)
	}

	// Отправка символа через COM1
	_, err = port1.Write([]byte(data))
	if err != nil {
		log.Fatalf("Failed to write to COM1: %v", err)
	}
	fmt.Printf("Sent character: %c\n", data[0])

	// Чтение символа из COM2
	buf := make([]byte, 1)
	n, err := port2.Read(buf)
	if err != nil {
		log.Fatalf("Failed to read from COM2: %v", err)
	}
	if n > 0 {
		fmt.Printf("Received character: %c\n", buf[0])
	} else {
		fmt.Println("No data received from COM2")
	}
}
