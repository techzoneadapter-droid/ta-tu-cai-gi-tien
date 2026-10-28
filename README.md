# Thiên Đạo Viết Lại — Thanh Khê Demo

Bản chơi thử **2D Thanh Khê** viết bằng **Godot 4.6**. Chơi đơn trên Windows x64, đồ họa hiện tại vẽ bằng mã nguồn gốc để thử gameplay, chưa phải mỹ thuật cuối cùng. Không sử dụng mã hay tài sản Ngọc Rồng Online/Ninja School.

## Tải và cập nhật Windows

**[TẢI LAUNCHER WINDOWS (mở một lần, tự cập nhật game)](https://github.com/techzoneadapter-droid/ta-tu-cai-gi-tien/releases/latest/download/ThanhKhe_Launcher.exe)**

Nếu đường tải trực tiếp báo lỗi, vào [**GitHub Releases — bản mới nhất**](https://github.com/techzoneadapter-droid/ta-tu-cai-gi-tien/releases/latest) rồi chọn **ThanhKhe_Launcher.exe** trong phần Assets.

1. Tải `ThanhKhe_Launcher.exe` về Windows 64-bit và mở.
2. Lần đầu cần Internet. Launcher kiểm tra bản mới trên GitHub Releases, tải game vào `%LOCALAPPDATA%\ThienDaoVietLai\ThanhKhe`, kiểm SHA-256 và cài đặt.
3. Nhấn **VÀO GAME**.
4. Những lần sau **mở lại launcher đã tải**. Launcher tự kiểm tra, nếu có bản mới sẽ tải/cài đè phiên bản game trước; không cần tải lại launcher từ chat.

Nếu không có mạng nhưng đã cài game hợp lệ, launcher cho chơi offline. Tệp game tải trực tiếp [ThanhKhe_Game.exe](https://github.com/techzoneadapter-droid/ta-tu-cai-gi-tien/releases/latest/download/ThanhKhe_Game.exe) **không có chức năng tự cập nhật**, nên khuyên dùng launcher.

**Lưu ý:** Bản demo chưa được ký mã số; Windows SmartScreen có thể hiển thị cảnh báo. Chỉ tải từ repository bạn tin cậy. Không cần chạy Administrator. Launcher hiện tải trọn file game khi có bản mới (không phải delta patch), nhưng tự động hóa hoàn toàn việc kiểm tra, tải và cài.

## Lưu dữ liệu

Dữ liệu nhân vật nằm trong thư mục `user://` của Godot (tệp `thanh_khe_demo.json`), không được launcher ghi đè khi game cập nhật. Launcher cài game riêng tại thư mục người dùng và không xóa save.

## Điều khiển

- **A/D hoặc mũi tên:** di chuyển. **Shift:** chạy. **Space:** nhảy.
- **J / chuột trái:** đánh quái. **E:** trò chuyện / hái linh thảo.
- **Giữ R** gần Linh Thụ: thiền định. **I:** xem nhân vật. **H:** hướng dẫn.
- **1–4:** lựa chọn Thái Hư, Vạn Pháp, Thiên Đạo hoặc Tán tu sau nhiệm vụ.

## Vòng chơi tân thủ

Tìm Tống tiên sinh → hái ba linh thảo → hạ ba linh thú → thiền định cạnh Linh Thụ → gặp Thôn trưởng, chọn con đường tu luyện.

## Phát triển và kiểm thử

- Game: `game.gd`, `main.tscn`, `project.godot`.
- Launcher: `launcher/Program.cs`, `launcher/ThanhKheLauncher.csproj`.
- GitHub Actions: [**Windows game and auto-update launcher**](.github/workflows/build-windows.yml). Mỗi push lên `main` có build thành công sẽ tạo bản Release phiên bản `v0.2.<run_number>`, gắn game, launcher, và `latest.json` checksum.
- Chạy Godot headless smoke test trước khi phát hành. Build .NET self-contained để **người chơi không phải tự cài .NET Runtime**.
- Đây là prototype, chưa có server MMORPG, nhân vật/art cuối cùng, tự cập nhật launcher riêng hoặc download theo từng phần.

