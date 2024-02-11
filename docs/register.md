# 레지스터의 종류

기본 레지스터는 다음과 같다. 

- ax: accumulator. 누적 연산기
- cx: counter
- dx: data
- bx: base
- sp: stack pointer
- bp: base pointer
- si: source index. 읽기 인덱스
- di: destination index. 쓰기 인덱스

- al: accumulator low
- ah: accumulator high
- bl: data low
- bh: data high
- cl: counter low
- ch: counter high
- dl: data low
- dh: data high

세그먼트는 다음과 같다. 세그먼트는 메모리의 주소를 나타내기 위해 사용한다. 예를 들어서

mov al, [es]

이런 식이다. 세그먼트는 상수를 바로 대입할 수 없는데, 이는 16비트 cpu 특성으로 인하여 안된다고 한다. 16비트에서 실행할 수 있는 명령어의 크기가 작고 효율적인 메모리 집합, 하위 호환성을 유지해야 한다 gpt가 카더라.

- es: extra segment
- cs: code segmnet
- ss: stack segment
- ds: data segment
- fs, gs: 명칭 없음

시스템 레지스터

- cr0: 보호모드 활성화를 위한 레지스터. 0번 비트는 PE로 보호모드 전환에 활용된다. 31번 비트는 PG로 페이징 활성화를 위해 활용된다. 