# Power_check
By connecting a ADS1115 board, we can measure voltage. 
This project measure the battery voltage and the very low voltage over a shunt to get amps through the shunt.

When running raspi-config also enable the interface I2C (and SSH, VNC and maybe camera)

Installation

Connect to your Raspberry Pi via SSH.
Clone this repo: git clone https://github.com/nrjphwe/Power_check

cd Power_check and run the setup script: ./script/install_power_check.sh

Need to update the config.ini file to your mysql password.
