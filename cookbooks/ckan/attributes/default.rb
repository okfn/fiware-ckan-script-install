default[:ckan][:user] = "ckan_user"
default[:ckan][:project_name] = "default"
default[:ckan][:site_url] = "http://default.ckanhosted.dev"
default[:ckan][:solr_url] = "http://127.0.0.1:8983/solr"
default[:ckan][:sql_password] = "pass"
default[:ckan][:sql_user] = "ckan_#{default[:ckan][:project_name]}"
default[:ckan][:sql_db_name] = "ckan_#{default[:ckan][:project_name]}"
default[:ckan][:virtual_env_dir] = "/usr/lib/ckan/#{default[:ckan][:project_name]}"
default[:ckan][:config_dir] = "/etc/ckan/#{default[:ckan][:project_name]}"
default[:ckan][:file_storage_dir] = "/var/lib/ckan/#{default[:ckan][:project_name]}"

default[:ckan][:datastore][:sql_user] = "datastore_#{default[:ckan][:project_name]}"  # readonly db user
default[:ckan][:datastore][:sql_db_name] = "datastore_#{default[:ckan][:project_name]}"

# The CKAN version to install.
default[:ckan_package][:url] = "http://packaging.ckan.org/"
default[:ckan_package][:file_name] = "python-ckan_2.4_amd64.deb"
# default[:ckan_package][:url] = ""
# default[:ckan_package][:file_name] = "python-ckan_2.3_amd64.deb"

# Apache config for production
default[:apache][:server_name] = "default.ckanhosted.dev"
default[:apache][:server_alias] = "www.default.ckanhosted.dev"

default['postgresql']['password']['postgres'] = "pass"
