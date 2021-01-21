package test

import (

    "fmt"
    "testing"
    "strings"
    "time"
    "io/ioutil"
    "encoding/base64"

    "github.com/stretchr/testify/require"
    "github.com/gruntwork-io/terratest/modules/random"
    "github.com/gruntwork-io/terratest/modules/k8s"
    "github.com/gruntwork-io/terratest/modules/helm"
    corev1 "k8s.io/api/core/v1"
    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func MustReadFile(filename string) []byte {
    data, err := ioutil.ReadFile(filename)
    if err != nil {
        panic(err)
    }
    return data
}

func GetPodNameWithPrefix(pods []corev1.Pod, prefix string) *corev1.Pod {
    for _, pod := range pods {
        if len(pod.ObjectMeta.Name) >= len(prefix) && pod.ObjectMeta.Name[0:len(prefix)] == prefix {
            return &pod
        }
    }
    return nil
}

func TestBasicChartDeploy(t *testing.T) {
    
    t.Parallel()

    //
    // Install helm chart!
    //

    // Path to the helm chart we will test
    helmChartPath := ".."
    //helmChartRegistry := os.Getenv("DOCKER_REGISTRY")
    //helmChartRegistrySecret := os.Getenv("DOCKER_REGISTRY_SECRET_NAME")

    helmOptions := &helm.Options{
        ValuesFiles: []string { "examples/whitelabel/values.yaml", },
        SetFiles: map[string]string {
            "initFile": "examples/whitelabel/init.sh",
            "configFile": "examples/whitelabel/config.py",
            "init.initFile": "examples/whitelabel/init.init.sh",
        },
        SetValues: map[string]string{
            "assets.images.favicon\\.png": base64.StdEncoding.EncodeToString(MustReadFile("examples/whitelabel/assets/images/favicon.png")),
            "assets.images.superset\\.png": base64.StdEncoding.EncodeToString(MustReadFile("examples/whitelabel/assets/images/superset.png")),
            "assets.images.superset-logo-horiz\\.png": base64.StdEncoding.EncodeToString(MustReadFile("examples/whitelabel/assets/images/superset-logo-horiz.png")),
        },
    }
    
    releaseName := fmt.Sprintf("test-whitelabel-superset-%s", strings.ToLower(random.UniqueId()))
    // Cleanup the release after the test is over
    defer helm.Delete(t, helmOptions, releaseName, true)

    helm.Install(t, helmOptions, helmChartPath, releaseName)

    // Setup the kubectl config and context.
    kubectlOptions := k8s.NewKubectlOptions("", "", "default")

    getAll, err := k8s.RunKubectlAndGetOutputE(t, kubectlOptions, "get", "all")
    require.NoError(t, err)

    fmt.Println(getAll)

    //
    // Ensure pod is healthy!
    // TODOO: Use k8s.Tunnel to actually grab the images and check them
    //

    pods := k8s.ListPods(t, kubectlOptions, metav1.ListOptions{})
    pod := GetPodNameWithPrefix(pods, releaseName)
    podName := pod.ObjectMeta.Name

    fmt.Println(podName)

    // Wait for the pod to come up. It takes some time for the Pod to start, so retry a few times.
    retries := 60
    sleep := 5 * time.Second
    k8s.WaitUntilPodAvailable(t, kubectlOptions, podName, retries, sleep)

    // output, err := k8s.RunKubectlAndGetOutputE(t, kubectlOptions, "logs", podName)
    // require.NoError(t, err)
}