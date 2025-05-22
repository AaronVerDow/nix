{
  lib,
  makeDesktopItem,
}:

makeDesktopItem {
  name = "restream-preview";
  exec = "restream -p";
  icon = "video-display"; # Using a standard icon
  comment = "Preview restream video output";
  desktopName = "Restream Preview";
  categories = [
    "AudioVideo"
    "Video"
  ];
  type = "Application";
}
