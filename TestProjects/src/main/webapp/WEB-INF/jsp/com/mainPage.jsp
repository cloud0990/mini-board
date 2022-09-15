<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 
<c:set var="sessionVo" value="${sessionScope.S_USER}"></c:set>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>HOME : USERS</title>
<style type="text/css">
input:focus{
	-webkit-box-shadow: none;
	box-shadow:none;
	outline:2px solid #d50000;
}
</style>
<script type="text/javascript">
$(function(){
	$("#srch_user_text").keypress(function(e){
		if(e.keyCode && e.keyCode == 13) {
			if($("#srch_user_text").val()=='') {
				$("#srch_user option:eq(0)").prop("selected", true);
			}
			$("#srch_user_btn").trigger('click'); //trigger() : 이벤트 강제 발생
		}
	});
	/* 검색필터 */
	$("#srch_user_btn").click(function(){
		if($("#srch_user_text").val()=='') {
			$("#srch_user option:eq(0)").prop("selected", true);
		}
		fn_user_srch();
	});
	
	/* 메인 그리드 */
	$("#mainGrid").jqGrid({
		url:"/main/selectUserList",
		loadtext:"로딩 중..",
		datatype:"json",
		mtype:"POST",
		height:'auto',
		width:1000,
		shrinkToFit: true,
		colNames:['회원번호', '닉네임', '아이디', '비밀번호', '가입일', '수정일'],
		colModel: [
					{name:'user_idx', index:'user_idx', align:"center", width:"45px"},
					{name:'user_nm',  index:'user_nm',  align:"center", width:"80px"},
					{name:'user_id',  index:'user_id',  align:"center", width:"70px"},
					{name:'user_pwd', index:'user_pwd', align:"center"},
					{name:'user_date', index:'user_date', align:"center", width:"60px"},
					{name:'upd_date', index:'upd_date', align:"center", width:"60px"},
					//{name:'empty',  index:'empty',  align:"center", formatter:formatOpt, width:50}
	              ],
	    rowNum: 20,
	    rowList: [20, 40, 60],
	    //rownumbers: true,
	    pager : '#pager',
	    viewrecords: true,
		loadComplete: function() {
			$(".ui-state-default.jqgrid-rownum").removeClass('ui-state-default jqgrid-rownum');
            var allRow = $("#mainGrid").jqGrid('getGridParam', 'records');        
            if(allRow == 0 ){          
            	$("#mainGrid > tbody").append("<tr><td align='center' colspan='7' style=''>조회된 데이터가 없습니다.</td></tr>");       
           	}
		},
 		onSelectRow: function(index, row) { //index = 선택된 row의 index
 			
 			$("#view_user_idx").val('');
 			
 			$("#status").val("update");		
 			$("#duplChk").css({"display":"none"});
 			
 			if(index) {
 				
 				var row = $("#mainGrid").jqGrid('getRowData', index);
 				
 				$("#view_user_idx").val(row.user_idx);
 				$("#view_user_id").val(row.user_id);
 				$("#view_user_pwd").val(row.user_pwd);
 				$("#view_user_nm").val(row.user_nm);
 				$("#view_user_date").val(row.user_date);
 				$("#view_upd_date").val(row.upd_date);
 			}
	    },
	    gridComplete: function() {
	    	$("#mainGrid td").css("vertical-align", "middel");
	    } 
	});
	
	/* 닉네임 중복체크 */
	$("#duplChk").click(function(){
		var user_nm  = $("#view_user_nm").val();
		$.post("/signUp/chkUserNm"
				, {user_nm:user_nm}
				, function(data){
					var resultCode = data.resultCode;
					if(resultCode=='S000'){
						alert("사용할 수 있는 닉네임입니다.");
					}else if(resultCode=='S999'){
						alert("중복된 닉네임입니다.");
						return false;
				   }else if(resultCode=='V999') {
						alert("작업수행에 실패하였습니다.");
						return false;
				   }
		});
	});
});


/*
//cellvalue : format 지정값
//options : Element 포함하는 객체 (rowId=row의 id, colModel=colModel배열의 컬럼 속성 객체)
//rowObject : datatype 옵션에 정의된 형식으로 표현된 row 데이터
function formatOpt(cellvalue, options, rowObject) {
	var str = "";
	str += "<div class=\"btn-group\">";
	str += "<button type='button' class='btn btn-light sm-1' style='padding:2px 10px 2px; z-index:1;' onclick=\"javascript:fn_update_allow()\">수정</button>";
	str += "<button type='button' class='btn btn-light sm-1' style='padding:2px 10px 2px; z-index:1;' onclick=\"javascript:fn_user_delete('" + rowObject.user_idx + "')\">삭제</button>";
	str += "</div>"
	return str;
}
*/

/* 신규버튼 click */
function fn_user_clear() {
	
	$("#status").val("create");
	
	$("#duplChk").css({"display":""});
	
	$("#view_user_idx").val('');
	$("#view_user_id").val('');
	$("#view_user_pwd").val('');
	$("#view_user_nm").val('');
	$("#view_user_date").val('');
	$("#view_upd_date").val('');
}

/* 사용자 삭제 */
function fn_user_delete() {
	if(!confirm("삭제하시겠습니까?")) return;
	callAjax("/main/deleteUser", $("#frm_update_user").serialize(), fn_result);
}

/* 사용자 수정 */
function fn_user_cu() {
	
	if($("#status").val() == "create") {
		if(!confirm("등록하시겠습니까?")) return;
		
		var user_id  = $("#view_user_id").val();
		var user_pwd = $("#view_user_pwd").val();
		var user_nm  = $("#view_user_nm").val();
	
		if(user_nm == '') {
			$("#view_user_nm").css("border", "2px solid red");
			$("#view_user_nm").css("box-shadow", "0 0 3px red");
			alert('닉네임을 입력해주세요.');
			return;
		}
		if(user_id == '') {
			$("#view_user_id").css("border", "2px solid red");
			$("#view_user_id").css("box-shadow", "0 0 3px red");
			alert('아이디를 입력해주세요.');
			return;
		}
		if(user_pwd == '') {
			$("#view_user_pwd").css("border", "2px solid red");
			$("#view_user_pwd").css("box-shadow", "0 0 3px red");
			alert('비밀번호를 입력해주세요.');
			return;
		}

		$.post("/signUp/insertUser"
				, {user_id:user_id, user_pwd:user_pwd, user_nm:user_nm}
				, function(data){
					var resultCode = data.resultCode;
					if(resultCode=='S000'){
					
						alert("사용자 등록이 완료되었습니다.");
						
						$("#mainGrid").setGridParam({url:"/main/selectUserList", page:1, datatype:"json"}).trigger("reloadGrid");	
					
					}else if(resultCode=='S999'){
						$("#view_user_id").attr("style", "border: 2px solid red;");
						$("#view_user_pwd").attr("style", "border: 2px solid red;");					
						$("#view_user_nm").attr("style", "border: 2px solid red;");
						alert("작업수행에 실패하였습니다.");
						return false;
				   }
		});
		
	}else if($("#status").val() == "update") {
		if(!confirm("수정하시겠습니까?")) return;
		
		callAjax("/main/updateUser", $("#frm_update_user").serialize(), fn_result);
	}
}
/* callback Function > update/delete */
function fn_result(data) {
	
	if(data.resultCode=="S000") {
		alert("작업수행이 정상적으로 처리되었습니다..");
		
		$("#mainGrid").setGridParam({url:"/main/selectUserList", page:1, datatype:"json"}).trigger("reloadGrid");
		
		//값 초기화
		$("#view_user_idx").val('');
		$("#view_user_id").val('');
		$("#view_user_pwd").val('');
		$("#view_user_nm").val('');
		$("#view_user_date").val('');
		$("#view_upd_date").val('');
		$("#status").val("create");
	}else {
		alert("작업수행에 실패하였습니다.");
	}
}

/* 사용자 검색 */
function fn_user_srch() {
	
	$("#mainGrid").clearGridData();
	
	$("#mainGrid").setGridParam({
		   url:"/main/selectUserList"
		 , postData: {
				  srch_user: $("#srch_user").val()
		   		, srch_user_text : $("#srch_user_text").val()	
		   }
		 , datatype:"json"
	}).trigger('reloadGrid');
}
</script>
</head>
<body>
<div id="content" style="float:left;">
	<div role="content">
		<div class="widget-body" style="padding:30px;">
			<fieldset>
				<div class="form-group" style="flex:center;">
					<label style="float:left;"><span class="widget-icon"><i class="fa fa-list-ul"></i>&nbsp;&nbsp;&nbsp;사용자</span></label>
				</div>
				<!-- 검색 -->
				<div class="input-group rounded" style="width:500px; float: right;">
				  <select id="srch_user" name="srch_user" style="border-radius: 3px; font-size: 13px; outline:none; border:none; margin-right:3px; width:100px;">
				  	<option value='srch_all'>전 체</option>
				  	<option value='srch_user_nm'>닉네임</option>
				  	<option value='srch_user_id'>아이디</option>
				  </select>
				  <input type="search" id="srch_user_text" name="srch_user_text" class="form-control rounded" placeholder="검색" aria-label="Search" aria-describedby="search-addon"/>
				  <button type="button" class="btn btn-default btn-sm" style="padding:2px 10px 2px; box-shadow: none;" id="srch_user_btn">
				 	 <span class="input-group-text border-0" id="search-addon"><i class="fas fa-search"></i></span>
				  </button>
				</div>
			</fieldset>
			<hr style="margin-top:0px;">
			<fieldset>		
				<div class="row" id="tableWrap">
					<table id="mainGrid"></table>
					<div id="pager"></div>
				</div>
			</fieldset>	
		</div>
	</div>
</div>
<form class="form-horizontal" id="frm_update_user" name="frm_update_user" onsubmit="return false">
	<input type="hidden" name="status" id="status" value="create"/>
	<div class="user_info" id="content" style="float:right; width:530px;">
		<div class="widget-body" style="padding:30px;">
			<fieldset>
				<div style="flex:center;">
					<label><span class="widget-icon"><i class="fa fa-list-alt txt-color-white"></i>&nbsp;&nbsp;&nbsp;사용자 상세정보</span></label>
				</div>
			</fieldset>
			<hr style="margin-top:0px;">
			<input type="hidden" id="view_user_idx" name="user_idx">
			<fieldset>		
				<legend style="padding-top:0px; font-size:14px; margin-bottom:5px; margin-top:15px;">닉네임</legend>
				<div style="display: inline-block; width:385px;">
					<input class="form-control input-sm" id="view_user_nm" name="user_nm"/>					
				</div>
                <div style="display: inline-block;">
	              <button type="button" class='btn btn-default btn-sm' id="duplChk" style="font-weight: bold; font-size: 12px; display:none;">중복확인</button>
                </div>
				<legend style="padding-top:0px; font-size:14px; margin-bottom:5px; margin-top:15px;">아이디</legend>
				<div>
					<input class="form-control input-sm" id="view_user_id" name="user_id"/>					
				</div>
				<legend style="padding-top:0px; font-size:14px; margin-bottom:5px; margin-top:15px;">비밀번호</legend>
				<div>
					<input class="form-control input-sm" id="view_user_pwd" name="user_pwd"/>					
				</div>
				<div style="float:left; width:232px;">
				<legend style="padding-top:0px; font-size:14px; margin-bottom:5px; margin-top:15px;">가입일</legend>
					<input class="form-control input-sm" id="view_user_date" disabled="disabled"/>					
				</div>
				<div style="float:right; width:234px;">
				<legend style="padding-top:0px; font-size:14px; margin-bottom:5px; margin-top:15px;">수정일</legend>
					<input class="form-control input-sm" id="view_upd_date" disabled="disabled"/>					
				</div>
			</fieldset>

			<div id="updateCancel_btn" style="margin-top: 15px; text-align: right; clear:both; font-weight: bold;">
				<button type='button' class='btn btn-default btn-sm' style="padding:2px 10px 2px; font-size: 15px;" onclick="fn_user_clear()">신규</button>		
				<button type='button' class='btn btn-default btn-sm' style="padding:2px 10px 2px; font-size: 15px;" onclick="fn_user_cu()">저장</button>		
				<button type='button' class='btn btn-default btn-sm' style="padding:2px 10px 2px; font-size: 15px;" onclick="fn_user_delete()">삭제</button>		
			</div>
		</div>
	</div>
</form>
</body>
</html>