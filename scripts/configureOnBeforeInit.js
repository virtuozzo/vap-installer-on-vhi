var settings = jps.settings.configure;
var fields = {};
for (var i = 0, field; field = jps.settings.configure.fields[i]; i++)
  fields[field.name] = field;

settings.fields.push({
    "type": "toggle",
    "name": "ssh_key_check",
    "caption": "New SSH Key",
    "tooltip": "If you have no SSH key in VHI cluster tick on the checkbox and come up with SSH key name. A new SSH key pair will be generated and injected into your environment and added to VHI cluster automatically.",
    "showIf": {
      "true": [
        {
          "type": "string",
          "name": "ssh_key_name",
          "caption": "New SSH Key Name",
          "required": true,
          "tooltip": "Minimum length of 3 symbols is required."
        }
      ]
    }
  });

return settings;
