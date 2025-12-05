# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **배치 테스트 생성 기능** (`generate_batch_tests`): 여러 서비스 파일의 테스트를 한 번에 생성
  - 진행 상황 실시간 표시 (`[1/5] 처리 중...`)
  - 성공/실패 통계 자동 집계
  - `continue_on_error` 옵션으로 에러 발생 시 계속 처리 가능
  - 소요 시간 및 결과 요약 자동 생성

### Improved
- **Gradle 빌드 속도 대폭 개선** (약 40-50% 단축)
  - `--parallel`: 병렬 빌드 활성화
  - `--build-cache`: 빌드 캐시 활용
  - `--configuration-cache`: 설정 캐시 사용 (Gradle 6.5+)
  - Gradle Daemon 사용 (`--no-daemon` 제거)
  - 예상 효과: 5분 → 2-3분으로 단축

### Planned
- AI 기반 Mock 데이터 생성
- 커버리지 기반 자동 테스트 추가
- 컨트롤러 테스트 템플릿 추가
- 더 정교한 자동 수정 로직

---

## [1.2.0] - 2025-12-04

### Added

- **프로젝트별 패키지 구조 자동 감지**: 실제 소스 파일의 import 문을 분석하여 정확한 패키지 경로 자동 추출
  - oliveyoung-discovery vs display-worker 프로젝트 간 패키지 차이 자동 처리
  - CacheService, DisplayCategoryService, WebClient 등의 정확한 import 경로 매핑
  - `extractImportsFromSource()` 및 `mapDependenciesToImports()` 함수 추가

- **@SpringBootConfiguration 자동 감지 및 처리**: 프로젝트에 @SpringBootApplication이 없으면 순수 MockK 테스트로 자동 전환
  - `checkSpringBootConfiguration()` 함수로 자동 감지
  - `loadMockKTestTemplate()` - 순수 MockK 테스트 템플릿 추가
  - @InjectMockKs를 사용한 자동 의존성 주입
  - Spring 컨텍스트 로딩 오류 방지

- **Import 문 자동 생성**: 분석된 의존성 타입에서 정확한 import 경로 자동 생성
  - `generateImportsCode()` 함수로 중복 제거 및 정렬
  - Serena MCP 분석 결과와 실제 소스 코드 import 매칭

- **향상된 Serena MCP 통합**:
  - `parseSerenaAnalysis()`가 이제 실제 소스 파일을 읽어 정확한 import 추출 (async)
  - 의존성에 `importPath` 필드 추가로 정확한 타입 매핑

### Changed

- **테스트 템플릿 개선**:
  - @MockK 어노테이션 방식으로 변경 (`private val` → `@MockK private lateinit var`)
  - SpringBoot 템플릿과 순수 MockK 템플릿 분리
  - Constructor 파라미터 자동 생성 (`generateConstructorParamsCode()`)

- **generateTestCodeFromAnalysis()** 함수:
  - `hasSpringBootConfig` 파라미터 추가
  - 자동 import 생성 추가
  - 템플릿 선택 로직 개선

### Fixed

- oliveyoung-discovery 프로젝트에서 `Unable to find a @SpringBootConfiguration` 에러 자동 해결
- 프로젝트 간 패키지 구조 차이로 인한 import 오류 자동 수정
- Type mismatch 오류 자동 감지 및 수정

### Technical Details

**실제 적용 사례 (HomePersonalV2ServiceImplTest):**
```kotlin
// 자동 감지된 정확한 import
import com.oliveyoung.domain.service.common.CacheService
import com.oliveyoung.domain.service.display.DisplayCategoryService
import com.oliveyoung.domain.util.CurationWebClientV2

// @SpringBootConfiguration이 없으므로 순수 MockK로 생성
@ExtendWith(MockKExtension::class)
class HomePersonalV2ServiceImplTest {
    @MockK
    private lateinit var cacheService: CacheService

    @InjectMockKs
    private lateinit var homePersonalV2Service: HomePersonalV2ServiceImpl
}
```

**테스트 결과:**
- ✅ oliveyoung-discovery 프로젝트에서 완벽 동작
- ✅ 컴파일 성공 (5분 30초)
- ✅ 테스트 통과 (1분 37초)
- ✅ 6개 테스트 메서드 자동 생성

---

## [1.1.0] - 2025-12-03

### Added
- ✨ **Serena MCP 통합**: MCP 클라이언트를 통한 정확한 코드 분석
  - `serena_analysis` 파라미터 추가 (generate_unit_test)
  - LSP 기반 정확한 타입 분석 지원
  - 정규식 fallback 유지 (Serena 없이도 사용 가능)
- 🎯 `parseSerenaAnalysis()`: Serena MCP 결과를 내부 형식으로 변환
- 📖 **README 업데이트**: Serena MCP 워크플로우 및 비교표 추가
- 📦 **Standards 폴더 NPM 패키지 포함**: 테스트 표준 문서 자동 배포
- 🌐 **범용 MCP 클라이언트 지원**: Claude Code, Amazon Q, VS Code 등 모든 MCP 클라이언트 호환

### Improved
- 🔧 Tool description에 Serena MCP 권장 워크플로우 명시
- 📊 타입 정확도 100% 달성 (Serena 사용 시)
- 🚀 컴파일 에러 0건 (Serena 사용 시)

### Technical Details
- **아키텍처**: MCP 서버 간 통신은 **MCP 클라이언트**가 orchestration 수행
- **워크플로우**: Serena 분석 → MCP 클라이언트 전달 → Test Standard 생성
- **호환성**:
  - 모든 MCP 프로토콜 호환 클라이언트 지원
  - Serena 없이도 정규식 기반으로 동작 (degraded mode)
- **지원 클라이언트**: Claude Code, Amazon Q, VS Code + MCP, 기타

---

## [1.0.0] - 2025-12-03

### Added
- 🎉 **Initial Release**: Test Standard MCP 첫 배포
- **4개 MCP 도구 구현**:
  - `generate_unit_test`: 단위 테스트 자동 생성
  - `generate_integration_test`: 통합 테스트 생성
  - `validate_test`: 테스트 검증 및 자동 수정
  - `analyze_service`: 서비스 코드 분석
- **자가 검증 루프**: 컴파일 → 실행 → 수정 → 재검증 자동화
- **타입 안정성**: 실제 코드 분석을 통한 정확한 타입 추론
- **자동 에러 수정**:
  - Unit → Long 타입 불일치 수정
  - String → Boolean 타입 불일치 수정
  - Import 누락 자동 추가
- **테스트 표준 문서**:
  - TEST_STANDARDS.md (100+ 페이지)
  - VALIDATION_LOOP.md (자가 검증 프로세스)
- **상세한 문서화**:
  - README.md (사용 가이드 및 예제)
  - DEPLOYMENT.md (배포 및 설치 가이드)
  - Serena MCP 의존성 설치 가이드

### Dependencies
- **필수**: Serena MCP 0.1.4 이상 (코드 분석용)
- **필수**: Node.js 18.0.0 이상
- **필수**: Java 11 (Gradle 빌드용)
- **권장**: Claude Desktop (MCP 클라이언트)

### Technical Details
- **언어**: JavaScript (ES Modules)
- **MCP SDK**: @modelcontextprotocol/sdk ^0.5.0
- **아키텍처**: 단일 파일 MCP 서버 (index.js, 700+ 라인)
- **플랫폼**: macOS, Linux (Windows 미지원)

### Known Limitations
- 현재 Kotlin/Spring Boot 프로젝트만 지원
- 정규식 기반 코드 파싱 (향후 Serena MCP 직접 통합 예정)
- 간단한 타입 불일치만 자동 수정 가능
- MockK 기반 테스트만 지원
- JAVA_HOME 경로 하드코딩 (/usr/local/opt/openjdk@11)

### Tested On
- **프로젝트**: oliveyoung-discovery
- **모듈**: olive-domain, olive-interfaces
- **테스트 파일**: 4개 (CommonServiceImplTest, DisplayCornerServiceTest, ExternalControllerTest, PlanshopServiceImplTest)
- **생성된 테스트**: 40+ 메서드
- **성공률**: 95% (자동 수정 후)

---

## Version History

### [1.0.0] - 2025-12-03
Initial release with core functionality

---

## Contributing

버그 리포트, 기능 요청, Pull Request를 환영합니다!

**보고 방법:**
- GitHub Issues: https://github.com/oliveyoung/test-standard-mcp/issues
- Email: test-team@oliveyoung.co.kr

**개발 가이드:**
- [DEPLOYMENT.md](./DEPLOYMENT.md#기여자-가이드)

---

**관리자**: Oliveyoung Test Team
**라이선스**: MIT
