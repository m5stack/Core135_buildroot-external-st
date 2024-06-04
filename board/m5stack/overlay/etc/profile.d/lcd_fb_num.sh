export LCD_FRAMEBUFFER=`cat /proc/fb | grep fb_ili9341 | awk '{print "/dev/fb"$1}'`
export HDMI_FRAMEBUFFER=`cat /proc/fb | grep stmdrmfb | awk '{print "/dev/fb"$1}'`
