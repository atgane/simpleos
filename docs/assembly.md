# 어셈블리 기본

- jmp segment:offset: segment * 16 + offset의 주소로 점프
- equ: define 역할. cyls equ 10
- cli: 인터럽트 초기화
- nop: cpu 파이프라인 휴식을 호출하는 명령어