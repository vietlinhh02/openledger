#!/bin/bash

# Cập nhật hệ thống
sudo apt-get update -y || sudo yum update -y

# Cài đặt Node.js và npm
if ! command -v node &> /dev/null; then
    echo "Node.js không được cài đặt. Đang tiến hành cài đặt..."
    if [ -x "$(command -v apt-get)" ]; then
        curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
        sudo apt-get install -y nodejs
    elif [ -x "$(command -v yum)" ]; then
        curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash -
        sudo yum install -y nodejs
    else
        echo "Không hỗ trợ trình quản lý gói này. Hãy cài đặt Node.js thủ công."
        exit 1
    fi
else
    echo "Node.js đã được cài đặt."
fi

# Kiểm tra và cài đặt git
if ! command -v git &> /dev/null; then
    echo "Git không được cài đặt. Đang tiến hành cài đặt..."
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get install -y git
    elif [ -x "$(command -v yum)" ]; then
        sudo yum install -y git
    else
        echo "Không hỗ trợ trình quản lý gói này. Hãy cài đặt Git thủ công."
        exit 1
    fi
else
    echo "Git đã được cài đặt."
fi

# Clone repository
REPO_URL="https://github.com/vietlinhh02/openledger.git"
CLONE_DIR="openledger"
if [ -d "$CLONE_DIR" ]; then
    echo "Thư mục $CLONE_DIR đã tồn tại. Xóa để clone lại..."
    rm -rf "$CLONE_DIR"
fi
echo "Đang clone repository từ $REPO_URL..."
git clone "$REPO_URL"

# Kiểm tra thư mục
if [ ! -d "$CLONE_DIR" ]; then
    echo "Clone repository thất bại. Hãy kiểm tra URL."
    exit 1
fi

# Tạo screen và chạy npm install, node .
cd "$CLONE_DIR"

# Cài đặt các gói npm trong screen
SCREEN_NAME="openledger_screen"
if screen -list | grep -q "$SCREEN_NAME"; then
    echo "Screen $SCREEN_NAME đã tồn tại."
else
    echo "Tạo screen $SCREEN_NAME và thực thi lệnh..."
    screen -dmS "$SCREEN_NAME" bash -c "npm install && node ."
    echo "Screen $SCREEN_NAME đã được tạo và đang chạy."
fi

# Hoàn thành
echo "Hoàn tất. Bạn có thể kết nối vào screen bằng lệnh: screen -r $SCREEN_NAME"
