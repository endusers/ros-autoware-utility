# AWSIM Docker 環境

## 目次

[CHAPTER_1]: #1-はじめに
[CHAPTER_2]: #2-動作環境
[CHAPTER_3]: #3-インストール
[CHAPTER_4]: #4-セットアップ準備
[CHAPTER_5]: #5-使用方法
[CHAPTER_6]: #6-変更履歴

- [1 はじめに][CHAPTER_1]
- [2 動作環境][CHAPTER_2]
- [3 インストール][CHAPTER_3]
- [4 セットアップ(準備)][CHAPTER_4]
- [5 使用方法][CHAPTER_5]
- [6 変更履歴][CHAPTER_6]

## 1 はじめに

本環境はAWSIMを動かすDocker環境である。  

- [AWSIM](https://github.com/autowarefoundation/AWSIM)  
- [AWSIM Document - Quick Start Demo](https://autowarefoundation.github.io/AWSIM/GettingStarted/QuickStartDemo/)  

## 2 動作環境

- Ubuntu 22.04, 24.04
- NVIDIA GPU
- Docker
- Docker Compose
- NVIDIA Container Toolkit

## 3 インストール

### 3-1 Enable multicast on lo

1. セットアップ

    ホストPCでループバックインターフェースでマルチキャストを有効にします

    ```bash
    cd ros-autoware-utility
    ./docker/setup/setup-enable-multicast-on-lo.sh
    ```

### 3-2 Tune system-wide network settings

1. セットアップ

    Linuxカーネルの最大バッファサイズを大きくします

    ```bash
    cd ros-autoware-utility
    ./docker/setup/setup-system-wide-network.sh
    ```

### 3-4 Reboot

1. 再起動

    上記設定を反映させるためホストPCを再起動する

### 3-5 Task Runner(optional)

Task Runnerを使用する場合はホストPCに下記をインストールします  
以降のコマンドの make を task に読み替えて実行してください。  

1. インストール


    [Task Runner](https://taskfile.dev/)

    ```bash
    pip install go-task-bin
    ```

1. 補完機能設定

    ホストPCで補完機能のコマンドの登録をします

    ```bash
    cd ros-autoware-utility
    ./docker/setup/setup-bashrc-add-task.sh
    ```

## 4 セットアップ(準備)

初回のみビルドなどで時間がかかるので  
とりあえず初回立ち上げを行います  

1. docker build

    Makefileがあるディレクトリで

    ```bash
    make build
    ```

    ビルドに約70分ほどかかります(通信環境とPCスペックにより変動します)

1. docker compose up

    Makefileがあるディレクトリで

    ```bash
    make up-bridge
    ```

1. Cyclone DDS 設定

    ネットワークインタフェースの設定を cyclonedds.xml に設定する  
    尚、本設定はコンテナ再生成時にリセットされるため、コンテナ再生性時は都度設定をすること  

    ```bash
    make exec
    nano ~/cyclonedds.xml
    ```

    - Dockerのネットワークが bridge 場合

        以下を設定する。

        ```txt
        <NetworkInterface autodetermine="false" name="lo" priority="default" multicast="default" />
        ```

        or

        ```txt
        <NetworkInterface autodetermine="false" address="172.17.0.0" priority="default" multicast="default" />
        ```

    - Dockerのネットワークが host 場合

       以下を設定する。

        ```txt
        <NetworkInterface autodetermine="false" name="xxxxx" priority="default" multicast="default" />
        ```
        ※nameにはネットワークインタフェース名を設定する( exp. eth0 )

        or

        ```txt
        <NetworkInterface autodetermine="false" address="xxx.xxx.xxxx.xxx" priority="default" multicast="default" />
        ```
        ※addressにはホストのサブネットを設定する( exp. 192.168.1.0 )

1. 一旦終了

    初回立ち上げが確認できたら、一旦全部落とす

## 5 使用方法

- make up-bridge はコンテナ立ち上げ時に1回のみ実行する  
- make exec はコンテナに入るときに実行する  
- 複数ターミナルを立ち上げたい場合は make exec を別ターミナルで実行する  
- ホストとのデータの共有は下記マウント済みの領域が使用できる  
  ホストの「ros-autoware-utility/docker/home」を「/home/docker/mnt」にマウント  
  ホストの「ros-autoware-utility/docker/tmp」を「/home/docker/mnt/tmp」にマウント  

### 5-1 セットアップ

1. コンテナ立ち上げ

    ```bash
    make up-bridge
    ```

1. AWSIMダウンロード

    ```bash
    make exec
    mkdir -p ~/mnt/AWSIM
    cd ~/mnt/AWSIM/
    wget https://github.com/autowarefoundation/AWSIM/releases/download/v2.0.1/AWSIM-Demo.zip
    unzip ./AWSIM-Demo.zip
    chmod +x ./AWSIM-Demo/AWSIM-Demo.x86_64
    ```

1. MAPダウンロード

    ```bash
    make exec
    mkdir -p ~/mnt/AWSIM/Map
    cd ~/mnt/AWSIM/Map/
    wget https://github.com/autowarefoundation/AWSIM/releases/download/v2.0.0/Shinjuku-Map.zip
    unzip ./Shinjuku-Map.zip
    ```

1. autowareビルド

    ```bash
    make exec
    cd ~/mnt/
    git clone -b 1.8.0 https://github.com/autowarefoundation/autoware.git
    cd autoware
    ```

    ```bash
    mkdir -p src
    vcs import --recursive src < ./repositories/autoware.repos
    ```

    ```bash
    rosdep update
    rosdep install -y --from-paths src --ignore-src --rosdistro $ROS_DISTRO
    ```

    ```bash
    colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-w" --parallel-workers 1
    ```

### 5-2 実行

1. コンテナ立ち上げ

    ```bash
    make up-bridge
    ```

1. マルチキャスト有効(DockerNetwork)

    ```bash
    make exec
    sudo ip link set lo multicast on
    ```

1. AWSIM立ち上げ

    ```bash
    make exec
    ~/mnt/AWSIM/AWSIM-Demo/AWSIM-Demo.x86_64
    ```

1. autoware立ち上げ

    ```bash
    make exec
    source ~/mnt/autoware/install/local_setup.bash
    ros2 launch autoware_launch e2e_simulator.launch.xml vehicle_model:=sample_vehicle sensor_model:=awsim_sensor_kit map_path:=/home/docker/mnt/AWSIM/Map/Shinjuku-Map/map
    ```

## 6 変更履歴

| バージョン | 内容                                        |
| ---------- | ------------------------------------------- |
| v0.1.0     | 初版作成                                    |
