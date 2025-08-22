#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
using namespace std;

int lcs2(string& s1, string& s2) {
    int n1 = s1.size();
    int n2 = s2.size();
    vector<int> dp1(n2 + 1, 0), dp2(n2 + 1, 0);
    for (int i = 1; i <= n1; i++) {
        for (int j = 1; j <= n2; j++) {
            if (s1[i - 1] == s2[j - 1]) dp2[j] = dp1[j - 1] + 1;
            else dp2[j] = max(dp1[j], dp2[j - 1]);
        }
        dp1.swap(dp2);
    }
    return dp1[n2];
}

int lcs3(string& s1, string& s2, string& s3) {
    int n1 = s1.size(), n2 = s2.size(), n3 = s3.size();
    vector<vector<vector<int>>> dp(n1 + 1, vector<vector<int>>(n2 + 1, vector<int>(n3 + 1, 0)));
    for (int i = 1; i <= n1; i++) {
        for (int j = 1; j <= n2; j++) {
            for (int k = 1; k <= n3; k++) {
                if (s1[i - 1] == s2[j - 1] && s1[i - 1] == s3[k - 1]) dp[i][j][k] = dp[i - 1][j - 1][k - 1] + 1;
                else dp[i][j][k] = max(max(dp[i - 1][j][k], dp[i][j - 1][k]), dp[i][j][k - 1]);
            }
        }
    }
    return dp[n1][n2][n3];
}

int lcs4(string& s1, string& s2, string& s3, string& s4) {
    int n1 = s1.size(), n2 = s2.size(), n3 = s3.size(), n4 = s4.size();
    vector<vector<vector<vector<int>>>> dp(n1 + 1, vector<vector<vector<int>>>(n2 + 1, vector<vector<int>>(n3 + 1, vector<int>(n4 + 1, 0))));
    for (int i = 1; i <= n1; i++) {
        for (int j = 1; j <= n2; j++) {
            for (int k = 1; k <= n3; k++) {
                for (int l = 1; l <= n4; l++) {
                    if (s1[i - 1] == s2[j - 1] && s1[i - 1] == s3[k - 1] && s1[i - 1] == s4[l - 1]) dp[i][j][k][l] = dp[i - 1][j - 1][k - 1][l - 1] + 1;
                    else dp[i][j][k][l] = max(max(max(dp[i - 1][j][k][l], dp[i][j - 1][k][l]), dp[i][j][k - 1][l]), dp[i][j][k][l - 1]);
                }
            }
        }
    }
    return dp[n1][n2][n3][n4];
}

int main() {
    int n,l[4];
    cin >> n;
    for (int i = 0; i < n; i++) cin >> l[i];
    vector<string> s(n);
    for (int i = 0; i < n; i++) cin >> s[i];
    int ans = 0;
    switch (n) {
    case 2:
        ans = lcs2(s[0], s[1]);
        break;
    case 3:
        ans = lcs3(s[0], s[1], s[2]);
        break;
    case 4:
        ans = lcs4(s[0], s[1], s[2], s[3]);
        break;
    default:
        break;
    }
    cout << ans << endl;
    return 0;
}
