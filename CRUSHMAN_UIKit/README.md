# CRUSHMAN (UIKit)

이모지 하나 + 한 줄 메모로 오늘 기분을 기록하는 iOS 앱.
**UIKit + SwiftData** (프로그래매틱 UI, 스토리보드 없음).

## 여는 법

맥에서 `CRUSHMAN_UIKit.xcodeproj`를 더블클릭해 Xcode로 열고 ⌘R.

- 서명(Signing) 탭에서 본인 **Team**을 선택하세요 (프로젝트에는 팀이 비워져 있음).
- 최소 배포 버전: **iOS 17.0**.
- **햅틱은 시뮬레이터에서 동작하지 않으므로 실기기로 확인**할 것.

> 이 프로젝트는 최신 Xcode의 폴더 동기화(PBXFileSystemSynchronizedRootGroup)
> 방식이라, `CRUSHMAN_UIKit/` 폴더에 파일을 넣으면 자동으로 타깃에 포함됩니다.

## 구조

```
CRUSHMAN_UIKit.xcodeproj            프로젝트 파일
CRUSHMAN_UIKit/
  AppDelegate.swift                 앱 진입점 + 공유 ModelContainer + Scene 설정
  SceneDelegate.swift               window 생성 + RootTabBarController 주입
  Models/Mood.swift                 고정 이모지 8종 프리셋
  Models/MoodEntry.swift            @Model — day(자정 정규화) / emoji / note
  Views/RootTabBarController.swift  탭 2개 (오늘, 기록)
  Views/TodayViewController.swift   이모지 그리드(UICollectionView) + 메모, 탭 즉시 저장
  Views/EmojiCell.swift             선택 시 확대 애니메이션 셀
  Views/HistoryViewController.swift 날짜 역순 UITableView, 스와이프 삭제
  Support/Haptics.swift             select() / saved()
  Assets.xcassets                   AppIcon / AccentColor
```

## 설계 결정

- **하루 1건.** 같은 날 다른 이모지를 탭하면 덮어쓴다. `day`를 `startOfDay`로 저장해
  `FetchDescriptor(predicate: #Predicate { $0.day == today })` 로 조회한다.
- **이모지 탭 = 즉시 저장.** 저장 버튼이 없다. 메모는 선택이며 편집 종료 시 저장된다.
- **선택지 8개 고정.** 자유 이모지 입력은 결정 부담을 늘려 "진입 장벽이 낮다"는 목표와 충돌한다.
- **SwiftData 유지.** UI만 UIKit로 바꾸고 저장 계층은 그대로. `@Query`(SwiftUI 전용) 대신
  `ModelContext` + `FetchDescriptor`로 직접 조회/저장한다.
- **스토리보드 없음.** 화면은 전부 코드로 구성하고, Scene은 AppDelegate의
  `configurationForConnecting`에서 `SceneDelegate`를 코드로 지정한다.

## 자정 넘김 처리

`TodayViewController`는 `today`를 프로퍼티로 들고 날짜가 바뀌면 predicate를 새로 만들어
다시 조회한다. 두 경우를 모두 관찰한다:

- `.NSCalendarDayChanged` — 앱을 켜 둔 채 자정을 넘긴 경우
- `UIApplication.didBecomeActiveNotification` — 백그라운드에 있다가 다음 날 다시 연 경우

## 다음 단계

- 캘린더 그리드(월별 히트맵) 뷰
- 기록 알림(로컬 푸시)
- 위젯
