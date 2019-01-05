pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function ellipse(
 cx,cy,xr,yr,c,hlinefunc
)
 xr=flr(xr)
 yr=flr(yr)
 hlinefunc=hlinefunc or rectfill
 local xrsq=shr(xr*xr,16)
 local yrsq=shr(yr*yr,16)
 local a=2*xrsq
 local b=2*yrsq
 local x=xr
 local y=0
 local xc=yrsq*(1-2*xr)
 local yc=xrsq
 local err=0
 local ex=b*xr
 local ey=0
 while ex>=ey do
  local dy=cy-y
  hlinefunc(cx-x,cy-y,cx+x,dy,c)
  dy+=y*2
  hlinefunc(cx-x,dy,cx+x,dy,c)
  y+=1
  ey+=a
  err+=yc
  yc+=a
  if 2*err+xc>0 then
   x-=1
   ex-=b
   err+=xc
   xc+=b
  end
 end

 x=0
 y=yr
 xc=yrsq
 yc=xrsq*(1-2*yr)
 err=0
 ex=0
 ey=a*yr
 while ex<=ey do
  local dy=cy-y
  hlinefunc(cx-x,cy-y,cx+x,dy,c)
  dy+=y*2
  hlinefunc(cx-x,dy,cx+x,dy,c)
  x+=1
  ex+=b
  err+=xc
  xc+=b
  if 2*err+yc>0 then
   y-=1
   ey-=a
   err+=yc
   yc+=a
  end
 end
end
