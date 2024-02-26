
run "create_cluster" {
  
  command = apply

  # Check that the service hostname exists
  assert {
    condition     = kubernetes_service.liatrio_go.status.0.load_balancer.0.ingress.0.hostname != ""
    error_message = "Address doesn't exist"
  }
}

run "container_is_running" {
  command = plan

  module {
    source = "./tests/final"
  }

  variables {
    endpoint = run.create_cluster.liatrio_go_url
  }

  assert {
    condition     = data.http.index.status_code == 200
    error_message = "Container responded with HTTP status ${data.http.index.status_code}"
  }

}