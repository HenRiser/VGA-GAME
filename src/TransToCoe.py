# Auther: Xhy
# 将图片自动转换为指定大小的.coe文件
# 最终的文件默认200*150大小，请尽量使用200k*150*k大小的图片
# 图片格式任意，路径可自行修改，默认为"test.jpeg"
# 输出image_thumb.jpg为缩略图，并输出result.coe

from PIL import Image
import os
#
file_root = 'D:/edgedownload/vscode/PROJ/Vwork/git/VGA-GAME/figs/figs_in/'  # 当前文件夹下的所有图片
file_list = os.listdir(file_root)
save_out_jpg = "D:/edgedownload/vscode/PROJ/Vwork/git/VGA-GAME/figs/figs_out/thumbjpg/" # 保存jpg的文件夹名称
save_out_coe = "D:/edgedownload/vscode/PROJ/Vwork/git/VGA-GAME/figs/figs_out/resultcoe/" # 保存coe的文件夹名称

for img_name in file_list:
  img_path = file_root + img_name
  img_raw = Image.open(img_path)  # 读取图片
  # 获取图片尺寸的大小__预期(600,400)
  print (img_raw.size)
  # 获取图片的格式 png
  print (img_raw.format)
  # 获取图片的图像类型 RGBA
  print (img_raw.mode)
  # 生成缩略图
  img_raw.thumbnail((200, 150))
  # 把图片强制转成RGB
  img = img_raw.convert("RGB")
  # 把图片调整为16色
  img_w=img.size[0]
  img_h=img.size[1]
  for i in range(0,img_w):
    for j in range(0,img_h):
      data=img.getpixel((i,j))
      re=(16*int(data[0]/16),16*int(data[1]/16),16*int(data[2]/16))
      img.putpixel((i,j),re)
  # 保存图片
  imgjpg_path = save_out_jpg + img_name
  img.save(imgjpg_path)
  # 转换为.coe文件
  width=200
  height=150
  imgcoe_path = save_out_coe + img_name.split('.')[0] + ".coe"
  file = open(imgcoe_path,"w")
  file.write(";32k*12\nmemory_initialization_radix=16;\nmemory_initialization_vector=\n")
  for j in range(0,height):
    for i in range(0,width):
      data=img.getpixel((i, j))
      re=['%01X' %int(s/16) for s in data]
      result=""
      for item in re:
        result+=item
      file.write(result)
      file.write(" ")
    file.write("\n")
  for i in range(0,32*1024-width*height):
    file.write("000 ")
  file.write("\n;")
  print("Finish")