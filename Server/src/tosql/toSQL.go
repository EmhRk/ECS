package tosql

import (
	"database/sql"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"github.com/jmoiron/sqlx"
	"strconv"
	"strings"
	"time"
)

var useduserid int=2//已派发的userid

var Database *sqlx.DB

func protect(){
	err:=recover()

	fmt.Println(err)
}

var null =""

func Login(username string, password string)string{

	defer protect()

	//向数据库查询用户信息
	var id string
	var psw string
	err := Database.QueryRow("SELECT CUSID,CUSPWD FROM customer WHERE CUSNAME='"+username+"'").Scan(&id,&psw)
	if err != nil {
		if err==sql.ErrNoRows{
			//用户不存在
			return "F"
		}
		CheckErr(err)
	} else {
		if password==psw{
			return "T&"+id
		}else{
			return "F"
		}
	}
	return "F"
}

func Register(username string, password string,data string)string{
	
	defer protect()

	//向数据库检查用户名是否已经被注册
	err := Database.QueryRow("SELECT CUSPWD FROM customer WHERE CUSID='"+username+"'").Scan()

	if err == nil {
		return "F"
	} else {
		if err==sql.ErrNoRows{
			//用户不存在
			stmt, err := Database.Prepare("insert customer set CUSID=?,CUSNAME=?,CUSPWD=?,CUSSEX=?,JOB=?,AREA=?,AGE=?")
			defer stmt.Close()
			CheckErr(err)
			res, err := stmt.Exec(strconv.Itoa(useduserid+1),username,password, strings.Split(data,"#")[0],
				strings.Split(data,"#")[1],strings.Split(data,"#")[2],strings.Split(data,"#")[3])
			CheckErr(err)
			id, err := res.LastInsertId()
			CheckErr(err)
			if err != nil {
				fmt.Println("插入数据失败")
				//??
				return "F"
			} else {
				fmt.Println("插入数据成功：", id)
				return "T&"+strconv.Itoa(useduserid+1)
				useduserid+=1
			}
		}
		CheckErr(err)
	}
	return "F"
}

func GetMainPage(typer string,tabid string,userid string,currentItemIndex string)string{

	defer protect()

	if typer=="getMainPage"&& tabid=="0"{

		//获取上方广告位
		rows, err := Database.Query("SELECT OUTIMAGEURL,PROID FROM upperTable ORDER BY SCORE DESC")
		defer rows.Close()

		ans:=""

		CheckErr(err)
		if err != nil {
			if err==sql.ErrNoRows{
				//无商品信息
			}
			fmt.Println("error:", err)
		} else {
			//..
			counter:=0

			var url string
			var proid string

			for rows.Next() {
				if counter==3{
					break
				}
				CheckErr(err)
				err = rows.Scan(&url,&proid)
				ans=ans+proid+"#"+url+"@"
				counter++
			}
			ans=ans[:len(ans)-1]+"&"
		}

		//visitor
		if userid=="-1"{


			//获取下方推荐位
			rows, err = Database.Query("SELECT OUTIMAGEURL,PRONAME,PROID,PROPRICE FROM shopSubTable ORDER BY SCORE DESC")

			CheckErr(err)
			if err != nil {
				if err==sql.ErrNoRows{
					//无商品信息
				}
				fmt.Println("error:", err)
			} else {
				//..
				counter:=0

				var url string
				var proname string
				var proid string
				var proprice string

				for rows.Next() {
					if counter==6{
						counter++
						break
					}
					CheckErr(err)
					err = rows.Scan(&url,&proname,&proid,&proprice)
					ans=ans+proid+"#"+proname+"#"+"¥ "+proprice+"#"+url+"@"
					counter++
				}
				ans=ans[:len(ans)-1]+"&"
			}
			if len(ans)==0{
				return ""
			}
			ans=ans[:len(ans)-1]
			return ans
		}else{
			//带有id的用户

			//获取用户近期点击的History type
			var historytype string

			err := Database.QueryRow("SELECT HISTORYTYPE FROM customer WHERE CUSID="+userid).Scan(&historytype)

			CheckErr(err)
			if err != nil {
				if err==sql.ErrNoRows{
					str:=GetMainPage(typer,tabid,"-1",currentItemIndex)
					return str
				}
				fmt.Println("error:", err)
				return ""
			} else {
				//..

				historytypes:=strings.Split(historytype,"&")

				if historytypes[0]==""{
					str:=GetMainPage(typer,tabid,"-1",currentItemIndex)
					return str
				}

				for i:=0;i< len(historytypes);i++{

					if i==6{
						break
					}

					//获取subtype对应的product
					rows, err = Database.Query("SELECT OUTIMAGEURL,PRONAME,PROID,PROPRICE FROM shopSubTable " +
						"WHERE PROSUBTYPEID="+historytypes[i]+" ORDER BY SCORE DESC")

					counter:=0
					var url string
					var proname string
					var proid string
					var proprice string


					for rows.Next() {
						if counter==6{
							break
						}
						err = rows.Scan(&url,&proname,&proid,&proprice)
						CheckErr(err)
						ans=ans+proid+"#"+proname+"#"+"¥ "+proprice+"#"+url+"@"
						counter++
					}

					ans=ans[:len(ans)-1]+"&"
				}
				if len(ans)==0{
					return ""
				}
				ans=ans[:len(ans)-1]
				return ans
			}

		}
	}else if typer=="getMainPage"{
		//tab!=0
		//获取上方广告位
		rows, err := Database.Query("SELECT OUTIMAGEURL,PROID FROM upperTable WHERE PROTYPES=" +
			tabid+" ORDER BY SCORE DESC")
		defer rows.Close()

		ans:=""

		CheckErr(err)
		if err != nil {
			if err==sql.ErrNoRows{
				//无商品信息
			}
			fmt.Println("error:", err)
		} else {
			//..
			counter:=0

			var url string
			var proid string

			for rows.Next() {
				if counter==3{
					break
				}
				CheckErr(err)
				err = rows.Scan(&url,&proid)
				ans=ans+proid+"#"+url+"@"
				counter++
			}
			ans=ans[:len(ans)-1]+"&"
		}

		//获取下方推荐位
		rows, err = Database.Query("SELECT OUTIMAGEURL,PRONAME,PROID,PROPRICE FROM shopSubTable WHERE PROTYPEID=" +
			tabid+" ORDER BY SCORE DESC")

		CheckErr(err)
		if err != nil {
			if err==sql.ErrNoRows{
				//无商品信息
			}
			fmt.Println("error:", err)
		} else {
			//..
			counter:=0

			var url string
			var proname string
			var proid string
			var proprice string

			for rows.Next() {
				if counter==6{
					break
				}
				CheckErr(err)
				err = rows.Scan(&url,&proname,&proid,&proprice)
				ans=ans+proid+"#"+proname+"#"+"¥ "+proprice+"#"+url+"@"
				counter++
			}
			ans=ans[:len(ans)-1]+"&"
		}
		if len(ans)==0{
			return ""
		}
		ans=ans[:len(ans)-1]
		return ans
	}else if typer=="getMorePage"&&tabid=="0"{
		ans:=""
		//visitor
		if userid=="-1"{

			//获取下方推荐位
			rows, err := Database.Query("SELECT OUTIMAGEURL,PRONAME,PROID,PROPRICE FROM shopSubTable ORDER BY SCORE DESC")
			defer rows.Close()
			CheckErr(err)
			if err != nil {
				if err==sql.ErrNoRows{
					//无商品信息
				}
				fmt.Println("error:", err)
			} else {
				//..
				cur,_:=strconv.Atoi(currentItemIndex)

				counter:=0
				var url string
				var proname string
				var proid string
				var proprice string

				for rows.Next() {
					if counter<cur{
						counter++
						continue
					}
					if counter==6+cur{
						break
					}
					CheckErr(err)
					err = rows.Scan(&url,&proname,&proid,&proprice)
					ans=ans+proid+"#"+proname+"#"+"¥ "+proprice+"#"+url+"@"
					counter++
				}
			}
			if len(ans)>0{
				ans=ans[:len(ans)-1]
			}
			return ans
		}else{
			//带有id的用户

			//获取用户近期点击的History type
			rows, err := Database.Query("SELECT HISTORYTYPE FROM customer WHERE CUSID="+userid)
			defer rows.Close()

			var historytype string

			CheckErr(err)
			if err != nil {
				if err==sql.ErrNoRows{
					//无id信息
				}
				fmt.Println("error:", err)
			} else {
				//..

				for rows.Next() {
					CheckErr(err)
					err = rows.Scan(&historytype)
				}
				historytypes:=strings.Split(historytype,"&")

				cur,_:=strconv.Atoi(currentItemIndex)

				counter:=0
				for i:=0;i< len(historytypes);i++{

					if counter==6{
						break
					}

					//获取subtype对应的product
					rows, err = Database.Query("SELECT OUTIMAGEURL,PRONAME,PROID,PROPRICE FROM shopSubTable " +
						"WHERE PROSUBTYPEID="+historytypes[i]+" ORDER BY SCORE DESC")

					counter1:=0
					var url string
					var proname string
					var proid string
					var proprice string

					for rows.Next() {
						if counter1<cur{
							counter1++
							continue
						}
						if counter1==6+cur{
							break
						}
						CheckErr(err)
						err = rows.Scan(&url,&proname,&proid,&proprice)
						ans=ans+proid+"#"+proname+"#"+"¥ "+proprice+"#"+url+"@"
						counter1++
					}
				}
				if len(ans)>0{
					ans=ans[:len(ans)-1]
				}
				return ans
			}

		}
	}else if typer=="getMorePage"{
		//tab!=0

		cur,_:=strconv.Atoi(currentItemIndex)


		ans:=""
		//visitor
		if userid=="-1"{

			//获取下方推荐位
			rows, err := Database.Query("SELECT OUTIMAGEURL,PRONAME,PROID,PROPRICE FROM shopSubTable ORDER BY SCORE DESC")

			CheckErr(err)
			if err != nil {
				if err==sql.ErrNoRows{
					//无商品信息
				}
				fmt.Println("error:", err)
			} else {
				//..

				counter:=0
				var url string
				var proname string
				var proid string
				var proprice string

				for rows.Next() {
					if counter<cur{
						continue
					}
					if counter==6+cur{
						break
					}
					CheckErr(err)
					err = rows.Scan(&url,&proname,&proid,&proprice)
					ans=ans+proid+"#"+proname+"#"+"¥ "+proprice+"#"+url+"@"
					counter++
				}
				ans=ans[:len(ans)-1]+"&"
			}
			ans=ans[:len(ans)-1]
			return ans
		}else{
			//带有id的用户

			//获取用户近期点击的History type

			var historytype string


			err := Database.QueryRow("SELECT HISTORYTYPE FROM customer WHERE CUSID="+userid).Scan(&historytype)
			CheckErr(err)
			if err != nil {
				if err==sql.ErrNoRows{
					return GetMainPage(typer,tabid,"-1",currentItemIndex)
				}
				fmt.Println("error:", err)
				return ""
			} else {
				//..
				historytypes:=strings.Split(historytype,"&")

				counter:=0
				for i:=0;i< len(historytypes);i++{

					if counter<cur{
						continue
					}
					if counter==6+cur{
						break
					}

					//获取subtype对应的product
					rows, err := Database.Query("SELECT OUTIMAGEURL,PRONAME,PROID,PROPRICE FROM shopSubTable" +
						"WHERE PROSUBTYPEID="+historytypes[i]+" ORDER BY SCORE DESC")

					counter:=0
					var url string
					var proname string
					var proid string
					var proprice string

					for rows.Next() {
						if counter<cur{
							continue
						}
						if counter==6+cur{
							break
						}
						CheckErr(err)
						err = rows.Scan(&url,&proname,&proid,&proprice)
						ans=ans+proid+"#"+proname+"#"+"¥ "+proprice+"#"+url+"@"
						counter++
					}
					ans=ans[:len(ans)-1]+"&"
				}
				ans=ans[:len(ans)-1]
				return ans
			}

		}
	}
	return""
}

func GetSearchAssociation(typer string,userid string,query string)string{

	defer protect()

	//fmt.Fprint(w,query+"&"+query)

	rows, err := Database.Query("SELECT PROSHORTNAME FROM shopSubTable WHERE PRONAME LIKE '%"+query+"%' OR '"+query+"%' OR '%"+query+"' ORDER BY SCORE DESC")
	defer rows.Close()

	CheckErr(err)
	if err != nil {
		if err==sql.ErrNoRows{
			//无商品信息
		}
		fmt.Println("error:", err)
		return ""
	} else {
		//..

		ans:=""
		var l []string
		counter:=0
		var proname string

		for rows.Next() {
			if counter==12{
				break
			}
			CheckErr(err)
			err = rows.Scan(&proname)
			isIn:=false
			for m:=0;m< len(l);m++{
				if l[m]==proname{
					isIn=true
					break
				}
			}

			if isIn==false{
				l=append(l, proname)
				ans=ans+proname+"&"
			}
			counter++
		}
		ans=ans[:len(ans)-1]
		return ans
	}
}

func GetSearchResult(typer string,plan string,userid string,query string,currentindex string)string{

	defer protect()

	ans:=""

	cur,_:=strconv.Atoi(currentindex)

	if plan=="综合"{
		rows, err := Database.Query("SELECT OUTIMAGEURL,PRONAME,PROID,PROPRICE FROM shopSubTable " +
			"WHERE PRONAME LIKE '%"+query+"%' OR '%"+query+"' OR '"+query+"%' ORDER BY SCORE DESC")
		defer rows.Close()

		CheckErr(err)
		if err != nil {
			if err==sql.ErrNoRows{
				//无商品信息
			}
			fmt.Println("error:", err)
			return ""
		} else {
			//..
			counter:=0

			var url string
			var proname string
			var proid string
			var proprice string

			for rows.Next() {
				if counter<cur{
					counter++
					continue
				}
				if counter==6+cur{
					ans=ans[:len(ans)-1]
					return ans
				}
				CheckErr(err)
				err = rows.Scan(&url,&proname,&proid,&proprice)
				ans=ans+proid+"#"+proname+"#"+"¥ "+proprice+"#"+url+"@"
				counter++
			}
			ans=ans[:len(ans)-1]
			return ans
		}
	}else if plan=="价格升序"{
		rows, err := Database.Query("SELECT OUTIMAGEURL,PRONAME,PROID,PROPRICE FROM shopSubTable " +
			"WHERE PRONAME LIKE '%"+query+"%' OR '%"+query+"' OR '"+query+"%' ORDER BY PROPRICE ASC")
		defer rows.Close()

		CheckErr(err)
		if err != nil {
			if err==sql.ErrNoRows{
				//无商品信息
			}
			fmt.Println("error:", err)
			return ""
		} else {
			//..
			counter:=0

			var url string
			var proname string
			var proid string
			var proprice string

			for rows.Next() {
				if counter<cur{
					counter++
					continue
				}
				if counter==6+cur{
					ans=ans[:len(ans)-1]
					return ans
				}
				CheckErr(err)
				err = rows.Scan(&url,&proname,&proid,&proprice)
				ans=ans+proid+"#"+proname+"#"+"¥ "+proprice+"#"+url+"@"
				counter++
			}
			ans=ans[:len(ans)-1]
			return ans
		}

	}else if plan=="价格降序"{
		rows, err := Database.Query("SELECT OUTIMAGEURL,PRONAME,PROID,PROPRICE FROM shopSubTable " +
			"WHERE PRONAME LIKE '%"+query+"%' OR '%"+query+"' OR '"+query+"%' ORDER BY PROPRICE DESC")
		defer rows.Close()

		CheckErr(err)
		if err != nil {
			if err==sql.ErrNoRows{
				//无商品信息
			}
			fmt.Println("error:", err)
			return ""
		} else {
			//..
			counter:=0

			var url string
			var proname string
			var proid string
			var proprice string

			for rows.Next() {
				if counter<cur{
					counter++
					continue
				}
				if counter==6+cur{
					ans=ans[:len(ans)-1]
					return ans
				}
				CheckErr(err)
				err = rows.Scan(&url,&proname,&proid,&proprice)
				ans=ans+proid+"#"+proname+"#"+"¥ "+proprice+"#"+url+"@"
				counter++
			}
			ans=ans[:len(ans)-1]
			return ans
		}

	}else if plan=="销量"{
		rows, err := Database.Query("SELECT OUTIMAGEURL,PRONAME,PROID,PROPRICE FROM shopSubTable " +
			"WHERE PRONAME LIKE '%"+query+"%' OR '%"+query+"' OR '"+query+"%' ORDER BY NSOLD DESC")
		defer rows.Close()

		CheckErr(err)
		if err != nil {
			if err==sql.ErrNoRows{
				//无商品信息
			}
			fmt.Println("error:", err)
			return ""
		} else {
			//..
			counter:=0

			var url string
			var proname string
			var proid string
			var proprice string

			for rows.Next() {
				if counter<cur{
					counter++
					continue
				}
				if counter==6+cur{
					ans=ans[:len(ans)-1]
					return ans
				}
				CheckErr(err)
				err = rows.Scan(&url,&proname,&proid,&proprice)
				ans=ans+proid+"#"+proname+"#"+"¥ "+proprice+"#"+url+"@"
				counter++
			}
			ans=ans[:len(ans)-1]
			return ans
		}

	}
	return ""
}

func GetProductPage(typer string,locationfrom string,index string,userid string,proid string)string{

	defer protect()

	if typer=="getProductPage"{
		//根据商品ID找到商品信息
		rows, err := Database.Query("SELECT UPIMAGEURL1,UPIMAGEURL2,UPIMAGEURL3,PRONAME,PROPRICE,PROTYPES," +
			"DETAILSIMAGEURL1,DETAILSIMAGEURL2,DETAILSIMAGEURL3,DETAILSIMAGEURL4,PROSUBTYPEID FROM shopSubTable WHERE PROID="+proid)
		defer rows.Close()

		CheckErr(err)

		prosubtypeid:="-1"

		CheckErr(err)
		if err != nil {
			if err==sql.ErrNoRows{
				//无商品信息
			}
			fmt.Println("error:", err)
			return ""
		} else {
			//..

			var upurl1 string
			var upurl2 string
			var upurl3 string
			var proname string
			var proprice string
			var protypes string
			var detailsimageurl1 string
			var detailsimageurl2 string
			var detailsimageurl3 string
			var detailsimageurl4 string

			ans:=""

			for rows.Next() {
				CheckErr(err)
				err = rows.Scan(&upurl1,&upurl2,&upurl3,&proname,&proprice,&protypes,&detailsimageurl1,&detailsimageurl2,&detailsimageurl3,&detailsimageurl4,&prosubtypeid)
				ans=upurl1+"#"+upurl2+"#"+upurl3+"&"+proname+"#"+"¥ "+proprice+"&"+protypes+"&"+detailsimageurl1+"#"+detailsimageurl2+"#"+detailsimageurl3+"#"+detailsimageurl4
			}

			//is in wish list or not
			var temp string
			err := Database.QueryRow("SELECT CUSSEX,JOB,AREA,PAYLEVEL,AGE,WISHLIST FROM customer WHERE CUSID="+userid).Scan(&temp)

			iswished:="0"

			CheckErr(err)
			if err != nil {
				if err==sql.ErrNoRows{
					//无商品信息
				}
				fmt.Println("error:", err)
			} else {
				temps:=strings.Split(temp,"&")
				for i:=0;i< len(temp);i++{
					if temps[i]==proid{
						iswished="1"
						break
					}
				}
			}
			ans=ans+"&"+iswished

			go func(){

				//增加用户足迹

				var cussex string
				var job string
				var area string
				var paylevel string
				var age string

				var his string
				var hisT string
				err := Database.QueryRow("SELECT CUSSEX,JOB,AREA,PAYLEVEL,AGE,HISTORY,HISTORYTYPE FROM customer WHERE CUSID="+userid).Scan(&cussex,&job,&area,&paylevel,&age,&his,&hisT)

				CheckErr(err)

				historys:=strings.Split(his,"&")
				historyTypes:=strings.Split(hisT,"&")

				//保存20个记录，修改时数据库的CHAR长度需要同步
				if len(historys)<20&&historys[0]!=""{
					//直接插入
					_,err0 := Database.Query("UPDATE customer SET HISTORY='"+proid+"&"+his+"' WHERE CUSID="+userid)
					CheckErr(err0)
				}else if len(historys)==20{
					htemp:=proid
					for i:=0;i<19;i++{
						htemp=htemp+"&"+historys[i]
					}
					_,err0 := Database.Query("UPDATE customer SET HISTORY='"+htemp+"' WHERE CUSID="+userid)
					CheckErr(err0)
				}else {
					_,err0 := Database.Query("UPDATE customer SET HISTORY='"+proid+"' WHERE CUSID="+userid)
					CheckErr(err0)
				}

				//记录浏览的子类目id
				state:=false
				for i:=0;i<len(historyTypes);i++{
					if historyTypes[i]==prosubtypeid{
						state=true
						break
					}
				}

				if len(historyTypes)==6{
					//满了
					if state==true{
						//..
						//do nothing
					}else {
						h:=prosubtypeid+"&"+historyTypes[0]+"&"+historyTypes[1]+"&"+historyTypes[2]+"&"+historyTypes[3]+
							"&"+historyTypes[4]+"&"+historyTypes[5]
						_,err0 := Database.Exec("UPDATE customer SET HISTORYTYPE='"+h+"' WHERE CUSID="+userid)
						CheckErr(err0)
					}
				}else {
					//没满
					if state==true{
						//..
						//do nothing
					}else {
						h:=prosubtypeid
						if historyTypes[0]!=""{
							for i:=0;i< len(prosubtypeid);i++{
								h=h+"&"+historyTypes[i]
							}
						}
							_,err0 := Database.Exec("UPDATE customer SET HISTORYTYPE='"+h+"' WHERE CUSID="+userid)
						CheckErr(err0)
					}
				}

				//处理流量信息

				buyer:="NNEWVISITOR"

				rows, err := Database.Query("SELECT PROIDS FROM customerOrderHis WHERE CUSID="+userid)

				CheckErr(err)

				if err!=nil{
					return
				}

				var temp string
				for rows.Next() {
					err = rows.Scan(&temp)
					temps:=strings.Split(temp,"#")
					for i:=0;i< len(temp);i++{
						 if temps[i]==proid{
							buyer="NNEWVISITOR"
							break
						}
					}
				}

				sex:="NFEMALEVISITOR"

				if cussex=="男" {
					sex = "NMALEVISITOR"
				}

				t:="N"+strconv.Itoa(time.Now().Hour())

				narea:="NFAREA"+area

				nlevel:="NLEVEL"+paylevel

				var njob string
				if job=="学生"{
					njob="NJOB4"
				}else if job=="个体经验/服务"{
					njob="NJOB0"
				}else if job=="公务员"{
					njob="NJOB1"
				}else if job=="公司职员"{
					njob="NJOB2"
				}else if job=="医务人员"{
					njob="NJOB3"
				}else if job=="教职工"{
					njob="NJOB5"
				}

				var nage string

				ageint,_:=strconv.Atoi(age)
				if 0<=ageint&&ageint<18{
					nage="NAGE0_18"
				}else if 18<=ageint&&ageint<25{
					nage="NAGE18_25"
				}else if 25<=ageint&&ageint<40{
				nage="NAGE25_40"
				}else if 40<=ageint&&ageint<60{
					nage="NAGE40_60"
				}else{
					nage="NAGE60_150"
				}

				//开启事务
				tx,err:=Database.Begin()
				CheckErr(err)

				//记录到 flowSourcePe中

				exec:="update flowSourcePe set NSCAN=NSCAN+1,"+buyer+"="+buyer+"+1,"+sex+"="+sex+"+1,"+t+"="+t+"+1,"+
					narea+"="+narea+"+1,"+nlevel+"="+nlevel+"+1,"+njob+"="+njob+"+1,"+nage+"="+nage+"+1 WHERE PROID="+proid+
					" AND FLOWDATE='"+time.Now().Format("2006-01-02")+"'"

				fmt.Println(exec)

				_, err1 := tx.Exec(exec)

				CheckErr(err1)

				//记录到 flowSourceFrom中
				from:="FROM"+strings.ToUpper(locationfrom)

				print(from)

				exec1:="update flowSourceFrom set "+from+"="+from+"+1 WHERE PROID="+proid+" AND RECDATE='"+time.Now().Format("2006-01-02")+"'"
				print(exec1)
				_, err2 := tx.Exec(exec)

				//如果有错误，该次流量不进行记录
				if err1!=nil||err2!=nil{
					tx.Rollback()
				}

				//提交事务
				tx.Commit()
			}()

			return ans
		}
	}else if index=="2"{
		//get recommend page

		//get sub type of the product
		rows, err := Database.Query("SELECT PROSUBTYPEID FROM shopSubTable WHERE PROID="+proid)
		defer rows.Close()
		CheckErr(err)

		var subtypeid string
		for rows.Next() {
			err = rows.Scan(&subtypeid)
			CheckErr(err)
		}

		rows1, err1 := Database.Query("SELECT OUTIMAGEURL,PRONAME,PROID,PROPRICE FROM shopSubTable ORDER BY SCORE DESC")
		defer rows.Close()

		CheckErr(err1)
		if err != nil {
			if err==sql.ErrNoRows{
				//无商品信息
			}
			fmt.Println("error:", err)
			return ""
		} else {
			//..
			counter:=0

			var url string
			var proname string
			var proid string
			var proprice string

			ans:=""

			for rows1.Next() {
				if counter==8{
					break
				}
				CheckErr(err)
				err = rows1.Scan(&url,&proname,&proid,&proprice)
				ans=ans	+proid+"#"+proname+"#"+"¥ "+proprice+"#"+url+"@"
				counter++
			}
			ans=ans[:len(ans)-1]
			return ans
		}

	}/*else if index=="3"{
		//comment page is removed
	}*/
	return ""
}

func AddActions(typer string,state string,userid string,proid string)string{

	defer protect()

	rows,err:=Database.Query("SELECT WISHLIST,SHOPCART FROM customer WHERE CUSID="+userid)
	defer rows.Close()
	CheckErr(err)

	var wishlist string
	var shopcart string

	newwishlist:=""
	newshopcart:=""

	for rows.Next() {
		err = rows.Scan(&wishlist,&shopcart)
	}

	if typer=="WL"{
		//...
		//state is true or false
		if state=="true"{
			//set it false
			wishes:=strings.Split(wishlist,"&")
			for i:=0;i< len(wishes);i++{
				if wishes[i]!=proid{
					newwishlist=newwishlist+wishes[i]+"&"
				}
			}
			if len(newwishlist)!=0{
				newwishlist=newwishlist[0:len(newwishlist)-1]
			}
			_,err:=Database.Exec("UPDATE customer SET WISHLIST='"+newwishlist+"' WHERE CUSID="+userid)
			CheckErr(err)

			return "done"

		}else if state=="false"{
			//set it true
			wishes:=strings.Split(wishlist,"&")
			for i:=0;i< len(wishes)-1;i++{
				if wishes[i]!=proid{
					newwishlist=newwishlist+"&"+wishes[i]
				}else {
					//already exist
					return "done"
				}
			}
			newwishlist=proid+newwishlist
			_,err:=Database.Exec("UPDATE customer SET WISHLIST='"+newwishlist+"' WHERE CUSID="+userid)
			CheckErr(err)

			return "done"
		}

	}else if typer=="SC"{
		//...
		//state means type state
		//判断有没有这个商品以及有没有这个类型(state变量)

		pros:=strings.Split(shopcart,"&")

		if pros[0]==""{
			newshopcart=proid+"#"+"1"+"#"+state
			_,err:=Database.Exec("UPDATE customer SET SHOPCART='"+newshopcart+"' WHERE CUSID="+userid)
			CheckErr(err)

			return "done"
		}

		isIn:=false

		for i:=0;i< len(pros);i++{
			prodatas:=strings.Split(pros[i],"#")
			if prodatas[0]==proid && prodatas[2]==state{
				isIn=true
				num,_:=strconv.Atoi(prodatas[1])
				num+=1
				prodatas[1]=strconv.Itoa(num)
			}
			if i== len(pros)-1 && isIn==false{
				//看完最后一个，没找到 加在队首
				if len(pros)>=20{
					//队列已满,不加最后一个
					newshopcart=proid+"#"+"1"+"#"+state+"&"
					break
				}else{
					//队列未满
					newshopcart=proid+"#"+"1"+"#"+state+"&"
				}
			}
			newshopcart=newshopcart+prodatas[0]+"#"+prodatas[1]+"#"+prodatas[2]+"&"
		}

		newshopcart=newshopcart[0:len(newshopcart)-1]
		_,err:=Database.Exec("UPDATE customer SET SHOPCART='"+newshopcart+"' WHERE CUSID="+userid)
		CheckErr(err)

		return "done"
	}else if typer=="changeTypeFromSC"{
		//...
		newtype:=strings.Split(state,"#")[0]
		oldtype:=strings.Split(state,"#")[1]
		pros:=strings.Split(shopcart,"&")
		for i:=0;i< len(pros);i++{
			prodatas:=strings.Split(pros[i],"#")
			if prodatas[0]==proid && prodatas[2]==oldtype{
				prodatas[2]=newtype
			}

			newshopcart=newshopcart+prodatas[0]+"#"+prodatas[1]+"#"+prodatas[2]+"&"
		}
		newshopcart=newshopcart[0:len(newshopcart)-1]
		_,err:=Database.Exec("UPDATE customer SET SHOPCART='"+newshopcart+"'")
		CheckErr(err)
		return "done"
	}
	return ""
}

func GetShopCartPage(userid string,currentitemindex string)string{

	defer protect()
	
	cur,_:=strconv.Atoi(currentitemindex)

	//获取userid对应sc信息
	var pro string
	err := Database.QueryRow("SELECT SHOPCART FROM customer WHERE CUSID="+userid).Scan(&pro)
	CheckErr(err)
	if err != nil {
		if err==sql.ErrNoRows{
			//无商品信息
			return ""
		}
		if pro==""{
			return ""
		}
	} else {
		//..

		pros:=strings.Split(pro,"&")

		ans:=""

		for i:=0;i< len(pros);i++{
			proid:=strings.Split(pros[i],"#")[0]
			rows, err := Database.Query("SELECT OUTIMAGEURL,PRONAME,PROID,PROPRICE,PROTYPES FROM shopSubTable WHERE PROID="+proid)
			defer rows.Close()
			CheckErr(err)
			if err != nil {
				if err==sql.ErrNoRows{
					//无商品信息
				}
				fmt.Println("error:", err)
			} else {
				//..
				counter:=0
				var url string
				var proname string
				var proid string
				var proprice string
				var protypes string

				for rows.Next() {
					if counter<cur{
						continue
					}
					if counter==6+cur{
						break
					}
					CheckErr(err)
					err = rows.Scan(&url,&proname,&proid,&proprice,&protypes)
					ans=ans+proname+"#"+"¥ "+proprice+"#"+strings.Split(pros[i],"#")[2]+"@"+protypes+"#"+
						strings.Split(pros[i],"#")[1]+"#"+proid+"#"+url+"&"
					counter++
				}
			}
		}

		ans=ans[:len(ans)-1]
		return ans

	}
	return ""
}

func EditShopCartPage(userid string,order string)string{

	defer protect()
	//...
	//delete targets
	_,err:=Database.Exec("UPDATE customer SET SHOPCART='"+order+"' WHERE CUSID="+userid)
	CheckErr(err)
	return "done"
}

func GetAddress(userid string)string{

	defer protect()

	var address string
	err := Database.QueryRow("SELECT ADDRESS FROM customer WHERE CUSID="+userid).Scan(&address)
	CheckErr(err)
	if err != nil {
		if err==sql.ErrNoRows{
			return ""
		}
		fmt.Println("error:", err)
	} else {
		//..
		return address
	}
	return ""
}

func EditAddress(newAddresses string,userid string)string{
	//...
	defer protect()

	_,err:=Database.Exec("UPDATE customer SET ADDRESS='"+newAddresses+"' WHERE CUSID="+userid)
	CheckErr(err)
	return "done"
}

func PayConfirm(userid string,order string)string{

	defer protect()

	//开启事务
	tx,err:=Database.Begin()
	CheckErr(err)

	//获取ip和num
	orders:=strings.Split(order,"@")

	//逐个进行修改，若有错误则回滚并返回
	for i:=0;i< len(orders);i++{
		id:=strings.Split(orders[i],"#")[0]
		num:=strings.Split(orders[i],"#")[1]
		typer:=strings.Split(orders[i],"#")[2]
		exec:="update shopSubTable set REST=REST-"+num+",NSOLD=NSOLD+"+num+" WHERE PROID="+id

		_, err := tx.Exec(exec)
		if err!=nil{
			tx.Rollback()
			fmt.Println(err)
			return "Failed"
		}

		//记录用户购买信息
		_, err = tx.Exec("INSERT INTO customerOrderHis VALUES ("+userid+","+id+","+num+",'"+typer+"','"+
			time.Now().Format("2006-01-02")+"','"+time.Now().Format("15:04:05")+"')")
		if err!=nil{
			tx.Rollback()
			fmt.Println(err)
			return "Failed"
		}
	}
	//提交事务
	tx.Commit()
	return "Succeed"
}

func GetMyPage(userid string) string {

	defer protect()

	var history string
	var wishList string
	var address string

	//..
	err := Database.QueryRow("SELECT HISTORY,WISHLIST,ADDRESS FROM customer WHERE CUSID="+userid).Scan(&history,&wishList,&address)
	if err != nil {
		if err==sql.ErrNoRows{
			return "0@0"
		}
		fmt.Println("error:", err)
	} else {
		hislen:=len(strings.Split(history,"&"))
		wislen:=len(strings.Split(wishList,"&"))
		if history==""{
			hislen=0
		}
		if wishList==""{
			wislen=0
		}
		ans:=strconv.Itoa(wislen)+"@"+strconv.Itoa(hislen)+"@"+address
		return ans
	}
	return "0@0"
}

func GetFootprint(userid string)string  {

	defer protect()

	//..

	//get porids

	var history string


	err := Database.QueryRow("SELECT HISTORY FROM customer WHERE CUSID="+userid).Scan(&history)
	CheckErr(err)
	if err != nil {
		if err==sql.ErrNoRows{
			return ""
		}
		fmt.Println("error:", err)
	} else {
		ans:=""
		historys:=strings.Split(history,"&")

		if historys[0]==""{
			return ""
		}

		for i:=0;i< len(historys);i++{
			row, err := Database.Query("SELECT OUTIMAGEURL FROM shopSubTable WHERE PROID="+historys[i])
			defer row.Close()
			CheckErr(err)
			if err != nil {
				if err==sql.ErrNoRows{
					continue
				}
				fmt.Println("error:", err)
			} else {

				var hisurl string
				for row.Next() {
					err = row.Scan(&hisurl)
					CheckErr(err)
				}

				ans=ans+historys[i]+"#"+hisurl+"&"
			}
		}
		if len(strings.Split(ans,"&"))>1{
			ans=ans[0:len(ans)-1]
		}		
		return ans
	}
	return ""
}

func GetWishList(userid string)string  {

	defer protect()
	//..

	var history string

	err := Database.QueryRow("SELECT WISHLIST FROM customer WHERE CUSID="+userid).Scan(&history)
	CheckErr(err)
	if err != nil {
		if err==sql.ErrNoRows{
			return ""
		}
		fmt.Println("error:", err)
	} else {
		ans:=""

		historys:=strings.Split(history,"&")
		
		if historys[0]==""{
			return ""
		}

		for i:=0;i< len(historys);i++{
			row, err := Database.Query("SELECT OUTIMAGEURL,PRONAME,PROPRICE FROM shopSubTable WHERE PROID="+historys[i])
			defer row.Close()
			CheckErr(err)
			if err != nil {
				if err==sql.ErrNoRows{
					continue
				}
				fmt.Println("error:", err)
			} else {
				var wishurl string
				var proname string
				var proprice string
				for row.Next() {
					err = row.Scan(&wishurl,&proname,&proprice)
					CheckErr(err)
				}

				ans=ans+proname+"#"+historys[i]+"#"+proprice+"#"+wishurl+"&"
			}
		}
		if len(strings.Split(ans,"&"))>1{
			ans=ans[0:len(ans)-1]
		}	
		
		return ans
	}
	return ""
}