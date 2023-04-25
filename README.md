# 增加自编译脚本

1、自己编译可以修改或增加action里的脚本，编译使用的库可以是你fork后自己的地址。默认是从我的库进行下载。
修改自己要编译的机型
![image](https://user-images.githubusercontent.com/39027157/234209770-f2185ebc-9a5b-4774-a799-f8c7dec8fc35.png)

修改要使用的代码库
![image](https://user-images.githubusercontent.com/39027157/234205788-f4f4f94d-d5d8-4516-a3b0-526a5693615e.png)

2、增减编译插件可以从3个地方修改，注意最好不要多个配置文件里有相同的项。特别是一个里面是y，另外一个又是n。

1） 编辑action脚本增减
![image](https://user-images.githubusercontent.com/39027157/234206844-61d3c6cd-c703-4965-a657-baa592783ef3.png)

2） 修改对应机型的编译配置文件
![image](https://user-images.githubusercontent.com/39027157/234207144-671527ac-b1c1-41e4-9479-6d343f7debce.png)

3)  修改编译初始脚本里的增补配置
![image](https://user-images.githubusercontent.com/39027157/234207663-c936b306-4ada-4bca-ac68-c7879ce60185.png)

3、自编译脚本执行
![image](https://user-images.githubusercontent.com/39027157/234207980-b217bc64-48ef-4a30-ae3a-5492921b2b0d.png)

4、获取编译成功后的固件
![image](https://user-images.githubusercontent.com/39027157/234208110-b163d066-ebe8-4643-8fc5-d02af82132dc.png)



# Padavan
基于hanwckf,chongshengB以及padavanonly的源码整合而来，支持7603/7615/7915的kvr  
编译方法同其他Padavan源码，主要特点如下：  
1.采用padavanonly源码的5.0.4.0无线驱动，支持kvr  
2.添加了chongshengB源码的所有插件  
3.其他部分等同于hanwckf的源码，有少量优化来自immortalwrt的padavan源码  
4.添加了MSG1500的7615版本config  
  
以下附上他们四位的源码地址供参考  
https://github.com/hanwckf/rt-n56u  
https://github.com/chongshengB/rt-n56u  
https://github.com/padavanonly/rt-n56u  
https://github.com/immortalwrt/padavan
  
最后编译出的固件对7612无线的支持已知是有问题的，包含7612的机型比如B70是无法正常工作的  
已测试的机型为MSG1500-7615，JCG-Q20，CR660x  
  
固件默认wifi名称
 - 2.4G：机器名_mac地址最后四位，如K2P_9981
 - 5G：机器名_5G_mac地址最后四位，如K2P_5G_9981

wifi密码
 - 1234567890

管理地址
 - 192.168.2.1

管理账号密码
 - admin
 - admin

**最近的更新代码都来自于hanwckf和MelsReallyBa大佬的4.4内核代码**
- https://github.com/hanwckf/padavan-4.4
- https://github.com/MeIsReallyBa/padavan-4.4
