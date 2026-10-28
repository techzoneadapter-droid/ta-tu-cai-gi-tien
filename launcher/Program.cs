using System.Diagnostics;
using System.Net.Http.Headers;
using System.Security.Cryptography;
using System.Text.Json;
using System.Windows.Forms;

namespace ThanhKheLauncher;

internal static class Program
{
    [STAThread]
    private static void Main()
    {
        ApplicationConfiguration.Initialize();
        Application.Run(new LauncherForm());
    }
}

internal sealed class LauncherForm : Form
{
    private const string Repo = "techzoneadapter-droid/ta-tu-cai-gi-tien";
    private const string ReleaseApi = "https://api.github.com/repos/" + Repo + "/releases/latest";
    private const string ReleasePage = "https://github.com/" + Repo + "/releases/latest";
    private const string GameAsset = "ThanhKhe_Game.exe";
    private const string ManifestAsset = "latest.json";
    private const long MaxDownload = 400L * 1024 * 1024;

    private static readonly HttpClient Http = CreateHttpClient();
    private readonly string _folder = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
        "ThienDaoVietLai", "ThanhKhe");

    private string GamePath => Path.Combine(_folder, GameAsset);
    private string InstalledManifestPath => Path.Combine(_folder, "installed.json");

    private readonly Label _status = new();
    private readonly Label _subtitle = new();
    private readonly ProgressBar _progress = new();
    private readonly Button _play = new();
    private readonly Button _check = new();
    private readonly Button _folderButton = new();
    private readonly Button _releaseButton = new();
    private bool _busy;

    public LauncherForm()
    {
        Text = "Thiên Đạo Viết Lại | Thanh Khê Launcher";
        ClientSize = new System.Drawing.Size(680, 355);
        MinimumSize = new System.Drawing.Size(700, 395);
        StartPosition = FormStartPosition.CenterScreen;
        BackColor = System.Drawing.Color.FromArgb(20, 28, 39);
        ForeColor = System.Drawing.Color.FromArgb(238, 230, 214);
        Font = new System.Drawing.Font("Segoe UI", 10);

        var title = new Label
        {
            Text = "THIÊN ĐẠO VIẾT LẠI",
            Font = new System.Drawing.Font("Segoe UI Semibold", 22, System.Drawing.FontStyle.Bold),
            AutoSize = false, Bounds = new System.Drawing.Rectangle(24, 21, 625, 47),
            ForeColor = System.Drawing.Color.FromArgb(242, 204, 128)
        };
        _subtitle.Text = "Thanh Khê • Demo 2D • Windows x64";
        _subtitle.SetBounds(27, 77, 615, 29);
        _subtitle.ForeColor = System.Drawing.Color.FromArgb(174, 192, 206);

        _status.Text = "Đang chuẩn bị kiểm tra bản cập nhật...";
        _status.SetBounds(27, 124, 625, 50);
        _status.AutoEllipsis = true;

        _progress.SetBounds(27, 182, 620, 24);
        _progress.Minimum = 0;
        _progress.Maximum = 100;
        _progress.Style = ProgressBarStyle.Marquee;

        StyleButton(_play, "VÀO GAME", 27, 234, 190);
        _play.BackColor = System.Drawing.Color.FromArgb(62, 111, 88);
        _play.Enabled = false;
        _play.Click += (_, _) => LaunchGame();

        StyleButton(_check, "Kiểm tra bản mới", 231, 234, 195);
        _check.Click += async (_, _) => await CheckAndUpdateAsync();
        StyleButton(_folderButton, "Thư mục game", 441, 234, 205);
        _folderButton.Click += (_, _) =>
        {
            Directory.CreateDirectory(_folder);
            Process.Start(new ProcessStartInfo("explorer.exe", $"\"{_folder}\"") { UseShellExecute = true });
        };
        StyleButton(_releaseButton, "Mở trang phát hành GitHub", 27, 291, 619);
        _releaseButton.Click += (_, _) =>
            Process.Start(new ProcessStartInfo(ReleasePage) { UseShellExecute = true });

        Controls.AddRange(new Control[] { title, _subtitle, _status, _progress,
            _play, _check, _folderButton, _releaseButton });
        Shown += async (_, _) => await CheckAndUpdateAsync();
    }

    private void StyleButton(Button button, string caption, int x, int y, int width)
    {
        button.Text = caption;
        button.SetBounds(x, y, width, 42);
        button.FlatStyle = FlatStyle.Flat;
        button.FlatAppearance.BorderColor = System.Drawing.Color.FromArgb(94, 123, 135);
        button.BackColor = System.Drawing.Color.FromArgb(36, 53, 70);
        button.ForeColor = System.Drawing.Color.White;
        button.Cursor = Cursors.Hand;
    }

    private static HttpClient CreateHttpClient()
    {
        var client = new HttpClient(new HttpClientHandler { AllowAutoRedirect = true });
        client.Timeout = Timeout.InfiniteTimeSpan;
        client.DefaultRequestHeaders.UserAgent.Add(new ProductInfoHeaderValue("ThanhKheLauncher", "1.0"));
        client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/vnd.github+json"));
        return client;
    }

    private void Status(string message)
    {
        _status.Text = message;
        _status.Refresh();
    }

    private static string? AssetUrl(JsonElement assets, string name)
    {
        foreach (var asset in assets.EnumerateArray())
            if (asset.GetProperty("name").GetString() == name)
                return asset.GetProperty("browser_download_url").GetString();
        return null;
    }

    private static bool IsTrustedAssetUrl(string? raw)
    {
        if (!Uri.TryCreate(raw, UriKind.Absolute, out var url)) return false;
        return url.Scheme == Uri.UriSchemeHttps
            && url.Host.Equals("github.com", StringComparison.OrdinalIgnoreCase)
            && url.AbsolutePath.StartsWith("/" + Repo + "/releases/download/", StringComparison.Ordinal);
    }

    private static bool ValidHash(string value) =>
        value.Length == 64 && value.All(Uri.IsHexDigit);

    private static async Task<string> Sha256FileAsync(string path, CancellationToken token)
    {
        await using var file = new FileStream(path, FileMode.Open, FileAccess.Read,
            FileShare.Read, 128 * 1024, FileOptions.Asynchronous | FileOptions.SequentialScan);
        var hash = await SHA256.HashDataAsync(file, token);
        return Convert.ToHexString(hash).ToLowerInvariant();
    }

    private async Task<bool> IsCachedGameValidAsync(CancellationToken token)
    {
        if (!File.Exists(GamePath)) return false;
        try
        {
            if (!File.Exists(InstalledManifestPath)) return false;
            using var doc = JsonDocument.Parse(await File.ReadAllTextAsync(InstalledManifestPath, token));
            var expected = doc.RootElement.GetProperty("sha256").GetString() ?? "";
            return ValidHash(expected) && string.Equals(
                expected, await Sha256FileAsync(GamePath, token), StringComparison.OrdinalIgnoreCase);
        }
        catch (Exception) { return false; }
    }

    private async Task CheckAndUpdateAsync()
    {
        if (_busy) return;
        _busy = true;
        _check.Enabled = false;
        _play.Enabled = false;
        _progress.Style = ProgressBarStyle.Marquee;
        Directory.CreateDirectory(_folder);

        using var tokenSource = new CancellationTokenSource(TimeSpan.FromMinutes(15));
        try
        {
            Status("Đang kiểm tra bản game mới nhất trên GitHub Releases...");
            using var metadataTimeout = new CancellationTokenSource(TimeSpan.FromSeconds(30));
            var response = await Http.GetStringAsync(ReleaseApi, metadataTimeout.Token);
            using var release = JsonDocument.Parse(response);
            var root = release.RootElement;
            var releaseVersion = root.GetProperty("tag_name").GetString() ?? "";
            var assets = root.GetProperty("assets");
            var gameUrl = AssetUrl(assets, GameAsset);
            var manifestUrl = AssetUrl(assets, ManifestAsset);
            if (!IsTrustedAssetUrl(gameUrl) || !IsTrustedAssetUrl(manifestUrl))
                throw new InvalidDataException("Bản phát hành thiếu tệp game hoặc bản mô tả hợp lệ.");

            var rawManifest = await Http.GetStringAsync(manifestUrl!, metadataTimeout.Token);
            using var manifest = JsonDocument.Parse(rawManifest);
            var expected = manifest.RootElement.GetProperty("sha256").GetString()?.ToLowerInvariant() ?? "";
            var assetName = manifest.RootElement.GetProperty("asset").GetString();
            var manifestVersion = manifest.RootElement.GetProperty("version").GetString();
            var size = manifest.RootElement.GetProperty("size").GetInt64();
            if (assetName != GameAsset || manifestVersion != releaseVersion
                || !ValidHash(expected) || size < 100_000 || size > MaxDownload)
                throw new InvalidDataException("Thông tin bản phát hành không hợp lệ.");

            if (File.Exists(GamePath)
                && new FileInfo(GamePath).Length == size
                && string.Equals(await Sha256FileAsync(GamePath, tokenSource.Token),
                    expected, StringComparison.OrdinalIgnoreCase))
            {
                await SaveInstalledManifestAsync(releaseVersion, expected, tokenSource.Token);
                Status("Game đã là bản mới nhất: " + releaseVersion + " — sẵn sàng chơi.");
                _progress.Style = ProgressBarStyle.Continuous;
                _progress.Value = 100;
                _play.Enabled = true;
                return;
            }

            Status("Đang tải cập nhật " + releaseVersion + " (không ảnh hưởng dữ liệu nhân vật)...");
            var staging = GamePath + ".download";
            try
            {
                using var gameResponse = await Http.GetAsync(gameUrl!,
                    HttpCompletionOption.ResponseHeadersRead, tokenSource.Token);
                gameResponse.EnsureSuccessStatusCode();
                if (gameResponse.Content.Headers.ContentLength is long contentLength && contentLength != size)
                    throw new InvalidDataException("Dung lượng gói tải không khớp manifest.");
                await using var stream = await gameResponse.Content.ReadAsStreamAsync(tokenSource.Token);
                await using (var output = new FileStream(staging, FileMode.Create, FileAccess.Write,
                    FileShare.None, 128 * 1024, FileOptions.Asynchronous | FileOptions.SequentialScan))
                {
                    var buffer = new byte[128 * 1024];
                    long bytes = 0;
                    _progress.Style = ProgressBarStyle.Continuous;
                    _progress.Value = 0;
                    int count;
                    while ((count = await stream.ReadAsync(buffer, tokenSource.Token)) > 0)
                    {
                        bytes += count;
                        if (bytes > size || bytes > MaxDownload)
                            throw new InvalidDataException("Tệp tải vượt dung lượng được công bố.");
                        await output.WriteAsync(buffer.AsMemory(0, count), tokenSource.Token);
                        _progress.Value = Math.Clamp((int)(bytes * 100 / size), 0, 100);
                        Status($"Đang tải {releaseVersion}: {bytes / 1048576} / {size / 1048576} MB...");
                    }
                }
                if (new FileInfo(staging).Length != size ||
                    !string.Equals(await Sha256FileAsync(staging, tokenSource.Token),
                        expected, StringComparison.OrdinalIgnoreCase))
                    throw new InvalidDataException("Tệp tải không khớp checksum SHA-256. Đã hủy cập nhật.");
                Status("Đã xác minh SHA-256, đang cài đặt an toàn...");
                var backup = GamePath + ".backup";
                bool hadPrevious = File.Exists(GamePath);
                if (File.Exists(backup)) File.Delete(backup);
                if (hadPrevious) File.Move(GamePath, backup);
                try
                {
                    File.Move(staging, GamePath);
                    await SaveInstalledManifestAsync(releaseVersion, expected, tokenSource.Token);
                    if (hadPrevious && File.Exists(backup)) File.Delete(backup);
                }
                catch
                {
                    if (File.Exists(GamePath)) File.Delete(GamePath);
                    if (hadPrevious && File.Exists(backup)) File.Move(backup, GamePath);
                    throw;
                }
            }
            finally
            {
                if (File.Exists(staging)) File.Delete(staging);
            }
            _progress.Value = 100;
            Status("Đã cập nhật thành công " + releaseVersion + ". Nhấn VÀO GAME để chơi.");
            _play.Enabled = true;
        }
        catch (Exception ex)
        {
            _progress.Style = ProgressBarStyle.Continuous;
            _progress.Value = 0;
            if (await IsCachedGameValidAsync(CancellationToken.None))
            {
                _play.Enabled = true;
                Status("Chưa kiểm tra được bản mới; vẫn có thể chơi offline. " + ex.Message);
            }
            else
            {
                Status("Chưa thể tải game: " + ex.Message + " — xem GitHub Releases.");
            }
        }
        finally
        {
            _busy = false;
            _check.Enabled = true;
        }
    }

    private async Task SaveInstalledManifestAsync(string version, string hash, CancellationToken token)
    {
        var json = JsonSerializer.Serialize(new { version, sha256 = hash });
        var staging = InstalledManifestPath + ".tmp";
        await File.WriteAllTextAsync(staging, json, token);
        File.Move(staging, InstalledManifestPath, true);
    }

    private void LaunchGame()
    {
        if (!File.Exists(GamePath))
        {
            MessageBox.Show("Chưa tìm thấy game. Hãy kiểm tra cập nhật.", "Thanh Khê");
            return;
        }
        try
        {
            Process.Start(new ProcessStartInfo(GamePath)
            {
                WorkingDirectory = _folder,
                UseShellExecute = true
            });
        }
        catch (Exception ex)
        {
            MessageBox.Show(ex.Message, "Không mở được game");
        }
    }
}
