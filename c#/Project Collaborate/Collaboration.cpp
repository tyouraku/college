#include <iostream>
#include <algorithm>
using namespace std;

struct Edge {
    int v, w, e;
    bool operator < (const Edge& E) {
        return e < E.e;
    }
};

int* father, * r;
void Unionfind(int X) {
    father = new int[X+1];
    r = new int[X+1];
    for (int i = 0; i < X; i++) {
        father[i] = i;
        r[i] = 0;
    }
}
int find(int x) {
    if (x != father[x]) father[x] = find(father[x]);
    return father[x];
}
void unite(int x, int y) {
    int x1 = find(x);
    int y1 = find(y);
    if (x1 != y1) {
        if (r[x1] > r[y1]) father[y1] = x1;
        else if (r[x1] < r[y1]) father[x1] = y1;
        else {
            father[y1] = x1;
            r[x1]++;
        }
    }
}

int Kruskal(int X, int Y, int Z, Edge* E) {
    if (Y < X - Z + 1) return -1;
    Unionfind(X);
    int weigh = 0, cnt = 0;
    sort(E, E+Y);
    for (int i = 0; i < Y; i++) {
        int v = E[i].v;
        int w = E[i].w;
        if (find(v) != find(w)) {
            unite(v, w);
            weigh += E[i].e;
            cnt++;
            if (cnt == X - Z) break;
        }
    }
    if (cnt == X - Z) return weigh;
    else return -1;
}

int main() {
    int X, Y, Z;
    cin >> X >> Y >> Z;
    Edge* E = new Edge[Y+1];
    for (int i = 0; i < Y; i++) cin >> E[i].v >> E[i].w >> E[i].e;
    int ans = Kruskal(X, Y, Z, E);
    if (ans == -1) cout << "false" << endl;
    else cout << ans << endl;
    delete[] E;
    delete[] father;
    delete[] r;
    return 0;
}