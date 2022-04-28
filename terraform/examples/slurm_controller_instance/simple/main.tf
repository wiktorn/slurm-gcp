/**
 * Copyright (C) SchedMD LLC.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

provider "google" {
  project = var.project_id
}

data "google_compute_subnetwork" "default" {
  name   = "default"
  region = var.region
}

module "slurm_partition0" {
  source = "../../../modules/slurm_partition"

  partition_name = "debug"
  partition_conf = {
    Default = "YES"
  }
  partition_nodes = [
    {
      group_name    = "test"
      count_dynamic = 10
      count_static  = 0
      node_conf     = {}

      additional_disks         = []
      can_ip_forward           = false
      disable_smt              = false
      disk_auto_delete         = true
      disk_labels              = {}
      disk_size_gb             = 32
      disk_type                = "pd-standard"
      enable_confidential_vm   = false
      enable_oslogin           = true
      enable_shielded_vm       = false
      enable_spot_vm           = false
      gpu                      = null
      instance_template        = null
      labels                   = {}
      machine_type             = "c2-standard-4"
      metadata                 = {}
      min_cpu_platform         = null
      on_host_maintenance      = null
      preemptible              = false
      service_account          = null
      shielded_instance_config = null
      spot_instance_config     = null
      source_image_family      = null
      source_image_project     = null
      source_image             = null
      tags                     = []
    },
  ]
  project_id         = var.project_id
  slurm_cluster_name = var.slurm_cluster_name
  subnetwork         = data.google_compute_subnetwork.default.self_link
}

module "slurm_partition1" {
  source = "../../../modules/slurm_partition"

  partition_name = "debug2"
  partition_conf = {
    Default = "NO"
  }
  partition_nodes = [
    {
      group_name    = "gpu"
      count_dynamic = 10
      count_static  = 0
      node_conf     = {}

      additional_disks       = []
      can_ip_forward         = false
      disable_smt            = false
      disk_auto_delete       = true
      disk_labels            = {}
      disk_size_gb           = 32
      disk_type              = "pd-standard"
      enable_confidential_vm = false
      enable_oslogin         = true
      enable_shielded_vm     = false
      enable_spot_vm         = false
      gpu = {
        count = 1
        type  = "nvidia-tesla-v100"
      }
      instance_template        = null
      labels                   = {}
      machine_type             = "n1-standard-4"
      metadata                 = {}
      min_cpu_platform         = null
      on_host_maintenance      = null
      preemptible              = false
      service_account          = null
      shielded_instance_config = null
      spot_instance_config     = null
      source_image_family      = null
      source_image_project     = null
      source_image             = null
      tags                     = []
    },
  ]
  project_id         = var.project_id
  slurm_cluster_name = var.slurm_cluster_name
  subnetwork         = data.google_compute_subnetwork.default.self_link
}

module "slurm_controller_template" {
  source = "../../../modules/slurm_instance_template"

  project_id = var.project_id
  subnetwork = data.google_compute_subnetwork.default.self_link

  slurm_cluster_name = var.slurm_cluster_name
}

module "slurm_controller_instance" {
  source = "../../../modules/slurm_controller_instance"

  instance_template  = module.slurm_controller_template.self_link
  subnetwork         = data.google_compute_subnetwork.default.self_link
  project_id         = var.project_id
  slurm_cluster_name = var.slurm_cluster_name
  partitions = [
    module.slurm_partition0,
    module.slurm_partition1,
  ]
}
