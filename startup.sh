#!/bin/bash
#
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#<!--* freshness: { owner: 'ttaggart@google.com' reviewed: '2020-sep-01' } *-->

 
apt-get update
apt-get install -y apache2
echo "Redirect 500 /error500" | sudo tee -a /etc/apache2/apache2.conf
service apache2 restart
cat <<EOF > /var/www/html/index.html
<html>
  <body>
    <h1>Hello Packet Mirroring Application Performance Troubleshooting Solution!</h1>
  </body>
</html>
EOF
