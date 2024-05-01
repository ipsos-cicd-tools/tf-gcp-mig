resource "google_compute_health_check" "default" {
  for_each = var.auto_healing_policies != null ? { "${var.auto_healing_policies.health_check.name}" = var.auto_healing_policies.health_check } : {}

  name                = each.value.name
  description         = lookup(each.value, "description", null)
  healthy_threshold   = lookup(each.value, "healthy_threshold", 2)
  unhealthy_threshold = lookup(each.value, "unhealthy_threshold", 2)
  check_interval_sec  = lookup(each.value, "check_interval_sec", 5)
  timeout_sec         = lookup(each.value, "timeout_sec", 5)

  dynamic "http_health_check" {
    for_each = each.value.http_health_check != null ? [each.value.http_health_check] : []
    content {
      host               = lookup(http_health_check.value, "host", null)
      request_path       = lookup(http_health_check.value, "request_path", "/")
      response           = lookup(http_health_check.value, "response", null)
      port               = lookup(http_health_check.value, "port", 80)
      proxy_header       = lookup(http_health_check.value, "proxy_header", "NONE")
      port_specification = lookup(http_health_check.value, "port_specification", "USE_FIXED_PORT")
    }
  }

  dynamic "https_health_check" {
    for_each = each.value.https_health_check != null ? [each.value.https_health_check] : []
    content {
      host               = lookup(https_health_check.value, "host", null)
      request_path       = lookup(https_health_check.value, "request_path", "/")
      response           = lookup(https_health_check.value, "response", null)
      port               = lookup(https_health_check.value, "port", 80)
      proxy_header       = lookup(https_health_check.value, "proxy_header", "NONE")
      port_specification = lookup(https_health_check.value, "port_specification", "USE_FIXED_PORT")
    }
  }

  dynamic "tcp_health_check" {
    for_each = each.value.tcp_health_check != null ? [each.value.tcp_health_check] : []
    content {
      request            = lookup(tcp_health_check.value, "request", null)
      response           = lookup(tcp_health_check.value, "response", null)
      port               = lookup(tcp_health_check.value, "port", 443)
      proxy_header       = lookup(tcp_health_check.value, "proxy_header", "NONE")
      port_specification = lookup(tcp_health_check.value, "port_specification", "USE_FIXED_PORT")
    }
  }

  dynamic "ssl_health_check" {
    for_each = each.value.ssl_health_check != null ? [each.value.ssl_health_check] : []
    content {
      request            = lookup(ssl_health_check.value, "request", null)
      response           = lookup(ssl_health_check.value, "response", null)
      port               = lookup(ssl_health_check.value, "port", 443)
      proxy_header       = lookup(ssl_health_check.value, "proxy_header", "NONE")
      port_specification = lookup(ssl_health_check.value, "port_specification", "USE_FIXED_PORT")
    }
  }

  dynamic "http2_health_check" {
    for_each = each.value.http2_health_check != null ? [each.value.http2_health_check] : []
    content {
      host               = lookup(http2_health_check.value, "host", null)
      request_path       = lookup(http2_health_check.value, "request_path", "/")
      response           = lookup(http2_health_check.value, "response", null)
      port               = lookup(http2_health_check.value, "port", 80)
      proxy_header       = lookup(http2_health_check.value, "proxy_header", "NONE")
      port_specification = lookup(http2_health_check.value, "port_specification", "USE_FIXED_PORT")
    }
  }

  dynamic "log_config" {
    for_each = each.value.log_config != null ? [each.value.log_config] : []
    content {
      enable = lookup(log_config.value, "enable", false)
    }
  }
}

resource "google_compute_instance_template" "default" {
  for_each = {
    for k, v in var.versions : v.instance_template.name => v
  }

  name                 = each.value.instance_template.name
  machine_type         = lookup(each.value.instance_template, "machine_type", "n1-standard-1")
  can_ip_forward       = lookup(each.value.instance_template, "can_ip_forward", false)
  description          = lookup(each.value.instance_template, "description", null)
  instance_description = lookup(each.value.instance_template, "instance_description", null)
  labels               = lookup(each.value.instance_template, "labels", {})
  metadata             = lookup(each.value.instance_template, "metadata", {})

  dynamic "disk" {
    for_each = each.value.instance_template.disks
    content {
      disk_name    = disk.value.disk_name
      source_image = disk.value.source_image
      auto_delete  = lookup(disk.value, "auto_delete", true)
      boot         = lookup(disk.value, "bool", false)
      device_name  = lookup(disk.value, "device_name", null)
      mode         = lookup(disk.value, "mode", "READ_WRITE")
      disk_type    = lookup(disk.value, "disk_type", "pd-standard")
      disk_size_gb = lookup(disk.value, "disk_size_gb", 10)
      labels       = lookup(disk.value, "labels", {})
    }
  }

  dynamic "network_interface" {
    for_each = each.value.instance_template.network_interfaces
    content {
      network            = lookup(network_interface.value, "network", null)
      subnetwork         = lookup(network_interface.value, "subnetwork", null)
      subnetwork_project = lookup(network_interface.value, "subnetwork_project", null)
      network_ip         = lookup(network_interface.value, "network_ip", null)
      queue_count        = lookup(network_interface.value, "queue_count", null)
      stack_type         = lookup(network_interface.value, "stack_type", "IPV4_ONLY")
    }
  }

  project = lookup(each.value.instance_template, "project", null)
  region  = lookup(each.value.instance_template, "region", null)

  dynamic "reservation_affinity" {
    for_each = each.value.instance_template.reservation_affinity != null ? [each.value.instance_template.reservation_affinity] : []
    content {
      type = lookup(reservation_affinity.value, "type", "ANY_RESERVATION")
    }
  }

  dynamic "scheduling" {
    for_each = each.value.instance_template.scheduling != null ? [each.value.instance_template.scheduling] : []
    content {
      automatic_restart   = lookup(scheduling.value, "automatic_restart", true)
      on_host_maintenance = lookup(scheduling.value, "on_host_maintenance", "MIGRATE")
      preemptible         = lookup(scheduling.value, "preemptible", false)
      provisioning_model  = lookup(scheduling.value, "provisioning_model", "STANDARD")
    }
  }

  dynamic "service_account" {
    for_each = each.value.instance_template.service_account != null ? [each.value.instance_template.service_account] : []
    content {
      email  = lookup(service_account.value, "email", null)
      scopes = lookup(service_account.value, "scopes", ["cloud-platform"])
    }
  }

  tags = lookup(each.value.instance_template, "tags", [])

  dynamic "guest_accelerator" {
    for_each = each.value.instance_template.guest_accelerator != null ? [each.value.instance_template.guest_accelerator] : []
    content {
      type  = lookup(guest_accelerator.value, "type", null)
      count = lookup(guest_accelerator.value, "count", 0)
    }
  }

  min_cpu_platform = lookup(each.value, "min_cpu_platform", null)

  dynamic "shielded_instance_config" {
    for_each = each.value.instance_template.shielded_instance_config != null ? [each.value.instance_template.shielded_instance_config] : []
    content {
      enable_secure_boot          = lookup(shielded_instance_config.value, "enable_secure_boot", false)
      enable_vtpm                 = lookup(shielded_instance_config.value, "enable_vtpm", true)
      enable_integrity_monitoring = lookup(shielded_instance_config.value, "enable_integrity_monitoring", true)
    }
  }
}

resource "google_compute_instance_group_manager" "default" {
  name               = var.name
  base_instance_name = var.base_instance_name
  zone               = var.zone
  description        = var.description

  dynamic "named_port" {
    for_each = var.named_port != null ? [var.named_port] : []
    content {
      name = lookup(named_port.value, "name", null)
      port = lookup(named_port.value, "port", null)
    }
  }

  project                        = var.project
  target_size                    = var.target_size
  list_managed_instances_results = var.list_managed_instances_results
  wait_for_instances             = var.wait_for_instances
  wait_for_instances_status      = var.wait_for_instances_status

  dynamic "auto_healing_policies" {
    for_each = var.auto_healing_policies != null ? [var.auto_healing_policies] : []
    content {
      health_check      = google_compute_health_check.default[auto_healing_policies.value.health_check.name].self_link
      initial_delay_sec = auto_healing_policies.value.initial_delay_sec
    }
  }

  dynamic "version" {
    for_each = {
      for k, v in var.versions : v.name => v
    }
    content {
      name              = version.value.name
      instance_template = google_compute_instance_template.default[version.value.instance_template.name].self_link
    }
  }

  depends_on = [google_compute_instance_template.default[version.value.instance_template.name], google_compute_health_check.default[auto_healing_policies.value.health_check.name]]

  dynamic "update_policy" {
    for_each = var.update_policy != null ? [var.update_policy] : []
    content {
      type                    = lookup(update_policy.value, "type", "PROACTIVE")
      minimal_action          = lookup(update_policy.value, "minimal_action", "REPLACE")
      max_surge_fixed         = lookup(update_policy.value, "max_surge_fixed", 1)
      max_unavailable_fixed   = lookup(update_policy.value, "max_unavailable_fixed", 1)
      max_surge_percent       = lookup(update_policy.value, "max_surge_percent", null)
      max_unavailable_percent = lookup(update_policy.value, "max_unavailable_percent", null)
      replacement_method      = lookup(update_policy.value, "replacement_method", "SUBSTITUTE")
    }
  }

  lifecycle {
    ignore_changes = [
      target_size
    ]
  }
}

resource "google_compute_autoscaler" "default" {
  for_each = var.autoscaling != null ? { "${var.autoscaling.name}" = var.autoscaling } : {}

  name        = each.value.name
  zone        = each.value.zone
  target      = google_compute_instance_group_manager.default.self_link
  description = lookup(each.value, "description", null)
  project     = lookup(each.value, "project", null)

  depends_on = [google_compute_instance_group_manager.default]

  dynamic "autoscaling_policy" {
    for_each = {
      for k, v in each.value.autoscaling_policy : k => v
    }
    content {
      min_replicas    = lookup(autoscaling_policy.value, "min_replicas", 1)
      max_replicas    = lookup(autoscaling_policy.value, "max_replicas", 1)
      cooldown_period = lookup(autoscaling_policy.value, "cooldown_period", 60)
      mode            = lookup(autoscaling_policy.value, "mode", "OFF")

      dynamic "scale_in_control" {
        for_each = autoscaling_policy.value.scale_in_control != null ? [autoscaling_policy.value.scale_in_control] : []
        content {
          dynamic "max_scaled_in_replicas" {
            for_each = scale_in_control.value.max_scaled_in_replicas != null ? [scale_in_control.value.max_scaled_in_replicas] : []
            content {
              fixed   = lookup(max_scaled_in_replicas.value, "fixed", null)
              percent = lookup(max_scaled_in_replicas.value, "percent", null)
            }
          }
          time_window_sec = lookup(scale_in_control.value, "time_window_sec", null)
        }
      }

      dynamic "cpu_utilization" {
        for_each = autoscaling_policy.value.cpu_utilization != null ? [autoscaling_policy.value.cpu_utilization] : []
        content {
          predictive_method = lookup(cpu_utilization.value, "predictive_method", "NONE")
          target            = lookup(cpu_utilization.value, "target", null)
        }
      }

      dynamic "load_balancing_utilization" {
        for_each = autoscaling_policy.value.load_balancing_utilization != null ? [autoscaling_policy.value.load_balancing_utilization] : []
        content {
          target = lookup(load_balancing_utilization.value, "target", 0.8)
        }
      }

      dynamic "scaling_schedules" {
        for_each = autoscaling_policy.value.scaling_schedules != null ? autoscaling_policy.value.scaling_schedules : []
        content {
          name                  = scaling_schedules.value.name
          min_required_replicas = scaling_schedules.value.min_required_replicas
          schedule              = scaling_schedules.value.schedule
          duration_sec          = scaling_schedules.value.duration_sec
          time_zone             = lookup(scaling_schedules.value, "time_zone", null)
          disabled              = lookup(scaling_schedules.value, "disabled", false)
          description           = lookup(scaling_schedules.value, "description", null)
        }
      }
    }
  }
}