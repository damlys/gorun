# Pod security

## Context and Problem Statement

We need to monitor pod security settings. Do not allow to use `hostPath` volumes, `hostPort` ports etc.

## Considered Options

- Kyverno
  - [Homepage](https://kyverno.io/)
  - [kyverno-policies](https://github.com/kyverno/kyverno/tree/main/charts/kyverno-policies) Helm chart
- Kubernetes Pod Security Standards (PSS)
  - [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
  - [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/)
  - [Enforce Pod Security Standards by Configuring the Built-in Admission Controller](https://kubernetes.io/docs/tasks/configure-pod-container/enforce-standards-admission-controller/)
  - [Enforce Pod Security Standards with Namespace Labels](https://kubernetes.io/docs/tasks/configure-pod-container/enforce-standards-namespace-labels/)

## Decision Outcome

Chosen PSS, because it is enough to keep Kubernetes workloads safe and does not require to maintain additional tools.
