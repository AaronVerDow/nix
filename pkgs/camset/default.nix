{
  python312Packages,
  fetchFromGitHub,
  pkgs
}:

python312Packages.buildPythonPackage rec {
  name = "camset";
  src = fetchFromGitHub {
    owner = "azeam";
    repo = "camset";
    rev = "b813ba9b1d29f2d46fad268df67bf3615a324f3e";
    hash = "sha256-vTF3MJQi9fZZDlbEj5800H22GGWOte3+KZCpSnsSTaQ=";
  };
  propagatedBuildInputs = [ 
    python312Packages.pytest 
    python312Packages.numpy 
    pkgs.libsndfile 
  ];
}
