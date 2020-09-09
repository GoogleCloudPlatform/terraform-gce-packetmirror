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

#<!--* freshness: { owner: 'ttaggart@google.com' reviewed: '2019-mar-01' } *-->

 
resource "google_compute_firewall" "allow-collector-ingress" {
  name          = "allow-collector-ingress"
  network       = google_compute_network.packetMirror_vpc.name
  project       = google_project.packetMirror.project_id
  target_tags   = ["collector"]

  source_ranges = [
    "0.0.0.0/0", 
  ]

  allow {
    protocol    = "tcp"
  }

   allow {
    protocol    = "udp"
  }

  allow {
    protocol    = "icmp"
  }
}

resource "google_compute_firewall" "allow-ssh" {
  name          = "allow-ssh"
  network       = google_compute_network.packetMirror_vpc.name
  project       = google_project.packetMirror.project_id

  source_ranges = [
    "35.235.240.0/20", 
  ]

  allow {
    protocol    = "tcp"
    ports       = ["22"]
  }
}

resource "google_compute_firewall" "allow-health-check-and-proxy" {
  name          = "allow-health-check-and-proxy"
  network       = google_compute_network.packetMirror_vpc.name
  project       = google_project.packetMirror.project_id
  target_tags   = ["webservers"]

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22", 
  ]

  allow {
    protocol    = "tcp"
    ports       = ["80","443"]
  }
}
