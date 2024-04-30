variable "name" {
  description = "The name of the instance group manager."
  type        = string
}

variable "base_instance_name" {
  description = "The base instance name to use for instances in this group."
  type        = string
}

variable "zone" {
  description = "The zone that instances in this group should be created in."
  type        = string
  default     = null
}

# variable "region" {
#   description = "value"
#   type = string
#   default = null
# }

variable "description" {
  description = "An optional textual description of the instance group manager."
  type        = string
  default     = null
}

variable "named_port" {
  description = "The named port configuration."
  type = object({
    name = string
    port = number
  })
  default = null
}

variable "project" {
  description = "The ID of the project in which the resource belongs."
  type        = string
  default     = null
}

variable "target_size" {
  description = "The target number of running instances for this managed instance group. This value will fight with autoscaler settings when set, and generally shouldn't be set when using one."
  type        = number
  default     = 0
}

variable "list_managed_instances_results" {
  description = "Pagination behavior of the listManagedInstances API method for this managed instance group. Valid values are: PAGELESS, PAGINATED. If PAGELESS (default)."
  type        = string
  default     = "PAGELESS"
}

variable "wait_for_instances" {
  description = "Whether to wait for all instances to be created/updated before returning. Note that if this is set to true and the operation does not succeed, Terraform will continue trying until it times out."
  type        = bool
  default     = false
}

variable "wait_for_instances_status" {
  description = "When used with wait_for_instances it specifies the status to wait for. When STABLE is specified this resource will wait until the instances are stable before returning. When UPDATED is set, it will wait for the version target to be reached and any per instance configs to be effective as well as all instances to be stable before returning."
  type        = string
  default     = "STABLE"
}

variable "auto_healing_policies" {
  description = "The autohealing policies for this managed instance group. You can specify only one value."
  type = object({
    health_check = object({
      name                = string
      description         = optional(string, null)
      healthy_threshold   = optional(number, 2)
      unhealthy_threshold = optional(number, 2)
      timeout_sec         = optional(number, 5)
      check_interval_sec  = optional(number, 5)
      http_health_check = optional(object({
        host               = optional(string, null)
        request_path       = optional(string, "/")
        response           = optional(string, null)
        port               = optional(number, 80)
        proxy_header       = optional(string, "NONE")
        port_specification = optional(string, "USE_FIXED_PORT")
      }), null)
      https_health_check = optional(object({
        host               = optional(string, null)
        request_path       = optional(string, "/")
        response           = optional(string, null)
        port               = optional(number, 443)
        proxy_header       = optional(string, "NONE")
        port_specification = optional(string, "USE_FIXED_PORT")
      }), null)
      tcp_health_check = optional(object({
        request            = optional(string, null)
        response           = optional(string, null)
        port               = optional(number, 443)
        proxy_header       = optional(string, "NONE")
        port_specification = optional(string, "USE_FIXED_PORT")
      }), null)
      ssl_health_check = optional(object({
        request            = optional(string, null)
        response           = optional(string, null)
        port               = optional(number, 443)
        proxy_header       = optional(string, "NONE")
        port_specification = optional(string, "USE_FIXED_PORT")
      }), null)
      http2_health_check = optional(object({
        host               = optional(string, null)
        request_path       = optional(string, "/")
        response           = optional(string, null)
        port               = optional(number, 443)
        proxy_header       = optional(string, "NONE")
        port_specification = optional(string, "USE_FIXED_PORT")
      }), null)
      log_config = optional(object({
        enable = optional(bool, false)
      }), null)
    })
    initial_delay_sec = number
  })
  default = null
}

variable "versions" {
  description = "Application versions managed by this instance group. Each version deals with a specific instance template, allowing canary release scenarios."
  type = list(object({
    name = string
    instance_template = object({
      name         = string
      machine_type = string
      disks = list(object({
        auto_delete  = optional(bool, true)
        boot         = optional(bool, false)
        device_name  = optional(string, null)
        disk_name    = string
        source_image = string
        mode         = optional(string, "READ_WRITE")
        disk_type    = optional(string, "pd-standard")
        disk_size_gb = optional(number, 10)
        labels       = optional(map(any), {})
      }))
      can_ip_forward       = optional(bool, false)
      description          = optional(string, null)
      instance_description = optional(string, null)
      labels               = optional(map(any), {})
      metadata             = optional(map(any), {})
      network_interfaces = list(object({
        network            = optional(string, null)
        subnetwork         = optional(string, null)
        subnetwork_project = optional(string, null)
        network_ip         = optional(string, null)
        queue_count        = optional(number, null)
        stack_type         = optional(string, "IPV4_ONLY")
      }))
      project = optional(string, null)
      region  = optional(string, null)
      reservation_affinity = optional(object({
        type = optional(string, "ANY_RESERVATION")
      }), null)
      scheduling = optional(object({
        automatic_restart   = optional(bool, true)
        on_host_maintenance = optional(string, "MIGRATE")
        preemptible         = optional(bool, false)
        provisioning_model  = optional(string, "STANDARD")
      }))
      service_account = optional(object({
        email  = optional(string, null)
        scopes = optional(list(string), ["cloud-platform"])
      }), null)
      tags = optional(map(any), {})
      guest_accelerator = optional(object({
        type  = string
        count = number
      }), null)
      min_cpu_platform = optional(string, null)
      shielded_instance_config = optional(object({
        enable_secure_boot          = optional(bool, false)
        enable_vtpm                 = optional(bool, true)
        enable_integrity_monitoring = optional(bool, true)
      }), null)
    })
  }))
  default = []
}

variable "update_policy" {
  description = "The update policy for this managed instance group."
  type = object({
    type                    = optional(string, "PROACTIVE")
    minimal_action          = optional(string, "REPLACE")
    max_surge_fixed         = optional(number, 1)
    max_unavailable_fixed   = optional(number, 1)
    max_surge_percent       = optional(number, null)
    max_unavailable_percent = optional(number, null)
    replacement_method      = optional(string, "SUBSTITUTE")
  })
  default = null
}

variable "autoscaling" {
  description = "value"
  type = object({
    name        = string
    description = optional(string, null)
    zone        = optional(string, null)
    project     = optional(string, null)
    autoscaling_policy = object({
      min_replicas    = optional(number, null)
      max_replicas    = optional(number, null)
      cooldown_period = optional(number, 60)
      mode            = optional(string, "OFF")
      scale_in_control = optional(object({
        max_scaled_in_replicas = optional(object({
          fixed   = optional(number, null)
          percent = optional(number, null)
        }), null)
        time_window_sec = optional(number, null)
      }), null)
      cpu_utilization = optional(object({
        predictive_method = optional(string, "NONE")
        target            = optional(number, null)
      }), null)
      load_balancing_utilization = optional(object({
        target = optional(number, 0.8)
      }), null)
      scaling_schedules = optional(list(object({
        name                  = string
        min_required_replicas = number
        schedule              = string
        time_zone             = string
        duration_sec          = number
        disabled              = optional(bool, false)
        description           = optional(string, null)
      })), null)
    })
  })
  default = null
}
