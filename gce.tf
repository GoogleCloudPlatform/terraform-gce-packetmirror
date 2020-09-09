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


locals {
  startup = "${file("${path.module}/startup.sh")}"
}

resource "google_compute_instance_template" "webserver" {
  project       = google_project.packetMirror.project_id
  region        = var.region
  name          = "webserver-template"
  description   = "This template is used to create web server instances."

  tags = ["webservers"]

  machine_type   = "n1-standard-1"
  can_ip_forward = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
  disk {
    source_image = "debian-cloud/debian-9"
    auto_delete  = true
    boot         = true
  }

  // Use an existing disk resource
  disk {
    // Instance Templates reference disks by name, not self link
    source_image = "debian-cloud/debian-9"
    auto_delete  = true
    boot         = false
  }

  network_interface {
    subnetwork = google_compute_subnetwork.webservers.self_link
  }

  metadata = {
    startup-script = local.startup
  }

  depends_on = [
    # The project's services must be set up before the
    # instance is enabled as the compute API will not
    # be enabled and cause the setup to fail.
    google_project_service.compute_api,
  ]

}

resource "google_compute_health_check" "http_basic" {
  name                = "http-basic-check"
  project             = google_project.packetMirror.project_id
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10

  http_health_check {
    request_path = "/"
    port         = "80"
  }

  depends_on = [
    # The project's services must be set up before the
    # instance is enabled as the compute API will not
    # be enabled and cause the setup to fail.
    google_project_service.compute_api,  
  ]

}

resource "google_compute_instance_group_manager" "webserver" {
  name               = "webserver-igm"
  project            = var.pid
  base_instance_name = "webserver"
  zone               = var.zone

  version {
    instance_template  = google_compute_instance_template.webserver.self_link
  }

  target_size  = 3

  named_port {
    name = "webservers"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.http_basic.self_link
    initial_delay_sec = 300
  }

  depends_on = [
    # The project's services must be set up before the
    # instance is enabled as the compute API will not
    # be enabled and cause the setup to fail.
    google_project_service.compute_api,  
  ]

}

resource "google_compute_instance" "collector" {
  name                      = "collector"
  machine_type              = "n1-standard-1"
  zone                      = var.zone
  project                   = var.pid
  allow_stopping_for_update = "true"
  can_ip_forward            = "true"

  depends_on = [
    # The compute api must be set up before
    # the collector is created.
    google_project_service.compute_api,
  ]

  metadata_startup_script = local.startup

  tags         = [
    "collector",
  ]

  boot_disk {
    initialize_params {
      image    = "debian-cloud/debian-9"
    }
  }

  network_interface {
    subnetwork =google_compute_subnetwork.collectors.self_link
  }
}

resource "google_compute_instance_group" "collector-ig" {
  name = "collector-ig"
  zone = var.zone

  instances = [
    google_compute_instance.collector.self_link,
  ]

  depends_on = [
    # The project's services must be set up before the
    # instance is enabled as the compute API will not
    # be enabled and cause the setup to fail.
    google_project_service.compute_api,  
  ]
}
