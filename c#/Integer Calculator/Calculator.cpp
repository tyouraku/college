#include <iostream>
#include <cmath>
using namespace std;
int ques[201], index[201], flag = 0;
int natural(int indexa,int indexb) {
	for (int i = indexb - 1; i >= indexa; i--) {
		if (index[i] == 5) {
			int temp2 = i + 1;
			while (index[temp2] != 0) {
				temp2++;
			}
			for (int j = i - 1; j >= indexa; j--) {
				if (index[j] == -1) continue;
				if (index[j] == 0) {
					if (ques[j] == 0 && ques[temp2] < 0) {
						cout << "Error";
						flag = -1;
						return 0;
					}
					ques[i] = static_cast<int>(pow(ques[j], ques[temp2]));
					index[j] = -1;
					index[i] = 0;
					index[temp2] = -1;
					break;
				}
			}
		}
	}
	for (int i = indexa; i < indexb; i++) {
		if (index[i] == 3) {
			int temp1 = i - 1, temp2 = i + 1;
			while (index[temp1] != 0) temp1--;
			while (index[temp2] != 0) temp2++;
			ques[i] = ques[temp1] * ques[temp2];
			index[i] = 0;
			index[temp1] = -1;
			index[temp2] = -1;
		}
		if (index[i] == 4) {
			int temp1 = i - 1, temp2 = i + 1;
			while (index[temp1] != 0) temp1--;
			while (index[temp2] != 0) temp2++;
			if (ques[temp2] == 0) {
				cout << "Error";
				flag = -1;
				return 0;
			}
			ques[i] = int(ques[temp1] / ques[temp2]);
			index[i] = 0;
			index[temp1] = -1;
			index[temp2] = -1;
		}
	}
	for (int i = indexa; i < indexb; i++) {
		if (index[i] == 1) {
			int temp1 = i-1, temp2 = i+1;
			while (index[temp1] != 0) temp1--;
			while (index[temp2] != 0) temp2++;
			ques[i] = ques[temp1] + ques[temp2];
			index[i] = 0;
			index[temp1] = -1;
			index[temp2] = -1;
		}
		if (index[i] == 2) {
			int temp1 = i - 1, temp2 = i + 1;
			while (index[temp1] != 0 && temp1 >= indexa) temp1--;
			while (index[temp2] != 0) temp2++;
			if (index[temp1] != 0) {
				ques[i] = 0 - ques[temp2];
				index[i] = 0;
				index[temp2] = -1;
			}
			else {
				ques[i] = ques[temp1] - ques[temp2];
				index[i] = 0;
				index[temp1] = -1;
				index[temp2] = -1;
			}
		}
	}
	for (int i = indexa; i < indexb; i++) {
		if (index[i] == 0) return ques[i];
	}
	return ques[indexa];
}
int main() {
	int num = 0, temp = 0, count = 0, flag1 = 0, ans = 0;
	char* s = new char[201];
	cin >> s;
	for (int i = 0; i < 201; i++) {
		ques[i] = 0;
		index[i] = 0;
	}
	for (int i = 0; i < 201; i++) {
		if (s[i] == '(') {
			flag1 = count;
			ques[count] = 0;
			index[count] = 6;
			count++;
		}
		if (s[i] == ')') {
			num++;
			ques[count] = 0;
			index[count] = 7;
			count++;
		}
		if (s[i] >= '0' && s[i] <= '9') {
			if (count == 0 || index[count - 1] != 0) {
				ques[count] = s[i] - '0';
				count++;
			}
			else if (count && index[count - 1] == 0) {
				ques[count - 1] = 10 * ques[count - 1] + (s[i] - '0');
			}
		}
		if (s[i] == '+') {
			ques[count] = 0;
			index[count] = 1;
			count++;
		}
		if (s[i] == '-') {
			if (s[i - 1] == '(') {
				int j = i + 1;
				while (s[j] >= '0' && s[j] <= '9') {
					ques[count] = 10 * ques[count] + (s[j] - '0');
					j++;
				}
				if (s[j] == ')') {
					if (count >= 1) {
						ques[count - 1] = 0 - ques[count];
						index[count - 1] = 0;
					}
					ques[count] = 0;
					i = j;
				}
				else {
					ques[count] = 0;
					index[count] = 2;
					count++;
				}
			}
			else {
				ques[count] = 0;
				index[count] = 2;
				count++;
			}
		}
		if (s[i] == '*') {
			ques[count] = 0;
			index[count] = 3;
			count++;
		}
		if (s[i] == '/') {
			ques[count] = 0;
			index[count] = 4;
			count++;
		}
		if (s[i] == '^') {
			ques[count] = 0;
			index[count] = 5;
			count++;
		}
	}
	for (int i = flag1; i >= 0; i--) {
		if (index[i] == 6) {
			int j = i;
			while (index[j] != 7) j++;
			ques[i] = natural(i + 1, j);
			index[i] = 0;
			for (int k = i + 1; k <= j; k++) index[k] = -1;
			num--;
		}
	}
	if (num == 0) ans = natural(0, count);
	if (flag == -1) return 0;
	cout << ans;
	delete[] s;
	return 0;
}