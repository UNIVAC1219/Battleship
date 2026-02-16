@echo off
REM Build script for Battleship Game - Intermediate AI
REM Unified script for MSVC and MinGW compilation
REM Supports cross-compilation for UNIVAC 1219 compatibility

echo.
echo ========================================
echo   Battleship - Unified Build Script
echo ========================================
echo.

set COMPILER=
set UNIVAC_BUILD=

REM ============================================================================
REM STEP 1: SELECT PLATFORM
REM ============================================================================
set PLATFORM=
echo Please select target platform:
echo   Press ENTER or 1 for Windows
echo   Press 2 for UNIVAC (cross-compile)
echo.
set /p PLATFORM="Enter your choice (default: Windows): "

if "%PLATFORM%"=="" set PLATFORM=1
if "%PLATFORM%"=="1" goto SELECT_COMPILER
if "%PLATFORM%"=="2" (
    set COMPILER=1
    set UNIVAC_BUILD=1
    goto UNIVAC_BUILD
)
echo Invalid choice. Defaulting to Windows.
set PLATFORM=1

REM ============================================================================
REM STEP 2: SELECT COMPILER (Windows only)
REM ============================================================================
:SELECT_COMPILER
echo.
echo Please select your compiler:
echo   Press ENTER or 1 for MinGW
echo   Press 2 for MSVC
echo.
set /p COMPILER="Enter your choice (default: MinGW): "

if "%COMPILER%"=="" set COMPILER=1
if "%COMPILER%"=="1" goto MINGW_BUILD
if "%COMPILER%"=="2" goto MSVC_BUILD
echo Invalid choice. Defaulting to MinGW.
set COMPILER=1

REM Jump to the selected compiler build
goto MINGW_BUILD

REM ============================================================================
REM UNIVAC BUILD (Cross-compile with -DUNIVAC flag)
REM ============================================================================
:UNIVAC_BUILD
echo.
REM Check if gcc is available
where gcc >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: GCC not found in PATH
    echo Please install MinGW-w64 or your cross-compiler toolchain
    pause
    exit /b 1
)

echo Compiler: GCC with UNIVAC flag
gcc --version | findstr "gcc"
echo.

REM Clean previous build artifacts
echo Cleaning previous build artifacts...
if exist battleship_univac.exe del /Q battleship_univac.exe
if exist battleship_univac.o del /Q battleship_univac.o
if exist *.o del /Q *.o
echo.

echo Building for UNIVAC platform...
echo Compiler: GCC
echo Platform Flags: -DUNIVAC
echo.

echo Compiling battleship...
gcc -c -DUNIVAC -O2 -Wall -Wextra -std=c99 main.c -o main.o
gcc -c -DUNIVAC -O2 -Wall -Wextra -std=c99 battlefield.c -o battlefield.o
gcc -c -DUNIVAC -O2 -Wall -Wextra -std=c99 ship.c -o ship.o
gcc -c -DUNIVAC -O2 -Wall -Wextra -std=c99 player.c -o player.o
gcc -c -DUNIVAC -O2 -Wall -Wextra -std=c99 ai_engine.c -o ai_engine.o
gcc -c -DUNIVAC -O2 -Wall -Wextra -std=c99 utils.c -o utils.o

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to compile source files
    pause
    exit /b 1
)

echo Linking...
gcc -o battleship_univac.exe main.o battlefield.o ship.o player.o ai_engine.o utils.o -lm

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo   BUILD SUCCESSFUL - UNIVAC
    echo ========================================
    echo.
    echo Output: battleship_univac.exe

    REM Display file size
    for %%A in (battleship_univac.exe) do (
        echo File size: %%~zA bytes
    )
    echo.
    echo Platform: UNIVAC (cross-compiled with -DUNIVAC)
    echo.
    echo NOTE: This executable is built for UNIVAC compatibility:
    echo   - No Windows dependencies (windows.h limited)
    echo   - XorShift RNG seeded with time(0)
    echo   - Uses strncpy instead of strcpy_s
    echo   - Minimal memory footprint
    echo.
    echo To run the game, type: battleship_univac.exe
    echo.
    goto :EOF
) else (
    echo.
    echo ========================================
    echo   BUILD FAILED
    echo ========================================
    echo.
    echo Check the error messages above.
    pause
    exit /b 1
)

exit /b 0

REM ============================================================================
REM MINGW BUILD
REM ============================================================================
:MINGW_BUILD
echo.
REM Check if gcc is available
where gcc >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: MinGW GCC not found in PATH
    echo Please install MinGW-w64 and add it to your PATH
    echo Download from: https://www.mingw-w64.org/
    pause
    exit /b 1
)

echo Compiler: MinGW GCC
gcc --version | findstr "gcc"
echo.

REM Clean previous build artifacts
echo Cleaning previous build artifacts...
if exist battleship_mingw.exe del /Q battleship_mingw.exe
if exist battleship.obj del /Q battleship.obj
if exist *.o del /Q *.o
echo.

REM ============================================================================
REM AGGRESSIVE OPTIMIZATION FLAGS
REM ============================================================================
REM -O3              : Maximum optimization level
REM -march=native    : Optimize for current CPU architecture
REM -mtune=native    : Tune code for current CPU
REM -flto            : Link-Time Optimization (whole program optimization)
REM -ffast-math      : Aggressive floating-point optimizations
REM -funroll-loops   : Unroll loops for better performance
REM -finline-functions : Inline functions aggressively
REM -fomit-frame-pointer : Remove frame pointer for faster function calls
REM -fno-stack-protector : Remove stack protection overhead
REM -fmerge-all-constants : Merge identical constants
REM -ftree-vectorize : Auto-vectorization of loops
REM -fprefetch-loop-arrays : Generate prefetch instructions
REM -msse4.2         : Use SSE 4.2 instructions
REM ============================================================================

set OPTIMIZE_FLAGS=-O3 -march=native -mtune=native -flto -ffast-math -funroll-loops -finline-functions -fomit-frame-pointer -fno-stack-protector -fmerge-all-constants -ftree-vectorize -fprefetch-loop-arrays -msse4.2

REM Warning flags (keep for code quality)
set WARNING_FLAGS=-Wall -Wextra -Wno-unused-parameter -std=c99

REM Additional performance flags
set PERF_FLAGS=-DNDEBUG -pipe

REM Linker optimization flags
set LINKER_FLAGS=-s -static -Wl,--gc-sections -Wl,--strip-all -Wl,-O3

echo Building with aggressive optimizations...
echo Compiler: MinGW GCC
echo Flags: %OPTIMIZE_FLAGS%
echo.

echo Compiling and linking...
gcc %WARNING_FLAGS% %OPTIMIZE_FLAGS% %PERF_FLAGS% ^
    -o battleship_mingw.exe ^
    main.c battlefield.c ship.c player.c ai_engine.c utils.c ^
    %LINKER_FLAGS% -lm

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo   BUILD SUCCESSFUL
    echo ========================================
    echo.
    echo Output: battleship_mingw.exe

    REM Display file size
    for %%A in (battleship_mingw.exe) do (
        echo File size: %%~zA bytes
    )
    echo.
    echo Optimization level: MAXIMUM (-O3 + LTO + native CPU^)
    echo.
    echo To run the game, type: battleship_mingw.exe
    echo.
    %LINKER_FLAGS% -lm

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo   BUILD SUCCESSFUL
    echo ========================================
    echo.
    echo Output: battleship_mingw.exe

    REM Display file size
    for %%A in (battleship_mingw.exe) do (
        echo File size: %%~zA bytes
    )
    echo.
    echo Optimization level: MAXIMUM (-O3 + LTO + native CPU^)
    echo.
    echo To run the database, type: battleship_mingw.exe
    echo.
) else (
    echo.
    echo ========================================
    echo   BUILD FAILED
    echo ========================================
    echo.
    echo Check the error messages above.
    pause
    exit /b 1
)

exit /b 0

REM ============================================================================
REM MSVC BUILD
REM ============================================================================
:MSVC_BUILD
echo.
REM Set up Visual Studio Developer Command Prompt environment
REM Try common Visual Studio 2022 installation paths
if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat" (
    call "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat" -no_logo
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\Tools\VsDevCmd.bat" (
    call "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\Tools\VsDevCmd.bat" -no_logo
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\VsDevCmd.bat" (
    call "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\VsDevCmd.bat" -no_logo
) else (
    echo Error: Could not find Visual Studio 2022 installation.
    echo Please ensure Visual Studio 2022 is installed.
    pause
    exit /b 1
)

echo.
echo Compiler: MSVC (Visual Studio 2022)
echo Compiling with MSVC...
echo.

REM MSVC Optimization flags
REM /O2     : Maximum optimization (speed)
REM /Ox     : Maximum optimization 
REM /Ob2    : Inline function expansion
REM /Oi     : Enable intrinsic functions
REM /Ot     : Favor speed over size
REM /Oy     : Omit frame pointers
REM /GL     : Whole program optimization
REM /LTCG   : Link-time code generation
REM /arch:AVX2 : Use AVX2 instructions

set MSVC_OPTIMIZE=/O2 /Ox /Ob2 /Oi /Ot /Oy /GL /arch:AVX2
set MSVC_LINKER=/LTCG /OPT:REF /OPT:ICF

REM Compile source file with maximum optimizations
cl /W4 %MSVC_OPTIMIZE% /Fe:battleship.exe main.c battlefield.c ship.c player.c ai_engine.c utils.c /link %MSVC_LINKER%

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo   BUILD SUCCESSFUL
    echo ========================================
    echo.
    echo Output: battleship.exe

    REM Display file size
    for %%A in (battleship.exe) do (
        echo File size: %%~zA bytes
    )
    echo.
    echo Optimization level: MAXIMUM (MSVC /O2 + Whole Program Optimization^)
    echo.
    echo To run the game, type: battleship.exe
    echo.
) else (
    echo.
    echo ========================================
    echo   BUILD FAILED
    echo ========================================
    echo.
    echo Check the error messages above for details.
    pause
    exit /b 1
)

exit /b 0

REM ============================================================================
REM ADDITIONAL BUILD OPTIONS
REM ============================================================================
REM
REM For debugging builds, you can manually run:
REM   gcc -g -O0 -DDEBUG -Wall -Wextra main.c battlefield.c ship.c player.c ai_engine.c utils.c -o battleship_debug.exe -lm
REM
REM For profile-guided optimization with GCC:
REM   Step 1: gcc -O3 -fprofile-generate main.c battlefield.c ship.c player.c ai_engine.c utils.c -o battleship_pgo.exe -lm
REM   Step 2: Run battleship_pgo.exe with typical usage patterns
REM   Step 3: gcc -O3 -fprofile-use main.c battlefield.c ship.c player.c ai_engine.c utils.c -o battleship_optimized.exe -lm
REM
REM For static analysis:
REM   gcc -Wall -Wextra -Wpedantic -Wformat=2 -Wconversion main.c battlefield.c ship.c player.c ai_engine.c utils.c -lm
REM
REM ============================================================================
