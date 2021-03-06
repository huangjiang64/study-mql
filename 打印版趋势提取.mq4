
//|                                                       趋势策略提取.mq4 |
//|                                                               hj |
//|                             https://cn.icmarkets.com/?camp=21702 |
//+------------------------------------------------------------------+
#property copyright "hj"
#property link      "https://cn.icmarkets.com/?camp=21702"
#property version   "1.00"
#property strict
#include "汇群MT4界面设计库.mqh"
//+------------------------------------------------------------------+
extern  int magic=9900;
extern ENUM_TIMEFRAMES TF=PERIOD_M5;//Fractals 周期
                              //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>趋势策略设置>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
extern  string  趋势策略="------趋势策略参数设置-----s01---------";
extern  int magic_s01=9901;
extern  ENUM_TIMEFRAMES  大周期_s01=PERIOD_M15;//
extern  ENUM_MA_METHOD   大周期均线类型_s01=MODE_SMA;
extern  int    大周期均线1_s01=120;
extern  int    大周期均线2_s01=20;
extern  ENUM_TIMEFRAMES  小周期_s01=PERIOD_M5;
extern  ENUM_MA_METHOD   小周期均线类型_s01=MODE_EMA;
extern  int    小周期均线1_s01=55;
extern  int    小周期均线2_s01=12;
extern  double 初始手数_s01=0.1;
extern  bool   是否顺势加仓_s01=true;
extern  double 加仓倍数_s01=0.8;
extern  int    最大加仓次数_s01=3;
extern  double 加仓间隔点数_s01=500;
extern  int    止损点数_s01=500;
extern  int    止盈点数_s01=1500;
extern  bool   是否移动止损_s01=true;
extern  int    移动止损点数_s01=500;
datetime       buytime_s01=0;
datetime       selltime_s01=0;
//顺势策略：多周期共振
//指标：MA，K线突破；
//进出场条件 ：大周期均线交叉定方向；小周期均线交叉和K线突破定进场价位和出场价位 ；动态止损（根据本周期ATR值计算）；动态止盈（根据更大周期ATR设置）
//+------------------------------------------------------------------+
int OnInit()
{
return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
{
}
//+------------------------------------------------------------------+

void OnTick()
{
//》》》》》趋势策略01《《《《《《《
double ma1=iMA(Symbol(),大周期_s01,大周期均线1_s01,0,大周期均线类型_s01,0,0);//120
double ma2=iMA(Symbol(),大周期_s01,大周期均线2_s01,0,大周期均线类型_s01,0,0);//20
double ma3=iMA(Symbol(),小周期_s01,小周期均线1_s01,0,小周期均线类型_s01,0,0);//55
double ma4=iMA(Symbol(),小周期_s01,小周期均线2_s01,0,小周期均线类型_s01,0,0);//12
double ma3_1=iMA(Symbol(),小周期_s01,小周期均线1_s01,0,小周期均线类型_s01,0,1);//55均线前一根
double ma4_1=iMA(Symbol(),小周期_s01,小周期均线2_s01,0,小周期均线类型_s01,0,1);//12均线前一根

double buyop_s01,buylots_s01;
int buydanshu_s01=buydanshu(buyop_s01,buylots_s01,magic_s01);

double sellop_s01,selllots_s01;
int selldanshu_s01=selldanshu(sellop_s01,selllots_s01,magic_s01);
//>>>>>>>> >>>>>趋势多单入场>>>>>>>>>buy>>>>>>>>>>>>>>>>>>>>>>>>>>>

if(buydanshu_s01==0)
{
if(ma2>ma1)//大周期上涨趋势
  {
   if(ma4_1<=ma3_1 && ma4_1<=ma4 && ma4>ma3 && Ask-ma3>=0 && Ask-ma3<=200*Point && MarketInfo(Symbol(),MODE_SPREAD)<100)//均线金叉
     {
      if(buytime_s01!=iTime(Symbol(),小周期_s01,0))
        {
         if(buy(初始手数_s01,止损点数_s01,止盈点数_s01,Symbol()+"趋势策略 buy"+IntegerToString(buydanshu_s01+1,0),magic_s01)>0)
           {
            buytime_s01=iTime(Symbol(),小周期_s01,0);
           }
        }
     }
  }
}
else//buydanshu不为0
{
if(是否顺势加仓_s01==true)//顺势加仓
  {
   if(buydanshu_s01<=最大加仓次数_s01 && (Ask-buyop_s01)>=加仓间隔点数_s01*Point && buytime_s01!=iTime(Symbol(),小周期_s01,0))
     {
      if(iClose(Symbol(),大周期_s01,1)>iOpen(Symbol(),大周期_s01,1) && iClose(Symbol(),小周期_s01,1)>iClose(Symbol(),大周期_s01,1)
       && MarketInfo(Symbol(),MODE_SPREAD)<100)
      //顺势加仓条件:昨日上涨，今日前一小时收盘价大于昨日收盘价,点差小于50
        {
         if(buy(flots(buylots_s01*加仓倍数_s01),止损点数_s01,止盈点数_s01,Symbol()+"趋势策略 buy"+IntegerToString(buydanshu_s01+1,0),magic_s01)>0)
           {
            buytime_s01=iTime(Symbol(),小周期_s01,0);
           }
        }
     }
  }

//>>>>>>>>>>>>>>sell>>>>>>>>>>>>趋势空单入场>>>>>>>>>>>>>>>>>

if(selldanshu_s01==0)
  {

   if(ma2<ma1)//大周期下跌趋势
     {

      if(ma4_1>=ma3_1 && ma4_1>=ma4 && ma4<ma3 && ma3-Bid>=0 && ma3-Bid<=200*Point && MarketInfo(Symbol(),MODE_SPREAD)<100)//均线金叉
        {
         if(selltime_s01!=iTime(Symbol(),小周期_s01,0))
           {
            if(sell(初始手数_s01,止损点数_s01,止盈点数_s01,Symbol()+"趋势策略 sell"+IntegerToString(selldanshu_s01+1,0),magic_s01)>0)
              {
               selltime_s01=iTime(Symbol(),小周期_s01,0);
              }
           }
        }

     }
  }
else//selldanshu不为0
  {
   if(是否顺势加仓_s01==true)//顺势加仓
     {
      if(selldanshu_s01<=最大加仓次数_s01 && (sellop_s01-Bid)>=加仓间隔点数_s01*Point && selltime_s01!=iTime(Symbol(),小周期_s01,0))
        {
         if(iClose(Symbol(),大周期_s01,1)<iOpen(Symbol(),大周期_s01,1) && iClose(Symbol(),小周期_s01,1)<iClose(Symbol(),大周期_s01,1) 
         && MarketInfo(Symbol(),MODE_SPREAD)<100)
         //顺势加仓条件:昨日下跌，今日前一小时收盘价小于昨日收盘价,点差小于50
           {
            if(sell(flots(selllots_s01*加仓倍数_s01),止损点数_s01,止盈点数_s01,Symbol()+"趋势策略 sell"+IntegerToString(selldanshu_s01+1,0),magic_s01)>0)
              {
               // printf("顺势交易策略开启");
               selltime_s01=iTime(Symbol(),小周期_s01,0);
              }
           }
        }
     }
  }
// printf("顺势交易策略开启");
}
//《《《《《《《《《《《《趋势策略出场策略《《《《《《《《《《《《《《
if(buydanshu_s01>0 || selldanshu_s01>0)
{
if(是否移动止损_s01==true)//移动止损
  {
   yidong(移动止损点数_s01,magic_s01);
  }
}
if(buydanshu_s01>0)
{

if(ma4_1>ma3_1 && ma4<=ma3 && MathAbs(Ask-buyop_s01)>=200*Point)//小周期均线死叉，现价离最近多单开仓价20点以上
  {
   closebuy(magic_s01);
  }
}
if(selldanshu_s01>0)
{
if(ma4_1<ma3_1 && ma4>=ma3 && MathAbs(Bid-sellop_s01)>=200*Point)//小周期均线金叉，现价离最近空单开仓价20点以上
  {
   closesell(magic_s01);
  }
}

}
//+------------------------------------------------------------------+
//==========================自定义函数部分=================================================

void yidong(int 移动止损点数,int magicnum)
{
for(int i=0;i<OrdersTotal();i++)//移动止损通用代码,次代码会自动检测buy和sell单并对其移动止损
{
if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
  {
   if(OrderType()==0 && OrderSymbol()==Symbol() && OrderMagicNumber()==magicnum)
     {
      if((Bid-OrderOpenPrice())>=Point*移动止损点数)
        {
         if(OrderStopLoss()<(Bid-Point*移动止损点数) || (OrderStopLoss()==0))
           {
            OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*移动止损点数,OrderTakeProfit(),0,Green);
           }
        }
     }
   if(OrderType()==1 && OrderSymbol()==Symbol() && OrderMagicNumber()==magicnum)
     {
      if((OrderOpenPrice()-Ask)>=(Point*移动止损点数))
        {
         if((OrderStopLoss()>(Ask+Point*移动止损点数)) || (OrderStopLoss()==0))
           {
            OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*移动止损点数,OrderTakeProfit(),0,Red);
           }
        }
     }
  }
}
}
//+------------------------------------------------------------------+
writetext("symbol",Symbol(),600,160,clrGray,50);
//+------------------------------------------------------------------+
void writetext(string Labelname,string data,int x,int y,color ColorValue,int FontSize)//通过Object写文字
{
ObjectDelete(Labelname);
ObjectCreate(Labelname,OBJ_LABEL,0,0,0);
ObjectSetText(Labelname,data,FontSize,"Times New Roman",ColorValue);
ObjectSet(Labelname,OBJPROP_CORNER,0);
ObjectSet(Labelname,OBJPROP_XDISTANCE,x);
ObjectSet(Labelname,OBJPROP_YDISTANCE,y);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double buyprofit(int magicnum) //省略sell
{
double a=0;
int t=OrdersTotal();
for(int i=t-1;i>=0;i--)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
{
if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
  {
   if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber()==magicnum)
     {
      a=a+OrderProfit()+OrderCommission()+OrderSwap();
     }
  }
}
return(a);
}
//+------------------------------------------------------------------+

void closebuy(int magicnum) //省略sell
{
double buyop,buylots;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
while(buydanshu(buyop,buylots,magicnum)>0)
{
int t=OrdersTotal();
for(int i=t-1;i>=0;i--)

  {
   if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
     {
      if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber()==magicnum)
        {
         OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),300,Green);
        }
     }
  }
Sleep(800);
}
}
//+------------------------------------------------------------------+

void tralingbuy(double sl,int magicnum) //没看到哪里用
{
for(int i=0;i<OrdersTotal();i++)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
{
if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
  {
   if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber()==magicnum)
     {
      if(NormalizeDouble(OrderStopLoss(),Digits)!=NormalizeDouble(sl,Digits))
        {
         OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,Green);
        }
     }
  }
}
}
//+------------------------------------------------------------------+

void tralingprofitbuy(int  sl,int magicnum)
{
for(int i=0;i<OrdersTotal();i++)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
{
if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
  {
   if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber()==magicnum)
     {
      if(NormalizeDouble(OrderStopLoss(),Digits)!=NormalizeDouble(OrderOpenPrice()+sl*Point,Digits))
        {
         OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+sl*Point,OrderTakeProfit(),0,Green);
        }
     }
  }
}
}
//+------------------------------------------------------------------+

void tralingsell(double sl,int magicnum)
{
for(int i=0;i<OrdersTotal();i++)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
{
if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
  {
   if(OrderSymbol()==Symbol() && OrderType()==OP_SELL && OrderMagicNumber()==magicnum)
     {
      if(NormalizeDouble(OrderStopLoss(),Digits)!=NormalizeDouble(sl,Digits))
        {
         OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,Green);
        }
     }
  }
}
}
//+------------------------------------------------------------------+

void tralingprofitsell(int  sl,int magicnum)
{
for(int i=0;i<OrdersTotal();i++)

{
if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
  {
   if(OrderSymbol()==Symbol() && OrderType()==OP_SELL && OrderMagicNumber()==magicnum)
     {
      if(NormalizeDouble(OrderStopLoss(),Digits)!=NormalizeDouble(OrderOpenPrice()-sl*Point,Digits))
        {
         OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-sl*Point,OrderTakeProfit(),0,Green);
        }
     }
  }
}
}
//+------------------------------------------------------------------+

double flots(double dlots) //手数标准化
{
double fb=NormalizeDouble(dlots/MarketInfo(Symbol(),MODE_MINLOT),0);
return(MarketInfo(Symbol(),MODE_MINLOT)*fb);
}
//+------------------------------------------------------------------+
void buyxiugaitp(double tp,int magicnum)
{
for(int i=0;i<OrdersTotal();i++)
{
if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
  {
   if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber()==magicnum)
     {
      if(NormalizeDouble(OrderTakeProfit(),Digits)!=NormalizeDouble(tp,Digits))
        {
         OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),tp,0,Green);
        }
     }
  }
}
}
//+------------------------------------------------------------------+

double avgbuyprice(int magicnum)
{
double a=0;
int shuliang=0;
double pricehe=0;
for(int i=0;i<OrdersTotal();i++)
{
if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
  {
   if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber()==magicnum)
     {
      pricehe=pricehe+OrderOpenPrice();
      shuliang++;
     }
  }
}
if(shuliang>0)
{
a=pricehe/shuliang;
}
return(a);
}
//+------------------------------------------------------------------+

int buydanshu(double &op,double &lots,int magicnum)
{
int a=0;
op=0;
lots=0;
for(int i=0;i<OrdersTotal();i++)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
{
if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
  {
   if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber()==magicnum)
     {
      a++;
      op=OrderOpenPrice();
      lots=OrderLots();
     }
  }
}
return(a);
}
//+------------------------------------------------------------------+

int buy(double lots,double sl,double tp,string com,int buymagic)
{
int a=0;
bool zhaodan=false;
for(int i=0;i<OrdersTotal();i++)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
{
if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
  {
   string zhushi=OrderComment();
   int ma=OrderMagicNumber();
   if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && zhushi==com && ma==buymagic)
     {
      zhaodan=true;
      break;
     }
  }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
if(zhaodan==false)
{
if(sl!=0 && tp==0)
  {
   a=OrderSend(Symbol(),OP_BUY,lots,Ask,50,Ask-sl*Point,0,com,buymagic,0,White);
  }

if(sl==0 && tp!=0)
  {
   a=OrderSend(Symbol(),OP_BUY,lots,Ask,50,0,Ask+tp*Point,com,buymagic,0,White);
  }

if(sl==0 && tp==0)
  {
   a=OrderSend(Symbol(),OP_BUY,lots,Ask,50,0,0,com,buymagic,0,White);
  }

if(sl!=0 && tp!=0)
  {
   a=OrderSend(Symbol(),OP_BUY,lots,Ask,50,Ask-sl*Point,Ask+tp*Point,com,buymagic,0,White);
  }
}
return(a);
}
//+------------------------------------------------------------------+
