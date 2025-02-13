.model small  ; Определяем модель памяти как small (маленькая модель)
.stack 100h   ; Определяем размер стека в 256 байт (100h в шестнадцатеричной системе)

.data         ; Начало секции данных

Error_Write db "Write error!",0Dh,0Ah,'$'  ; Сообщение об ошибке записи
Error_Read db "Read error!",0Dh,0Ah,'$'    ; Сообщение об ошибке чтения
Information db 0Dh,0Ah,"Byte sent:",'$'    ; Сообщение о отправленном байте
Data_Byte db ?                             ; Переменная для хранения отправляемого байта
Data_Byte2 db ?                            ; Переменная для хранения полученного байта

.code         ; Начало секции кода

; Процедура инициализации COM1 порта
Init_COM1 proc
    mov al,80h       ; Устанавливаем бит DLAB (Divisor Latch Access Bit)
    mov dx,3FBh      ; Адрес регистра управления линией (Line Control Register)
    out dx,al        ; Записываем значение в регистр

    mov dx,3F8h      ; Адрес младшего байта делителя (Baud Rate Divisor Latch Low Byte)
    mov al,00h       ; Устанавливаем младший байт делителя (для скорости 9600 бод)
    out dx,al        ; Записываем значение в регистр
    mov al,0Ch       ; Устанавливаем старший байт делителя (для скорости 9600 бод)
    mov dx,3F9h      ; Адрес старшего байта делителя (Baud Rate Divisor Latch High Byte)
    out dx,al        ; Записываем значение в регистр

    mov dx,3FCh      ; Адрес регистра управления модемом (Modem Control Register)
    mov al,00001011b ; Устанавливаем биты DTR и RTS (Data Terminal Ready и Request to Send)
    out dx,al        ; Записываем значение в регистр

    mov dx,3F9h      ; Адрес регистра управления прерываниями (Interrupt Enable Register)
    mov al,0         ; Отключаем все прерывания
    out dx,al        ; Записываем значение в регистр
    ret              ; Возврат из процедуры
Init_COM1 endp

; Процедура проверки готовности к записи в COM1
IsWrite_COM1 proc
    xor al,al        ; Очищаем регистр AL
    mov dx,3FDh      ; Адрес регистра состояния линии (Line Status Register)
    in al,dx         ; Читаем значение из регистра
    test al,10h      ; Проверяем бит THRE (Transmitter Holding Register Empty)
    jnz NoWRite      ; Если бит не установлен, переходим к процедуре NoWRite
    ret              ; Возврат из процедуры
IsWrite_COM1 endp

; Процедура вывода сообщения об ошибке записи
NoWRite proc
   mov ah,9          ; Функция DOS для вывода строки
   mov dx,offset Error_Write  ; Загружаем адрес сообщения об ошибке записи
   int 21h           ; Вызов прерывания DOS для вывода строки
   ret               ; Возврат из процедуры
NoWRite endp

; Процедура проверки готовности к чтению из COM2
IsRead_COM2 proc
    xor al,al        ; Очищаем регистр AL
    mov dx,3FDh      ; Адрес регистра состояния линии (Line Status Register)
    in al,dx         ; Читаем значение из регистра
    test al,10b      ; Проверяем бит DR (Data Ready)
    jnz NoRead       ; Если бит не установлен, переходим к процедуре NoRead
    ret              ; Возврат из процедуры
IsRead_COM2 endp

; Процедура вывода сообщения об ошибке чтения
NoRead proc
   mov ah,9          ; Функция DOS для вывода строки
   mov dx,offset Error_Read  ; Загружаем адрес сообщения об ошибке чтения
   int 21h           ; Вызов прерывания DOS для вывода строки
   ret               ; Возврат из процедуры
NoRead endp

; Процедура отправки байта через COM1
Send_Byte proc
    mov ah,01h       ; Функция DOS для ввода символа
    int 21h          ; Вызов прерывания DOS для ввода символа
    mov Data_Byte,al ; Сохраняем введенный символ в переменную Data_Byte
    mov dx,3F8h      ; Адрес регистра данных COM1 (Transmitter Holding Register)
    mov al,Data_Byte ; Загружаем символ в AL
    out dx,al        ; Отправляем символ через COM1
    ret              ; Возврат из процедуры
Send_Byte endp

; Процедура чтения байта из COM2
Read_Byte proc
    mov dx,3F8h      ; Адрес регистра данных COM2 (Receiver Buffer Register)
    in al,dx         ; Читаем символ из COM2
    mov Data_Byte2,al ; Сохраняем прочитанный символ в переменную Data_Byte2
    ret              ; Возврат из процедуры
Read_Byte endp

; Процедура завершения программы
Exit proc
    mov ax,4C00h     ; Функция DOS для завершения программы
    int 21h          ; Вызов прерывания DOS для завершения программы
    ret              ; Возврат из процедуры
Exit endp

; Начало программы
start:
    mov ax,@data     ; Загружаем адрес сегмента данных в AX
    mov ds,ax        ; Устанавливаем регистр DS на сегмент данных
    call Init_COM1   ; Инициализируем COM1 порт
    call IsWrite_COM1 ; Проверяем готовность к записи в COM1
    call Send_Byte   ; Отправляем байт через COM1
    mov al,2         ; Загружаем значение 2 в AL (не используется в коде)
    call IsRead_COM2 ; Проверяем готовность к чтению из COM2
    call Read_Byte   ; Читаем байт из COM2
    mov dx,offset Information ; Загружаем адрес сообщения о отправленном байте
    mov ah,9         ; Функция DOS для вывода строки
    int 21h          ; Вызов прерывания DOS для вывода строки
    mov ah,02h       ; Функция DOS для вывода символа
    mov dl,Data_Byte2 ; Загружаем прочитанный символ в DL
    int 21h          ; Вызов прерывания DOS для вывода символа
    call Exit        ; Завершаем программу

end start            ; Конец программы
