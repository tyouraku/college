#include <iostream>
#include <fstream>
#include <string>
#include <vector>
using namespace std;


//创建car类
class car {
protected:
	string number;//string类型车牌号
	string cartype;//string类型车型
	string color;//string类型颜色
	int year;//int类型年份

public:
	friend class operation;
	//声明operation类为友元函数，方便调取对车辆的操作函数

	car(string n, string t, string c, int y) {
		number = n;
		cartype = t;
		color = c;
		year = y;
	}
	//car类的构造函数

	void display() const {
		cout << "车牌：" << number << "，车型：" << cartype << "，颜色：" << color << "，年份：" << year << endl;
	}
	//car类的输出函数
};


//创建operation类
class operation {
private:
	string filename;//进行操作的文件名
	vector<car> Cars;//包含文件中车辆的容器
	void SaveToFile();//文件存储
	void LoadFromFile();//文件读取

public:
	operation(string& fn) {
		filename = fn;
		LoadFromFile();
	}
	//operation类的构造函数

	void addcar(car& c);//添加车辆
	void deletecar(string& n);//删除车辆
	void modifycar(string& n, car& c);//修改车辆信息
	car* searchcar_number(string& n);//通过车牌号查询车辆
	vector<car*> searchcar_cartype(string& t);//通过车型查询车辆
};

//添加车辆的函数
void operation::addcar(car& c) {
	Cars.push_back(c);
	SaveToFile();
}

//删除车辆的函数
void operation::deletecar(string& n) {
	for (auto it = Cars.begin(); it != Cars.end(); ++it) {
		if (it->number == n) {//识别到与输入车牌匹配的车辆信息
			Cars.erase(it);//则删除该车辆信息
			SaveToFile();//文件存储
			return;
		}
	}
}

//修改车辆信息的函数
void operation::modifycar(string& n, car& c) {
	for (auto& car : Cars) {
		if (car.number == n) {//识别到与输入车牌匹配的车辆信息
			car = c;//则用新的车辆信息覆盖原位置处的车辆信息
			SaveToFile();//文件存储
			return;
		}
	}
}

//通过车牌号查询车辆的函数
car* operation::searchcar_number(string& n) {
	for (auto& car : Cars) {
		if (car.number == n) {//识别到与输入车牌匹配的车辆信息
			return &car;//返回car类指针
		}
	}
	return nullptr;
}

//通过车型查询车辆的函数
vector<car*> operation::searchcar_cartype(string& t) {
	vector<car*> matchingCars;
	for (auto& car : Cars) {
		if (car.cartype == t) {//识别到与输入车型匹配的车辆信息
			matchingCars.push_back(&car);
		}
	}
	return matchingCars;//返回包含所有匹配车型的car类的容器指针
}

//文件存储的函数
void operation::SaveToFile() {
	ofstream file(filename);
	if (!file) {//异常处理
		cerr << "open error!" << endl;
		return;
	}
	if (file.is_open()) {
		for (auto& car : Cars) {//用逗号相隔的形式存储所有容器内的车辆数据至文件
			file << car.number << "," << car.cartype << "," << car.color << "," << car.year << endl;
		}
		file.close();
	}
}

//文件读取的函数
void operation::LoadFromFile() {
	Cars.clear();
	ifstream file(filename);//异常处理
	if (!file) {
		cerr << "open error!" << endl;
		abort();
	}

	string line;
	while (getline(file, line)) {
		size_t pos = line.find(",");//找到第1个逗号
		string n = line.substr(0, pos);//把第1个逗号前的内容存入车牌号信息string n中
		line.erase(0, pos + 1);//删除第1个逗号及以前的内容

		pos = line.find(",");//找到新的第1个逗号（原第2个）
		string t = line.substr(0, pos);
		line.erase(0, pos + 1);

		pos = line.find(",");//找到新的第1个逗号（原第3个）
		string c = line.substr(0, pos);
		line.erase(0, pos + 1);

		string y_0 = line;//把最后一个逗号以后的所有内容存入年份信息string y_0中
		int y = stoi(y_0);//从string到int的类型转换

		Cars.push_back(car(n, t, c, y));
	}
	file.close();
}


//创建people类
class people {
protected:
	string name;//账号
	string password;//密码
	int type;//用户类型

public:
	people() {
		name = '0';
		password = '0';
		type = 0;
	}
	//people类的默认构造函数

	virtual void addcar(string fn) = 0;
	virtual void deletecar(string fn) = 0;
	virtual void modifycar(string fn) = 0;
	virtual void searchcar(string fn) = 0;
	//抽象类的虚函数
};


//创建people类的公共派生类user类
class user :public people {
public:
	user() :people() {};
	//user类的默认构造函数

	user(string n, string p, int t) {
		name = n;
		password = p;
		type = 1;
	}
	//user类的构造函数

	friend class operation;
	//声明operation类为友元函数，方便调取对车辆的操作函数
	
	void addcar(string fn) override {
		cout << "无权限！" << endl;
	}
	void deletecar(string fn) override { 
		cout << "无权限！" << endl; 
	}
	void modifycar(string fn) override { 
		cout << "无权限！" << endl;
	}
	void searchcar(string fn) override;
	//user类权限下的函数重载
};

//user类权限下的查询车辆函数
void user::searchcar(string fn) {
	class operation ope = operation(fn);
	string n;

	int option;
	cout << "用车牌查询请输入1,用车型查询请输入2" << endl;
	cout << "请选择查询方式：";
	cin >> option;
	//用户选择查询方式

	if (option == 1) {
		cout << "请输入要查询的车牌号：";
		cin >> n;
		cout << endl;
		class car* ans = ope.searchcar_number(n);
		if (ans != nullptr) {
			cout << "查找完成！输出结果" << endl;
			ans->display();
		}
		//返回值不为空指针则输出指向的车辆信息

		else {
			cout << "无匹配结果！" << endl;
		}
		//返回值为空指针输出默认提示信息
	}
	//用车牌查询

	if (option == 2) {
		cout << "请输入要查询的车型：";
		getline(cin, n);
		cin.ignore();
		cout << endl;
		vector<car*> ans = ope.searchcar_cartype(n);
		if (!ans.empty()) {
			cout << "查找完成！输出结果" << endl;
			for (auto& car : ans) {//遍历容器中的所有car类
				car->display();
			}
		}
		//返回值不为空指针则输出指向的所有车辆信息

		else {
			cout << "无匹配结果！" << endl;
		}
		//返回值为空指针输出默认提示信息
	}
	//用车型查询
}


//创建people类的公共派生类manager类
class manager :public people {
public:
	manager() :people() {};
	//manager类的默认构造函数

	manager(string n, string p, int t) {
		name = n;
		password = p;
		type = -1;
	}
	//manager类的构造函数

	friend class operation;
	//声明operation类为友元函数，方便调取对车辆的操作函数

	void addcar(string fn) override;
	void deletecar(string fn) override;
	void modifycar(string fn) override;
	void searchcar(string fn) override;
	//manager类权限下的函数重载
};

//manager类权限下的添加车辆函数
void manager::addcar(string fn) {
	class operation ope = operation(fn);//创建operation类对象并调用构造函数
	string n, t, c;//string类型的车牌号、车型、颜色
	int y;//int类型的年份

	cout << "请输入需要添加的车辆信息" << endl;
	cin.ignore();//添加此行以忽略换行符
	cout << "车牌号：";
	getline(cin, n);
	cout << "车型：";
	getline(cin, t);
	cout << "颜色：";
	getline(cin, c);
	cout << "年份：";
	cin >> y;
	cout << endl;
	//从控制台输入添加的车辆信息
	
	class car add = car(n, t, c, y);//创建car类对象
	ope.addcar(add);//调用operation类的添加车辆函数
}

//manager类权限下的删除车辆函数
void manager::deletecar(string fn) {
	class operation ope = operation(fn);//创建operation类对象并调用构造函数
	string n;//string类型的车牌

	cout << "请输入要删除车辆的车牌号：";
	cin >> n;
	cout << endl << endl;
	//从控制台输入要删除车辆的车牌信息

	ope.deletecar(n);//调用operation类的删除车辆函数
}

//manager类权限下的修改车辆信息函数
void manager::modifycar(string fn) {
	class operation ope = operation(fn);//创建operation类对象并调用构造函数
	string n_0, n, t, c;//string类型的修改前车牌、修改后车牌、修改后车型、修改后颜色
	int y;//int类型的修改后年份

	cout << "请输入要修改车辆的车牌号：";
	cin >> n_0;
	cout << endl;
	//从控制台输入要修改车辆的车牌

	cout << "请输入该车辆的具体信息" << endl;
	cin.ignore();
	cout << "车牌号：";
	getline(cin, n);
	cout << "车型：";
	getline(cin, t);
	cout << "颜色：";
	getline(cin, c);
	cout << "年份：";
	cin >> y;
	cout << endl;
	//从控制台输入要修改车辆的所有信息

	class car modify = car(n, t, c, y);//创建car类对象
	ope.modifycar(n_0, modify);//调用operation类的修改车辆信息函数
}

//manager类权限下的车辆查询函数
void manager::searchcar(string fn) {
	class operation ope = operation(fn);
	string n;

	int option;
	cout << "用车牌查询请输入1,用车型查询请输入2" << endl;
	cout << "请选择查询方式：";
	cin >> option;
	//用户选择查询方式

	if (option == 1) {
		cout << "请输入要查询的车牌号：";
		cin >> n;
		cout << endl;
		class car* ans = ope.searchcar_number(n);
		if (ans != nullptr) {
			cout << "查找完成！输出结果" << endl;
			ans->display();
		}
		//返回值不为空指针则输出指向的车辆信息

		else {
			cout << "无匹配结果！" << endl;
		}
		//返回值为空指针输出默认提示信息
	}
	//用车牌查询

	if (option == 2) {
		cout << "请输入要查询的车型：";
		cin >> n;
		cout << endl;
		vector<car*> ans = ope.searchcar_cartype(n);
		if (!ans.empty()) {
			cout << "查找完成！输出结果" << endl;
			for (auto& car : ans) {//遍历容器中的所有car类
				car->display();
			}
		}
		//返回值不为空指针则输出指向的所有车辆信息

		else {
			cout << "无匹配结果！" << endl;
		}
		//返回值为空指针输出默认提示信息
	}
	//用车型查询
}


//登录系统前的准备模块
int login() {
	cout << "------------------------------" << endl;
	cout << "  欢迎进入车辆管理综合系统！" << endl;
	cout << "------------------------------" << endl << endl;
	//进入系统的默认界面

	cout << "登录系统请输入1，退出系统请输入0" << endl;
	cout << "请选择操作：";
	string command;
	cin >> command;
	//从控制台输入用户操作命令

	while (command != "0" && command != "1") {
		cout << endl;
		cout << "命令错误！" << endl;
		cout << "请重新输入：";
		cin >> command;
	}
	//不合法输入需重新输入

	if (command == "0") {
		cout << endl;
		cout << "------------------------------" << endl;
		cout << "         已退出系统！" << endl;
		cout << "------------------------------" << endl << endl;
		return 0;
	}
	//用户选择退出系统返回0

	if (command == "1") {
		cout << endl;
		cout << "请输入账号和密码信息" << endl;
		return 1;
	}
	//用户选择登录系统返回1

	return 0;
}


//主函数
int main() {
	int type = 0;//int类型的用户类型type，初始化设为0

	int login();
	int result_login = login();
	//调用login函数

	if (result_login == 0) {
		return 0;
	}
	//用户选择退出系统则直接结束

	if (result_login == 1) {
		string name, password;//string类型的账号、密码
		int count = 0;//int类型的用户输入次数

		while (count <= 5) {
			cout << "账号：";
			cin >> name;
			cout << "密码：";
			cin >> password;
			//从控制台输入账号和密码

			if (name == "user" && password >= "a" && password <= "z") {
				type = 1;
				cout << endl;
				cout << "您已成功登录！身份：普通用户" << endl << endl;
				break;
			}
			if (name == "manager" && password >= "a" && password <= "z") {
				type = -1;
				cout << endl;
				cout << "您已成功登录！身份：管理员" << endl << endl;
				break;
			}
			//账号密码和默认匹配则提示成功登录，并显示用户身份

			count++;//用户输入次数自增

			if ((5 - count) <= 0) {
				cout << "错误次数过多！自动退出系统" << endl;
				cout << endl;
				cout << "------------------------------" << endl;
				cout << "         已退出系统！" << endl;
				cout << "------------------------------" << endl << endl;
				return 0;
			}
			//输入账号密码错误次数过多则自动退出系统

			cout << "账号或密码错误！您还有" << (5 - count) << "次机会" << endl << endl;
			cout << "请重新输入账号和密码信息" << endl;
			//账号密码和默认不匹配则提示重新输入
		}
	}
	//用户选择登录系统

	cout << endl;
	//完成登录处理

	cout << "您已成功登录车辆综合管理系统！请选择后续操作" << endl;
	cout << "继续操作请输入1,退出系统请输入0" << endl << endl;
	cout << "请选择操作：";
	//完成登录后系统的默认提示

	string funcindex_0;
	cin >> funcindex_0;
	//从控制台输入用户操作命令

	while (funcindex_0 != "0" && funcindex_0 != "1") {
		cout << endl;
		cout << "命令错误！" << endl;
		cout << "请重新输入：";
		cin >> funcindex_0;
	}
	//不合法输入需重新输入

	string filename;
	if (funcindex_0 == "1") {
		cout << endl;
		cout << "请输入文件名：" << endl;
		cin >> filename;
	}
	//用户选择继续操作

	while (funcindex_0 == "1") {//判断用户是否选择的是操作
		cout << endl;
		cout << "添加车辆请输入1，删除车辆请输入2，修改车辆信息请输入3，查询车辆请输入4" << endl;
		cout << "请选择操作：";
		//选择继续操作后系统的默认提示

		int funcindex;
		cin >> funcindex;
		//从控制台输入用户操作命令

		while (funcindex != 1 && funcindex != 2 && funcindex != 3 && funcindex != 4) {
			cout << endl;
			cout << "命令错误！" << endl;
			cout << "请重新输入：";
			cin >> funcindex;
		}
		cout << endl;
		//不合法输入需重新输入
		
		if (type == 1) {
			class user Utemp;
			if (funcindex == 1) { Utemp.addcar(filename); }
			if (funcindex == 2) { Utemp.deletecar(filename); }
			if (funcindex == 3) { Utemp.modifycar(filename); }
			if (funcindex == 4) { Utemp.searchcar(filename); }
		}
		if (type == -1) {
			class manager Mtemp;
			if (funcindex == 1) { Mtemp.addcar(filename); }
			if (funcindex == 2) { Mtemp.deletecar(filename); }
			if (funcindex == 3) { Mtemp.modifycar(filename); }
			if (funcindex == 4) { Mtemp.searchcar(filename); }
		}
		//对于用户的不同类型，创建对应类型的对象并调用对应指令的功能函数

		cout << endl;
		cout << "当前操作已完成！请选择后续操作" << endl;
		cout << "退出系统请输入0，继续操作请输入1" << endl;
		cout << "请选择操作：";
		//完成上一次操作后系统的默认提示

		cin >> funcindex_0;
		//从控制台输入用户操作命令

		while (funcindex_0 != "0" && funcindex_0 != "1") {
			cout << endl;
			cout << "命令错误！" << endl;
			cout << "请重新输入：";
			cin >> funcindex_0;
		}
		//不合法输入需重新输入
	}

	if (funcindex_0 == "0") {
		cout << endl;
		cout << "------------------------------" << endl;
		cout << "         已退出系统！" << endl;
		cout << "------------------------------" << endl << endl;
		return 0;
	}
	//用户选择退出系统

	//完成功能处理

	return 0;
}