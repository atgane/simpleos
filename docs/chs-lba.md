# 디스크 주소 지정 방식

chs: 실린더, 헤드, 섹터를 이용하여 주소를 지정하는 방식. 물리적인 주소에 기반하지만 용량에 제한이 발생한다. 

위의 한계를 극복하기 위한 주소 지정 방식이 lba이다. 하드 디스크에 존재하는 모든 섹터를 일렬로 늘어뜨린 후 번호를 매겼다고 생각하면 된다. 즉, 논리적인 방식으로 섹터 번호를 얻게 된다. 이 논리적인 방식을 물리적인 위치 값으로 변환해야 하는데, 이것은 디스크 컨트롤러가 알아서 해준다. 

한편 변환 공식은 다음과 같다. 

```
lba = ((cylinder * head per cylinder + head) * sectors per track) + sector - 1
sector = lba % sectors per track + 1
head = (lba / sectors per track) % heads
cylinder = (lba / sectors per track) / heads
```