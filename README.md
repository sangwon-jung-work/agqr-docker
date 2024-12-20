# agqr-docker
文化放送 超！A＆G+ 스트림 방송을 저장하는 환경을 Docker에 구현

*(접속지역에는 제한이 없으나, 추후 文化放送 의 정책 변경에 따라 달라질 수 있습니다)*

## 사용법
```sh
# save repository
git clone https://github.com/sangwon-jung-work/agqr-docker.git
cd agqr-docker

#
# install github cli or latest ffmpeg build url
#
# install github cli
# https://github.com/cli/cli#installation
#
# get url from release page
# search to ffmpeg-nx.x-latest-linux64-gpl-x.x.tar.xz (not master-latest) and copy url that
# https://github.com/yt-dlp/FFmpeg-Builds/releases/tag/latest

#
# set environment variable (for url)
#
# if install github cli
gh auth login

FFMPEG_URL=$( gh api --jq '.assets[8]."browser_download_url"' -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" /repos/yt-dlp/FFmpeg-Builds/releases/latest )
#
# if just copy url
FFMPEG_URL=(paste that url)

#
# set build date
TODAY=$( date '+%Y%m%d' )

# Build image
docker build --build-arg FFMPEG_LATEST_URL=$FFMPEG_URL --build-arg BUILD_DATE=$TODAY --tag (image name):(image version) .
# Build image Example
docker build --build-arg FFMPEG_LATEST_URL=$FFMPEG_URL --build-arg BUILD_DATE=$TODAY --tag agqr_recorder:1.1 .

# recording
docker run --rm -v (save dir):/var/agqr (image name):(image version) (recording minute) (file name)

# recording example
docker run --rm -v /recorder:/var/agqr agqr_recorder:1.1 30 AGQR_TEST
```

## License
[MIT License](LICENSE)
