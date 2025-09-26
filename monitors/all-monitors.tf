resource "datadog_monitor" "Replication_Slot_Inactive" {
  escalation_message = <<EOT

EOT
  include_tags = false
  new_group_delay = 60
  notification_preset_name = "hide_all"
  on_missing_data = "default"
  require_full_window = false
  monitor_thresholds {
    critical = 0.5
  }
  name = "Replication Slot Inactive"
  type = "query alert"
  tags = ["team:platform-infrastructure-team"]
  query = <<EOT
avg(last_5m):max:saviadb.replication_slot.active{slot_type:logical} by {database_instance,slot_name} < 0.5
EOT
  message = <<EOT
The replication slot {{slot_name.name}} is inactive on database host {{database_instance.name}} @teams-NotificationsAlerts @pagerduty-Platform_Team_Service @oncall-platform-infrastructure-team
EOT
}

# ----------------------------------------
# Next Monitor
# ----------------------------------------

resource "datadog_monitor" "Database_is_down" {
  escalation_message = <<EOT

EOT
  new_group_delay = 60
  notification_preset_name = "hide_all"
  require_full_window = false
  monitor_thresholds {
    critical = 3
    ok = 1
    warning = 1
  }
  name = "Database is down"
  type = "service check"
  tags = ["team:platform-infrastructure-team"]
  query = <<EOT
"postgres.can_connect".over("*").by("host").last(4).count_by_status()
EOT
  message = <<EOT
Database {{host.name}} appears to be unavailable @teams-NotificationsAlerts @pagerduty-Platform_Team_Service @oncall-platform-infrastructure-team
EOT
}

# ----------------------------------------
# Next Monitor
# ----------------------------------------

resource "datadog_monitor" "Replication_Backlog_Size" {
  new_group_delay = 60
  require_full_window = false
  monitor_thresholds {
    critical = 50000000000
    warning = 20000000000
  }
  name = "Replication Backlog Size"
  type = "query alert"
  tags = ["team:platform-infrastructure-team"]
  query = <<EOT
avg(last_5m):avg:saviadb.replication_slot.backlog_size{*} by {database_instance,slot_name} > 50000000000
EOT
  message = <<EOT
{{#is_warning}}
Replication backlog for {{slot_name.name}} on {{database_instance.name}} is higher than it should be. @teams-NotificationsAlerts
{{/is_warning}}
{{#is_alert}}
Replication backlog for {{slot_name.name}} on {{database_instance.name}} has exceeded tolerable size. Please address. @pagerduty-Platform_Team_Service @teams-NotificationsAlerts
{{/is_alert}}
{{#is_recovery}}
Replication backlog for {{slot_name.name}} on {{database_instance.name}} is recovered. @pagerduty-Platform_Team_Service  @teams-NotificationsAlerts
{{/is_recovery}}
EOT
}

# ----------------------------------------
# Next Monitor
# ----------------------------------------

resource "datadog_monitor" "Kafka_Consumer_Lag" {
  include_tags = false
  new_group_delay = 60
  notification_preset_name = "hide_all"
  notify_by = ["*"]
  on_missing_data = "default"
  require_full_window = false
  monitor_thresholds {
    critical = 1000
    warning = 500
  }
  name = "Kafka Consumer Lag"
  type = "query alert"
  tags = ["team:platform-infrastructure-team"]
  query = <<EOT
min(last_7m):min:kafka_consumergroup_lag_sum{!consumergroup:cli*} by {kube_namespace,topic,consumergroup} > 1000
EOT
  message = <<EOT
The lag for Kafka consumer group {{consumergroup.name}} has exceeded ideal levels for topic {{topic.name}} in {{kube_namespace.name}}
{{#is_warning}}
@teams-NotificationsAlerts
{{/is_warning}}
{{#is_alert}}
@pagerduty-Platform_Team_Service
{{/is_alert}}
{{#is_recovery}}
@teams-NotificationsAlerts @pagerduty-Platform_Team_Service
{{/is_recovery}} @oncall-platform-infrastructure-team
EOT
}

# ----------------------------------------
# Next Monitor
# ----------------------------------------

resource "datadog_monitor" "Excessive_Database_Growth" {
  evaluation_delay = 300
  new_group_delay = 60
  require_full_window = false
  monitor_thresholds {
    critical = 5
    warning = 3
  }
  name = "Excessive Database Growth"
  type = "query alert"
  tags = ["team:platform-infrastructure-team"]
  query = <<EOT
change(avg(last_4h),last_1h):avg:azure.dbforpostgresql_flexibleservers.storage_percent{*} by {database_instance} > 5
EOT
  message = <<EOT
{{database_instance.name}} is experiencing unusually high growth. @teams-NotificationsAlerts
EOT
}

# ----------------------------------------
# Next Monitor
# ----------------------------------------

resource "datadog_monitor" "Pulsar_Backlog_High" {
  new_group_delay = 60
  on_missing_data = "show_no_data"
  require_full_window = false
  monitor_thresholds {
    critical = 1000
    warning = 500
  }
  name = "Pulsar Backlog High"
  type = "query alert"
  tags = ["team:platform-infrastructure-team"]
  query = <<EOT
min(last_15m):sum:pulsar.subscription_back_log{NOT subscription:_compaction AND NOT subscription:*reader* AND (namespace:clinical-apps/* OR namespace:inbound/clinical-events) AND NOT subscription:*-dlt AND NOT subscription:*-DLT} by {subscription} > 1000
EOT
  message = <<EOT
The total Pulsar subscription backlog for namespace {{namespace.name}} is higher than expected.
{{#is_warning}}@teams-NotificationsAlerts{{/is_warning}}
{{#is_alert}}@pagerduty-Platform_Team_Service @teams-NotificationsAlerts {{/is_alert}}
{{#is_recovery}}
@teams-NotificationsAlerts  @pagerduty-Platform_Team_Service
{{/is_recovery}} @oncall-platform-infrastructure-team
EOT
}

# ----------------------------------------
# Next Monitor
# ----------------------------------------

resource "datadog_monitor" "Pulsar_DLT_Backlog_High" {
  new_group_delay = 60
  require_full_window = false
  monitor_thresholds {
    critical = 1000
    warning = 10
  }
  name = "Pulsar DLT Backlog High"
  type = "query alert"
  tags = ["team:platform-infrastructure-team"]
  query = <<EOT
min(last_5m):sum:pulsar.subscription_back_log{subscription:*-dlt OR subscription:*-DLT} by {namespace,subscription} > 1000
EOT
  message = <<EOT
The Pulsar dead-letter subscription backlog for namespace {{subscription.name}} is higher than expected.
EOT
}

# ----------------------------------------
# Next Monitor
# ----------------------------------------

resource "datadog_monitor" "Heap_of_Trouble" {
  new_group_delay = 60
  require_full_window = false
  timeout_h = 1
  monitor_thresholds {
    critical = 97
  }
  name = "Heap of Trouble"
  type = "query alert"
  tags = ["team:platform-infrastructure-team"]
  query = <<EOT
avg(last_5m):avg:jvm_memory_used_bytes{area:heap, kube_container_name:abd-apps-server*} by {kube_namespace,pod_name} * 100 / avg:jvm_memory_max_bytes{area:heap, kube_container_name:abd-apps-server*} by {kube_namespace,pod_name} > 97
EOT
  message = <<EOT
Heap memory exhausted in {{kube_replica_set.name}} or {{kube_stateful_set.name}} in {{kube_namespace.name}} @teams-NotificationsAlerts
EOT
}

# ----------------------------------------
# Next Monitor
# ----------------------------------------

resource "datadog_monitor" "In-n-Out_Burger_FHIR_Ingress" {
  include_tags = false
  new_group_delay = 60
  monitor_thresholds {
    critical = 1000
  }
  name = "In-n-Out Burger: FHIR Ingress"
  type = "query alert"
  tags = ["team:platform-infrastructure-team"]
  query = <<EOT
avg(last_5m):abs(diff(sum:pulsar.out_messages_total{topic:*/abd-fhir-ingress} by {namespace}) - diff(sum:pulsar.in_messages_total{topic:*/abd-fhir-ingress} by {namespace})) > 1000
EOT
  message = <<EOT
Pulsar message rate in and rate out do not match for the abd-fhir-ingress topic in namespace {{namespace.name}}.

If message out rate exceeds message in rate you may want to look for excessive retries due to message failures.

If message in rate exceeds message out rate you may want to verify that consumers are still connected and receiving messages.

@pagerduty-Platform_Team_Service
@teams-NotificationsAlerts
EOT
}

# ----------------------------------------
# Next Monitor
# ----------------------------------------

resource "datadog_monitor" "In-n-Out_Burger_External_WF_Task_Triggered" {
  include_tags = false
  new_group_delay = 60
  monitor_thresholds {
    critical = 4000
  }
  name = "In-n-Out Burger: External WF Task Triggered"
  type = "query alert"
  tags = ["team:platform-infrastructure-team"]
  query = <<EOT
avg(last_5m):abs(diff(sum:pulsar.out_messages_total{topic:*/external-workflow-task-triggered*} by {namespace}) - diff(sum:pulsar.in_messages_total{topic:*/external-workflow-task-triggered*} by {namespace})) > 4000
EOT
  message = <<EOT
Pulsar message rate in and rate out do not match for the external-workflow-task-triggered topic in namespace {{namespace.name}}.

If message out rate exceeds message in rate you may want to look for excessive retries due to message failures.

If message in rate exceeds message out rate you may want to verify that consumers are still connected and receiving messages.

@pagerduty-Platform_Team_Service
@teams-NotificationsAlerts
EOT
}

# ----------------------------------------
# Next Monitor
# ----------------------------------------

resource "datadog_monitor" "In-n-Out_Burger_Model_Persisted_Events" {
  include_tags = false
  new_group_delay = 60
  monitor_thresholds {
    critical = 4000
  }
  name = "In-n-Out Burger: Model Persisted Events"
  type = "query alert"
  tags = ["team:platform-infrastructure-team"]
  query = <<EOT
avg(last_5m):abs((diff(sum:pulsar.out_messages_total{topic:*/abd_db.art.model_persisted_event_journal} by {namespace}) / max:pulsar.subscriptions_count{topic:*/abd_db.art.model_persisted_event_journal} by {namespace}) - diff(sum:pulsar.in_messages_total{topic:*/abd_db.art.model_persisted_event_journal} by {namespace})) > 4000
EOT
  message = <<EOT
Pulsar message rate in and rate out do not match for the abd_db.model_persisted_event_journal topic in namespace {{namespace.name}}.

If message out rate exceeds message in rate you may want to look for excessive retries due to message failures.

If message in rate exceeds message out rate you may want to verify that consumers are still connected and receiving messages.

@pagerduty-Platform_Team_Service
@teams-NotificationsAlerts
EOT
}

# ----------------------------------------
# Next Monitor
# ----------------------------------------

resource "datadog_monitor" "Log_Ingestion_On_the_Rise" {
  include_tags = false
  require_full_window = false
  monitor_thresholds {
    critical = 200000000
  }
  name = "Log Ingestion On the Rise"
  type = "query alert"
  tags = ["team:platform-infrastructure-team"]
  query = <<EOT
change(avg(last_1h),last_1d):sum:datadog.estimated_usage.logs.ingested_bytes{*} > 200000000
EOT
  message = <<EOT
Log ingestion has increase by more than 10GB since the same time the previous day. @teams-NotificationsAlerts
EOT
}

# ----------------------------------------
# Next Monitor
# ----------------------------------------

resource "datadog_monitor" "DB_Connections_High_for_database_instancename" {
  evaluation_delay = 300
  new_group_delay = 60
  on_missing_data = "show_no_data"
  require_full_window = false
  monitor_thresholds {
    critical = 90
    warning = 75
  }
  name = "DB Connections High for {{database_instance.name}}"
  type = "query alert"
  tags = ["team:platform-infrastructure-team"]
  query = <<EOT
avg(last_15m):avg:postgresql.connections{*} by {database_instance} * 100 / max:postgresql.max_connections{*} by {database_instance} > 90
EOT
  message = <<EOT
Number of database connections higher than expected for database {{database_instance.name}}

Consider reviewing connected cleints (SELECT client_addr, count(datid) FROM pg_stat_activity group by client_addr order by 2 desc) or adding a network monitor to analyze traffic.

{{#is_warning}}@teams-NotificationsAlerts {{/is_warning}}
{{#is_alert}}@pagerduty-Platform_Team_Service  @teams-NotificationsAlerts {{/is_alert}}
{{#is_recovery}}@teams-NotificationsAlerts  @pagerduty-Platform_Team_Service {{/is_recovery}}
EOT
}

# ----------------------------------------
# Next Monitor
# ----------------------------------------

resource "datadog_monitor" "Analytics_DB_Stroage_Alert" {
  evaluation_delay = 300
  include_tags = false
  on_missing_data = "default"
  require_full_window = false
  monitor_thresholds {
    critical = 85
  }
  name = "Analytics DB Stroage Alert"
  type = "query alert"
  tags = ["team:platform-infrastructure-team"]
  query = <<EOT
avg(last_1h):avg:azure.dbforpostgresql_flexibleservers.storage_percent{database_instance:savia-analytics-psql-ihc-database-prd-9f41.postgres.database.azure.com} > 85
EOT
  message = <<EOT
The storage for savia-analytics database has exceeded 70% -- check qvera usage etc.
@pagerduty-Platform_Team_Service  @teams-NotificationsAlerts
EOT
}

# ----------------------------------------
# Next Monitor
# ----------------------------------------

resource "datadog_monitor" "Transient_Exception_Alert" {
  new_group_delay = 60
  on_missing_data = "resolve"
  require_full_window = false
  monitor_thresholds {
    critical = 1000
    warning = 500
  }
  name = "Transient Exception Alert"
  type = "query alert"
  tags = ["team:platform-infrastructure-team"]
  query = <<EOT
sum(last_5m):min:savia.transientPipelineErrors{*} by {kube_namespace,service}.as_count().fill(zero) > 1000
EOT
  message = <<EOT
Transient exceptions are occurring in {{service.name}} in the {{kube_namespace.name}} namespace. Ignoring this can cause missed data and/or excessive log usage.
@teams-NotificationsAlerts @oncall-platform-infrastructure-team
EOT
}

# ----------------------------------------
# Next Monitor
# ----------------------------------------

resource "datadog_monitor" "Ponderous_Pod_kube_namespacename_-_pod_namename" {
  new_group_delay = 60
  on_missing_data = "resolve"
  require_full_window = false
  monitor_thresholds {
    critical = 10
    warning = 5
  }
  name = "Ponderous Pod {{kube_namespace.name}} - {{pod_name.name}}"
  type = "query alert"
  tags = ["team:platform-infrastructure-team"]
  query = <<EOT
change(max(last_1h),last_5m):max:kubernetes.containers.restarts{*} by {kube_namespace,pod_name} > 10
EOT
  message = <<EOT
Pod {{pod_name.name}} in namespace {{kube_namespace.name}} has been doing a lot of restarting.
@teams-NotificationsAlerts
EOT
}

# ----------------------------------------
# Next Monitor
# ----------------------------------------

resource "datadog_monitor" "QIE_Too_Many_Errors" {
  new_group_delay = 60
  on_missing_data = "default"
  require_full_window = false
  monitor_thresholds {
    critical = 200
  }
  name = "QIE Too Many Errors"
  type = "query alert"
  tags = ["team:platform-infrastructure-team"]
  query = <<EOT
avg(last_5m):max:qie.channel.errors{!channel.name:*location* , !channel.name:*lbh* , !channel.name:peaks-v2} by {channel.name} > 200
EOT
  message = <<EOT
The qie error backlog for {{[channel.name].name}} has exceeded 200 and needs to be resolved manually.
@teams-NotificationsAlerts @pagerduty-Platform_Team_Service @oncall-platform-infrastructure-team
EOT
}

# ----------------------------------------
# Next Monitor
# ----------------------------------------

resource "datadog_monitor" "QIE_Unresolved_Errors" {
  new_group_delay = 60
  on_missing_data = "default"
  require_full_window = false
  monitor_thresholds {
    critical = 199
    warning = 50
  }
  name = "QIE Unresolved Errors"
  type = "query alert"
  tags = ["team:platform-infrastructure-team"]
  query = <<EOT
min(last_30m):min:qie.channel.errors{!channel.name:*location* , !channel.name:*lbh* , !channel.name:peaks-v2 , !channel.name:metrics} by {channel.name} > 199
EOT
  message = <<EOT
The qie error backlog for {{[channel.name].name}} has unresolved errors and needs to be resolved manually.
@teams-NotificationsAlerts @pagerduty-Platform_Team_Service @oncall-platform-infrastructure-team
EOT
}

# ----------------------------------------
# Next Monitor
# ----------------------------------------

resource "datadog_monitor" "Where_Did_Everybody_Go" {
  enable_logs_sample = true
  groupby_simple_monitor = false
  on_missing_data = "show_and_notify_no_data"
  require_full_window = false
  monitor_thresholds {
    critical = 0
  }
  variables {
    event_query {
      compute {
        aggregation = "count"
      }
      data_source = "logs"
      name = "query"
      search {
        query = <<EOT
kube_namespace:integration environment:prd @channelName:*HL7* "message processed"
EOT
      }
      group_by {
        facet = "@channelName"
        limit = 10
        sort {
          aggregation = "count"
          order = "desc"
          metric = "count"
        }
        should_exclude_missing = true
      }
      indexes = ["*"]
    }
  }
  name = "Where Did Everybody Go"
  type = "log alert"
  tags = ["team:platform-infrastructure-team"]
  query = <<EOT
formula("default_zero(throughput(query))").last("5m") == 0
EOT
  message = <<EOT
Inbound data on {{@channelName.name}} appears to have stopped.
@oncall-platform-infrastructure-team @teams-NotificationsAlerts
EOT
}

# ----------------------------------------
# Next Monitor
# ----------------------------------------

resource "datadog_monitor" "Overly_Ingressive_Behavior_in_kube_namespacename" {
  new_group_delay = 60
  on_missing_data = "default"
  require_full_window = false
  monitor_thresholds {
    critical = 2500
    warning = 1250
  }
  name = "Overly Ingressive Behavior in {{kube_namespace.name}}"
  type = "query alert"
  tags = ["team:platform-infrastructure-team"]
  query = <<EOT
sum(last_5m):sum:savia.event.received{container_name:pubsub-ingress-service} by {client,kube_namespace}.as_count() > 2500
EOT
  message = <<EOT
{{client.name}} ingress rates in namespace {{kube_namespace.name}} are well above normal. You may want to monitor for growing backlogs.
TIP: MESSAGING_PULSAR_CONSUMER_IGNOREMESSAGEKEYS environment variable can be used in older fhir-ingress pipelines to skip messages.
Notify: @teams-NotificationsAlerts
{{#is_alert}}@oncall-platform-infrastructure-team {{/is_alert}}
{{#is_alert_recovery}}@oncall-platform-infrastructure-team {{/is_alert_recovery}}
EOT
}

# ----------------------------------------
# Next Monitor
# ----------------------------------------

resource "datadog_monitor" "Tired_of_Asking" {
  groupby_simple_monitor = false
  new_group_delay = 60
  on_missing_data = "default"
  require_full_window = false
  monitor_thresholds {
    critical = 5
  }
  name = "Tired of Asking"
  type = "log alert"
  tags = ["team:platform-infrastructure-team"]
  query = <<EOT
logs("\"akka.pattern.AskTimeoutException:\"").index("*").rollup("count").by("pod_name,kube_namespace").last("5m") > 5
EOT
  message = <<EOT
Triggering Akka AskTikmeOutExceptions in {{kube_namespace.name}}/{{pod_name.name}}. Please restart service.
@teams-NotificationsAlerts
@oncall-platform-infrastructure-team
EOT
}