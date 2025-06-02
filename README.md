# 🗓️ Flutter 캘린더 메모/카테고리 앱

> **직관적인 달력 기반 일정/메모 관리 앱**  
> Flutter & Dart 기반, TableCalendar/Provider/ColorPicker 등 활용  

---

## 📌 프로젝트 소개

**Flutter Calendar Memo App**은  
사용자가 달력에서 날짜를 선택하고,  
카테고리별로 메모를 추가·관리할 수 있는 일정 관리 앱입니다.

- 달력의 월 이동 버튼(좌/우)과 설정(톱니바퀴) 버튼이 겹치지 않도록 커스텀 헤더를 구현했습니다.
- 설정 버튼을 누르면 달력 위에 작은 팝업이 오버레이로 뜨고,  
  여기서 카테고리 추가 등 관리 기능을 제공합니다.
- 토요일은 파란색, 일요일은 빨간색으로 요일 및 날짜가 표시되어  
  직관적이고 깔끔한 UI를 제공합니다.

  
<img src="./flutter.png" width="200">


---

## 🛠️ 주요 기능

- **TableCalendar 기반 달력**
  - 월 이동, 날짜 선택, 요일별 색상(토요일 파랑, 일요일 빨강)
- **설정(톱니바퀴) 버튼**
  - 달력 우측 상단에 위치, 팝업으로 카테고리 관리 기능 제공
- **카테고리 추가/관리**
  - 카테고리별 색상 선택(프리셋 10종)
  - 카테고리별로 메모를 분류하여 관리
- **메모 관리**
  - 날짜별, 카테고리별로 할 일/메모 추가, 체크, 삭제
- **반응형 UI**
  - 모바일/태블릿 모두 대응
- **깔끔한 디자인**
  - 달력과 메모 영역의 배경색 통일, 불필요한 여백/배경 없음

---

## ⚙️ 개발 환경 및 기술

- **Flutter 3.x / Dart**
- **table_calendar, provider, flutter_colorpicker, uuid, intl** 등 주요 패키지 활용
- **상태 관리**: Provider
- **플랫폼**: iOS, Android, Web 지원

---

## 🖥️ 실행 예시

- 달력에서 날짜를 누르면 아래에 해당 날짜의 메모가 나타나고,
- 설정 버튼을 누르면 달력 위에 작은 팝업이 자연스럽게 오버레이로 뜹니다.
- 카테고리 추가 버튼을 통해 원하는 색상의 카테고리를 자유롭게 생성할 수 있습니다.

---

## 💡 이런 분께 추천합니다

- Flutter로 일정/메모/카테고리 관리 앱 구조를 배우고 싶은 분
- TableCalendar, Provider, 커스텀 헤더/팝업 UI 예제를 찾는 분
- 모바일과 웹 양쪽에서 잘 동작하는 Flutter 캘린더 앱을 만들고 싶은 분

---

## 📦 주요 패키지

- [table_calendar](https://pub.dev/packages/table_calendar)
- [provider](https://pub.dev/packages/provider)
- [flutter_colorpicker](https://pub.dev/packages/flutter_colorpicker)
- [uuid](https://pub.dev/packages/uuid)
- [intl](https://pub.dev/packages/intl)

---

## 🗂️ 프로젝트 구조 및 커스텀 UI

- TableCalendar의 기본 헤더를 숨기고,
  Row로 월 이동 버튼, 월 타이틀, 설정 버튼을 직접 배치해
  버튼 겹침 없이 원하는 위치에 UI를 배치했습니다.
- 설정 버튼을 누르면, 달력 위에 작은 팝업이 오버레이로 자연스럽게 뜨도록
  Stack과 Positioned 위젯을 활용했습니다.
- 토요일/일요일 요일과 날짜 색상, 카테고리별 색상 등
  실제 캘린더 앱에서 자주 쓰는 디자인 패턴을 적용했습니다.

---

## 📝 참고

- 모든 소스코드는 [GitHub 저장소](https://github.com/your-github-id/your-calendar-memo-repo)에서 확인할 수 있습니다.
- 자세한 구현 및 커스텀 위젯 구조는 소스코드와 주석을 참고해 주세요.

---

**이 프로젝트는 Flutter를 활용한 달력/메모/카테고리 관리 앱의 실전 구조와 UI/UX를 경험해보고 싶은 분께 추천합니다.**
