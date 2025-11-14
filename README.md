# singularity-docker

# TODO
- [x] macにsingularity環境を構築
- [x] dockerファイル作成
- [ ] sifファイルに変換
- [x] juliaのhello world作成
- [ ] ローカルのsingularity環境で実行
- [ ] 富岳に持っていく
- [ ] 確認

# mac
brew install --cask singularity

# イメージ作成
```
docker build -f Dockerfile -t julia_img .
singularity build julia_img.sif docker-daemon://julia_img:latest
```

# julia hello
```
# hello_world.jl
println("Hello, World!")
```

julia hello_world.jl

## create sif file
```
docker build -t apptainer-builder:1.4.4 -f Dockerfile.apptainer .

sh conv.sh
```
singularity build julia_img.sif docker-daemon://julia_img:latest

# exec singularity
```
#singularity run julia_img_latest.sif julia hello_world.jl

docker run --rm -it \
    --privileged \
    -v "$(pwd)":/workdir \
    apptainer-builder:1.4.4 bash -c "cd /workdir && apptainer run julia_img_latest.sif julia hello_world.jl"

```

docker run --rm -it julia_img bash

docker run --rm -it \
    --privileged \
    -v "$(pwd)":/workdir \
    apptainer-builder:1.4.4 bash
