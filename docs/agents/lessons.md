# Lessons — flutter_show_menu 실증

이 repo 가 `theflow` 의 각 단계에서 실제로 **무엇을 놓쳤나** 의 기록 — 규칙에 무게를 주는
근거. 전부 이 repo 에서 실제로 일어났다. 단계 번호는 `theflow` SKILL.md 와 일치. 바인딩
(`theflow.md`)이 추상으로 읽히면 여기 사건과 대조하라.

---

## 우회 금지 (근본 층에서 고쳐라)

- **#18 / ADR-0004 (근본 층 = 불변식이 결정되는 자리)**: scale 원점이 flip 을 따라가지
  않는 버그의 증상은 애니메이션에 보였지만 원인은 **build 와 layout 의 순서**였다 — flip 은
  메뉴 자신의 크기를 알아야 해서 `getPositionForChild`(layout)에서 정해지는데 `ScaleTransition`
  은 그 전에 build 된 트리에서 alignment 를 읽는다. 기각한 우회 둘: "build 에서 오버플로를
  예측한다"(호출자가 메뉴 크기를 미리 선언하는 API 를 요구 — 내부 순서를 공개 표면으로 밀어냄),
  "`ValueNotifier` 로 되보고 rebuild 한다"(보정이 한 프레임 늦어 오차 최대인 첫 프레임 scale 0.9
  가 틀린 프레임이 됨). 답은 layout 에서 원점을 정하고 paint 에서 읽는 렌더 오브젝트였다.
- **#9 (방어 코드로 덮지 말고 소스에서 확정)**: `on TickerCanceled` catch 가 "혹시 모르니"
  로 살아 있었다. `scheduler/ticker.dart` 를 읽어 `await controller.reverse()` 가 그 예외를
  **절대** 안 던짐을 증명하고서야 지웠다 — 도달 불가의 *적극적 증명*이지 커버리지 부재가 아니다.
- **#8 (계약을 결함으로 오진 금지)**: unmount 된 context 를 넘기면 Flutter 가 `Cannot get
  renderObject of inactive element` 을 던지지만 그건 `assert` 안이라 release 에선 발동 안 함 —
  SDK 결함처럼 보인다. 그러나 깨진 불변식은 이쪽 것이었다: *anchor context 는 `RenderBox` 를
  가진다* 는 계약을 `showOverlayMenu` 가 명시·검사 없이 무조건 캐스트했다. 여기서 `FlutterError`
  가드로 고쳤다.

## Step 1 — 이슈 먼저 (본문 근거도 실측 대상)

- **#7 (틀린 근거 정정)**: "`==` 를 넣으면 `OverlayMenuButton` 의 rebuild short-circuit 이
  살아난다" 고 적었으나, `framework.dart:4014` 는 `child.widget == newWidget` — **위젯 자체**를
  비교한다. `OverlayMenuButton` 은 `==` 를 오버라이드하지 않으므로 설정 객체 동등성은 rebuild 에
  영향 0. 착수 전에 본문을 진짜 근거(const 동등·`didUpdateWidget` diff·`Set`/`Map` 키)로 갈았다.
- **#9 (삭제엔 적극적 증명)**: `on TickerCanceled` 가 한 번도 실행 안 됐다는 관찰만으로 지웠다면,
  도달 가능했을 경우 처리 안 된 async 에러가 된다. "지우려면 증명하라" 를 이슈에 못박았고, 증명은
  SDK 소스에서 나왔다.
- **#18 (범위 밖 발견은 별도 이슈로)**: scale 원점이 flip 을 안 따라간다는 걸 #6 작업 중
  발견했으나 원인이 구조적이라 그 자리서 안 고치고, 재현·수치·기각 후보 넷을 담아 별도 이슈로 열었다.

## Step 2 — 추측 금지 (SDK 소스가 진실)

- **#5 (프로브 숫자)**: `initialValue` 가 뷰포트 중앙에 온다는 건 가정이었다. 프로브가 뷰포트
  192(`maxHeight` 200 − padding 8), 항목 중심 409 vs 뷰포트 중심 405 를 찍었다 — 4px 어긋남,
  header/footer 넣으면 52px.
- **#9 (SDK 소스로 도달 불가 증명)**: `scheduler/ticker.dart` — `TickerFuture.then`/
  `whenComplete` 는 `_primaryCompleter` 에 위임하고, `dispose()`/`stop(canceled:true)` 는
  `_secondaryCompleter`(=`orCancel`)만 에러로 완료시킨다. 즉 `await controller.reverse()` 는
  `TickerCanceled` 를 절대 안 던진다 → catch 는 죽은 코드.
- **#18 (원리적 불가능을 소스로 확정)**: `painting/alignment.dart:161,163,165` — `AlignmentGeometry`
  는 private abstract 멤버(`_x`/`_start`/`_y`)를 선언한다. paint 시점 해석 커스텀 alignment 안이
  **원리적으로 불가능**함을 이걸로 확정하고 ADR-0004 에 기각 사유로 남겼다.
- **#8 (debug ≠ 프로덕션)**: unmount context 는 우리 캐스트 전에 Flutter 가 `assert` 안에서
  던진다 — release 에선 발동 안 하고 stale 렌더 오브젝트가 반환돼 사라진 위젯 자리에 메뉴가 열린다.
- **#7 (test ≠ release)**: `identical(const SizedBox(), const SizedBox())` 는 **test 에선
  false**(widget creation tracking 이 소스 위치 주입), release 에선 true. 빌드 모드에 따라 갈리는
  명제를 특성화 테스트로 굳히지 마라.

## Step 3/4 — 설계 확정 & RED→GREEN

- **1.0.0 (계약을 red 전에)**: `Controller.close()` 가 exit 애니메이션을 재생해야 하는가는 red
  전에 정했다. 그 답이 "결과는 Close 가 *요청되는* 순간 latch 된다"(ADR-0002)를 낳았고, 결과 유실
  버그 두 개를 동시에 없앴다. 여섯 후보를 `/grilling` 질문 여섯 개로 확정한 뒤 코드를 시작했다.
- **#18 (공개 seam 에서 관찰)**: 12 개 테스트가 `ScaleTransition.alignment` 를 단언했다. 구현을
  커스텀 렌더 오브젝트로 바꾸자 **관측 가능 동작은 하나도 안 바뀌었는데 12 개가 전부 깨졌다.**
  seam 을 "메뉴가 어느 점을 고정한 채 자라는가" 로 다시 긋고 뒤집힌 4 방향까지 덮었다.
- **#8 (RED 가 정말 RED)**: unmount context 에 `throwsA(isA<FlutterError>())` 는 처음부터
  초록불(Flutter 가 이미 던짐). 메시지가 `showOverlayMenu` 를 지목하는지를 요구해야 red 가 됐다.

## Step 5 — 테스트 신뢰 (100% 커버 ≠ 옳음)

- **#18**: `lib/` 100% 인 상태에서도 scale 원점 버그는 멀쩡히 살아 있었다 — 그 줄들은 *실행*되지만
  *검증*되지 않았다. 원점 고정 테스트 16 개는 메뉴가 실제로 커졌는지 확인 안 하면 scale 1 고정에도
  전부 통과 → `_expectItGrew` 가드.
- **#7**: `copyWith` 의 `x ?? this.x` 에서 오른쪽 피연산자가 한 번도 평가 안 됐다 — 각 필드를
  *교체할 때만* 테스트하고 *보존할 때는* 안 함. 인자 없는 `copyWith()` 가 원본과 동등해야 한다는
  속성 하나로 일곱 클래스를 덮었다.

## Step 6/7 — 정합성 & 게이트

- **1.0.0 (모든 표면 갱신)**: CHANGELOG 1.0.0 절이 네 가시 변화보다 먼저 쓰여 게시 직전 맞췄다.
  README 는 `copyWith` 가 새 그룹 3 개에만 있다고 적었으나 실제 7 개 전부였고, `showOverlayMenu`
  의 `FlutterError` 와 반환 latch 시점은 어디에도 없었다. `.pubignore` 는 `coverage/` 가
  `.gitignore:31` 에 있는데도 아카이브에 실려 나갔다.
- **커버리지 바닥 100**: `test/menu_chrome_test.dart` 를 통째로 지우면 정확히 **99.0%**(518/523)
  — 바닥이 99 였다면 `99.0 < 99.0` 이 거짓이라 통과. #18 의 새 렌더 오브젝트가 미커버 3 줄
  (호출 안 되는 `updateRenderObject`)을 달고 들어왔고 게이트가 잡았다.
- **1.0.0 태그 (불변 포인터)**: 태그·GitHub 릴리스가 이미 원격에 있었으나 첨부 0 개였고 `dry-run`
  이 `The previous version is 0.7.0`(= pub.dev 는 1.0.0 을 모른다)을 알렸다. 1.0.1 로 도망가면
  0.7.0 과 첫 공개 릴리스 사이에 이유 없는 구멍이 남아 태그를 옮겼다.
