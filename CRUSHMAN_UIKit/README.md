# CRUSHMAN — 오늘의 기분 이미지 일기

이모지 하나 + 한 줄 메모로 오늘 기분을 기록하는 iOS 앱.
**UIKit + SwiftData** (프로그래매틱 UI, 스토리보드 없음).

## 맥에서 세팅하는 법

1. Xcode → **File ▸ New ▸ Project ▸ iOS ▸ App**
   - Product Name: `CRUSHMAN`
   - Interface: **Storyboard** (UIKit 라이프사이클 생성용)
   - Language: **Swift**
   - Minimum Deployment: **iOS 17.0** 이상
2. Xcode가 자동 생성한 `AppDelegate.swift`, `SceneDelegate.swift`,
   `ViewController.swift`, `Main.storyboard`는 **삭제**.
3. 이 폴더의 `AppDelegate.swift` / `SceneDelegate.swift` / `Models` / `Views` /
   `Support`를 프로젝트 네비게이터로 드래그
   (Copy items if needed 체크, Create groups 선택).
4. **Info.plist 정리** — 스토리보드를 지웠으므로:
   - `UIApplicationSceneManifest ▸ ... ▸ Storyboard Name` 항목 삭제
   - Target ▸ General ▸ **Main Interface** 값 비우기
   - (Scene 설정은 `AppDelegate.configurationForConnecting`에서 코드로 지정)
5. ⌘R 로 시뮬레이터 실행. **햅틱은 시뮬레이터에서 동작하지 않으므로 실기기로 확인**할 것.

## 구조

```
AppDelegate.swift              앱 진입점 + 공유 ModelContainer + Scene 설정
SceneDelegate.swift            window 생성 + RootTabBarController 주입
Models/Mood.swift              고정 이모지 8종 프리셋
Models/MoodEntry.swift         @Model — day(자정 정규화) / emoji / note
Views/RootTabBarController.swift  탭 2개 (오늘, 기록)
Views/TodayViewController.swift   이모지 그리드(UICollectionView) + 메모, 탭 즉시 저장
Views/EmojiCell.swift          선택 시 확대 애니메이션 셀
Views/HistoryViewController.swift 날짜 역순 UITableView, 스와이프 삭제
Support/Haptics.swift          select() / saved()
```

## 설계 결정

- **하루 1건.** 같은 날 다른 이모지를 탭하면 덮어쓴다. `day`를 `startOfDay`로 저장해
  `FetchDescriptor(predicate: #Predicate { $0.day == today })` 로 조회한다.
- **이모지 탭 = 즉시 저장.** 저장 버튼이 없다. 메모는 선택이며 편집 종료 시 저장된다.
- **선택지 8개 고정.** 자유 이모지 입력은 결정 부담을 늘려 "진입 장벽이 낮다"는 목표와 충돌한다.
- **SwiftData 유지.** UI만 UIKit로 바꾸고 저장 계층은 그대로 둔다. `@Query`(SwiftUI 전용)
  대신 `ModelContext` + `FetchDescriptor`로 직접 조회/저장한다.

## 자정 넘김 처리 (해결됨)

`TodayViewController`는 `today`를 프로퍼티로 들고, 날짜가 바뀌면 predicate를 새로
만들어 다시 조회한다. 두 경우를 모두 관찰한다:

- `.NSCalendarDayChanged` — 앱을 **켜 둔 채** 자정을 넘긴 경우
- `UIApplication.didBecomeActiveNotification` — 백그라운드에 있다가 **다음 날 다시 연**
  경우 (이땐 dayChanged가 안 올 수 있음)

## 다음 단계

- 캘린더 그리드(월별 히트맵) 뷰
- 기록 알림(로컬 푸시)
- 위젯
