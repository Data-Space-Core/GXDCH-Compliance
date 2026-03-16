# GXDCH-Compliance

This repository is a GitOps-ready ArgoCD project for deploying the Gaia-X GXDCH compliance stack into a Kubernetes cluster.

It includes:

- `gx-registry`
- `gx-compliance`
- `gx-notary` (registration number notary)

The child applications use ArgoCD multi-source applications:

- Helm chart source: upstream Gaia-X GitLab repositories
- Values source: this repository

## Repository Layout

```text
platform-apps/
  argocd/
    gxdch-compliance-application.yaml
  gxdch-compliance/
    appproject.yaml
    gx-compliance-application.yaml
    gx-notary-application.yaml
    gx-registry-application.yaml
    kustomization.yaml
    namespace.yaml
    values/
      gx-compliance-values.yaml
      gx-notary-values.yaml
      gx-registry-values.yaml
```

## Before You Push

Update the placeholder repository URL in these files:

- `platform-apps/argocd/gxdch-compliance-application.yaml`
- `platform-apps/gxdch-compliance/gx-registry-application.yaml`
- `platform-apps/gxdch-compliance/gx-compliance-application.yaml`
- `platform-apps/gxdch-compliance/gx-notary-application.yaml`

Replace:

```text
https://github.com/REPLACE_ME/GXDCH-Compliance.git
```

with your real GitHub repository URL.

## Before You Sync In ArgoCD

Edit the values files under `platform-apps/gxdch-compliance/values/`:

- replace the placeholder hosts with your real DNS names
- replace the placeholder TLS secret names if needed
- replace the placeholder base64-encoded private keys and certificates
- adjust storage classes if your cluster requires explicit classes

Important:

- `PRIVATE_KEY` and `X509_CERTIFICATE` values must be base64 encoded because the upstream Helm charts inject them into Kubernetes `Secret` resources
- the default placeholders are intentionally non-working and must be replaced before a real deployment

## Bootstrap

1. Push this folder to GitHub.
2. Update the placeholder repo URLs.
3. Apply the root ArgoCD application:

```bash
kubectl apply -n argocd -f platform-apps/argocd/gxdch-compliance-application.yaml
```

ArgoCD will then create the `gxdch-compliance` project and sync the three child applications.

## Notes

- `gx-registry` is synced before `gx-compliance` because compliance depends on the registry API.
- The chart references track the upstream `main` branches by default. Pin them to tags if you want stricter reproducibility.
- This layout assumes ArgoCD supports multi-source applications.
