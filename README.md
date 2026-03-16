# GXDCH-Compliance

This repository is a GitOps-ready ArgoCD project for deploying the Gaia-X GXDCH compliance stack into a Kubernetes cluster.

It includes:

- `gx-registry`
- `gx-compliance`
- `gx-notary` (registration number notary)

The child applications use vendored local Helm charts so the deployment stays self-contained and can consume pre-created Kubernetes Secrets for signing material.

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

## Repository URL

The manifests currently point to:

```text
https://github.com/Data-Space-Core/GXDCH-Compliance.git
```

If your repository URL differs, update:

- `platform-apps/argocd/gxdch-compliance-application.yaml`
- `platform-apps/gxdch-compliance/appproject.yaml`
- `platform-apps/gxdch-compliance/gx-registry-application.yaml`
- `platform-apps/gxdch-compliance/gx-compliance-application.yaml`
- `platform-apps/gxdch-compliance/gx-notary-application.yaml`

## Before You Sync In ArgoCD

Edit the values files under `platform-apps/gxdch-compliance/values/`:

- replace the placeholder hosts with your real DNS names
- replace the placeholder TLS secret names if needed
- adjust storage classes if your cluster requires explicit classes

Important:

- signing keys are now expected from pre-created Kubernetes Secrets referenced through `existingSecret`
- helper script: `scripts/generate-signing-secret.sh`
- the helper generates a PKCS#8 RSA key and self-signed certificate, then prints a Secret manifest with all keys required by the three charts

## Bootstrap

1. Push this folder to GitHub.
2. Update the placeholder repo URLs.
3. Generate and apply signing secrets:

```bash
./scripts/generate-signing-secret.sh gx-compliance-signing gxdch-compliance | kubectl apply -f -
./scripts/generate-signing-secret.sh gx-registry-signing gxdch-compliance | kubectl apply -f -
./scripts/generate-signing-secret.sh gx-notary-signing gxdch-compliance | kubectl apply -f -
```

4. Apply the root ArgoCD application:

```bash
kubectl apply -n argocd -f platform-apps/argocd/gxdch-compliance-application.yaml
```

ArgoCD will then create the `gxdch-compliance` project and sync the three child applications.

## Notes

- `gx-registry` is synced before `gx-compliance` because compliance depends on the registry API.
- Vendored charts live under `charts/` so you can patch and pin them in Git.
