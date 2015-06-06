# Ruby app capable of encrypting/decrypting files using OpenSSL ciphering algorithims and then base64 encoding the ciphering result back into the same file. 

## Overview
Uses an private key and iv to make the encryption process of the file content more secure.

#### Cipher and lib used used
`OpenSSL` 
`aes-128-cbc`