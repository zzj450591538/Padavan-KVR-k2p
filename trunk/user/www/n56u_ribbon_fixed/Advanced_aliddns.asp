<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#> - Lucky工具箱</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">

<link rel="shortcut icon" href="images/favicon.ico">
<link rel="icon" href="images/favicon.png">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/main.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/engage.itoggle.css">

<script type="text/javascript" src="/jquery.js"></script>
<script type="text/javascript" src="/bootstrap/js/bootstrap.min.js"></script>
<script type="text/javascript" src="/bootstrap/js/engage.itoggle.min.js"></script>
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/itoggle.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script>
var $j = jQuery.noConflict();

$j(document).ready(function() {

	init_itoggle('aliddns_enable',change_aliddns_enable_bridge);

});

</script>
<script>

<% login_state_hook(); %>

function initial(){
	show_banner(2);
	show_menu(5,17,0);
	show_footer();
	showmenu();

	change_aliddns_enable_bridge(1);

	if (!login_safe())
		textarea_scripts_enabled(0);
}

function showmenu(){
	showhide_div('dtolink', found_app_ddnsto());
	showhide_div('zelink', found_app_zerotier());
	showhide_div('wirlink', found_app_wireguard());
}

function textarea_scripts_enabled(v){
	inputCtrl(document.form['scripts.ddns_script.sh'], v);
}

function applyRule(){
	showLoading();
	
	document.form.action_mode.value = " Apply ";
	document.form.current_page.value = "/Advanced_aliddns.asp";
	document.form.next_page.value = "";
	
	document.form.submit();
}


function done_validating(action){
	refreshpage();
}

function change_aliddns_enable_bridge(mflag){
	var m = document.form.aliddns_enable[0].checked;
	showhide_div("aliddns_ak_tr", m);
	showhide_div("aliddns_sk_tr", m);
	showhide_div("aliddns_interval", m);
	showhide_div("aliddns_ttl_tr", m);
	showhide_div("aliddns_domain_tr", m);
	showhide_div("aliddns_domain2_tr", m);
	showhide_div("aliddns_domain6_tr", m);
	showhide_div("row_post_wan_script", m);
}

</script>
</head>

<body onload="initial();" onunLoad="return unload_body();">

<div class="wrapper">
	<div class="container-fluid" style="padding-right: 0px">
		<div class="row-fluid">
			<div class="span3"><center><div id="logo"></div></center></div>
			<div class="span9" >
				<div id="TopBanner"></div>
			</div>
		</div>
	</div>

	<div id="Loading" class="popup_bg"></div>

	<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>

	<form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">

	<input type="hidden" name="current_page" value="Advanced_aliddns.asp">
	<input type="hidden" name="next_page" value="">
	<input type="hidden" name="next_host" value="">
	<input type="hidden" name="sid_list" value="LANHostConfig;General;">
	<input type="hidden" name="group_id" value="">
	<input type="hidden" name="action_mode" value="">
	<input type="hidden" name="action_script" value="">
	<input type="hidden" name="wan_ipaddr" value="<% nvram_get_x("", "wan0_ipaddr"); %>" readonly="1">
	<input type="hidden" name="wan_netmask" value="<% nvram_get_x("", "wan0_netmask"); %>" readonly="1">
	<input type="hidden" name="dhcp_start" value="<% nvram_get_x("", "dhcp_start"); %>">
	<input type="hidden" name="dhcp_end" value="<% nvram_get_x("", "dhcp_end"); %>">

	<div class="container-fluid">
		<div class="row-fluid">
			<div class="span3">
				<!--Sidebar content-->
				<!--=====Beginning of Main Menu=====-->
				<div class="well sidebar-nav side_nav" style="padding: 0px;">
					<ul id="mainMenu" class="clearfix"></ul>
					<ul class="clearfix">
						<li>
							<div id="subMenu" class="accordion"></div>
						</li>
					</ul>
				</div>
			</div>

			<div class="span9">
				<!--Body content-->
				<div class="row-fluid">
					<div class="span12">
						<div class="box well grad_colour_dark_blue">
							<h2 class="box_head round_top">Lucky工具箱 - <#menu5_30#></h2>
							<div class="round_bottom">
							<div>
							    <ul class="nav nav-tabs" style="margin-bottom: 10px;">
								<li class="active">
								    <a href="Advanced_aliddns.asp">Lucky</a>
								</li>
								<li id="dtolink" style="display:none">
								    <a href="Advanced_ddnsto.asp"><#menu5_32_2#></a>
								</li>
								<li id="zelink" style="display:none">
								    <a href="Advanced_zerotier.asp"><#menu5_32_1#></a>
								</li>
								<li id="wirlink" style="display:none">
								    <a href="Advanced_wireguard.asp"><#menu5_35_1#></a>
								</li>
							    </ul>
							</div>
								<div class="row-fluid">
									<div id="tabMenu" class="submenuBlock"></div>
									<div class="alert alert-info" style="margin: 10px;">Lucky工具箱 ，这是一款集多种功能的插件，公网神器,ipv6/ipv4端口转发,反向代理,动态域名,语音助手网络唤醒,ipv4内网穿透,计划任务,自动证书等。</a>
<div>项目地址: <a href="https://github.com/gdy666/lucky" target="blank">https://github.com/gdy666/lucky 。</a>                                  <a href="http://lucky666.cn" target="blank">使用指南。 </a>                   <a href="https://www.right.com.cn/forum/thread-8243984-1-1.html" target="blank">恩山论坛反馈。 </a>
<a href="https://url21.ctfile.com/d/44547821-55537427-a5525e?p=16601" target="blank">程序下载。 </a></div>
<div>Lucky版本更新请下载文件后缀为Linux_mipsle_softfloat.tar.gz的文件，解压出 lucky 上传至/etc/storage/bin/文件夹里即可完成更新。</div>
											
												
									</div>
<table width="100%" align="center" cellpadding="4" cellspacing="0" class="table">
										<tr>
											<th width="30%" style="border-top: 0 none;" onmouseover="openTooltip(this, 26, 9);">启用 Lucky</a></th>
											<td style="border-top: 0 none;">
													<div class="main_itoggle">
													<div id="aliddns_enable_on_of">
														<input type="checkbox" id="aliddns_enable_fake" <% nvram_match_x("", "aliddns_enable", "1", "value=1 checked"); %><% nvram_match_x("", "aliddns_enable", "0", "value=0"); %>  />
													</div>
												</div>
												<div style="position: absolute; margin-left: -10000px;">
													<input type="radio" value="1" name="aliddns_enable" id="aliddns_enable_1" class="input" value="1" onClick="change_aliddns_enable_bridge(1);" <% nvram_match_x("", "aliddns_enable", "1", "checked"); %> /><#checkbox_Yes#>
													<input type="radio" value="0" name="aliddns_enable" id="aliddns_enable_0" class="input" value="0" onClick="change_aliddns_enable_bridge(1);" <% nvram_match_x("", "aliddns_enable", "0", "checked"); %> /><#checkbox_No#>
												</div>

											</td>
										</tr>
						<tr id="aliddns_interval" style="display:none;">
											<th width="30%" style="border-top: 0 none;" onmouseover="openTooltip(this, 26, 9);">启动模式:</a></th>
											<td style="border-top: 0 none;">
                                                <select id="aliddns_interval" name="aliddns_interval" class="input" onchange="aliddns_interval()">
                                                    <option value="0" <% nvram_match_x("","aliddns_interval", "0","selected"); %>>普通版</option>
                                                    <option value="1" <% nvram_match_x("","aliddns_interval", "1","selected"); %>>全能版</option>
					                                             </select><div>&nbsp;<span style="color:#888;">普通版：目前比全能版大吉少一个内置FileBrowser模块，约5M</span></div>  
<div>&nbsp;<span style="color:#888;">全能版（daji）：包含所有模块，全功能版本，约12M</span></div>   
											</td>
</tr>
										<tr id="aliddns_ttl_tr" style="display:none;">
											<th width="30%" style="border-top: 0 none;" onmouseover="openTooltip(this, 26, 9);">启动命令 :</a></th>
											<td style="border-top: 0 none;">
												<input type="text"  id="aliddns_ttl" name="aliddns_ttl"  value="<% nvram_get_x("","aliddns_ttl"); %>"  onkeypress="return is_number(this,event);" />
												<div>&nbsp;<span style="color:#888;"> -c  配置文件路径 </span></div>
											</td>
																				<tr id="aliddns_domain_tr" style="display:none;">
											<th width="30%" style="border-top: 0 none;" onmouseover="openTooltip(this, 26, 9);">主页地址：</a></th>
											<td style="border-top: 0 none;">
												<a href="<% nvram_get_x("", "luckyip"); %>"><% nvram_get_x("", "luckyip"); %></a>											</td>
										</tr>

										
										

										<tr>
											<td colspan="2" style="border-top: 0 none;">
												<br />
												<center><input class="btn btn-primary" style="width: 219px" type="button" value="<#CTL_apply#>" onclick="applyRule()" /></center>
											</td>
										</tr>
									</table>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>

	</form>

	<div id="footer"></div>
</div>
</body>
</html>

