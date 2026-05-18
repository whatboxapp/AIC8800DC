# AIC8800DC / FC (UGREEN CM760-35262)

Tested on Linux kernel 6.16 with openSUSE Tumbleweed.

src: https://www.lulian.cn/download/122.html (UGREEN CM760-35262, `a69c:88de`)

## Disclaimer

I did not develop this software, The code is sourced from the UGREEN CM760-35262 driver. I only made some modifications to the code to adapt it to newer kernel versions. Apart from compilation issues, I am unable to address other problems. Some modifications are adapted from [shenmintao/aic8800d80](https://github.com/shenmintao/aic8800d80). Credit to the original authors.

# Usage

Simply run the master install script, which automatically compiles the driver, configures firmware, deploys USB switching rules, and loads the active driver:

```bash
# Grant execution permissions
chmod +x install_setup.sh

# Run the master installer to compile, install, and configure everything automatically!
sudo ./install_setup.sh
```