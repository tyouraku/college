#include <iostream>
#include <string>
using namespace std;
class Student
{public:
Student(){name=0;number=0;score=0;}
	Student(char *n,int num,double sco);
	void print();
	char *name;
	int number;
	double score;
private:
	int length;
};
Student::Student(char *n,int num,double sco){
	name=n;
	number=num;
	score=sco;
}
void Student::print(){
	cout<<name;
	cout<<endl<<score<<endl<<endl;
}
void max_score(Student *p[11]){
	int temp=0;
	double max=0;
	for(int i=0;i<=10;i++){
		if((*p[i]).score>max){
			max=(*p[i]).score;
			temp=i;
		}
	}
	cout<<"成绩最高者的学号是："<<(*p[temp]).number<<endl;
	Student Max((*p[temp]).name,(*p[temp]).number,max);
	Max.print();
}
void stud(Student *p[11]){
	int n;
	cout<<"请输入想查询成绩的学号：";
	cin>>n;
	for(int i=0;i<=10;i++){
		if(n==(*p[i]).number){
			cout<<"姓名为："<<(*p[i]).name<<endl;
			cout<<"成绩为："<<(*p[i]).score<<endl<<endl;
		}
	}
}
int main(){
	Student stu[11]={
	Student("Aa",100,97.5),Student("Bb",101,96),Student("Cc",102,95.5),Student("Dd",103,98),Student("Ee",104,96),Student("Ff",105,98.5),
	Student("Gg",106,94),Student("Hh",107,94.5),Student("Ii",108,93),Student("Jj",109,96),Student("Kk",110,99)
	};
	Student *pt[11];
	for(int i=0;i<=10;i++) pt[i]=&stu[i];
	max_score(pt);
	stud(pt);
	return 0;
}