This umbrella chart is created to deploy my motivation for a Scalable Selenium Grid, details as below

Fortunately, [Selenium-Grid Helm Chart](charts/selenium-grid/README.md) added autoscaling in default values.yaml from version [0.19.0](https://github.com/SeleniumHQ/docker-selenium/blob/trunk/charts/selenium-grid/CHANGELOG.md#heavy_check_mark-0190)

![Scalable Grid](docs/central_grid_diagram.png)

More details on my motivation are mentioned in the presentation [here](docs/Topic_Scalable-Parallel-AT_Publish.pdf).

## System requires

1. Maven (Tested version 3.8.4)
2. Helm v3 (Tested version v3.8.2)
3. Kubernetes (Tested version v1.23.13 - Runtime: docker - Provisioned by Minikube v1.26.0)

## Build the umbrella chart

```shell
mvn clean install
```
Built chart is located under target/helm/repo/scalable-selenium-grid-x.x.x.tgz
