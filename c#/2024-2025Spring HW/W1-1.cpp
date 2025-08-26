#include <iostream>
using namespace std;
enum CPU_rank{P1=1,P2,P3,P4,P5,P6,P7};
class CPU
{private:
	CPU_rank rank;
	int Rank;
	int frequency;
	double voltage;
public:
	void enter();
	void display();
};
void CPU::enter(){
	cin>>Rank;
	cin>>frequency;
	cin>>voltage;
}
void CPU::display(){
	cout<<"P"<<Rank<<endl<<frequency<<endl<<voltage<<endl;
}
int main(){
	CPU CPU_1;
	CPU_1.enter();
	CPU_1.display();
	return 0;
}