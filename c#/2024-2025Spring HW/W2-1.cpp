#include <iostream>
using namespace std;
class Student{
public:
	Student(int num,double sco):number(num),score(sco){};
	void show();
private:
	int number;
	double score;
};

void Student::show(){
	cout<<"student number: "<<number<<endl;
	cout<<"score: "<<score<<endl<<endl;
}

int main(){
	Student stu[5]={
		Student(1,98.5),Student(2,97.5),Student(3,94.5),Student(4,100),Student(5,96)
	};
	stu[0].show();
	stu[2].show();
	stu[4].show();
	return 0;
}