require_relative 'workflow_base'

class Base::CronWorkflow < Base::WorkflowBase
  def create(service_account)
    data = {
      apiVersion: 'argoproj.io/v1alpha1',
      kind: 'CronWorkflow',
      metadata: {
        name: name,
        labels: {
          'workflows.argoproj.io/owner' => owner,
          'workflows.argoproj.io/service' => service,
        },
        annotations: {
          'workflows.argoproj.io/title' => name,
          'workflows.argoproj.io/description' => '',
        },
      },
      spec: {
        suspend: true,
        schedule: '* * * * *',
        timezone: 'Asia/Tokyo',
        concurrencyPolicy: 'Forbid',
        successfulJobsHistoryLimit: 1,
        failedJobsHistoryLimit: 1,
        startingDeadlineSeconds: 60,
        workflowMetadata: {
          labels: {
            'workflows.argoproj.io/name' => name,
            'workflows.argoproj.io/owner' => owner,
            'workflows.argoproj.io/service' => service,
          },
        },
        workflowSpec: {
          entrypoint: 'main',
          activeDeadlineSeconds: 28800,
          # serviceAccountName: '',
          # securityContext: { fsGroup: 1000 }
          # volumes: [{ name: 'dsdsocket', hostPath: { path: '/var/run/datadog/' }}],
          templates:[{
            name: 'main',
            # retryStrategy: { limit: 10, retryPolicy: 'OnFailure', backoff: { duration: '1', factor: '2', maxDuration: '1m' } },
            container: {
              name: 'main',
              image: '${DOCKER_IMAGE}',
              command: ['echo', '-c'],
              args: ['Hello, World!'],
              resources: {
                limits: { memory: '32Mi' },
                requests: { cpu: '100m', memory: '32Mi' },
              },
              envFrom: [{ configMapRef: { name: name } }],
              # volumeMounts: [{ name: 'dsdsocket', mountPath: '/var/run/datadog/' }],
            },
          }],
        },
      },
    }
    data[:spec][:workflowSpec][:serviceAccountName] = service_account if service_account && !service_account.empty?
    data
  end
end
