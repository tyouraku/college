#include <iostream>
#include <vector>
#include <cmath>
#include <iomanip>
using namespace std;

double UTV(vector<vector<double>>& A, vector<double>& v, int j) {
    int m = A.size();
    double ans = 0;
    for (int i = 0; i < m; i++) {
        ans += A[i][j] * v[i];
    }
    return ans;
}

void Householder(vector<vector<double>>& A, vector<double>& b) {
    int m = A.size();
    int n = A[0].size();
    double vtv = 0, utv = 0;
    vector<double> norm(n, 0.0);
    vector<double> v(m, 0.0);
    for (int i = 0; i < n; i++) {
        for (int j = i; j < m; j++) {
            norm[i] += A[j][i] * A[j][i];
        }
        norm[i] = sqrt(norm[i]);
        vtv = 0;
        utv = 0;
        for (int j = 0; j < m; j++) {
            if (j < i) v[j] = 0;
            else if (i == j) {
                if (A[j][i]>0) v[j] = A[j][i] + norm[i];
                else v[j] = A[j][i] - norm[i];
            }
            else v[j] = A[j][i];
            vtv += v[j] * v[j];
        }
        for (int j = 0; j < m; j++) utv += b[j] * v[j];
        for (int j = 0; j < m; j++) {
            b[j] = b[j] - 2 * utv / vtv * v[j];
        }
        for (int j = i; j < n; j++) {
            utv = UTV(A, v, j);
            for (int k = 0; k < m; k++) {
                A[k][j] = A[k][j] - 2 * utv / vtv * v[k];
            }
        }
    }
}

void solve(vector<vector<double>>& A, vector<double>& b, vector<double>& x, int N) {
    for (int i = N-1; i >= 0; i--) {
        x[i] = 1.00 * b[i] / A[i][i];
        for (int j = i - 1; j >= 0; j--) b[j] -= A[j][i] * x[i];
    }
    for (int i = 0; i < N; i++) cout << fixed << setprecision(6) << x[i] << " ";
}

int main() {
    int M, N;
    double c;
    cin >> M >> N >> c;
    double* xi = new double[M];
    double* yi = new double[M];
    double* xj = new double[N];
    double* yj = new double[N];
    vector<double> b(N, 0.0);
    vector<vector<double>> A(N, vector<double>(M));
    for (int i = 0; i < M; i++) cin >> xi[i] >> yi[i];
    for (int i = 0; i < N; i++) cin >> xj[i] >> yj[i] >> b[i];
    c = c * c;
    for (int i = 0; i < M; i++) {
        for (int j = 0; j < N; j++) {
            A[j][i] = sqrt((xj[j] - xi[i]) * (xj[j] - xi[i]) + (yj[j] - yi[i]) * (yj[j] - yi[i]) + c);
        }
    }
    delete[] xi;
    delete[] yi;
    delete[] xj;
    delete[] yj;
    vector<double> x(M, 0.0);
    Householder(A,b);
    solve(A, b, x, M);
    return 0;
}