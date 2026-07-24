using System.IO;
using System.Text.Json;

namespace SlideShow;

public enum SortOrder
{
    FileName,
    CreationDate,
    Random
}

internal sealed class UserSettings
{
    public string FolderPath { get; set; } = string.Empty;
    public double IntervalSeconds { get; set; } = 3;
    public string MonitorDeviceName { get; set; } = string.Empty;
    public SortOrder Order { get; set; } = SortOrder.FileName;
    public double? WindowLeft { get; set; }
    public double? WindowTop { get; set; }

    private static readonly JsonSerializerOptions SerializerOptions = new()
    {
        WriteIndented = true
    };

    private static string SettingsPath => Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
        "SlideShow",
        "settings.json");

    public static UserSettings Load()
    {
        try
        {
            if (!File.Exists(SettingsPath))
            {
                return new UserSettings();
            }

            var json = File.ReadAllText(SettingsPath);
            return JsonSerializer.Deserialize<UserSettings>(json) ?? new UserSettings();
        }
        catch
        {
            return new UserSettings();
        }
    }

    public void Save()
    {
        var directoryPath = Path.GetDirectoryName(SettingsPath);
        if (!string.IsNullOrEmpty(directoryPath))
        {
            Directory.CreateDirectory(directoryPath);
        }

        var json = JsonSerializer.Serialize(this, SerializerOptions);
        File.WriteAllText(SettingsPath, json);
    }
}