# --------------------------------------------------------------
# 1️⃣ ベースイメージ
# --------------------------------------------------------------
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 LC_ALL=C.UTF-8

# --------------------------------------------------------------
# 2️⃣ 必要なシステムパッケージ（root 権限でインストール）
# --------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gfortran openmpi-bin libopenmpi-dev \
    libscalapack-openmpi-dev libopenblas-dev liblapack-dev \
    cmake pkg-config git curl ca-certificates \
    libssl-dev libffi-dev libbz2-dev libreadline-dev libsqlite3-dev \
    zlib1g-dev liblzma-dev tk-dev vim \
    libboost-all-dev libomp-dev python3-dev expect \
 && rm -rf /var/lib/apt/lists/*

# --------------------------------------------------------------
# 3️⃣ 非特権ユーザー作成
# --------------------------------------------------------------
ARG APP_USER=appuser
ARG APP_UID=501   # 必要に応じてホスト側と合わせる
ARG APP_GID=501

RUN addgroup --gid ${APP_GID} ${APP_USER} && \
    adduser --uid ${APP_UID} --ingroup ${APP_USER} \
            --disabled-password --gecos "" ${APP_USER}

# --------------------------------------------------------------
# 4️⃣ 作業ディレクトリ・環境変数（非特権ユーザー用）
# --------------------------------------------------------------
USER ${APP_USER}
WORKDIR /home/${APP_USER}
ENV HOME=/home/${APP_USER}
ENV PATH="${HOME}/.local/bin:${PATH}"

# Julia 用の書き込み可能ディレクトリを先に作っておく
RUN mkdir -p "${HOME}/.juliaup"

# --------------------------------------------------------------
# 5️⃣ uv のインストール（非特権ユーザーで実行）
# --------------------------------------------------------------
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# --------------------------------------------------------------
# 6️⃣ Python 環境構築 & Jupyter
# --------------------------------------------------------------
RUN uv python install 3.11 && \
    uv python pin 3.11 && \
    uv venv && \
    uv pip install jupyterlab notebook

# --------------------------------------------------------------
# 7️⃣ アプリケーション固有の Python パッケージ
# --------------------------------------------------------------
COPY --chown=${APP_USER}:${APP_USER} requirements.txt /tmp/
RUN uv pip install qulacs && \
    uv pip install -r /tmp/requirements.txt

# --------------------------------------------------------------
# 8️⃣ Julia のインストール（非特権ユーザーで実行） 
#   → 事前に .juliaup を削除してクリーン状態にする
# --------------------------------------------------------------
RUN rm -rf "${HOME}/.juliaup" && \
    curl -fsSL https://install.julialang.org | sh -s -- -y

# --------------------------------------------------------------
# 9️⃣ シンボリックリンク作成は root 権限で実行
# --------------------------------------------------------------
USER root
RUN ln -s "${HOME}/.juliaup/bin/julia" /usr/local/bin/julia && \
    ln -s "${HOME}/.juliaup/bin/julialauncher" /usr/local/bin/julialauncher

# 再び非特権ユーザーに戻す
USER ${APP_USER}

# --------------------------------------------------------------
# 10️⃣ 必要な Julia パッケージをインストール
# --------------------------------------------------------------
RUN julia -e 'using Pkg; \
    Pkg.add(["JSON","HDF5","ITensors","ITensorMPS","PyCall","Distributions"]); \
    Pkg.precompile()'

# --------------------------------------------------------------
# 11️⃣ デフォルト作業ディレクトリとエントリポイント
# --------------------------------------------------------------
WORKDIR ${HOME}
CMD ["/bin/bash"]
