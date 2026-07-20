using System.IO;
using System.Windows;
using System.Windows.Input;
using System.Windows.Media.Animation;
using System.Windows.Media.Imaging;
using System.Windows.Threading;

namespace SlideShow;

public partial class SlideshowWindow : Window
{
    private static readonly string[] SupportedExtensions = [".jpg", ".jpeg", ".png", ".bmp", ".gif", ".webp"];

    private readonly string[] _imagePaths;
    private readonly TimeSpan _interval;
    private readonly DispatcherTimer _timer;
    private readonly TimeSpan _fadeDuration = TimeSpan.FromMilliseconds(600);
    private bool _isFrontActive = true;
    private int _currentIndex;
    private bool _isTransitioning;

    public SlideshowWindow(string folderPath, TimeSpan interval)
    {
        InitializeComponent();

        _interval = interval;
        _imagePaths = Directory.EnumerateFiles(folderPath)
            .Where(path => SupportedExtensions.Contains(Path.GetExtension(path), StringComparer.OrdinalIgnoreCase))
            .OrderBy(path => path, StringComparer.OrdinalIgnoreCase)
            .ToArray();

        _timer = new DispatcherTimer
        {
            Interval = _interval
        };
        _timer.Tick += Timer_Tick;
    }

    private void Window_Loaded(object sender, RoutedEventArgs e)
    {
        if (_imagePaths.Length == 0)
        {
            System.Windows.MessageBox.Show(this, "指定したフォルダに表示できる画像がありません。", "SlideShow", MessageBoxButton.OK, MessageBoxImage.Information);
            Close();
            return;
        }

        DisplayImage(FrontImage, _imagePaths[0]);
        FrontImage.Opacity = 1;
        BackImage.Opacity = 0;
        _isFrontActive = true;

        _timer.Start();
        Keyboard.Focus(this);
    }

    private async void Timer_Tick(object? sender, EventArgs e)
    {
        if (_isTransitioning || _imagePaths.Length <= 1)
        {
            return;
        }

        _isTransitioning = true;
        _timer.Stop();

        _currentIndex = (_currentIndex + 1) % _imagePaths.Length;

        var activeImage = _isFrontActive ? FrontImage : BackImage;
        var inactiveImage = _isFrontActive ? BackImage : FrontImage;

        DisplayImage(inactiveImage, _imagePaths[_currentIndex]);
        inactiveImage.Opacity = 0;

        var fadeOut = new DoubleAnimation(1, 0, _fadeDuration);
        var fadeIn = new DoubleAnimation(0, 1, _fadeDuration);

        activeImage.BeginAnimation(OpacityProperty, fadeOut);
        inactiveImage.BeginAnimation(OpacityProperty, fadeIn);

        await Task.Delay(_fadeDuration);
        _isFrontActive = !_isFrontActive;
        _isTransitioning = false;
        _timer.Start();
    }

    private static void DisplayImage(System.Windows.Controls.Image imageControl, string imagePath)
    {
        var bitmap = new BitmapImage();
        bitmap.BeginInit();
        bitmap.CacheOption = BitmapCacheOption.OnLoad;
        bitmap.UriSource = new Uri(imagePath, UriKind.Absolute);
        bitmap.EndInit();
        bitmap.Freeze();

        imageControl.Source = bitmap;
    }

    private void Window_KeyDown(object sender, System.Windows.Input.KeyEventArgs e)
    {
        if (e.Key == Key.Escape)
        {
            Close();
        }
    }
}