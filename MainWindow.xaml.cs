using System.IO;
using System.Windows;
using Forms = System.Windows.Forms;

namespace SlideShow;

public partial class MainWindow : Window
{
    private readonly UserSettings _settings;
    private readonly MonitorOption[] _monitorOptions;
    private readonly double? _restoredLeft;
    private readonly double? _restoredTop;

    public MainWindow()
    {
        InitializeComponent();

        _settings = UserSettings.Load();
        _monitorOptions = BuildMonitorOptions();
        Closing += MainWindow_Closing;
        Loaded += MainWindow_Loaded;

        var version = typeof(MainWindow).Assembly.GetName().Version;
        VersionTextBlock.Text = $"SlideShow Version {version}";

        FolderPathTextBox.Text = string.IsNullOrWhiteSpace(_settings.FolderPath)
            ? Environment.GetFolderPath(Environment.SpecialFolder.MyPictures)
            : _settings.FolderPath;

        IntervalTextBox.Text = _settings.IntervalSeconds > 0
            ? _settings.IntervalSeconds.ToString("0.###")
            : "3";

        MonitorComboBox.ItemsSource = _monitorOptions;
        MonitorComboBox.SelectedItem = _monitorOptions.FirstOrDefault(option => string.Equals(option.DeviceName, _settings.MonitorDeviceName, StringComparison.OrdinalIgnoreCase))
            ?? _monitorOptions.FirstOrDefault(option => option.IsPrimary)
            ?? _monitorOptions.FirstOrDefault();

        (_restoredLeft, _restoredTop) = GetRestoredWindowPosition();
        ApplyRestoredWindowPosition();
    }

    private void BrowseFolder_Click(object sender, RoutedEventArgs e)
    {
        using var dialog = new System.Windows.Forms.FolderBrowserDialog
        {
            Description = "画像フォルダを選択してください",
            UseDescriptionForTitle = true,
            SelectedPath = Directory.Exists(FolderPathTextBox.Text)
                ? FolderPathTextBox.Text
                : Environment.GetFolderPath(Environment.SpecialFolder.MyPictures)
        };

        if (dialog.ShowDialog() == System.Windows.Forms.DialogResult.OK)
        {
            FolderPathTextBox.Text = dialog.SelectedPath;
        }
    }

    private void Start_Click(object sender, RoutedEventArgs e)
    {
        var folderPath = FolderPathTextBox.Text.Trim();

        if (!Directory.Exists(folderPath))
        {
            System.Windows.MessageBox.Show(this, "画像フォルダが見つかりません。", "入力エラー", MessageBoxButton.OK, MessageBoxImage.Warning);
            return;
        }

        if (!double.TryParse(IntervalTextBox.Text.Trim(), out var intervalSeconds) || intervalSeconds <= 0)
        {
            System.Windows.MessageBox.Show(this, "切り替え間隔は 0 より大きい数値を入力してください。", "入力エラー", MessageBoxButton.OK, MessageBoxImage.Warning);
            return;
        }

        SaveSettings(folderPath, intervalSeconds);

        var slideshowWindow = new SlideshowWindow(folderPath, TimeSpan.FromSeconds(intervalSeconds), GetSelectedMonitorDeviceName());
        slideshowWindow.Show();
        Close();
    }

    private void MainWindow_Closing(object? sender, System.ComponentModel.CancelEventArgs e)
    {
        var folderPath = FolderPathTextBox.Text.Trim();
        var intervalSeconds = double.TryParse(IntervalTextBox.Text.Trim(), out var parsedInterval) && parsedInterval > 0
            ? parsedInterval
            : _settings.IntervalSeconds;

        SaveSettings(folderPath, intervalSeconds);
    }

    private void SaveSettings(string folderPath, double intervalSeconds)
    {
        _settings.FolderPath = folderPath;
        _settings.IntervalSeconds = intervalSeconds;
        _settings.MonitorDeviceName = GetSelectedMonitorDeviceName();
        _settings.WindowLeft = Left;
        _settings.WindowTop = Top;
        _settings.Save();
    }

    private string GetSelectedMonitorDeviceName()
    {
        return (MonitorComboBox.SelectedItem as MonitorOption)?.DeviceName ?? string.Empty;
    }

    private void MainWindow_Loaded(object sender, RoutedEventArgs e)
    {
        ApplyRestoredWindowPosition();
    }

    private (double? Left, double? Top) GetRestoredWindowPosition()
    {
        if (_settings.WindowLeft is not double left || _settings.WindowTop is not double top)
        {
            return (null, null);
        }

        var maxLeft = SystemParameters.VirtualScreenLeft + SystemParameters.VirtualScreenWidth - Width;
        var maxTop = SystemParameters.VirtualScreenTop + SystemParameters.VirtualScreenHeight - Height;

        if (left < SystemParameters.VirtualScreenLeft || left > maxLeft || top < SystemParameters.VirtualScreenTop || top > maxTop)
        {
            return (null, null);
        }

        return (left, top);
    }

    private void ApplyRestoredWindowPosition()
    {
        if (_restoredLeft is not double left || _restoredTop is not double top)
        {
            return;
        }

        WindowStartupLocation = WindowStartupLocation.Manual;
        Left = left;
        Top = top;
    }

    private static MonitorOption[] BuildMonitorOptions()
    {
        return Forms.Screen.AllScreens
            .Select((screen, index) =>
            {
                var primarySuffix = screen.Primary ? " (メイン)" : string.Empty;
                var bounds = screen.Bounds;
                var displayName = $"モニタ {index + 1}{primarySuffix} - {bounds.Width}x{bounds.Height} ({bounds.X}, {bounds.Y})";
                return new MonitorOption(screen.DeviceName, displayName, screen.Primary);
            })
            .ToArray();
    }

    private sealed record MonitorOption(string DeviceName, string DisplayName, bool IsPrimary);
}