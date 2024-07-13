{
  fusuma = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0k92bz448zl8d27wqinhbbnq35zlirz2ydx8lggiwp90sljiggf1";
      type = "gem";
    };
    version = "2.5.1";
  };
  fusuma-plugin-appmatcher = {
    dependencies = ["fusuma" "rexml" "ruby-dbus"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0mfl51a5v3ym3v68z94rv92i0g5kkbaqb8f4z5gnbfqdw1gkqi1n";
      type = "gem";
    };
    version = "0.4.0";
  };
  fusuma-plugin-keypress = {
    dependencies = ["fusuma"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pl0svszy5bvq0j4202k0kxfm25xdgr0qb133nxplc09v4h1hp04";
      type = "gem";
    };
    version = "0.8.0";
  };
  fusuma-plugin-sendkey = {
    dependencies = ["fusuma" "revdev"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10gn9b3fd8hxdhfj509xqa47g0gwl3lfmzpagd77qh2w41gs04w1";
      type = "gem";
    };
    version = "0.10.0";
  };
  fusuma-plugin-touchscreen = {
    dependencies = ["fusuma"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1jdaixndsrya3xxvnpwhrfhcllxg3azmgl11pybycygvi759ddgg";
      type = "gem";
    };
    version = "0.1.0";
  };
  fusuma-plugin-wmctrl = {
    dependencies = ["fusuma"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17hd8d2d0b8dyblj93rawnvrm9aii4p89w3jv6nf2x5xb5wgzbf9";
      type = "gem";
    };
    version = "1.2.0";
  };
  revdev = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1b6zg6vqlaik13fqxxcxhd4qnkfgdjnl4wy3a1q67281bl0qpsz9";
      type = "gem";
    };
    version = "0.2.1";
  };
  rexml = {
    dependencies = ["strscan"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "09f3sw7f846fpcpwdm362ylqldwqxpym6z0qpld4av7zisrrzbrl";
      type = "gem";
    };
    version = "3.3.1";
  };
  ruby-dbus = {
    dependencies = ["rexml"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0hf9y5lbi1xcadc2fw87wlif75s1359c2wwlvvd0gag7cq5dm0pm";
      type = "gem";
    };
    version = "0.23.1";
  };
  strscan = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0mamrl7pxacbc79ny5hzmakc9grbjysm3yy6119ppgsg44fsif01";
      type = "gem";
    };
    version = "3.1.0";
  };
}
