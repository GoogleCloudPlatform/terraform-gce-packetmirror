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


resource "google_compute_global_address" "lb" {
  name    = "global-lb-ip"
  project = var.pid

  depends_on = [
    # The project's services must be set up before the
    # resource is enabled as the compute API will not
    # be enabled and cause the setup to fail.
    google_project_service.compute_api,
  ]
}

resource "google_compute_backend_service" "packetMirror" {
  provider      = google-beta
  project       = var.pid
  name          = "packet-mirror-backend"
  health_checks = [google_compute_http_health_check.lb.self_link]

  backend {
    balancing_mode  = "UTILIZATION"
    max_utilization = ".08"
    capacity_scaler = "1"
    group           = google_compute_instance_group_manager.webserver.instance_group
  }
  
  log_config {
    enable = "true"
    sample_rate = "1.0"
  }

  depends_on = [
    # The project's services must be set up before the
    # resource is enabled as the compute API will not
    # be enabled and cause the setup to fail.
    google_project_service.compute_api,
  ]
}

resource "google_compute_http_health_check" "lb" {
  project            = var.pid
  name               = "health-check"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1

  depends_on = [
    # The project's services must be set up before the
    # resource is enabled as the compute API will not
    # be enabled and cause the setup to fail.
    google_project_service.compute_api,
  ]
}

resource "google_compute_url_map" "http_lb" {
  project         = var.pid
  name            = "http-lb"
  default_service = google_compute_backend_service.packetMirror.self_link

  depends_on = [
    # The project's services must be set up before the
    # resource is enabled as the compute API will not
    # be enabled and cause the setup to fail.
    google_project_service.compute_api,
  ]
}

resource "google_compute_target_http_proxy" "http_ib_proxy" {
  project = var.pid
  name    = "http-lb-proxy"
  url_map = google_compute_url_map.http_lb.self_link

  depends_on = [
    # The project's services must be set up before the
    # resource is enabled as the compute API will not
    # be enabled and cause the setup to fail.
    google_project_service.compute_api,
  ]
}

resource "google_compute_global_forwarding_rule" "packetMirror_gfr" {
  project    = var.pid
  name       = "packet-mirror-gfr"
  target     = google_compute_target_http_proxy.http_ib_proxy.self_link
  port_range = "80"
  ip_address = google_compute_global_address.lb.self_link

  depends_on = [
    # The project's services must be set up before the
    # resource is enabled as the compute API will not
    # be enabled and cause the setup to fail.
    google_project_service.compute_api,
  ]
}


