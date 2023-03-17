      var resp = {result:0};
      var url = "https://raw.githubusercontent.com/sych74/vap-installer/ui/scripts/configure.yaml";
      resp.settings = toNative(new org.yaml.snakeyaml.Yaml().load(new com.hivext.api.core.utils.Transport().get(url)));
      return resp;
