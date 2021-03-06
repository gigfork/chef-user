#
# Cookbook Name:: user
# Recipe:: data_bag
#
# Copyright 2011, Fletcher Nichol
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

bag = node['user']['data_bag_name']

# Fetch the user array from the node's attribute hash. If a subhash is
# desired (ex. node['base']['user_accounts']), then set:
#
#     node['user']['user_array_node_attr'] = "base/user_accounts"

user_array = node
node['user']['user_array_node_attr'].split("/").each do |hash_key|
  user_array = user_array.send(:[], hash_key)
end

# only manage the subset of users defined
Array(user_array).each do |i|
  item = i.gsub(/[.]/, '-')
  u = merged_data_bag_item(bag, item).to_hash
  u['username'] ||= item
  u['dotfiles'] ||= Hash.new

  u['password'] ||= "*" # default to pubkey access only

  user_account u['username'] do
    comment      u['comment']
    uid          u['uid']
    gid          u['gid']
    home         u['home']
    shell        u['shell']
    password     u['password']
    system_user  u['system_user']
    manage_home  u['manage_home']
    create_group u['create_group']
    ssh_keys     u['ssh_keys'] || ""
    dotfiles     u['dotfiles']
    id_rsa       u["id_rsa"]
    id_rsa_pub   u["id_rsa_pub"]
    hosts        u["hosts"]
    action       u['action'].to_sym if u['action']
    ignore_failure true if u['action'].eql? "remove"
  end
  unless u['groups'].nil?
    u['groups'].each do |groupname|
      group groupname do
        members u['username']
        append true
        action :modify
      end
    end
  end
end
