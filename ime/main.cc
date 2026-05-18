#define WIN32_LEAN_AND_MEAN
#include <windows.h>

#include <cstdlib>
#include <iostream>
#include <optional>
#include <string>
#include <string_view>

namespace
{
    constexpr UINT ImectlMessage = WM_APP + 0x1;
    constexpr wchar_t AhkWindowClass[] = L"AutoHotkeyGUI";
    constexpr wchar_t AhkWindowTitle[] = L"IMEControllerAHK";

    enum class Command : WPARAM
    {
        Off = 0,
        On = 1,
    };

    enum class ExitCode : int
    {
        Success = 0,
        RuntimeError = 1,
        UsageError = 2,
    };

    void print_usage()
    {
        std::cerr << "usage: ime on|off\n";
    }

    std::optional<Command> parse_command(std::string_view arg)
    {
        if (arg == "on")
        {
            return Command::On;
        }

        if (arg == "off")
        {
            return Command::Off;
        }

        return std::nullopt;
    }

    std::string format_win32_error(DWORD error_code)
    {
        LPSTR buffer = nullptr;

        const DWORD length = FormatMessageA(
            FORMAT_MESSAGE_ALLOCATE_BUFFER |
                FORMAT_MESSAGE_FROM_SYSTEM |
                FORMAT_MESSAGE_IGNORE_INSERTS,
            nullptr,
            error_code,
            MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
            reinterpret_cast<LPSTR>(&buffer),
            0,
            nullptr);

        if (length == 0 || buffer == nullptr)
        {
            return "unknown error";
        }

        std::string message(buffer, length);
        LocalFree(buffer);

        while (!message.empty() &&
               (message.back() == '\n' || message.back() == '\r'))
        {
            message.pop_back();
        }

        return message;
    }

    HWND find_ahk_window()
    {
        return FindWindowW(AhkWindowClass, AhkWindowTitle);
    }

    bool post_ime_command(HWND hwnd, Command command)
    {
        return PostMessageW(
                   hwnd,
                   ImectlMessage,
                   static_cast<WPARAM>(command),
                   0) != FALSE;
    }
}

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        print_usage();
        return static_cast<int>(ExitCode::UsageError);
    }

    const auto command = parse_command(argv[1]);

    if (!command)
    {
        std::cerr << "unknown command: " << argv[1] << '\n';
        print_usage();
        return static_cast<int>(ExitCode::UsageError);
    }

    const HWND hwnd = find_ahk_window();

    if (hwnd == nullptr)
    {
        std::cerr << "IMEControllerAHK not found\n";
        return static_cast<int>(ExitCode::RuntimeError);
    }

    if (!post_ime_command(hwnd, *command))
    {
        const DWORD error = GetLastError();

        std::cerr << "PostMessageW failed. "
                  << "GetLastError=" << error
                  << " (" << format_win32_error(error) << ")\n";

        return static_cast<int>(ExitCode::RuntimeError);
    }

    return static_cast<int>(ExitCode::Success);
}
