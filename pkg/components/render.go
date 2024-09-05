package components

import (
	"bytes"
	"crypto/sha256"
	"fmt"
	"path/filepath"
	"strings"
	"text/template"

	"k8s.io/kubernetes/pkg/apis/core"

	"github.com/openshift/microshift/pkg/assets"
	"github.com/openshift/microshift/pkg/config"
	"github.com/openshift/microshift/pkg/release"
)

var templateFuncs = map[string]interface{}{
	"Dir":       filepath.Dir,
	"Sha256sum": func(s string) string { return fmt.Sprintf("%x", sha256.Sum256([]byte(s))) },
}

func renderParamsFromConfig(cfg *config.Config, extra assets.RenderParams) assets.RenderParams {
	params := map[string]interface{}{
		"ReleaseImage": release.Image,
		"NodeName":     cfg.CanonicalNodeName(),
		"NodeIP":       cfg.Node.NodeIP,
		"ClusterCIDR":  strings.Join(cfg.Network.ClusterNetwork, ","),
		"ServiceCIDR":  strings.Join(cfg.Network.ServiceNetwork, ","),
		"ClusterDNS":   cfg.Network.DNS,
		"BaseDomain":   cfg.DNS.BaseDomain,
	}
	ipFamily := core.IPFamilyPolicySingleStack
	if cfg.IsIPv4() && cfg.IsIPv6() {
		ipFamily = core.IPFamilyPolicyPreferDualStack
	}
	params["IPFamily"] = ipFamily

	for k, v := range extra {
		params[k] = v
	}

	return params
}

func renderTemplate(tb []byte, data assets.RenderParams) ([]byte, error) {
	tmpl, err := template.New("").Option("missingkey=error").Funcs(templateFuncs).Parse(string(tb))
	if err != nil {
		return nil, err
	}
	var buf bytes.Buffer
	if err := tmpl.Execute(&buf, data); err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}
