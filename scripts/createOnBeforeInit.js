      var infraFlavorList = getJsonFromFile("infraFlavors.json");
      var infraFlavorListPrepared = prepareFlavorsList(JSON.parse(infraFlavorList));
      var userFlavorList = getJsonFromFile("userFlavors.json");
      var userFlavorListPrepared = prepareFlavorsList(JSON.parse(userFlavorList));
      var imagesList = getJsonFromFile("images.json");
      var imageListPrepared = prepareImageList(JSON.parse(imagesList));
      var subnetsList = getJsonFromFile("subnets.json");
      var subnetListPrepared = prepareSubnetList(JSON.parse(subnetsList));
      var vapStackName = jelastic.env.control.ExecCmdById('env-3339505', session, '365110', toJSON([{ command: 'source .vapenv && echo $VAP_STACK_NAME' }]), true).responses[0].out;      
       
      function getJsonFromFile(jsonFile) {
        var cmd = "cat /var/www/webroot/" + jsonFile;
        var resp = jelastic.env.control.ExecCmdById('env-3339505', session, '365110', toJSON([{ "command": cmd }]), true);
        if (resp.result != 0) return resp;
        return resp.responses[0].out;
      }
      
      function prepareFlavorsList(values) {
        var aResultValues = [];
        values = values || [];
        for (var i = 0, n = values.length; i < n; i++) {
          aResultValues.push({
            caption: values[i].RAM +" Mb "+ values[i].VCPUs +" VCPUs ",
            value: values[i].id
          });   
        }
        return aResultValues;
      }
      
      function prepareSubnetList(values) {
        var aResultValues = [];
        values = values || [];
        for (var i = 0, n = values.length; i < n; i++) {
          aResultValues.push({
            caption: values[i].Subnet,
            value: values[i].id
          });   
        }
        return aResultValues;
      }

      function prepareImageList(values) {
        var aResultValues = [];
        values = values || [];
        for (var i = 0, n = values.length; i < n; i++) {
          aResultValues.push({
            caption: values[i].Name,
            value: values[i].id
          });   
        }
        return aResultValues;
      }

      var resp = {result:0};
      var url = "https://raw.githubusercontent.com/sych74/vap-installer/ui/scripts/createSettings.yaml";
      resp.settings = toNative(new org.yaml.snakeyaml.Yaml().load(new com.hivext.api.core.utils.Transport().get(url)));
      var fields = resp.settings.fields;
      for (var i = 0, field; field = fields[i]; i++)
        fields[field.name] = field;
      var instTypeFields = fields["inst_type"].showIf;
      instTypeFields.poc[0].values = infraFlavorListPrepared;
      instTypeFields.poc[1].values = userFlavorListPrepared;
      instTypeFields.sb[0].values = infraFlavorListPrepared;
      instTypeFields.sb[1].values = userFlavorListPrepared;
      instTypeFields.prod[0].values = infraFlavorListPrepared;
      instTypeFields.prod[1].values = userFlavorListPrepared;
      instTypeFields.high_prod[0].values = infraFlavorListPrepared;
      instTypeFields.high_prod[1].values = userFlavorListPrepared;
      fields["vap_stack_name"].value = vapStackName;
      fields["subnet"].values = subnetListPrepared;
      fields["image_name"].values = imageListPrepared;
      
      return resp;
