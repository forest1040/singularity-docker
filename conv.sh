#!/usr/bin/env bash
set -euo pipefail

# ---------- 設定 ----------
IMG="julia_img:latest"
#WORKDIR="${HOME}/container_build"
#mkdir -p "${WORKDIR}"
#cd "${WORKDIR}"
WORKDIR="${PWD}"

# ---------- 1. ダンプ ----------
DUMP="${IMG//[:\/]/_}.tar"
docker save -o "${DUMP}" "${IMG}"
echo "Docker image saved to ${DUMP}"

# ---------- 2. SIF ビルド ----------
#SIF="${IMG##*/}_$(date +%Y%m%d).sif"   # 例: julia_img_20251114.sif
SIF="${IMG//[:\/]/_}.sif"
docker run --rm -it \
    --privileged \
    -v "$(pwd)":/workdir \
    apptainer-builder:1.4.4 \
    bash -c "\
        cd /workdir && \
        apptainer build ${SIF} docker-archive://${DUMP}"
echo "SIF created: ${SIF}"

# ---------- 3. 確認 ----------
#singularity exec "${SIF}" julia --version || echo "Julia が実行できません"
