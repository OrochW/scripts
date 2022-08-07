#! /bin/bash
read -p "请输入要签发证书的域名：" DOMAIN
## 证书适用IP
IP=$(ip addr|awk '/^[0-9]+: / {}; /inet.*global/ {print gensub(/(.*)\/(.*)/, "\\1", "g", $2)}'|head -n 1)

DATE=36500

rm -rf ${DOMAIN} ca.key ca.csr ca.crt

mkdir ${DOMAIN}

# 生成CA根证书
## 准备ca配置文件，得到ca.conf
cat > ${DOMAIN}/ca.conf << EOF
[ req ]
default_bits       = 4096
distinguished_name = req_distinguished_name

[ req_distinguished_name ]
countryName                 = Country Name (2 letter code)
countryName_default         = CN
stateOrProvinceName         = State or Province Name (full name)
stateOrProvinceName_default = BeiJing
localityName                = Locality Name (eg, city)
localityName_default        = BeiJing
organizationName            = Organization Name (eg, company)
organizationName_default    = pskzs
commonName                  = Common Name (e.g. server FQDN or YOUR name)
commonName_max              = 64
commonName_default          = PSKZS CA Center
EOF

## 生成ca秘钥，得到ca.key
openssl genrsa -out ca.key 4096

## 生成ca证书签发请求，得到ca.csr
openssl req -new -subj "/C=CN/ST=BeiJing/L=BeiJing/O=pskzs/CN=PSKZS CA Center" -sha256 -out ca.csr -key ca.key -config ${DOMAIN}/ca.conf

## 生成ca根证书，得到ca.crt
openssl x509 -req -days ${DATE} -in ca.csr -signkey ca.key -out ca.crt

# 生成终端用户证书
## 准备配置文件，得到server.conf
cat > ${DOMAIN}/server.conf << EOF
[ req ]
default_bits       = 2048
distinguished_name = req_distinguished_name
req_extensions     = req_ext

[ req_distinguished_name ]
countryName                 = Country Name (2 letter code)
countryName_default         = CN
stateOrProvinceName         = State or Province Name (full name)
stateOrProvinceName_default = BeiJing
localityName                = Locality Name (eg, city)
localityName_default        = BeiJing
organizationName            = Organization Name (eg, company)
organizationName_default    = pskzs
commonName                  = Common Name (e.g. server FQDN or YOUR name)
commonName_max              = 64
EOF
echo commonName_default          "=" ${DOMAIN} >> ${DOMAIN}/server.conf
cat >> ${DOMAIN}/server.conf << EOF

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
EOF
echo DNS.1 = ${DOMAIN} >> ${DOMAIN}/server.conf
echo DNS.2 = ${DOMAIN_EXT} >> ${DOMAIN}/server.conf
echo IP    = ${IP} >> ${DOMAIN}/server.conf

## 生成秘钥，得到server.key
openssl genrsa -out server.key 2048

## 生成证书签发请求，得到server.csr
openssl req -new -subj "/C=CN/ST=BeiJing/L=BeiJing/O=pskzs/CN=${DOMAIN}" -sha256 -out server.csr -key server.key -config ${DOMAIN}/server.conf

## 用CA证书生成终端用户证书，得到server.crt
openssl x509 -req -days 3650 -CA ca.crt -CAkey ca.key -CAcreateserial -in server.csr -out server.crt -extensions req_ext -extfile ${DOMAIN}/server.conf
echo "key:server.key"
echo "crt:server.crt"
