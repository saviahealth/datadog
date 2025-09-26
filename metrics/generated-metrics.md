Metric name: `savia.assistant.ssoSuccessful`  
Query: `@service:savia-assistant "sso login successful"`  
Group By: `@appCustomer`


Metric name: `savia.assistant.launches`  
Query: `@service:savia-assistant "getConfiguration from profile"`  
Group By: `@appCustomer`  


Metric name: `qie.message.processed`  
Query: `kube_namespace:integration client:lbh "MESSAGE PROCESSED"`  
Group By: `client kube_namespace pod_name service`  


Metric name: `qie.fhir.query`  
Query: `kube_namespace:integration client:lbh "FHIR QUERY"`  
Group by: `kube_namespace pod_name service`


Metric name: `savia.event.skipped`  
Query: `kube_namespace:rtm-teach-nisil service:pubsub-ingress-service "Skipping message with id"`  
Group by: `client container_name kube_namespace pod_name service`  


Metric name: `savia.event.processed`  
Query: `(source:abd-pipeline "Consumed message from") OR (service:workflow-task-execution-endpoint-invoker-service "Processed message with key") OR (service:workflow-fhir-provider "Processed eventId") OR (service:fhir-integration-service "Processed message from topic") OR (service:stateless-workflow-integration-service "Processed message with key")`  
Group by: `client container_name kube_namespace pod_name service`  


Metric name: `savia.event.received`  
Query: `(source:abd-pipeline "Received event with messageId") OR (container_name:pubsub-ingress-service ("Received and published pubsub event" OR "Received message with id" OR "Received amqpMessage")) OR (container_name:qvera-ingress-service ("Received message" OR "Received pulsarMessage")) OR (container_name:analytics-index-agent "Received message from") OR (container_name:fhir-integration-service ("Processing event" OR "Received message from topic")) OR (container_name:stateless-workflow-integration-service ("Processed message for partition" OR "Received message with key")) OR (container_name:workflow-fhir-provider kube_namespace:rtm-teach-nisil "Received message from topic") OR (service:workflow-task-execution-endpoint-invoker-service "Received message with key")`  
Group by: `client container_name kube_namespace pod_name service topic`  


Metric name: `savia.transientPipelineErrors`  
Query: `PlatformTransientException`  
Group By: `client kube_namespace pod_name service`  
