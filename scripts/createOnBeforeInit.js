      var infraFlavorList = getJsonFromFile("infraFlavors.json");
      var infraFlavorListPrepared = prepareFlavorsList(JSON.parse(infraFlavorList));
      var userFlavorList = getJsonFromFile("userFlavors.json");
      var userFlavorListPrepared = prepareFlavorsList(JSON.parse(userFlavorList));
      var imagesList = getJsonFromFile("images.json");
      var imageListPrepared = prepareImageList(JSON.parse(imagesList));
      var subnetsList = getJsonFromFile("subnets.json");
      var subnetListPrepared = prepareSubnetList(JSON.parse(subnetsList));
      var sshKeys = getSSHKeysList();
      var sshKeysPrepared = prepareSSHKeysList(JSON.parse(sshKeys));
      var vapStackName = jelastic.env.control.ExecCmdById('${env.envName}', session, '${nodes.cp.master.id}', toJSON([{ command: 'source .vapenv && echo $VAP_STACK_NAME' }]), true).responses[0].out;
       
      function getJsonFromFile(jsonFile) {
        var cmd = "cat /var/www/webroot/" + jsonFile;
        var resp = jelastic.env.control.ExecCmdById('${env.envName}', session, '${nodes.cp.master.id}', toJSON([{ "command": cmd }]), true);
        if (resp.result != 0) return resp;
        return resp.responses[0].out;
      }

      function getSSHKeysList() {
	var cmd = "source .vapenv; /opt/jelastic-python311/bin/openstack keypair list -f json"
        var resp = jelastic.env.control.ExecCmdById('${env.envName}', session, '${nodes.cp.master.id}', toJSON([{ "command": cmd }]), true);
        if (resp.result != 0) return resp;
        return resp.responses[0].out;
      }

      function prepareSSHKeysList(values) {
        var aResultValues = [];
        values = values || [];
        for (var i = 0, n = values.length; i < n; i++) {
          aResultValues.push({
            caption: values[i].Name,
            value: values[i].Name
          });
        }
        return aResultValues;
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

      var settings = jps.settings.create;
      var fields = {};
      for (var i = 0, field; field = jps.settings.create.fields[i]; i++)
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
      fields["ssh_key"].values = sshKeysPrepared;
      fields["ssh_key"].values = sshKeysPrepared;
      fields["ssh_key"].default = '${settings.ssh_key_name}';
      
      return settings;
