Devise::LDAP::Connection.class_eval do
  # overridden method from devise_ldap_authenticatable gem for working with multiple different LDAP configs in ldap.yml
  def initialize(params = {})
    ldap_configs = YAML.load(ERB.new(File.read(::Devise.ldap_config || "#{Rails.root}/config/ldap.yml")).result)[Rails.env]
    ldap_configs = ldap_configs.is_a?(Hash) ? [ldap_configs] : ldap_configs
    ldap_options = params
    ldap_configs.each do |ldap_config|
      ldap_options = params
      ldap_config["ssl"] = :simple_tls if ldap_config["ssl"] === true
      ldap_options[:encryption] = ldap_config["ssl"].to_sym if ldap_config["ssl"]
      @ldap = Net::LDAP.new(ldap_options)
      @ldap.host = ldap_config["host"]
      @ldap.port = ldap_config["port"]
      @ldap.base = ldap_config["base"]
      @attribute = ldap_config["attribute"]
      @allow_unauthenticated_bind = ldap_config["allow_unauthenticated_bind"]

      @ldap_auth_username_builder = params[:ldap_auth_username_builder]

      @group_base = ldap_config["group_base"]
      @check_group_membership = ldap_config.has_key?("check_group_membership") ? ldap_config["check_group_membership"] : ::Devise.ldap_check_group_membership
      @required_groups = ldap_config["required_groups"]
      @required_attributes = ldap_config["require_attribute"]

      @ldap.auth ldap_config["admin_user"], ldap_config["admin_password"] if params[:admin]
      @ldap.auth params[:login], params[:password] if ldap_config["admin_as_user"]

      @login = params[:login]
      @password = params[:password]
      @new_password = params[:new_password]
      if @ldap.bind
         # puts "Authentification success on " + ldap_config["host"]
         break
      end
    end
  end

  # overridden method from devise_ldap_authenticatable gem added custom logs
  def authorized?
    now = DateTime.now.to_datetime.strftime('%a, %d %b %Y %H:%M:%S')
    DeviseLdapAuthenticatable::Logger.send("Authorizing user #{dn}")
    if !authenticated?
      Rails.logger.warn '[WARNING] '+ now.to_s + " LDAP user #{dn} authorization failed"
      DeviseLdapAuthenticatable::Logger.send("Not authorized because not authenticated.")
      return false
    elsif !in_required_groups?
      Rails.logger.warn '[WARNING] '+ now.to_s + " LDAP user #{dn} authorization failed"
      DeviseLdapAuthenticatable::Logger.send("Not authorized because not in required groups.")
      return false
    elsif !has_required_attribute?
      Rails.logger.warn '[WARNING] '+ now.to_s + " LDAP user #{dn} authorization failed"
      DeviseLdapAuthenticatable::Logger.send("Not authorized because does not have required attribute.")
      return false
    else
      Rails.logger.info '[INFO] '+ now.to_s + " LDAP user #{dn} authorization successed"
      return true
    end
  end
end