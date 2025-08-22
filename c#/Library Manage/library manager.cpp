#include<iostream>
#include<stack>
using namespace std;
bool book[1100001], ans[1100001];

int main() {
    char c;
    int temp = 0, sum = 0, multiplier = 1, count = 0, n, ope, key;
    for (int i = 0; i < 1100001; i++) {
        book[i] = 0;
        ans[i] = 0;
    }
    stack<int> s;
    while ((c = getchar()) != '\n') {
        if (c >= '0' && c <= '9') {
            s.push(c - '0');
        }
        if (c == ' ') {
            while (!s.empty()) {
                temp = s.top();
                sum += temp * multiplier;
                multiplier *= 10;
                s.pop();
            }
            book[sum] = true;
            count++;
            sum = 0;
            multiplier = 1;
        }
    }
    while (!s.empty()) {
        temp = s.top();
        sum += temp * multiplier;
        multiplier *= 10;
        s.pop();
    }
    if (sum != 0) {
        book[sum] = true;
        count++;
    }

    cin >> n;
    temp = 0;
    for (int i = 0; i < n; i++) {
        cin >> ope >> key;
        if (ope == 1) {
            if (book[key] == 1) {
                ans[i] = 1;
            }
        }
        if (ope == 2) {
            if (book[key] == 1) {
                ans[i] = 1;
                book[key] = 0;
            }
        }
        if (ope == 3) {
            if (book[key] == 0) {
                ans[i] = 1;
                book[key] = 1;
            }
        }
    }
    for (int i = 0; i < n; i++) cout << ans[i];
    return 0;
}