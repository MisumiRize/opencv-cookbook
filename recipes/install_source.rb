#
# Cookbook Name:: opencv
# Recipe:: install
# Author:: Yann Robin <yann.robin@youscribe.com>
#
# Copyright 2014, Societe YouScribe.
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

include_recipe "build-essential"

package "unzip"
package "cmake"
package "python-numpy"

src_filepath  = "#{Chef::Config['file_cache_path'] || '/tmp'}/#{::File.basename(node['opencv']['source']['url'])}"

remote_file node['opencv']['source']['url'] do
  path src_filepath
  checksum node['opencv']['source']['checksum']
  source node['opencv']['source']['url']
  backup false
end

bash "compile_opencv_source" do
  cwd ::File.dirname(src_filepath)
  code <<-EOH
    unzip #{::File.basename(src_filepath)} -d . &&
    cd #{::File.basename(src_filepath, ::File.extname(src_filepath))} &&
	mkdir release &&
	cd release &&
	cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local .. &&
	make &&
	make install
  EOH

  not_if do 
    node['opencv']['source']['force_recompile'] == false && ::File.directory?(::File.dirname(src_filepath) + '/' + ::File.basename(src_filepath, ::File.extname(src_filepath)))
  end
end