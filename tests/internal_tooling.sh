#!/bin/bash

# Quick checks to verify that tooling installed looks as it's expected.)
# NOTE this script leverages a few bash-isms that may not work in other shells.

matches_version () {
    grep -q -E '^v[0-9]+\.[0-9]+$'
}

installed_kubernetes_paths () {
    find /opt/cnct/kubernetes -maxdepth 1 -type d -name 'v*.*' | \
        grep -E 'v[0-9]+\.[0-9]+$'
}


kube_path_contains_binaries () {
    count=0
    while read -r versionpath; do
        count=$((count + 1))
        echo "Checking Kubernetes path: ${versionpath}"
        test -d "${versionpath}/bin"  || echo "ERROR Missing directory ${versionpath}/bin" >&2
        test -x "${versionpath}/bin/helm" || echo "ERROR Missing executable ${versionpath}/bin/helm" >&2
        test -x "${versionpath}/bin/kubectl" || echo "ERROR Missing executable ${versionpath}/bin/kubectl" >&2

    done < <(installed_kubernetes_paths)

    test 3 -eq $count || echo "ERROR Found ${count} kubernetes versions; expected 3." >&2
}


general_binaries () {
    which kubectl || echo "ERROR Could not find kubectl in \$PATH" >&2
    which helm || echo "ERROR Could not find helm in \$PATH" >&2
    which gcloud || echo "ERROR Could not find gcloud in \$PATH" >&2
    which appr || echo "ERROR Could not find appr in \$PATH" >&2
    which terraform || echo "ERROR Could not find terraform in \$PATH" >&2
}

installed_kubernetes_paths | kube_path_contains_binaries
general_binaries
