#include <iostream>
using namespace std;
class sales
{private:
	int num;
	double price;
public:
	sales(int n,int c,double p,double s):num(n),count(c),price(p),sum(s){};
	void sumup();
	int count;
	double sum;
};
void sales::sumup(){
	if(count>10) sum=0.98*count*price;
	else sum=count*price;
}

int main(){
	sales s[3]={sales(101,5,23.5,1.0),sales(102,12.24,5,1.0),sales(103,100,21.5,1.0)};
	s[0].sumup();
	s[1].sumup();
	s[2].sumup();
	double total=s[0].sum+s[1].sum+s[2].sum;
	double ave=total/(s[0].count+s[1].count+s[2].count);
	cout<<total<<endl;
	cout<<ave<<endl<<endl;
	return 0;
}