{
  pandoc-mustache,
  runCommand,
}:
runCommand "pandoc-mustache-test-console"
  {
    nativeBuildInputs = [ pandoc-mustache ];
  }
  ''
    false
  ''
