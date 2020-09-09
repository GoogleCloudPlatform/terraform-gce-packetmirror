#!/usr/bin/env python
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

 
def packet_mirror_pubsub(data, context):
  """Background Cloud Function to be triggered by Pub/Sub.
  Args:
       data (dict): The dictionary with data specific to this type of event.
       context (google.cloud.functions.Context): The Cloud Functions event
       metadata.
  """

  import base64
  import requests
  import json

  if 'data' in data:
    name = base64.b64decode(data['data']).decode('utf-8')
  else:
    name = 'World'
  print('HTTP 500 Error Detected in: {}'.format(name))
  print('Activating Packet Mirroring For Analysis')

  my_response = requests.get(
      'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token',
      headers={'Metadata-Flavor': 'Google'},
  )

  # For successful API call, response code will be 200 (OK)

  if(my_response.ok):
    json_response = my_response.json()
    token = json_response['access_token']
    print(token)
    packet_mirror_api = requests.patch(
        'https://www.googleapis.com/compute/v1/projects/PROJECT-ID/regions/REGION/packetMirrorings/pm-mirror-subnet1',
        headers={'Authorization': 'Bearer ' + token},
        json={
            'network': {
                'url': 'https://www.googleapis.com/compute/v1/projects/PROJECT-ID/global/networks/packet-mirror-vpc',
                'canonicalUrl': 'https://www.googleapis.com/compute/v1/projects/PROJECT-ID/global/networks/NETWORK-ID'
            },
            'enable': 'TRUE'
        },
    )
    print(packet_mirror_api.text)

  else:
    # If response code is not ok (200),
    # print the resulting http error code with description.

    print(my_response.raise_for_status())

