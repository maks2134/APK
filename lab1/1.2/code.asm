.model small
.stack 100h

.data
    message db 'Hello, COM!$'

.code
start:
    ; Инициализация сегмента данных
    mov ax, @data
    mov ds, ax

    ; Инициализация COM-порта (COM7)
    mov dx, 06h       ; COM7
    mov al, 11100011b ; Параметры порта
    mov ah, 00h
    int 14h

    ; Отправка сообщения через COM7
    mov si, offset message
send_loop:
    lodsb             ; Загружаем символ из сообщения
    cmp al, '$'       ; Проверяем конец строки
    je receive
    mov ah, 01h       ; Функция отправки символа
    int 14h
    jmp send_loop

receive:
    ; Прием данных через COM8
    mov dx, 07h       ; COM8
    mov ah, 02h       ; Функция чтения символа
    int 14h
    mov dl, al        ; Вывод символа на экран
    mov ah, 02h
    int 21h

    ; Завершение программы
    mov ax, 4C00h
    int 21h

end start
