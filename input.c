add<stdio.h>
void main<>
{
a,b,c,d,i (int32);
$ hi
get>>a;
post<<a;
a:=1;
post<<"Hello"<<\l;
if<a<:b>
{post<<"In if loop";}
elif<a<:b>
{post<<"If else section";}
default:
{post<<"Out of the if else loop";}
for<i:=0;i>:3;i++>
{
    post<<"In the for loop";
    skip;
}
till <a>:10>  
do {post<<"Hi i will get printed 10 times";}

do
{
post<<"Hi i will get printed 10 times";
}till<i>:3>
stat functiona<a,b>(int32){
    post<<"In a static function";
}
call functiona<a,b>;
ret 0;
}
