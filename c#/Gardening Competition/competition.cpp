#include <stdio.h>
#include <algorithm>
using namespace std;
int main() {
	int k, n;
	scanf_s("%d %d", &k, &n);
	int* N= new int[n * n];
	for (int i = 0; i < n * n; i++) scanf_s("%d", &N[i]);
	sort(N, N + n * n);
	printf("%d", N[k - 1]);
	return 0;
}