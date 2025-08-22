#include <stdio.h>
#include <stdlib.h>

typedef struct TreeNode {
    unsigned short int value;
    unsigned long long int weight;
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
    if (stack->top < stack->capacity - 1) {
        stack->items[++stack->top] = node;
    }
}

TreeNode* pop(Stack* stack) {
    if (!isEmpty(stack)) {
        return stack->items[stack->top--];
    }
    return NULL;
}

void freeStack(Stack* stack) {
    free(stack->items);
    free(stack);
}

TreeNode* buildTree(unsigned short int* preorder, unsigned short int* inorder, unsigned short int size, unsigned long long int* weigh) {
    if (!size) return NULL;
    TreeNode* root = (TreeNode*)malloc(sizeof(TreeNode));
    root->value = preorder[0];
    root->weight = weigh[0];
    root->left = NULL;
    root->right = NULL;
    Stack* s = createStack(size);
    push(s, root);
    int inorderIndex = 0;
    for (int i = 1; i < size; ++i) {
        int preorderVal = preorder[i];
        TreeNode* node = s->items[s->top];
        if (node->value != inorder[inorderIndex]) {
            node->left = (TreeNode*)malloc(sizeof(TreeNode));
            node->left->value = preorderVal;
            node->left->weight = weigh[i];
            node->left->left = NULL;
            node->left->right = NULL;
            push(s, node->left);
        }
        else {
            while (!isEmpty(s) && s->items[s->top]->value == inorder[inorderIndex]) {
                node = s->items[s->top];
                pop(s);
                ++inorderIndex;
            }
            node->right = (TreeNode*)malloc(sizeof(TreeNode));
            node->right->value = preorderVal;
            node->right->weight = weigh[i];
            node->right->left = NULL;
            node->right->right = NULL;
            push(s, node->right);
        }
    }
    freeStack(s);
    return root;
}

void printInorder(TreeNode* root) {
    if (root == NULL) {
        return;
    }
    printInorder(root->left);
    printf("%d ", root->value);
    printInorder(root->right);
}

void freeTree(TreeNode* root) {
    if (root == NULL) {
        return;
    }
    freeTree(root->left);
    freeTree(root->right);
    free(root);
}

int main() {
    unsigned short int preorder[] = { 0, 1, 3, 6, 7, 4, 8, 2, 5, 9 };
    unsigned short int inorder[] = { 6, 3, 7, 1, 4, 8, 0, 2, 5, 9 };
    unsigned short int n = 10;
    unsigned long long int weigh[] = { 9, 8, 5, 3, 4, 3, 2, 4, 7, 5 };
    int inorderIndex = 0;

    TreeNode* root = buildTree(preorder, inorder, n, weigh, &inorderIndex);

    printf("Inorder traversal of the constructed tree is:\n");
    printInorder(root);
    printf("\n");

    freeTree(root);
    return 0;
}