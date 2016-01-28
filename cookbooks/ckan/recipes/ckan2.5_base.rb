ENV['VIRTUAL_ENV'] = node[:ckan][:virtual_env_dir]
ENV['PATH'] = "#{ENV['VIRTUAL_ENV']}/bin:#{ENV['PATH']}"
SOURCE_DIR = "#{ENV['VIRTUAL_ENV']}/src"
CKAN_DIR = "#{SOURCE_DIR}/ckan"
CKAN_PACKAGE_NAME = 'python-ckan_2.5-trusty_amd64.deb'

# INSTALL APACHE
#
package "apache2" do
  action :install
end
package "libapache2-mod-rpaf" do
  action :install
end
package "libapache2-mod-wsgi" do
  action :install
end
package "libpq5" do
  action :install
end

# INSTALL NGINX
#
package "nginx" do
  action :install
end

# INSTALL .DEB TO /VAR/CHEF/CACHE (BUILD SERVER)
#
# `remote_file` for production, `cookbook_file` is useful for development
# where the package is on the host machine. Comment out as approiate.

remote_file "#{Chef::Config[:file_cache_path]}/#{CKAN_PACKAGE_NAME}" do
  source "#{node[:ckan_package][:url]}#{CKAN_PACKAGE_NAME}"
end
# cookbook_file "#{Chef::Config[:file_cache_path]}/#{CKAN_PACKAGE_NAME}" do
#   source "#{node[:ckan_package][:url]}#{CKAN_PACKAGE_NAME}"
# end
dpkg_package "python-ckan_2.5" do
  action :install
  source "#{Chef::Config[:file_cache_path]}/#{CKAN_PACKAGE_NAME}"
end

# CONFIGURE APACHE2
#
template "#{node[:ckan][:config_dir]}/apache.wsgi" do
  source "apache.wsgi.erb"
  variables({
    :source_dir => node[:ckan][:virtual_env_dir]
  })
end
template "/etc/apache2/sites-available/ckan_#{node[:ckan][:project_name]}" do
  source "apache_site_tmpl.erb"
  variables({
    :project_name => node[:ckan][:project_name],
    :server_name => node[:apache][:server_name],
    :server_alias => node[:apache][:server_alias],
    :config_dir => node[:ckan][:config_dir]
  })
end
execute "disable default apache site" do
  command "sudo a2dissite default"
  only_if { ::File.exists?("/etc/apache2/sites-enabled/000-default.conf")}
end

# CONFIGURE NGINX
#
file "/etc/nginx/sites-enabled/default" do
  action :delete
end

# INSTALL AND CONFIGURE SOLR-JETTY
#
package "solr-jetty" do
  action :install
end
template "/etc/default/jetty" do
  source "jetty.erb"
  variables({
    :java_home => node["java"]["java_home"]
  })
end
link "/etc/solr/conf/schema.xml" do
  to "#{CKAN_DIR}/ckan/config/solr/schema.xml"
  action :create
end
service "jetty" do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

# CONFIGURATION FILE FOR CKAN
#
# move secrets template file to client
chef_gem "uuidtools"
template "/etc/ckan/#{node[:ckan][:project_name]}/deployment_secrets.erb" do
  def set_uuid()
    require "uuidtools"
    return UUIDTools::UUID.random_create
  end
  def set_secret()
    require "securerandom"
    s = SecureRandom.base64(25)
    badchars = ['\n', '\r', '=']
    badchars.each {|badchar| s.gsub!(badchar, '')}
    return s[0..24]
  end
  source "deployment_secrets.erb"
  variables({
    :app_instance_uuid => set_uuid(),
    :app_instance_secret => set_secret()
  })
  action :create_if_missing
end
template "/etc/ckan/#{node[:ckan][:project_name]}/production.ini" do
  source "production.ini.2.3.erb"
  variables({
    :project_name => node[:ckan][:project_name],
    :site_url => node[:ckan][:site_url],
    :sql_password => node[:ckan][:sql_password],
    :sql_user => node[:ckan][:sql_user],
    :sql_db_name => node[:ckan][:sql_db_name],
    :ds_sql_user => node[:ckan][:datastore][:sql_user],
    :ds_sql_db_name => node[:ckan][:datastore][:sql_db_name],
    :file_storage_dir => node[:ckan][:file_storage_dir]
  })
end

# INSTALL AND CONFIGURE POSTGRES USERS AND TABLE
#
# Create Postgres User and Database
postgresql_connection_info = {
  :host      => '127.0.0.1',
  :port      => 5432,
  :username  => 'postgres',
  :password  => node['postgresql']['password']['postgres']
}
postgresql_database_user node[:ckan][:sql_user] do
  connection postgresql_connection_info
  createdb true
  superuser true
  login true
  password node[:ckan][:sql_password]
  action :create
end
postgresql_database node[:ckan][:sql_db_name] do
  connection postgresql_connection_info
  owner node[:ckan][:sql_user]
  encoding "utf8"
  action :create
end

# Create read-only pg user and database for datastore
postgresql_database_user node[:ckan][:datastore][:sql_user] do
  connection postgresql_connection_info
  createdb false
  superuser false
  login true
  password node[:ckan][:sql_password]
  action :create
end
postgresql_database node[:ckan][:datastore][:sql_db_name] do
  connection postgresql_connection_info
  owner node[:ckan][:sql_user]
  encoding "utf8"
  action :create
end
execute "initialize ckan database" do
  command "sudo ckan db init"
end
execute "set permissions" do
  cwd CKAN_DIR
  command "paster --plugin=ckan datastore set-permissions -c #{node[:ckan][:config_dir]}/production.ini | sudo -u postgres psql --set ON_ERROR_STOP=1"
end

# CREATE FILE STORAGE DIRECTORY
#
directory node[:ckan][:file_storage_dir] do
  owner 'www-data'
  mode '0755'
  recursive true
  action :create
end

package "postfix" do
  action :install
end

service "jetty" do
  supports :status => true, :restart => true, :reload => true
  action [:restart]
end
service "apache2" do
  supports :restart => true, :reload => true
  action [:enable, :restart]
end
service "nginx" do
  supports :restart => true, :reload => true
  action [:enable, :restart]
end
