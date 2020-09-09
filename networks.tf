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

 
resource "google_compute_network" "packetMirror_vpc" {
  name                    = "packet-mirror-vpc"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
  project                 = google_project.packetMirror.project_id

  depends_on = [
    # The project's services must be set up before the
    # network is enabled as the compute API will not
    # be enabled and cause the setup to fail.
    google_project_service.compute_api,
  ]

  timeouts {
    create = "10m"
    delete = "10m"
  }
}

resource "google_compute_subnetwork" "webservers" {
  region        = var.region
  name          = "webservers"
  ip_cidr_range = "172.16.20.0/24"
  project       = google_project.packetMirror.project_id
  network       = google_compute_network.packetMirror_vpc.self_link

  timeouts {
    create = "10m"
    delete = "10m"
  }
}


resource "google_compute_subnetwork" "collectors" {
  region        = var.region
  name          = "collectors"
  ip_cidr_range = "172.16.21.0/24"
  project       = google_project.packetMirror.project_id
  network       = google_compute_network.packetMirror_vpc.self_link

  timeouts {
    create = "10m"
    delete = "10m"
  }
}

