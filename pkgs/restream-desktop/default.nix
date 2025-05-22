{
  lib,
  makeDesktopItem,
}:

makeDesktopItem {
  name = "reStream";
  exec = "restream -p";
  icon = ./remarkable.png; # Using the remarkable icon
  comment = "Stream reMarkable tablet";
  desktopName = "reStream";
  categories = [
    "AudioVideo"
    "Video"
  ];
  type = "Application";
}
