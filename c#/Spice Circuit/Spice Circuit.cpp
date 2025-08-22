#include <iostream>
#include <iomanip>
#include <complex>
#include <algorithm>
using namespace std;

#define size 1010
complex<double> A[size][size], x[size];
complex<double> i(0.0, 1.0);
int num_nodes, num_components, target_node, node1, node2;
double freq, freq1, value;
char type;

void swap(int row1, int row2) {
	for (int j = 1; j <= num_nodes; j++) swap(A[row1][j], A[row2][j]);
	swap(A[row1][size-1], A[row2][size-1]);
}

bool zero(int col, int n) {
	for (int i = col; i <= n; i++) {
		if (abs(A[i][col]) > 1e-15) return false;
	}
	A[col][col] = 1;
	return true;
}

bool gauss() {
	for (int col = 1; col <= num_nodes; col++) {
		zero(col, num_nodes);
		if (zero(col, num_nodes)) continue;
		int max = col;
		for (int j = col + 1; j <= num_nodes; j++) {
			if (abs(A[j][col]) > abs(A[max][col])) max = j;
		}
		if (abs(A[max][col]) < 1e-15) continue;
		swap(max, col);
		for (int row = col + 1; row <= num_nodes; row++) {
			complex<double> factor = A[row][col] / A[col][col];
			for (int j = col; j <= num_nodes; j++) A[row][j] -= factor * A[col][j];
			A[row][size-1] -= factor * A[col][size-1];
		}
		for (int j = 1; j <= num_nodes; j++) {
			for (int k = 1; k <= num_nodes; k++) {
				cout << A[j][k] << " ";
			}
			cout << A[j][size-1] << endl;
		}
		cout << endl;
	}
	return true;
}

bool solve() {
	if (!gauss()) return false;
	for (int k = num_nodes; k >= 1; k--) {
		if (abs(A[k][k]) < 1e-15) continue;		
		x[k] = 1.00 * A[k][size - 1] / A[k][k];
		for (int j = k - 1; j >= 1; j--) A[j][size - 1] -= A[j][k] * x[k];
		for (int k = num_nodes; k >= 1; k--) cout << x[k] << " ";
		cout << endl;
	}
	return true;
}

int main() {
	for (int k = 0; k < size; k++) {
		for (int j = 0; j < size; j++) A[k][j] = 0;
		x[k] = 0;
	}
	cin >> num_nodes >> num_components >> freq >> target_node;
	freq1 = 2 * 3.14159 * freq;
	for (int j = 0; j < num_components; j++) {
		cin >> type >> node1 >> node2 >> value;
		if (type == 'R') {
			value = 1.00 / value;
			if (node1 == 0 && node2 == 0)continue;
			else if (node1 == 0) A[node2][node2] += value;
			else if(node2 == 0) A[node1][node1] += value;
			else {
				A[node1][node1] += value;
				A[node2][node2] += value;
				A[node1][node2] -= value;
				A[node2][node1] -= value;
			}
		}
		if (type == 'L') {
			value = 1.00 / (freq1 * value);
			if (node1 == 0 && node2 == 0)continue;
			else if (node1 == 0) A[node2][node2] += value / i;
			else if (node2 == 0) A[node1][node1] += value / i;
			else {
				A[node1][node1] += value / i;
				A[node2][node2] += value / i;
				A[node1][node2] -= value / i;
				A[node2][node1] -= value / i;
			}
		}
		if (type == 'C') {
			value = freq1 * value;
			if (node1 == 0 && node2 == 0)continue;
			else if (node1 == 0) A[node2][node2] += value * i;
			else if (node2 == 0) A[node1][node1] += value * i;
			else {
				A[node1][node1] += value * i;
				A[node2][node2] += value * i;
				A[node1][node2] -= value * i;
				A[node2][node1] -= value * i;
			}
		}
		if (type == 'I') {
			A[node1][size-1] += value;
			A[node2][size-1] -= value;
		}
		if (type == 'V') {
			num_nodes++;
			A[node1][num_nodes] += 1;
			A[node2][num_nodes] += -1;
			A[num_nodes][node1] += 1;
			A[num_nodes][node2] += -1;
			A[num_nodes][size-1] += value;
		}
	}
	for (int j = 1; j <= num_nodes; j++) {
		for (int k = 1; k <= num_nodes; k++) {
			cout << A[j][k] << " ";
		}
		cout << A[j][size-1] << endl;
	}
	cout << endl;
	solve();
	cout << fixed << setprecision(2) << abs(x[target_node]);
	return 0;
}