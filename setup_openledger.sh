#!/bin/bash

# Cập nhật danh sách gói và cài đặt các gói cần thiết
sudo apt-get update
sudo apt-get install -y curl gnupg screen git

# Cài đặt Node.js sử dụng NodeSource
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -  # Bạn có thể thay đổi 18.x thành phiên bản Node.js khác nếu muốn
sudo apt-get install -y nodejs

# Kiểm tra phiên bản Node.js và npm
node -v
npm -v

# Clone repository từ GitHub
git clone https://github.com/vietlinhh02/openledger.git

# Di chuyển vào thư mục vừa clone
cd openledger

# Cài đặt các dependencies
npm install

# Tạo screen mới với tên "openledger"
screen -dmS openledger

# Chạy lệnh npm start trong screen
screen -S openledger -X stuff "npm start^M"

# Chạy ứng dụng Node.js (giả sử tệp chính là index.js)
# Nếu ứng dụng Node.js không được khởi động bằng npm start, bạn có thể sử dụng lệnh này:
# screen -S openledger -X stuff "node index.js^M"

# Thông báo hoàn thành
echo "Cài đặt và chạy ứng dụng thành công!"
echo "Kiểm tra screen với lệnh: screen -r openledger"

exit 0
