#include <stdio.h>
#include <stdlib.h>

double ans = 0;
unsigned short int n;
unsigned short int* preorder;
unsigned short int* inorder;
unsigned long long int* weigh;

typedef struct TreeNode {
    unsigned short int value, child;
    unsigned long long int weigh;
    struct TreeNode* left;
    struct TreeNode* right;
} TreeNode;

typedef struct {
    TreeNode** items;
    int top;
    int capacity;
} Stack;

Stack* createStack(int capacity) {
    Stack* stack = (Stack*)malloc(sizeof(Stack));
    stack->capacity = capacity;
    stack->top = -1;
    stack->items = (TreeNode**)malloc(stack->capacity * sizeof(TreeNode*));
    return stack;
}

int isEmpty(Stack* stack) {
    return stack->top == -1;
}

void push(Stack* stack, TreeNode* node) {
    if (stack->top < stack->capacity - 1) stack->items[++stack->top] = node;
}

TreeNode* pop(Stack* stack) {
    if (!isEmpty(stack)) return stack->items[stack->top--];
    return NULL;
}

void freeStack(Stack* stack) {
    free(stack->items);
    free(stack);
}

TreeNode* buildTree() {
    if (!n) return NULL;
    TreeNode* root = (TreeNode*)malloc(sizeof(TreeNode));
    root->value = preorder[0];
    root->weigh = weigh[0];
    root->left = NULL;
    root->right = NULL;
    root->child = 1;
    Stack* s = createStack(n);
    push(s, root);
    unsigned short int Index = 0;
    for (unsigned short int i = 1; i < n; ++i) {
        int value = preorder[i];
        TreeNode* node = s->items[s->top];
        if (node->value != inorder[Index]) {
            node->left = (TreeNode*)malloc(sizeof(TreeNode));
            node->left->value = value;
            node->left->weigh = weigh[i];
            node->left->left = NULL;
            node->left->right = NULL;
            node->left->child = 1;
            push(s, node->left);
        }
        else {
            while (!isEmpty(s) && s->items[s->top]->value == inorder[Index]) {
                node = s->items[s->top];
                pop(s);
                ++Index;
            }
            node->right = (TreeNode*)malloc(sizeof(TreeNode));
            node->right->value = value;
            node->right->weigh = weigh[i];
            node->right->left = NULL;
            node->right->right = NULL;
            node->right->child = 1;
            push(s, node->right);
        }
    }
    freeStack(s);
    return root;
}

void freeTree(TreeNode* root) {
    if (root == NULL) return;
    freeTree(root->left);
    freeTree(root->right);
    free(root);
}

void update(TreeNode* node) {
    if (node == NULL) return;
    if (node->left != NULL) {
        node->weigh += node->left->weigh;
        node->child += node->left->child;
    }
    if (node->right != NULL) {
        node->weigh += node->right->weigh;
        node->child += node->right->child;
    }
    if ((1.00 * (n - node->child) / n * node->weigh) > ans) ans = (1.00 * (n - node->child) / n * node->weigh);
    return;
}

void postUpdate(TreeNode* node) {
    if (node == NULL) return;
    postUpdate(node->left);
    postUpdate(node->right);
    update(node);
}

int main() {
    scanf_s("%hu", &n);
    preorder = (unsigned short*)malloc(n * sizeof(unsigned short));
    inorder = (unsigned short*)malloc(n * sizeof(unsigned short));
    weigh = (unsigned long long*)malloc(n * sizeof(unsigned long long));
    for (unsigned short i = 0; i < n; i++) scanf_s("%hu", &preorder[i]);
    for (unsigned short i = 0; i < n; i++) scanf_s("%llu", &weigh[i]);
    for (unsigned short i = 0; i < n; i++) scanf_s("%hu", &inorder[i]);
    TreeNode* root = buildTree();
    free(preorder);
    free(inorder);
    free(weigh);
    postUpdate(root);
    printf("%.2lf", ans);
    freeTree(root);
    return 0;
}