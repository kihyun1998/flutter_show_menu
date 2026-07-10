## Agent skills

### Issue tracker

Issues are tracked as GitHub issues in `kihyun1998/flutter_show_menu`, managed via the `gh` CLI. Pull requests are not a triage surface. See `docs/agents/issue-tracker.md`.

### Triage labels

Canonical label vocabulary (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.

## 우회 금지 (근본 층에서 고쳐라)

**증상이 보이는 층과 원인이 사는 층은 다르다.** 증상이 난 자리에서 덮지 마라. 우회는 ① 진짜 버그를 가려 고칠 압력을 없애고, ② 같은 지식을 두 층에 복제해 divergence 씨앗이 되고, ③ 잘못된 기본값을 영원히 기본값으로 남긴다. **우회하고 싶은 충동 = 멈추고 사용자에게 온다** — 무슨 상황인지 설명하고("원인은 X 층인데 Y 층에서 덮으면 통과한다") 근본 수정 여부를 *묻는다*. 혼자 우회하지도, 혼자 이슈만 파고 넘어가지도 마라.

**"고치는 비용" 과 "우회의 비용" 을 같은 저울에 올려라 — 우회의 비용은 공개 표면과 첫 프레임에서 청구된다.** 실증(#18, ADR-0004): scale 원점이 flip 을 따라가지 않는 버그의 증상은 애니메이션에 보였지만, 원인은 **build 와 layout 의 순서**였다 — flip 은 메뉴 자신의 크기를 알아야 하므로 `getPositionForChild`(layout) 에서 결정되는데 `ScaleTransition` 은 그 전에 build 된 트리에서 alignment 를 읽는다. 기각한 우회 둘: *"build 에서 오버플로를 예측한다"* 는 호출자가 메뉴 크기를 미리 선언하는 API 를 요구했다(내부 순서 문제를 공개 인터페이스로 밀어냄), *"`ValueNotifier` 로 되보고 rebuild 한다"* 는 보정이 한 프레임 늦어 **오차가 가장 큰 첫 프레임(scale 0.9)이 틀린 프레임**이 된다. 근본 층 — flip 이 결정되는 그 자리 — 에서 원점을 정하고 paint 에서 읽는 렌더 오브젝트가 답이었다.

**상류가 Flutter SDK 일 때도 같다. 모르는 것을 방어 코드로 덮지 말고 소스에서 확정하라.** 방어적 catch·널 가드·"혹시 모르니" 는 상류를 이해하지 못했다는 고백을 코드로 굳힌 우회다. 실증(#9): `on TickerCanceled` catch 는 "혹시 모르니" 로 살아 있었다. `scheduler/ticker.dart` 를 읽어 `await controller.reverse()` 가 그 예외를 **절대** 던지지 않음을 증명하고서야 지웠다 — 도달 불가의 *적극적 증명*이지, 커버리지 부재가 아니다. 실증(#18): "커스텀 `AlignmentGeometry` 로 늦게 해석시킨다" 는 우회는 시도하기 전에 `painting/alignment.dart:161,163,165` 가 private abstract 멤버(`_x`/`_start`/`_y`)를 선언한다는 사실로 **원리적으로 불가능**함이 확정됐고, ADR-0004 에 기각 사유로 남았다.

**역방향도 신호다: 같은 우회가 두 군데 이상에서 독립적으로 나타나면, 그건 공개 API 의 기본값이 함정이라는 증거다.** 사람들이 올바른 옵션을 발견한 게 아니라 버그를 발견하고 돌아간 것이다. 옵션을 하나 더 얹어 도망치지 말고 기본값을 의심하라.

이 패키지에는 아직 소비처가 없다 — 로컬 형제 repo 93 개 중 0 개, pub.dev dependents 0 개(2026-07-10 확인). 소비처가 생기면 이 원칙에 두 단계가 붙는다: 발행 전 `pubspec_overrides.yaml` 로 하류 스위트 실검증, 발행 후 하류가 들고 있는 우회 제거. 없는 동안은 이 flow 에 그 단계가 없다 — *생략한 게 아니라 대상이 없다.*

## 작업 flow

*Substantive 변경*(버그 수정·기능 추가·동작 변경)이면 이 8단계로 짠다. 단계를 *생략*하려면 (건너뛰는 게 아니라) *왜 이 변경엔 해당 없는지를 명시*한다 — 조용한 스킵 금지.

괄호 안 실증은 그 단계를 건너뛰었다면 놓쳤을 것이다. 전부 이 repo 에서 실제로 일어났다.

### 1. 이슈 먼저 — 실측 숫자·기각한 대안·부정 결과

측정한 숫자를 이슈에 박고, **기각한 대안과 그 이유**를 함께 적는다. 안 그러면 같은 대안이 다시 제안된다.

- **이슈 본문에 쓴 근거도 실측 대상이다.** 틀린 근거가 리포 기록에 남으면 다음 사람이 그걸 믿고 판단한다. 실증(#7): *"`==` 를 넣으면 `OverlayMenuButton` 의 rebuild short-circuit 이 살아난다"* 고 적었으나, `framework.dart:4014` 는 `child.widget == newWidget` — **위젯 자체**를 비교한다. `OverlayMenuButton` 은 `==` 를 오버라이드하지 않으므로 설정 객체의 동등성은 rebuild 에 아무 영향이 없다. 착수 전에 본문을 정정하고 진짜 근거(const 동등·`didUpdateWidget` diff·`Set`/`Map` 키)로 갈아끼웠다.
- **삭제에는 도달 불가의 *적극적 증명*을 요구한다.** 커버리지 부재는 증거가 아니다. 실증(#9): `on TickerCanceled` 가 한 번도 실행되지 않았다는 관찰만으로 지웠다면, 도달 가능했을 경우 처리되지 않은 async 에러가 된다. 이슈에 "지우려면 증명하라" 를 못박아 두었고, 실제 증명은 SDK 소스에서 나왔다(Step 2).
- **부정 결과·범위 밖 발견도 재현과 함께 남긴다.** 실증(#18): scale 원점이 flip 을 따라가지 않는다는 걸 #6 작업 중 발견했으나 원인이 구조적(레이아웃 vs build 순서)이라 그 자리에서 고치지 않고, 재현·수치·기각 후보 네 개를 담아 별도 이슈로 열었다.

### 2. 추측 금지 — spike 로 실측한다

**코드를 *읽어서* 얻은 확신은 확신이 아니다.**

- **버리는 프로브 테스트** (`test/_probe_test.dart`, 확인 후 삭제). 실제 rect·좌표·호출 순서를 `debugPrint` 로 뽑는다. 프로브는 버리되 **숫자는 이슈/PR 에 남긴다**. 실증(#5): `initialValue` 가 뷰포트 중앙에 온다는 건 가정이었다. 프로브가 뷰포트 192(= `maxHeight` 200 − padding 8), 항목 중심 409 vs 뷰포트 중심 405 를 찍었다 — 4px 어긋남. header/footer 를 넣으면 52px.
- **Flutter SDK 소스를 직접 `grep`/`sed`** (`/d/flutter/packages/flutter/lib/src/…`). 기억·요약 금지.
  - 실증(#9): `scheduler/ticker.dart` — `TickerFuture` 의 `then`/`whenComplete` 는 `_primaryCompleter` 에 위임하고, `Ticker.dispose()`/`stop(canceled: true)` 는 `_cancel()` 로 가서 **`_secondaryCompleter`(=`orCancel`)만** 에러로 완료시킨다. 즉 `await controller.reverse()` 는 `TickerCanceled` 를 절대 던지지 않는다 → catch 는 죽은 코드.
  - 실증(#18): `painting/alignment.dart:161,163,165` — `AlignmentGeometry` 는 private abstract 멤버(`_x`/`_start`/`_y`)를 선언한다. paint 시점에 해석되는 커스텀 alignment 로 고치는 안이 **원리적으로 불가능**함을 이걸로 확정했고, ADR-0004 에 기각 사유로 남겼다.
- **프레임워크의 debug 동작을 프로덕션 동작으로 착각하지 마라.** 실증(#8): unmount 된 context 는 우리 캐스트에 도달하기 전에 Flutter 가 `Cannot get renderObject of inactive element.` 를 던진다 — 그런데 그건 `assert` 안이라 **release 에선 발동하지 않고**, stale 한 렌더 오브젝트가 반환돼 사라진 위젯 위치에 메뉴가 열린다. debug 크래시보다 release 의 조용한 오작동이 나쁘다.
- **테스트 환경이 프로덕션과 다를 수 있다.** 실증(#7): `identical(const SizedBox(), const SizedBox())` 는 **false** 다. `flutter test` 와 debug 빌드는 widget creation tracking 으로 모든 위젯 const 생성자 호출에 소스 위치를 주입하므로 정규화가 일어나지 않는다. release 는 정규화한다. 특성화 테스트를 "const 위젯은 동등하다" 로 쓰면 빌드 모드에 따라 참·거짓이 갈린다.
- **외부 사실도 조회 대상이다.** pub.dev 상태는 `curl -s https://pub.dev/api/packages/flutter_show_menu`.
- **"확인했다" 가 정말 확인인지 본다.** 실증: `pub publish --dry-run` 의 파일 트리에서 `tool/` 부재를 확인한다며 `|--` 로 grep 했는데 실제 출력은 `├──` 였다. 아무것도 매칭되지 않은 것을 "없다" 로 읽었다 — 어느 쪽이든 빈 결과가 나오는 검사는 검사가 아니다. ASCII 문자열(`tool`, `github`, `ci.yml`)로 다시 확인했다.

**"확인 못 했다" ≠ "없다".** 미확인 사실은 갭이다. 이슈로 surfacing 하거나 사용자에게 묻는다 — 조용히 설계 가정으로 승격시키지 마라.

### 3. 설계 판단은 코드 전에 사용자와 확정

**TDD 는 "무엇이 옳은가" 를 답해주지 않는다.** 기대값을 발명하기 전에 정책을 못 박는다. *결정 유형으로 라우팅*한다.

- **순수 메커니즘**(좌표계·훅 선택·자료구조 — 소스로 도출 가능) → 직접 결정하고 **검증 결과만** 제시. 답이 코드에 있는 걸 묻는 건 일 떠넘기기다.
- **계약·정책**(테스트 seam, 폴백 동작, 공개 API 표면, 동작 변경 허용 여부) → **묻는다.** 실증(1.0.0): `Controller.close()` 가 exit 애니메이션을 재생해야 하는가는 red 테스트를 쓰기 *전에* 정해야 했다. 그 답이 "결과는 Close 가 *요청되는* 순간 latch 된다" 를 낳았고, 그게 결과 유실 버그 두 개를 동시에 없앴다.
- **`/grilling` 으로 설계 트리를 먼저 흔든다.** 1.0.0 의 여섯 후보는 grilling 에서 나온 질문 여섯 개(Close 원칙 → 선점 규칙 → 애니메이션 소유권 → 그룹 경계 → entry view 공개 여부 → 레지스트리 seam)로 확정한 뒤에야 코드가 시작됐다.

### 4. `/tdd` 로 RED→GREEN 수직 슬라이스

한 번에 하나 — 테스트 하나 → 최소 구현 → 반복.

- **공개 seam 에서 관찰한다.** 위젯의 속성을 읽지 말고, 그 위젯이 만들어내는 관측 가능한 사실을 읽는다. 실증(#18): 12 개 테스트가 `ScaleTransition.alignment` 를 단언했다. 구현을 커스텀 렌더 오브젝트로 바꾸자 **관측 가능한 동작은 하나도 안 바뀌었는데 12 개가 전부 깨졌다** — implementation-coupled 의 교과서적 증상이다. seam 을 *"메뉴가 어느 점을 고정한 채 자라는가"* 로 다시 긋고, 뒤집힌 4 방향까지 덮었다.
- **RED 가 정말 RED 인지 본다.** 실증(#8): unmount context 에 `throwsA(isA<FlutterError>())` 를 단언하면 **처음부터 초록불**이다 — Flutter 가 이미 `FlutterError` 를 던지니까. 메시지가 `showOverlayMenu` 를 지목하는지를 요구해야 red 가 됐다.
- **규칙을 어겼으면 되돌린다.** 실증(#8): red 없이 가드 두 개를 한 번에 넣었다가, 두 번째를 되돌리고 red 부터 다시 했다. TDD 의 가치는 코드가 아니라 "이 테스트가 정말 실패하는가" 를 보는 순간에 있다.

### 5. 테스트 신뢰 게이트 — 두 질문은 다르다

- **구분력이 있는가.** 통과하는 테스트는 그 자체로 아무것도 증명하지 않는다.
  - 실증(#7): Dart 는 동일 인자의 `const` 값을 **같은 인스턴스로 정규화**한다. `const a == const b` 는 `operator ==` 가 없어도 identity 로 통과한다. 모든 동등성 테스트는 값을 런타임에 만들고 `expect(identical(a, b), isFalse)` 를 **먼저** 단언한다.
  - 실증(#18): 원점 고정 테스트 16 개는 메뉴가 실제로 커졌는지 확인하지 않으면, 샘플링이 망가져 scale 이 1 로 고정돼도 전부 통과한다. `_expectItGrew` 가드를 넣었다.
- **옳은 이유로 통과하는가.** 부수 조건까지 단언해 우연한 순서로 통과할 수 없게 만든다.
- **커버리지는 "무엇을 안 봤는지" 를 알려주지, "본 것이 옳은지" 는 말해주지 않는다.**
  - 실증(#7): `copyWith` 의 `x ?? this.x` 에서 **오른쪽 피연산자가 한 번도 평가되지 않았다** — 각 필드를 *교체할 때만* 테스트하고 *보존할 때는* 안 했다. 인자 없는 `copyWith()` 가 원본과 동등해야 한다는 속성 하나로 네 클래스를 덮었다.
  - 실증(#18): `lib/` 가 100% 인 상태에서도 scale 원점 버그는 멀쩡히 살아 있었다. 그 줄들은 *실행*되지만 *검증*되지 않았을 뿐이다.

### 6. `/code-review`

구현·테스트가 끝나고 릴리스 전에 돌린다. 지적은 고치거나, 안 고치면 *왜 안 고치는지*를 남긴다.

### 7. 정합성 스윕 — 동작을 기술하는 모든 표면

코드만 고치고 끝나는 변경은 없다. 아무도 안 보므로 **명시적으로 훑는다**.

- **`CHANGELOG.md`** — pub.dev 는 *발행 시점의* CHANGELOG 를 스냅샷으로 박는다. 이미 발행된 버전의 항목을 고치지 말고 새 버전을 연다. 실증(1.0.0): CHANGELOG 의 1.0.0 절이 네 개의 사용자 가시 변화(`initialValue` 중앙 정렬 수정·anchor context 가드·값 의미론·`TickerCanceled` 제거)보다 먼저 쓰였고, 게시 직전에야 맞췄다.
- **`README.md`** — 실증(1.0.0): `copyWith` 가 새 그룹 3 개에만 있다고 적혀 있었고(실제로는 7 개 클래스 전부), `showOverlayMenu` 가 `FlutterError` 를 던진다는 사실과 반환값이 Close 요청 시점에 확정된다는 사실은 어디에도 없었다.
- **`docs/adr/`** — 결정이 뒤집히면 ADR 도 뒤집는다. 실증(#9): ADR-0002 가 `TickerCanceled` catch 를 *"살아있는 유의미한 가드"* 로 기록하고 있었는데, 그 catch 는 도달 불가로 증명돼 삭제됐다. ADR 의 Consequences 를 진실로 고쳤다.
- **`CONTEXT.md` 용어집** — 도메인 용어의 source of truth. 용어집이 개념을 덜 정의하면 코드가 그 빈칸을 임의로 채운다. 실증(1.0.0): **Close** 가 "결과를 전달한다" 고만 말하고 *언제* 결과가 정해지는지 침묵했다 — 그 침묵이 결과 유실 버그 두 개가 살던 자리였다. *Animated Close* / *Instant Close* / *Open Menu Registry* 를 추가했다.
- **`.pubignore`** — `.pubignore` 가 존재하면 pub 은 **git 기반 파일 목록을 끈다.** `.gitignore` 는 더 이상 적용되지 않는다. 실증(1.0.0 게시 직전): `coverage/` 가 `.gitignore:31` 에 있는데도 아카이브에 실려 나가고 있었다. `build/`·`.dart_tool/` 은 이미 명시돼 있었으나 CI 가 만든 새 디렉터리를 아무도 추가하지 않았다. **pub.dev 아카이브는 한 번 올라가면 내릴 수 없다.**
- **낡은 근거 회수** — 연속 PR 에서 앞선 이슈·PR·ADR 에 적은 근거가 뒤 작업에 의해 거짓이 된다.

### 8. 게이트 & PR & 릴리스

게이트 전부 — CI(`.github/workflows/ci.yml`)가 매 PR 에서 이 순서로 돌린다:

```
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos --fatal-warnings
flutter test --coverage
dart run tool/check_coverage.dart --min 100 --report
```

- **포맷 검사는 `pub get` 뒤여야 한다.** `dart format` 은 `.dart_tool/package_config.json` 에서 언어 버전을 읽고, Dart 3.7 의 tall style 은 언어 버전 3.7+ 에서만 적용된다. 이 패키지는 `sdk: ">=3.0.0"` 이라 구 스타일이지만, 패키지 설정이 없으면 포매터가 최신 버전을 가정해 레포 전체를 재포맷한다. 실증: 깨끗한 `git worktree` 에서 `pub get` 없이 돌리면 14 개 파일 changed·exit 1, `pub get` 후엔 exit 0. 로컬엔 `.dart_tool` 이 항상 있어 절대 재현되지 않는다.
- **커버리지 바닥은 100 이다.** 여유를 두면 딱 그 여유만큼의 회귀를 허용하고, 실제 회귀는 임계값 근처에 앉는다. 실증: `test/menu_chrome_test.dart` 를 통째로 지우면 정확히 **99.0%** (518/523) — 바닥이 99 였다면 `99.0 < 99.0` 이 거짓이라 그대로 통과했다. 실증(#18): 새 렌더 오브젝트가 미커버 3 줄(호출되지 않는 `updateRenderObject`)을 달고 들어왔고 게이트가 잡았다.
- **덮을 수 없는 줄은 `// coverage:ignore-start` / `ignore-end` 로 감싼다.** 그 줄들은 미커버로 세는 게 아니라 **분모에서 빠진다**(실증: 프로브에서 `LF` 14 → 15, ignore 로 감싼 줄은 리포트에 없음). 예외가 조용한 침식이 아니라 diff 에 남는 명시적 편집이 된다.
- **릴리스 전 `flutter pub publish --dry-run` 이 경고 0 개**여야 하고, 아카이브에 `build/`·`.dart_tool/`·`coverage/`·`docs/`·`tool/`·`.github/` 가 없어야 한다(Step 7 의 `.pubignore` 항목).
- **태그는 커밋을 가리키는 불변 포인터다.** 문서까지 다 들어간 뒤에 단다. 발행되지 않은 태그를 옮기는 비용은 0 이다 — 실증(1.0.0): 태그와 GitHub 릴리스가 이미 원격에 있었으나 릴리스에 첨부 파일이 0 개였고 `dry-run` 이 `The previous version is 0.7.0` 이라고 알려줬다(= pub.dev 는 1.0.0 을 모른다). 1.0.1 로 도망가면 0.7.0 과 첫 공개 릴리스 사이에 이유 없는 구멍이 남는다. 태그를 옮겼다.
- 브랜치 → `fix(<scope>): …` → PR(`Closes #issue`) → CI 그린 확인 → 머지.
- **`flutter pub publish` 는 되돌릴 수 없고 pub.dev 는 버전 삭제가 없다(retract 만). 에이전트가 실행하지 않는다 — 사용자가 직접.**
