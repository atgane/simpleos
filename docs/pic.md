# pic

[https://0x200.tistory.com/category/Operating%20Systems/OS%20%EC%BB%A4%EB%84%90%20%EC%A0%9C%EC%9E%91?page=2](https://0x200.tistory.com/category/Operating%20Systems/OS%20%EC%BB%A4%EB%84%90%20%EC%A0%9C%EC%9E%91?page=2)

pc의 모든 하드웨어 인터럽트는 8259A 칩이 처리한다. os는 해당 pic를 초기화하고 연결하고 cpu 입력 형식이 내부에 정의되어야 한다. pic는 master/slave구조이다. master/slave의 각 핀 8개를 통하여 장치의 인터럽트를 받아 cpu에 알린다. cpu는 해당 정보를 받으면 인터럽트 루틴을 실행한다. 

마스터 동작은 다음과 같다. 

1. int핀에 신호를 보낸다. cpu는 eflags의 IE 비트를 1로 셋하고 인터럽트 수신이 가능하면 inta 핀으로 신호를 보낸다. 
2. cpu로부터 inta핀으로 신호가 오면 몇 번째 irq에 연결된 장치의 인터럽트인지 데이터버스로 전달한다. cpu는 pic가 보낸 데이터를 참조하여 보호모드라면 해당 번호의 디스크립터를 찾아 인터럽트 핸들러를 실행한다. 

슬레이브 동작은 다음과 같다. 

1. 자신의 int 핀에 신호를 보낸다. 마스터 irq 2번 핀에 인터럽트 신호를 보낸다. 이후 마스터가 cpu에 신호를 보낸다. 
2. cpu가 inta 신호를 주면 데이터버스에 숫자를 보내 몇 번째 장치에서 인터럽트를 받았는지 알린다. 

pic를 제어하기 위해 icw1, icw2, icw3, icw4라는 프로그램을 정의한다. 

세부 사항은 다음을 참조하자. 

[https://itguava.tistory.com/17?category=630867](https://itguava.tistory.com/17?category=630867)