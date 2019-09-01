package main

import (
	"fmt"
	"net/http"
	"net/url"
	"strings"
	"sync"
	"tosql"
)


var localIP="172.16.0.5"
//var localIP="192.168.1.133"
var loginAddress=localIP+":32769"
var getMainPageAddress=localIP+":32770"
var getSearchAssociation=localIP+":32771"
var getSearchResult=localIP+":32772"
var getProductPage=localIP+":32773"
var addActions=localIP+":32774"
var getShopCartPage=localIP+":32775"
var getAddress=localIP+":32776"
var payConfirm=localIP+":32777"
var getMyPage=localIP+":32778"
var comment=localIP+":32779"

func main(){

	swg:=sync.WaitGroup{}

	swg.Add(1)

	var opened bool

	opened,tosql.Database =tosql.OpenDB()

	if opened{
		fmt.Println("MySQL open succeed")
	}else {
		fmt.Println("MySQL open failed")
		return
	}

	//Handle login requests
	go func(){
		mux := http.NewServeMux()
		mux.HandleFunc("/", loginHandlerFunc)
		http.ListenAndServe(loginAddress, mux)
	}()

	//Handle get page requests
	go func(){
		mux := http.NewServeMux()
		mux.HandleFunc("/", getMainPageHandlerFunc)
		http.ListenAndServe(getMainPageAddress, mux)
	}()

	//Handle get query association requests
	go func(){
		mux := http.NewServeMux()
		mux.HandleFunc("/", getSearchAssociationHandlerFunc)
		http.ListenAndServe(getSearchAssociation, mux)
	}()

	//Handle get search result requests
	go func(){
		mux := http.NewServeMux()
		mux.HandleFunc("/", getsearchResultHandlerFunc)
		http.ListenAndServe(getSearchResult, mux)
	}()

	//Handle get product page requests
	go func(){
		mux := http.NewServeMux()
		mux.HandleFunc("/", getProductPageHandlerFunc)
		http.ListenAndServe(getProductPage, mux)
	}()

	//Handle add actions requests
	go func(){
		mux := http.NewServeMux()
		mux.HandleFunc("/", addActionsHandlerFunc)
		http.ListenAndServe(addActions, mux)
	}()

	//Handle get shop cart page requests
	go func(){
		mux := http.NewServeMux()
		mux.HandleFunc("/", getShopCartPageHandlerFunc)
		http.ListenAndServe(getShopCartPage, mux)
	}()

	//Handle address requests
	go func(){
		mux := http.NewServeMux()
		mux.HandleFunc("/", getAddressHandlerFunc)
		http.ListenAndServe(getAddress, mux)
	}()

	//Handle pay confirm requests
	go func(){
		mux := http.NewServeMux()
		mux.HandleFunc("/", payConfirmHandlerFunc)
		http.ListenAndServe(payConfirm, mux)
	}()

	//Handle get my page requests
	go func(){
		mux := http.NewServeMux()
		mux.HandleFunc("/", getMyPageHandlerFunc)
		http.ListenAndServe(getMyPage, mux)
	}()

	//Handle get comment requests
	/*go func(){
		mux := http.NewServeMux()
		mux.HandleFunc("/", commentHandlerFunc)
		http.ListenAndServe(comment, mux)
	}()*/

	swg.Wait()

	tosql.Database.Close()

}

func loginHandlerFunc(w http.ResponseWriter, r *http.Request) {

	leng := r.ContentLength
	body := make([]byte, leng)
	r.Body.Read(body)



	req := string(body)
	fmt.Println(req)
	reqs := strings.Split(req, "&")
	typer:=strings.Split(reqs[0], "=")[1]
	username := strings.Split(reqs[1], "=")[1]

	username,_=url.QueryUnescape(username)

	password := strings.Split(reqs[2], "=")[1]

	password=tosql.GetMD5Hash(password)

	var res string="F"
	if typer=="login"{
		res=tosql.Login(username, password)
	}else if typer=="register"{
		s,_:=url.QueryUnescape(strings.Split(reqs[3], "=")[1])
		fmt.Println(username+" "+s)
		res=tosql.Register(username, password,s)
	}
	fmt.Fprint(w,res)

}

func getMainPageHandlerFunc(w http.ResponseWriter, r *http.Request) {

	len:=r.ContentLength
	body:=make([]byte,len)
	r.Body.Read(body)
	req:=string(body)
	reqs:=strings.Split(req,"&")
	typer:=strings.Split(reqs[0],"=")[1]
	tabid:=strings.Split(reqs[1],"=")[1]
	userid:=strings.Split(reqs[2],"=")[1]
	currentItemIndex:=strings.Split(reqs[3],"=")[1]

	result:=tosql.GetMainPage(typer,tabid,userid,currentItemIndex)

	if result!=""{
		fmt.Fprint(w,result)
	}

	fmt.Println(req)

}

func getSearchAssociationHandlerFunc(w http.ResponseWriter,r *http.Request) {

	len:=r.ContentLength
	body:=make([]byte,len)
	r.Body.Read(body)
	req:=string(body)

	req,_=url.QueryUnescape(req)

	reqs:=strings.Split(req,"&")

	fmt.Println(req)

	typer:=strings.Split(reqs[0],"=")[1]
	userid:=strings.Split(reqs[1],"=")[1]
	query:=strings.Split(reqs[2],"=")[1]

	result:=tosql.GetSearchAssociation(typer,userid,query)

	if result!=""{
		fmt.Fprint(w,result)
	}

}

func getsearchResultHandlerFunc(w http.ResponseWriter,r *http.Request){
	len:=r.ContentLength
	body:=make([]byte,len)
	r.Body.Read(body)
	req:=string(body)

	req,_=url.QueryUnescape(req)

	reqs:=strings.Split(req,"&")
	temp:=strings.Split(reqs[0],"=")[1]
	typer:=strings.Split(temp,"#")[0]
	plan:=strings.Split(temp,"#")[1]
	userid:=strings.Split(reqs[1],"=")[1]
	query:=strings.Split(reqs[2],"=")[1]
	currentindex:=strings.Split(reqs[3],"=")[1]

	reuslt:=tosql.GetSearchResult(typer,plan,userid,query,currentindex)

	fmt.Fprint(w,reuslt)

	fmt.Println(req)

}

func getProductPageHandlerFunc(w http.ResponseWriter, r *http.Request) {

	len:=r.ContentLength
	body:=make([]byte,len)
	r.Body.Read(body)
	req:=string(body)

	fmt.Println(req)

	req,_=url.QueryUnescape(req)

	fmt.Println(req)

	reqs:=strings.Split(req,"&")
	temp:=strings.Split(reqs[0],"=")[1]
	typer:=strings.Split(temp,"#")[0]
	locationfrom:=strings.Split(temp,"#")[1]
	index:=strings.Split(reqs[1],"=")[1]
	userid:=strings.Split(reqs[2],"=")[1]
	proid:=strings.Split(reqs[3],"=")[1]

	result:=tosql.GetProductPage(typer,locationfrom,index,userid,proid)

	fmt.Fprint(w,result)
}

func addActionsHandlerFunc(w http.ResponseWriter, r *http.Request) {
	len:=r.ContentLength
	body:=make([]byte,len)
	r.Body.Read(body)
	req:=string(body)

	req,_=url.QueryUnescape(req)

	fmt.Println(req)

	reqs:=strings.Split(req,"&")
	typer:=strings.Split(reqs[0],"=")[1]
	state:=strings.Split(reqs[1],"=")[1]
	userid:=strings.Split(reqs[2],"=")[1]
	proid:=strings.Split(reqs[3],"=")[1]

	res:=tosql.AddActions(typer,state,userid,proid)

	fmt.Fprint(w,res)
}

func getShopCartPageHandlerFunc(w http.ResponseWriter, r *http.Request) {

	len:=r.ContentLength
	body:=make([]byte,len)
	r.Body.Read(body)
	req:=string(body)

	req,_=url.QueryUnescape(req)

	reqs:=strings.Split(req,"&")
	typer:=strings.Split(reqs[0],"=")[1]
	userid:=strings.Split(reqs[1],"=")[1]

	if typer=="getShopCartPage"{
		res:=tosql.GetShopCartPage(userid,strings.Split(reqs[2],"=")[1])
		fmt.Fprint(w,res)
	}else if typer=="editShopCart"{
		res:=tosql.EditShopCartPage(userid,strings.Split(reqs[2],"=")[1])
		fmt.Fprint(w,res)
	}

	fmt.Println(req)
}

func getAddressHandlerFunc(w http.ResponseWriter, r *http.Request) {

	len:=r.ContentLength
	body:=make([]byte,len)
	r.Body.Read(body)
	req:=string(body)

	req,_=url.QueryUnescape(req)

	reqs:=strings.Split(req,"&")
	typer:=strings.Split(reqs[0],"=")[1]
	userid:=strings.Split(reqs[1],"=")[1]

	if typer=="getAddress"{
		res:=tosql.GetAddress(userid)
		fmt.Fprint(w,res)
	}else if typer=="editAddress"{
		res:=tosql.EditAddress(strings.Split(reqs[2],"=")[1],userid)
		fmt.Fprint(w,res)
	}

	fmt.Println(req)
}

func payConfirmHandlerFunc(w http.ResponseWriter, r *http.Request)  {
	len:=r.ContentLength
	body:=make([]byte,len)
	r.Body.Read(body)
	req:=string(body)

	req,_=url.QueryUnescape(req)

	fmt.Println(req)

	reqs:=strings.Split(req,"&")
	//typer:=strings.Split(reqs[0],"=")[1]
	userid:=strings.Split(reqs[1],"=")[1]
	order:=strings.Split(reqs[2],"=")[1]

	res:=tosql.PayConfirm(userid,order)

	fmt.Fprint(w,res)
}

func getMyPageHandlerFunc(w http.ResponseWriter, r *http.Request)  {
	len:=r.ContentLength
	body:=make([]byte,len)
	r.Body.Read(body)
	req:=string(body)

	req,_=url.QueryUnescape(req)

	reqs:=strings.Split(req,"&")
	typer:=strings.Split(reqs[0],"=")[1]
	userid:=strings.Split(reqs[1],"=")[1]

	if typer=="getMyPage"{
		res:=tosql.GetMyPage(userid)
		fmt.Fprint(w,res)
	}else if typer=="getFootprint"{
		res:=tosql.GetFootprint(userid)
		fmt.Fprint(w,res)
	}else if typer=="getWishList"{
		res:=tosql.GetWishList(userid)
		fmt.Fprint(w,res)
	}

	fmt.Println(req)
}

/*func commentHandlerFunc(w http.ResponseWriter, r *http.Request)  {
	len:=r.ContentLength
	body:=make([]byte,len)
	r.Body.Read(body)
	req:=string(body)
	reqs:=strings.Split(req,"&")
	typer:=strings.Split(reqs[0],"=")[1]
	userid:=strings.Split(reqs[1],"=")[1]

	if typer=="getComment"{
		tosql.GetComment(userid,w)
	}else if typer=="handleComment"{
		tosql.HandleComment(userid,strings.Split(reqs[1],"=")[2],w)
	}

	fmt.Println(req)
}*/

func ServeHttp(w http.ResponseWriter,r *http.Request)  {
	len:=r.ContentLength
	body:=make([]byte,len)
	r.Body.Read(body)
	fmt.Println(string(body))
	fmt.Fprint(w,"")
}
