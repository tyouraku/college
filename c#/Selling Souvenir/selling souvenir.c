#include <stdio.h>
int main() {
	int n, ans=1, change[2],get,expect,sum=0;
	for (int i = 0; i < 2; i++) {
		change[i] = 0;
	}
	scanf_s("%d", &n);
	for (int i = 0; i < n; i++) {
		scanf_s("%d", &get);
		if (get == 5) change[0] += 1;
		if (get == 10) change[1] += 1;
		sum += 5;
		expect = get - 5;
		if (expect == 0) continue;
		if (expect == 5) {
			if (change[0] == 0) {
				ans = 0;
				sum -= 5;
				break;
			}
			change[0] -= 1;
		}
		if (expect == 10) {
			if (change[1] >= 1) {
				change[1] -= 1;
				continue;
			}
			if (change[0] >= 2) {
				change[0] -= 2;
				continue;
			}
			else {
				ans = 0;
				sum -= 5;
				break;
			}
		}
		if (expect == 15) {
			if (change[1] >= 1 && change[0] >= 1) {
				change[1] -= 1;
				change[0] -= 1;
				continue;
			}
			if (change[0] >= 3) {
				change[0] -= 3;
				continue;
			}
			else {
				ans = 0;
				sum -= 5;
				break;
			}
		}
	}
	printf("%d %d", ans, sum);
	return 0;
}