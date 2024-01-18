# x86 시스템 아키텍처

모든 프로세서는 레지스터를 갖는다. 자주 쓰이는 레지스터는 특정 종류로 구분된다. 

- general purpose register: 다양한 목적으로 사용할 수 있는 레지스터이다. ex) AL, AH, BL, BH ... 
- index register: 인덱스와 포인터를 저장하기 위해 사용되는 레지스터이다. 다른 목적으로 사용될 수 있다. ex) BP, DI, SI, SP
- program counter: 현재 명령이 시작되는 메모리 위치를 추적하는 특수 레지스터이다. ex) IP
- segment register: 활성화된 세그먼트를 추적하는데 사용된다. ex) CS, SS, DS, ES, FS, GS
- flag register: 다양한 명령에 의해 설정되는 특수 플래그이다. ex) FLAGS
- accumulator register: 산술 연산에서 사용되는 레지스터이다. ex) AX, BX, CX, DX

한편 20비트 메모리를 표현하기 위해 두 개의 16비트값을 사용한다. segment와 offset이다. 실제 주소를 다음과 같은 식으로 구현했다. 

real_address = segment * 16 + offset

메모리 세그먼트에서 다루는 특별한 레지스터가 존재한다. 

- CS: currently running code segment: 어디서 코드가 실행되고 있는지를 나타내는 세그먼트이다. 
- IP: program counter register: 오프셋으로 사용되는 레지스터이다. 
- DS: data segment
- ES, GS, FS: extra data segment
- SS: stack segment: 현재 스택 레지스터를 나타낸다. 

메모리 세그먼트는 다음과 같이 표현된다. 

segment = base + index * scale + displacement

- segment 레지스터는 data segment register인 CS, DS, ES, FS, GS, SS가 사용된다. 
- base는 16bit에서 제한적으로 BP/BX가 이용된다. general purpose register가 사용된다. 
- index는 16bit에서 SI, DI만 사용할 수 있다. general purpose register가 사용된다. 
- scale은 16bit 모드에서 존재하지 않는다. 1, 2, 4, 8의 값을 갖는다. 
- displacement는 상수이다. 

세그먼트 레지스터에는 상수를 직접 쓸 수 없다. 따라서 중간 레지스터를 이용해야 한다. 

다음 예시를 살펴보자.

```asm
var: dw 100
    mov ax, var     ; copy offset to ax
    mov ax, [var]   ; copy memory contents
```

100의 값을 가지는 var 레이블을 정의헀다. 첫 번째 명령은 레이블의 오프셋을 ax 레지스터에 넣고 두 번째 명령은 메모리의 내용을 넣는다. 세그먼트 레지스터가 지정되지 않았기 때문에 DS가 사용된다. 

```asm
array: dw 100, 200, 300
    mov bx, array       ; copy offset to ax
    mov si, 2 * 2s      ; array[2], words are 2 byte wide

    mov ax, [bx + si]   ; copy memory contents
```

***

코드 세그먼트 레지스터는 BIOS로 인해 0을 가리킨다. 