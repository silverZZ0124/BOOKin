<%@page import="semi.beans.ReviewDao"%>
<%@page import="semi.beans.MemberDto"%>
<%@page import="semi.beans.MemberDao"%>
<%@page import="semi.beans.BookReviewDto"%>
<%@page import="semi.beans.BookReviewDao"%>
<%@page import="java.util.ArrayList"%>
<%@page import="semi.beans.GenreDto"%>
<%@page import="java.util.List"%>
<%@page import="semi.beans.GenreDao"%>
<%@page import="semi.beans.BookDto"%>
<%@page import="semi.beans.BookDao"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%
	int no = Integer.parseInt(request.getParameter("no"));
	String root = request.getContextPath();
	
	BookDao bookDao = new BookDao();
	BookDto bookDto = bookDao.get(no);
	if (bookDto.getBookImage() == null) {
		bookDto.setBookImage(root + "/image/nullbook.png");
	}
	
	GenreDao genreDao = new GenreDao();
	GenreDto genreDto = genreDao.get(bookDto.getBookGenreNo());
	GenreDto genreDto2;
	GenreDto genreDto1 = genreDao.get(genreDao.get(genreDto.getGenreParents()).getGenreNo());
	if (genreDao.get(genreDto1.getGenreParents()) != null) {
		genreDto2 = genreDao.get(genreDao.get(genreDto1.getGenreParents()).getGenreNo());
	} else {
		genreDto2 = null;
	}
	List<BookDto> bookList = bookDao.authorSearch(bookDto.getBookAuthor(), 1, 10);
	List<BookDto> bookList2 = bookDao.publisherSearch(bookDto.getBookPublisher(), 1, 10);
	List<BookDto> bookList3 = bookDao.genreSearch(bookDto.getBookGenreNo());
	List<GenreDto> genreList = genreDao.sameGenreList(bookDto.getBookGenreNo());
	
	bookDao.bookView((int) no);
%>
<%
	int price = bookDto.getBookPrice();
	int discount = bookDto.getBookDiscount();
	int priceDif = price - discount;
	int discountPercent = (int) (((double) priceDif / (double) price) * (100.0));
%>
<%
	//페이지 네이셔 구현 코드
	int pageNo;//현재 페이지 번호
	try {
		pageNo = Integer.parseInt(request.getParameter("pageNo"));
		if (pageNo < 1) {
			throw new Exception();
		}
	} catch (Exception e) {
		pageNo = 1;//기본값 1페이지
	}
	
	int pageSize;
	try {
		pageSize = Integer.parseInt(request.getParameter("pageSize"));
		if (pageSize < 10) {
			throw new Exception();
		}
	} catch (Exception e) {
		pageSize = 5;//기본값 15개
	}
	
	//rownum의 시작번호(startRow)와 종료번호(endRow)를 계산
	int startRow = pageNo * pageSize - (pageSize - 1);
	int endRow = pageNo * pageSize;
	
	//해당 책 리뷰
	BookReviewDao bookReviewDao = new BookReviewDao();
	List<BookReviewDto> reviewList = bookReviewDao.list(no, startRow, endRow);
	
	//해당 책 리뷰 개수
	int reviewCount = bookReviewDao.count(no);
	//해당 책 리뷰 평점
	int reviewAvg = bookReviewDao.avg(no);
	
	int count = bookReviewDao.count(no);
	
	int blockSize = 10;
	int lastBlock = (count + pageSize - 1) / pageSize;
	//	int lastBlock = (count - 1) / pageSize + 1;
	int startBlock = (pageNo - 1) / blockSize * blockSize + 1;
	int endBlock = startBlock + blockSize - 1;
	
	if (endBlock > lastBlock) {//범위를 벗어나면
		endBlock = lastBlock;//범위를 수정
}
%>
<%
	int bookNo = (int) Long.parseLong(request.getParameter("no"));
	
	int member;
	try {
		member = (int) session.getAttribute("member");
	} catch (Exception e) {
		member = 0;
	}
	
	ReviewDao reviewDao = new ReviewDao();
	boolean isPurchase = reviewDao.isPurchase(bookNo, member);
	
	boolean isReview = reviewDao.isReview(bookNo, member);
%>

<link rel="stylesheet" type="text/css" href="<%=root%>/css/review.css">
<jsp:include page="/template/header.jsp"></jsp:include>
<script src="https://code.jquery.com/jquery-3.6.0.js"></script>
<style>
.hidden {
	display: none;
}

.non-hidden {
	display: block;
}

.star {
	width: 30px;
}
</style>
<script>
	//페이지 네이션 
	$(function() {
		$(".pagination > a").click(
				function() {
					//주인공 == a태그
					var pageNo = $(this).text();
					if (pageNo == "이전") {//이전 링크 : 현재 링크 중 첫 번째 항목 값 - 1
						pageNo = parseInt($(".pagination > a:not(.move-link)")
								.first().text()) - 1;
						$("input[name=pageNo]").val(pageNo);
						$(".page-form").submit();//강제 submit 발생
					} else if (pageNo == "다음") {//다음 링크 : 현재 링크 중 마지막 항목 값 + 1
						pageNo = parseInt($(".pagination > a:not(.move-link)").last().text()) + 1;
						$("input[name=pageNo]").val(pageNo);
						$(".page-form").submit();//강제 submit 발생
					} else {//숫자 링크
						$("input[name=pageNo]").val(pageNo);
						$(".page-form").submit();//강제 submit 발생
					}
				});
	});
</script>
<script>
	$(function() {
		$(".edit_button").click(function() {
			var beforeEditId = "#beforeEdit" + $(this).attr("data-reviewno");

			$(beforeEditId).removeClass("hidden");
			$(beforeEditId).removeClass("non-hidden");

			$(beforeEditId).addClass("hidden");

			var afterEditId = "#afterEdit" + $(this).attr("data-reviewno");

			$(afterEditId).removeClass("hidden");
			$(afterEditId).removeClass("non-hidden");

			$(afterEditId).addClass("non-hidden");

		});

		$(".cancle_button").click(function() {

			var beforeEditId = "#beforeEdit" + $(this).attr("data-reviewno");

			$(beforeEditId).removeClass("hidden");
			$(beforeEditId).removeClass("non-hidden");

			$(beforeEditId).addClass("non-hidden");

			var afterEditId = "#afterEdit" + $(this).attr("data-reviewno");

			$(afterEditId).removeClass("hidden");
			$(afterEditId).removeClass("non-hidden");

			$(afterEditId).addClass("hidden");

		});

	});
</script>

<div class="container-700">

	<div class="row text-left">
		<h1><%=bookDto.getBookTitle()%></h1><br>
		<div>
			<span><%=bookDto.getBookAuthor()%> (지은이)&nbsp;&nbsp;</span> 
			<span><%=bookDto.getBookPublisher()%>&nbsp;&nbsp;</span>
			<span><%=bookDto.getBookPubDate()%></span> 
			<span class="container-right"><a href="<%=root%>/book/bookEdit.jsp?no=<%=bookDto.getBookNo()%>">수정</a></span>
			<span class="container-right"><a href="bookDelete.kh?bookNo=<%=bookDto.getBookNo()%>">삭제</a></span>
		</div>
	</div>
	<hr>

	<div class="main-detail">
		<div class="book-image-box">


			<%
			if (bookDto.getBookImage().startsWith("https")) {
			%>
			<img title="<%=bookDto.getBookTitle()%>"
				src="<%=bookDto.getBookImage()%>" class="book-image">
			<%
			} else {
			%>
			<img title="<%=bookDto.getBookTitle()%>" class="book-image"
				src="<%=root%>/book/bookImage.kh?bookNo=<%=bookDto.getBookNo()%>">
			<%
			}
			%>
		</div>
		<div class="book-table-box">
			<div class="site-color-red">신구간의 매력적인 조합, 인문ON! 와이드 데스크 매트</div>
			<br> <br>

			<div>
				<span>정가</span> <span>&emsp;&emsp;&emsp;<%=bookDto.getBookPrice()%>원
				</span>
			</div>
			<br>
			<div>
				<span>판매가&emsp;&emsp;</span> <span class="price-text"><%=bookDto.getBookDiscount()%></span>
				<span>원&nbsp;(<%=discountPercent%>%, <%=priceDif%>원 할인)
				</span>
			</div>
			<br> <br>
			<div>
				<span>배송료</span> <span>&emsp;&emsp;신간도서 단 1권도 무료</span>
			</div>
			<div class="detail-info-box">
				<div class="detail-info-clock-box">
					<img src="<%=root%>/image/clock-regular.svg" class="clock-image">
				</div>
				<div class="detail-info-text-box">
					<div class="carpet-delivery-text">양탄자배송</div>
					<span>밤 10시까지 주문하면 내일 아침 7시 </span><span class="site-color-red">출근전
						배송</span><br> <span>(중구 중림동 기준) 지역변경</span>
				</div>
			</div>
			<br> <br>
			<div class="detail-etc-text-box">
				<div>
					<span>인문학 주간 2위, 종합 top100</span><span
						class="detail-etc-text-highlight"> 2주</span> <span>&emsp;|&emsp;Sales
						Point : </span><span class="detail-etc-text-highlight">29,900</span>
				</div>
				<span class="star-image-box"> <%
 if (reviewAvg == 0) {
 %> <span class="site-color-red detail-etc-text-highlight">리뷰가
						없습니다.</span> <%
 } else {
 %> <%
 for (int i = 0; i < reviewAvg; i++) {
 %> <span><img src="<%=root%>/image/star_on.png"
						class="star-image"></span> <%
 }
 %> <%
 for (int i = 0; i < 5 - reviewAvg; i++) {
 %> <span><img src="<%=root%>/image/star_off.png"
						class="star-image"></span> <%
 }
 %> <span class="site-color-red detail-etc-text-highlight"><%=reviewAvg%></span>
					<%
					}
					%>
				</span> <span> &emsp;100자평(5) </span> <span> &emsp;리뷰(0)&emsp; </span> <span
					class="blue-box"> 이 책 어때요? </span>
			</div>
			<div class="payment-text-box">
				<div class="payment-text">카드/간편결제 할인 &gt;</div>
				<div class="payment-text">무이자 할부 &gt;</div>
				<div class="payment-text">소득공제 690원</div>

			</div>
			<br> <br>

			<div class="payment-button-box">


				<form action="<%=root%>/member/cartInsert.kh" method="post"
					onsubmit="foo();">
					<input type="hidden" name="memberNo" value="<%=member%>"> <input
						type="hidden" name="bookNo" value="<%=bookNo%>"><br>

					수량<span><button type="button" name="button"
							onclick="minus()">
							<img src="<%=root%>/image/minus-solid.svg" alt="minus"
								class="amount-image" />
						</button></span> <span><input type="text" name="cartAmount" value="1"
						size="10" id="count" class="text-center"></span> <span><button
							type="button" name="button" onclick="plus()">
							<img src="<%=root%>/image/plus-solid.svg" alt="plus"
								class="amount-image" />
						</button></span> <br> <br> <input type="submit" value="장바구니 담기"
						class="payment-button">
				</form>
		
				<div class="payment-button">
					<a href="#" class="payment-button-text">바로구매</a>
				</div>
				<div class="payment-button">
					<a href="#" class="payment-button-text-red">보관함+</a>
				</div>
				<div class="payment-button">
					<a href="#" class="payment-button-text-red">선물하기</a>
				</div>

			</div>
			<br> <br> <br>
			<div class="secondHand-text-box">
				<div class="secondHand-text">전자책 출간알림 신청 &gt;</div>
				<div class="secondHand-text">중고 등록알림 신청 &gt;</div>
				<div class="secondHand-text">중고로 팔기 &gt;</div>
			</div>
			<br> <br> <br>
		</div>

	</div>
	<hr>

	<div class="row text-left book-detail-semi-box">
		<div class="book-detail-semi-title">
			<span>기본정보</span>
		</div>
		<div class="book-detail-semi-subtitle">
			<div class="book-detail-semi-subtitle-text">주제분류</div>
			<br>
			<div>
				<%
				if (genreDto2 == null) {
				%>
				<%=genreDto1.getGenreName()%>
				&gt;<%=genreDto.getGenreName()%>
				<%
				} else {
				%>

				<%=genreDto2.getGenreName()%>
				&gt;
				<%=genreDto1.getGenreName()%>
				&gt;
				<%=genreDto.getGenreName()%>
				<%
				}
				%>
			</div>
		</div>
	</div>
	<hr>

	<div class="row text-left book-detail-semi-box">
		<div class="book-detail-semi-title">
			<span>책소개</span>
		</div>
		<div class="book-detail-semi-subtitle"><%=bookDto.getBookDescription()%></div>
	</div>
	<hr>

	<div class="row text-left book-detail-semi-box2">
		<div class="book-detail-semi-title2">
			<span><%=bookDto.getBookAuthor()%></span> <span
				class="book-detail-semi-title2-highlight"> 작가의 다른 책</span>

		</div>
		<div class="book-detail-semi-image-box">
			<%
				if (bookList.size() < 5) {
			%>
			<%
				for (int i = 0; i < bookList.size(); i++) {
			%>
			<%
				if (bookDto.getBookNo() == bookList.get(i).getBookNo()) {
					continue;
				}
			%>


			<a href="<%=root%>/book/bookDetail.jsp?no=<%=bookList.get(i).getBookNo()%>">
				<%
					if (bookList.get(i).getBookImage().startsWith("https")) {
				%> 
					<img title="<%=bookList.get(i).getBookTitle()%>"
					src="<%=bookList.get(i).getBookImage()%>"
					class="same-author-book-img"> 
				<%} else {%> 
				 <img title="<%=bookList.get(i).getBookTitle()%>"
				class="same-author-book-img"
				src="<%=root%>/book/bookImage.kh?bookNo=<%=bookList.get(i).getBookNo()%>">
				<% } %>
			</a>
			
			<%
			}
			%>

			<%
			} else {
			%>
			<%
			for (int i = 0; i < 4; i++) {
			%>
			<%
			if (bookDto.getBookNo() == bookList.get(i).getBookNo()) {
				continue;
			}
			%>
			<a
				href="<%=root%>/book/bookDetail.jsp?no=<%=bookList.get(i).getBookNo()%>">

				<%
				if (bookList.get(i).getBookImage().startsWith("https")) {
				%> <img title="<%=bookList.get(i).getBookTitle()%>"
				src="<%=bookList.get(i).getBookImage()%>"
				class="same-author-book-img"> <%
 } else {
 %> <img title="<%=bookList.get(i).getBookTitle()%>"
				class="same-author-book-img"
				src="<%=root%>/book/bookImage.kh?bookNo=<%=bookList.get(i).getBookNo()%>">
				<%
				}
				%>

			</a>
			<%
			}
			%>
			<%
			}
			%>


		</div>
	</div>
	<hr>
	<div class="row text-left book-detail-semi-box2">
		<div class="book-detail-semi-title2">
			<span><%=bookDto.getBookPublisher()%></span> <span
				class="book-detail-semi-title2-highlight"> 출판사의 다른 책</span>

		</div>
		<div class="book-detail-semi-image-box">

			<%
			if (bookList2.size() < 5) {
			%>
			<%
			for (int i = 0; i < bookList2.size(); i++) {
			%>
			<%
			if (bookDto.getBookNo() == bookList2.get(i).getBookNo()) {
				continue;
			}
			%>


			<a
				href="<%=root%>/book/bookDetail.jsp?no=<%=bookList2.get(i).getBookNo()%>">

				<%
				if (bookList2.get(i).getBookImage().startsWith("https")) {
				%> <img title="<%=bookList2.get(i).getBookTitle()%>"
				src="<%=bookList2.get(i).getBookImage()%>"
				class="same-author-book-img"> <%
 } else {
 %> <img title="<%=bookList2.get(i).getBookTitle()%>"
				class="same-author-book-img"
				src="<%=root%>/book/bookImage.kh?bookNo=<%=bookList2.get(i).getBookNo()%>">
				<%
				}
				%>

			</a>
			<%
			}
			%>

			<%
			} else {
			%>
			<%
			for (int i = 0; i < 4; i++) {
			%>
			<%
			if (bookDto.getBookNo() == bookList2.get(i).getBookNo()) {
				continue;
			}
			%>
			<a
				href="<%=root%>/book/bookDetail.jsp?no=<%=bookList2.get(i).getBookNo()%>">

				<%
				if (bookList2.get(i).getBookImage().startsWith("https")) {
				%> <img title="<%=bookList2.get(i).getBookTitle()%>"
				src="<%=bookList2.get(i).getBookImage()%>"
				class="same-author-book-img"> <%
 } else {
 %> <img title="<%=bookList2.get(i).getBookTitle()%>"
				class="same-author-book-img"
				src="<%=root%>/book/bookImage.kh?bookNo=<%=bookList2.get(i).getBookNo()%>">
				<%
				}
				%>

			</a>
			<%
			}
			%>
			<%
			}
			%>
		</div>
	</div>
	<hr>
	<div class="row text-left book-detail-semi-box2">
		<div class="book-detail-semi-title2">
			<span><%=genreDto.getGenreName()%></span> <span
				class="book-detail-semi-title2-highlight"> 장르의 다른 책</span>

		</div>
		<div class="book-detail-semi-image-box">
			<%
			if (bookList3.size() < 5) {
			%>
			<%
			for (int i = 0; i < bookList3.size(); i++) {
			%>
			<%
			if (bookDto.getBookNo() == bookList3.get(i).getBookNo()) {
				continue;
			}
			%>


			<a
				href="<%=root%>/book/bookDetail.jsp?no=<%=bookList3.get(i).getBookNo()%>">

				<%
				if (bookList3.get(i).getBookImage().startsWith("https")) {
				%> <img title="<%=bookList3.get(i).getBookTitle()%>"
				src="<%=bookList3.get(i).getBookImage()%>"
				class="same-author-book-img"> <%
	 } else {
	 %> <img title="<%=bookList3.get(i).getBookTitle()%>"
				class="same-author-book-img"
				src="<%=root%>/book/bookImage.kh?bookNo=<%=bookList3.get(i).getBookNo()%>">
				<%
				}
				%>

			</a>
			<%
			}
			%>

			<%
			} else {
			%>
			<%
			for (int i = 0; i < 4; i++) {
			%>
			<%
			if (bookDto.getBookNo() == bookList3.get(i).getBookNo()) {
				continue;
			}
			%>
			<a
				href="<%=root%>/book/bookDetail.jsp?no=<%=bookList3.get(i).getBookNo()%>">

				<%
					if (bookList3.get(i).getBookImage().startsWith("https")) {
				%> <img title="<%=bookList3.get(i).getBookTitle()%>"src="<%=bookList3.get(i).getBookImage()%>" class="same-author-book-img"> <%
 				} else {
 %> <img title="<%=bookList3.get(i).getBookTitle()%>"
				class="same-author-book-img"
				src="<%=root%>/book/bookImage.kh?bookNo=<%=bookList3.get(i).getBookNo()%>">
				<%
				}
				%>

			</a>
			<%
			}
			%>
			<%
			}
			%>
		</div>
		<hr>
	</div>
	<div class="row text-left book-detail-semi-box2">
		<!-- 리뷰 -->
		<!-- 		어떤책에 누가 리뷰번호,리뷰내용,평점,작성시간 넣을 수 있음 -->
		<%
		if (isPurchase && (isReview == false)) {
		%><div class="review-regit-reply">
			<!-- 			보내야할 정보 책,작성자번호,리뷰내용,평점 -->
			<div class="review-row">
				<form action="<%=root%>/review/reviewInsert.kh" method="post">
					<label>리뷰 내용</label>
					<textarea name="review_content" class="review_inbox_text"></textarea>
					<div class="row">
						<img id="star1" class="star" src="<%=root%>/image/star_off.png">
						<img id="star2" class="star" src="<%=root%>/image/star_off.png">
						<img id="star3" class="star" src="<%=root%>/image/star_off.png">
						<img id="star4" class="star" src="<%=root%>/image/star_off.png">
						<img id="star5" class="star" src="<%=root%>/image/star_off.png">
					</div>
					<!--  <label>평점</label> <input type="text" name="review_rate">  -->
					<input type="hidden" name="review_book" value="<%=no%>"> <input
						type="hidden" name="review_member" value="<%=member%>"> <input
						type="submit" value="입력">
				</form>
			</div>
		</div>
		<%
		}
		%>




		<div class="book-detail-semi-title2">
			<span>BOOK 리뷰</span>
		</div>
		<%MemberDao memberDao = new MemberDao();%>
		<%
		if (reviewCount > 0) {
		%>
		<%
		for (BookReviewDto bookReviewDto : reviewList) {
		%>
		<!-- 처음에 보여줘야 할 부분  -->
		<div class="row" class="non-hidden"
			id="beforeEdit<%=bookReviewDto.getReviewNo()%>"
			style="padding-bottom: 15px;">
			<div class="row">
				<span style="display: none;"><%=bookReviewDto.getReviewRate()%></span>
				<%
				int reviewRate = bookReviewDto.getReviewRate();
				%>
				<%
				for (int i = 0; i < reviewRate; i++) {
				%>
				<img src="<%=root%>/image/star_on.png">
				<%
				}
				%>
				<%
				for (int i = 0; i < 5 - reviewRate; i++) {
				%>
				<img src="<%=root%>/image/star_off.png">
				<%
				}
				%>
			</div>

			<div class="row text-left">
				<p style="min-height: 40px;"><%=bookReviewDto.getReviewContent()%></p>
			</div>


			<div class="row">
				<div class="text-left" style="display: inline-block; width: 50%">
					<%
					MemberDto memberDto = memberDao.getMember(bookReviewDto.getReviewMember());
					%>
					<span style="font-size: 12px;"><%=memberDto.getMemberId()%></span>
					<span style="font-size: 12px;"><%=bookReviewDto.getReviewTime()%></span>
				</div>
				<%
				if (bookReviewDto.getReviewMember() == member) {
				%>
				<div class="text-right" style="display: inline-block; width: 48%;">
					<div style="display: inline-block;">
						<input class="edit_button" type="button"
							data-reviewno="<%=bookReviewDto.getReviewNo()%>" value="수정">
					</div>
					<div style="display: inline-block;">
						<form action="<%=root%>/review/reviewDelete.kh">
							<input class="float-container right" type="hidden"
								name="review_no" value="<%=bookReviewDto.getReviewNo()%>">
							<input type="hidden" name="book_no"
								value="<%=bookReviewDto.getReviewBook()%>"> <input
								type="submit" value="삭제" style="display: inline-block;">
						</form>
					</div>
				</div>
				<%
				}
				%>
			</div>
		</div>



		<img class="img-1" src="">
		<%
		if (bookReviewDto.getReviewMember() == member) {
		%>
		<!-- 숨겨놨다가 수정 버튼을 누르면 보여줘야 할 부분   -->
		<div class="row afterEdit hidden"
			id="afterEdit<%=bookReviewDto.getReviewNo()%>">

			<form action="<%=root%>/review/reviewEdit.kh" method="post">

				<input type="hidden" name="review_no"
					value="<%=bookReviewDto.getReviewNo()%>">
				<textarea placeholder="<%=bookReviewDto.getReviewContent()%>"
					name="review_content"></textarea>
				<input type="text" placeholder="<%=bookReviewDto.getReviewRate()%>"
					name="review_rate"> <input class="cancle_button"
					type="button" data-reviewno="<%=bookReviewDto.getReviewNo()%>"
					value="취소"> <input type="hidden" name="book_no"
					value="<%=bookReviewDto.getReviewBook()%>"> <input
					type="submit" value="수정완료">
			</form>
		</div>
		<%
		}
		%>
		<%
		}
		%>
		<%
		} else {
		%>
		<div class="row text-center">
			<div class="row" style="height: 100px;">
				<span style="color: lightgray;">작성된 리뷰가 없습니다.</span>
			</div>
		</div>
		<%
		}
		%>






		<!-- 페이지 네이션 -->
		<div class="pagination text-center">

			<%
			if (startBlock > 1) {
			%>
			<a class="move-link">이전</a>
			<%
			}
			%>

			<%
			for (int i = startBlock; i <= endBlock; i++) {
			%>
			<%
			if (i == pageNo) {
			%>
			<a class="on"><%=i%></a>
			<%
			} else {
			%>
			<a><%=i%></a>
			<%
			}
			%>
			<%
			}
			%>

			<%
			if (endBlock < lastBlock) {
			%>
			<a class="move-link">다음</a>
			<%
			}
			%>

		</div>


		<form class="page-form" action="bookDetail.jsp?no=<%=no%>"
			method="post">
			<input type="hidden" name="pageNo">
		</form>

	</div>


</div>



<script>
	function foo() {
		alert("장바구니에 담겼습니다.");
	};
</script>

<jsp:include page="/template/footer.jsp"></jsp:include>
