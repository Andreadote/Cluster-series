
# monitor.tf 

resource "datadog_monitor" "process_alert-example" {
  name               = "Process alert monitor"
  type               = "Process alert"
  message            = "Multiple java processes running on example-tag"
  escalation_message = "processes('java').over('example-tag').rollup('count').last('10m') > 1"
  monitor_thresholds {
    critical_recovery = 0.0
    critical          = 1.0

  }

  notify_no_data    = false
  renotify_interval = 60
}

resource "datadog_monitor" "foo" {
  name    = "Name for monitor foo"
  type    = "metric alert"
  message = "Monitor triggered. Notify: @hipchat-channel"
  query   = "avg(last_1h):avg:aws.ec2.cpu{environment:foo,host:foo} by {host}> 2"

  monitor_thresholds {
    ok       = 3
    warning  = 2
    critical = 1
  }

  timeout_h = 24

  include_tags = true
  #silenced {
  # "*" = 0
  # }

  tags = ["foo:bar", "baz"]

}


# Create a new datadog - Amazon Web Services integration
resource "datadog_integration_aws" "sandbox" {
  #account_id = "411854276167"
  account_id                 = data.aws_caller_identity.current.account_id
  role_name                  = "DatadogIntegrationRole"
  metrics_collection_enabled = "true"
  filter_tags                = ["Name:Ansible-Ubuntu"]
  host_tags                  = ["Name:Ansible-Ubuntu"]
  account_specific_namespace_rules = {
    auto_scaling = false
    opworks      = false
  }
  #excluded_regions = ["us-east-1", "us-west-2"]
}


resource "datadog_monitor" "cpuMonitor" {
  #account_id = "411854276167"
  name            = "cpu monitor ${aws_intance.base.id}"
  type            = "metric alert"
  message         = "CPU usage alert"
  query           = "avg(last_1m):avg:system.cpu.system{host:${aws_instance.base.id}} by {host} > 0.1"
  new_group_delay = 30 # just so we can generate an alert quickly


  tags = ["env:prod"]
}


resource "datadog_monitor" "cpuMonitor1" {
  name    = "cpu monitor"
  type    = "metric alert"
  message = "CPU usage alert"
  query   = "avg(last_1m):avg:system.cpu.system{*} by {host} > 60"
}


resource "datadog_monitor" "demo" {
  name               = "Kubernetes Pod Health"
  type               = "metric alert"
  message            = "Kubernetes Pods are not in an optimal health state. Notify: @operator"
  escalation_message = "Please investigate the Kubernetes Pods, @operator"
  priority           = 1

  query = "max(last_1m):sum:kubernetes.containers.running{short_image:demo} <= 1"

  monitor_thresholds {
    ok       = 3
    warning  = 2
    critical = 1
  }

  notify_no_data = true

  tags = ["app:demo", "env:demo"]
}
