#!/bin/bash

# 定义 Oh My Zsh 自定义目录
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# 检查是否已安装 Zsh
if ! command -v zsh &> /dev/null; then
  # 更新包列表并安装 Zsh
  echo "Zsh 未安装，正在安装 Zsh..."
  sudo apt update && sudo apt install -y zsh
else
  echo "Zsh 已安装。"
fi

# 检查是否已安装 Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  # 安装 Oh My Zsh 并自动接受所有默认选项
  echo "Oh My Zsh 未安装，正在安装 Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/oh-my-zsh/master/tools/install.sh)" "" --unattended
else
  echo "Oh My Zsh 已安装，准备重新配置插件。"
  # 删除现有的插件目录
  rm -rf "${ZSH_CUSTOM}/plugins/*"
fi

# 安装 zsh-autosuggestions 插件
echo "正在安装 zsh-autosuggestions 插件..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions

# 安装 zsh-syntax-highlighting 插件
echo "正在安装 zsh-syntax-highlighting 插件..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting

# 安装 zsh-completions 插件
echo "正在安装 zsh-completions 插件..."
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM}/plugins/zsh-completions

# 安装 incr 插件
echo "正在安装 incr 插件..."
mkdir -p ${ZSH_CUSTOM}/plugins/incr
curl -o ${ZSH_CUSTOM}/plugins/incr/incr.zsh https://mimosa-pudica.net/src/incr-0.2.zsh

# 更新 .zshrc 文件中的插件配置
echo "正在更新 .zshrc 文件..."

# 清空并重新添加插件到 .zshrc 文件
sed -i '/plugins=/c\plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)' "$HOME/.zshrc"

# 添加 incr 插件的源码引用到 .zshrc 文件
grep -q "source \$ZSH_CUSTOM/plugins/incr/incr.zsh" "$HOME/.zshrc" || echo 'source $ZSH_CUSTOM/plugins/incr/incr.zsh' >> "$HOME/.zshrc"

# 更改默认 shell 到 Zsh（可选）
chsh -s $(which zsh)

echo "安装和配置完成，请重新打开终端或运行 'source ~/.zshrc' 来应用更改。"
