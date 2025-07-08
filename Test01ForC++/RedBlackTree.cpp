#include <iostream>
#include <queue>
#include <iomanip>
#include <windows.h>
#include <fstream>

// 红黑树节点颜色枚举
enum Color { RED, BLACK };

// 红黑树节点结构
template<typename T>
struct Node {
    T data;
    Color color;
    Node<T> *left, *right, *parent;
    
    Node(T value) : data(value), color(RED), left(nullptr), right(nullptr), parent(nullptr) {}
};

// 红黑树类
template<typename T>
class RedBlackTree {
private:
    Node<T> *root;
    Node<T> *NIL; // 哨兵节点
    
    // 私有辅助函数
    void leftRotate(Node<T> *x);
    void rightRotate(Node<T> *x);
    void insertFixup(Node<T> *k);
    void deleteFixup(Node<T> *x);
    void transplant(Node<T> *u, Node<T> *v);
    Node<T>* minimum(Node<T> *node);
    void destroyTree(Node<T> *node);
    void printTreeHelper(Node<T> *root, int space) const;
    void printTreeHelper(Node<T> *root, int space, std::ofstream& outFile) const;
    
public:
    RedBlackTree();
    ~RedBlackTree();
    
    // 基本操作
    void insert(T value);
    void remove(T value);
    bool search(T value) const;
    void printTree() const;
    void printTree(std::ofstream& outFile) const;
    void levelOrderTraversal() const;
    void levelOrderTraversal(std::ofstream& outFile) const;
    
    // 获取根节点（用于测试）
    Node<T>* getRoot() const { return root; }
};

// 构造函数
template<typename T>
RedBlackTree<T>::RedBlackTree() {
    NIL = new Node<T>(T());
    NIL->color = BLACK;
    root = NIL;
}

// 析构函数
template<typename T>
RedBlackTree<T>::~RedBlackTree() {
    destroyTree(root);
    delete NIL;
}

// 销毁树
template<typename T>
void RedBlackTree<T>::destroyTree(Node<T> *node) {
    if (node != NIL) {
        destroyTree(node->left);
        destroyTree(node->right);
        delete node;
    }
}

// 左旋操作
template<typename T>
void RedBlackTree<T>::leftRotate(Node<T> *x) {
    Node<T> *y = x->right;
    x->right = y->left;
    
    if (y->left != NIL) {
        y->left->parent = x;
    }
    
    y->parent = x->parent;
    
    if (x->parent == nullptr) {
        root = y;
    } else if (x == x->parent->left) {
        x->parent->left = y;
    } else {
        x->parent->right = y;
    }
    
    y->left = x;
    x->parent = y;
}

// 右旋操作
template<typename T>
void RedBlackTree<T>::rightRotate(Node<T> *x) {
    Node<T> *y = x->left;
    x->left = y->right;
    
    if (y->right != NIL) {
        y->right->parent = x;
    }
    
    y->parent = x->parent;
    
    if (x->parent == nullptr) {
        root = y;
    } else if (x == x->parent->right) {
        x->parent->right = y;
    } else {
        x->parent->left = y;
    }
    
    y->right = x;
    x->parent = y;
}

// 插入操作
template<typename T>
void RedBlackTree<T>::insert(T value) {
    Node<T> *node = new Node<T>(value);
    node->left = NIL;
    node->right = NIL;
    
    Node<T> *y = nullptr;
    Node<T> *x = root;
    
    // 找到插入位置
    while (x != NIL) {
        y = x;
        if (node->data < x->data) {
            x = x->left;
        } else {
            x = x->right;
        }
    }
    
    node->parent = y;
    if (y == nullptr) {
        root = node;
    } else if (node->data < y->data) {
        y->left = node;
    } else {
        y->right = node;
    }
    
    // 修复红黑树性质
    insertFixup(node);
}

// 插入后修复红黑树性质
template<typename T>
void RedBlackTree<T>::insertFixup(Node<T> *k) {
    Node<T> *u;
    while (k->parent != nullptr && k->parent->color == RED) {
        if (k->parent == k->parent->parent->right) {
            u = k->parent->parent->left;
            if (u->color == RED) {
                u->color = BLACK;
                k->parent->color = BLACK;
                k->parent->parent->color = RED;
                k = k->parent->parent;
            } else {
                if (k == k->parent->left) {
                    k = k->parent;
                    rightRotate(k);
                }
                k->parent->color = BLACK;
                k->parent->parent->color = RED;
                leftRotate(k->parent->parent);
            }
        } else {
            u = k->parent->parent->right;
            if (u->color == RED) {
                u->color = BLACK;
                k->parent->color = BLACK;
                k->parent->parent->color = RED;
                k = k->parent->parent;
            } else {
                if (k == k->parent->right) {
                    k = k->parent;
                    leftRotate(k);
                }
                k->parent->color = BLACK;
                k->parent->parent->color = RED;
                rightRotate(k->parent->parent);
            }
        }
        if (k == root) {
            break;
        }
    }
    root->color = BLACK;
}

// 查找最小值
template<typename T>
Node<T>* RedBlackTree<T>::minimum(Node<T> *node) {
    while (node->left != NIL) {
        node = node->left;
    }
    return node;
}

// 移植操作
template<typename T>
void RedBlackTree<T>::transplant(Node<T> *u, Node<T> *v) {
    if (u->parent == nullptr) {
        root = v;
    } else if (u == u->parent->left) {
        u->parent->left = v;
    } else {
        u->parent->right = v;
    }
    v->parent = u->parent;
}

// 删除操作
template<typename T>
void RedBlackTree<T>::remove(T value) {
    Node<T> *z = root;
    
    // 查找要删除的节点
    while (z != NIL) {
        if (value == z->data) {
            break;
        } else if (value < z->data) {
            z = z->left;
        } else {
            z = z->right;
        }
    }
    
    if (z == NIL) {
        std::cout << "值 " << value << " 不在树中" << std::endl;
        return;
    }
    
    Node<T> *y = z;
    Color y_original_color = y->color;
    Node<T> *x;
    
    if (z->left == NIL) {
        x = z->right;
        transplant(z, z->right);
    } else if (z->right == NIL) {
        x = z->left;
        transplant(z, z->left);
    } else {
        y = minimum(z->right);
        y_original_color = y->color;
        x = y->right;
        
        if (y->parent == z) {
            x->parent = y;
        } else {
            transplant(y, y->right);
            y->right = z->right;
            y->right->parent = y;
        }
        
        transplant(z, y);
        y->left = z->left;
        y->left->parent = y;
        y->color = z->color;
    }
    
    delete z;
    
    if (y_original_color == BLACK) {
        deleteFixup(x);
    }
}

// 删除后修复红黑树性质
template<typename T>
void RedBlackTree<T>::deleteFixup(Node<T> *x) {
    Node<T> *w;
    while (x != root && x->color == BLACK) {
        if (x == x->parent->left) {
            w = x->parent->right;
            if (w->color == RED) {
                w->color = BLACK;
                x->parent->color = RED;
                leftRotate(x->parent);
                w = x->parent->right;
            }
            if (w->left->color == BLACK && w->right->color == BLACK) {
                w->color = RED;
                x = x->parent;
            } else {
                if (w->right->color == BLACK) {
                    w->left->color = BLACK;
                    w->color = RED;
                    rightRotate(w);
                    w = x->parent->right;
                }
                w->color = x->parent->color;
                x->parent->color = BLACK;
                w->right->color = BLACK;
                leftRotate(x->parent);
                x = root;
            }
        } else {
            w = x->parent->left;
            if (w->color == RED) {
                w->color = BLACK;
                x->parent->color = RED;
                rightRotate(x->parent);
                w = x->parent->left;
            }
            if (w->right->color == BLACK && w->left->color == BLACK) {
                w->color = RED;
                x = x->parent;
            } else {
                if (w->left->color == BLACK) {
                    w->right->color = BLACK;
                    w->color = RED;
                    leftRotate(w);
                    w = x->parent->left;
                }
                w->color = x->parent->color;
                x->parent->color = BLACK;
                w->left->color = BLACK;
                rightRotate(x->parent);
                x = root;
            }
        }
    }
    x->color = BLACK;
}

// 查找操作
template<typename T>
bool RedBlackTree<T>::search(T value) const {
    Node<T> *current = root;
    while (current != NIL) {
        if (value == current->data) {
            return true;
        } else if (value < current->data) {
            current = current->left;
        } else {
            current = current->right;
        }
    }
    return false;
}

// 打印树结构
template<typename T>
void RedBlackTree<T>::printTree() const {
    if (root == NIL) {
        std::cout << "树为空" << std::endl;
        return;
    }
    printTreeHelper(root, 0);
}

// 打印树结构到文件
template<typename T>
void RedBlackTree<T>::printTree(std::ofstream& outFile) const {
    if (root == NIL) {
        outFile << "树为空" << std::endl;
        return;
    }
    printTreeHelper(root, 0, outFile);
}

// 辅助打印函数
template<typename T>
void RedBlackTree<T>::printTreeHelper(Node<T> *root, int space) const {
    if (root == NIL) {
        return;
    }
    
    space += 10;
    
    printTreeHelper(root->right, space);
    
    std::cout << std::endl;
    for (int i = 10; i < space; i++) {
        std::cout << " ";
    }
    std::cout << root->data << "(" << (root->color == RED ? "R" : "B") << ")";
    
    printTreeHelper(root->left, space);
}

// 辅助打印函数到文件
template<typename T>
void RedBlackTree<T>::printTreeHelper(Node<T> *root, int space, std::ofstream& outFile) const {
    if (root == NIL) {
        return;
    }
    
    space += 10;
    
    printTreeHelper(root->right, space, outFile);
    
    outFile << std::endl;
    for (int i = 10; i < space; i++) {
        outFile << " ";
    }
    outFile << root->data << "(" << (root->color == RED ? "R" : "B") << ")";
    
    printTreeHelper(root->left, space, outFile);
}

// 层序遍历
template<typename T>
void RedBlackTree<T>::levelOrderTraversal() const {
    if (root == NIL) {
        std::cout << "树为空" << std::endl;
        return;
    }
    
    std::queue<Node<T>*> q;
    q.push(root);
    
    while (!q.empty()) {
        Node<T> *current = q.front();
        q.pop();
        
        std::cout << current->data << "(" << (current->color == RED ? "R" : "B") << ") ";
        
        if (current->left != NIL) {
            q.push(current->left);
        }
        if (current->right != NIL) {
            q.push(current->right);
        }
    }
    std::cout << std::endl;
}

// 层序遍历到文件
template<typename T>
void RedBlackTree<T>::levelOrderTraversal(std::ofstream& outFile) const {
    if (root == NIL) {
        outFile << "树为空" << std::endl;
        return;
    }
    
    std::queue<Node<T>*> q;
    q.push(root);
    
    while (!q.empty()) {
        Node<T> *current = q.front();
        q.pop();
        
        outFile << current->data << "(" << (current->color == RED ? "R" : "B") << ") ";
        
        if (current->left != NIL) {
            q.push(current->left);
        }
        if (current->right != NIL) {
            q.push(current->right);
        }
    }
    outFile << std::endl;
}

// 测试函数
int main() {
    // 设置控制台编码为UTF-8
    SetConsoleOutputCP(CP_UTF8);
    
    // 创建输出文件
    std::ofstream outFile("RedBlackTreeResult.txt");
    if (!outFile.is_open()) {
        std::cout << "无法创建输出文件！" << std::endl;
        return 1;
    }
    
    RedBlackTree<int> tree;
    
    std::cout << "=== 红黑树测试 ===" << std::endl;
    outFile << "=== 红黑树测试 ===" << std::endl;
    
    // 插入测试
    std::cout << "\n插入元素: 7, 3, 18, 10, 22, 8, 11, 26, 2, 6, 13" << std::endl;
    outFile << "\n插入元素: 7, 3, 18, 10, 22, 8, 11, 26, 2, 6, 13" << std::endl;
    tree.insert(7);
    tree.insert(3);
    tree.insert(18);
    tree.insert(10);
    tree.insert(22);
    tree.insert(8);
    tree.insert(11);
    tree.insert(26);
    tree.insert(2);
    tree.insert(6);
    tree.insert(13);
    
    std::cout << "\n层序遍历结果:" << std::endl;
    outFile << "\n层序遍历结果:" << std::endl;
    tree.levelOrderTraversal();
    tree.levelOrderTraversal(outFile);
    
    std::cout << "\n树结构:" << std::endl;
    outFile << "\n树结构:" << std::endl;
    tree.printTree();
    tree.printTree(outFile);
    
    // 查找测试
    std::cout << "\n查找测试:" << std::endl;
    outFile << "\n查找测试:" << std::endl;
    std::cout << "查找 10: " << (tree.search(10) ? "找到" : "未找到") << std::endl;
    outFile << "查找 10: " << (tree.search(10) ? "找到" : "未找到") << std::endl;
    std::cout << "查找 5: " << (tree.search(5) ? "找到" : "未找到") << std::endl;
    outFile << "查找 5: " << (tree.search(5) ? "找到" : "未找到") << std::endl;
    std::cout << "查找 18: " << (tree.search(18) ? "找到" : "未找到") << std::endl;
    outFile << "查找 18: " << (tree.search(18) ? "找到" : "未找到") << std::endl;
    
    // 删除测试
    std::cout << "\n删除元素 10:" << std::endl;
    outFile << "\n删除元素 10:" << std::endl;
    tree.remove(10);
    
    std::cout << "\n删除后的层序遍历:" << std::endl;
    outFile << "\n删除后的层序遍历:" << std::endl;
    tree.levelOrderTraversal();
    tree.levelOrderTraversal(outFile);
    
    std::cout << "\n删除后的树结构:" << std::endl;
    outFile << "\n删除后的树结构:" << std::endl;
    tree.printTree();
    tree.printTree(outFile);
    
    std::cout << "\n删除元素 3:" << std::endl;
    outFile << "\n删除元素 3:" << std::endl;
    tree.remove(3);
    
    std::cout << "\n删除后的层序遍历:" << std::endl;
    outFile << "\n删除后的层序遍历:" << std::endl;
    tree.levelOrderTraversal();
    tree.levelOrderTraversal(outFile);
    
    std::cout << "\n删除后的树结构:" << std::endl;
    outFile << "\n删除后的树结构:" << std::endl;
    tree.printTree();
    tree.printTree(outFile);
    
    // 关闭文件
    outFile.close();
    std::cout << "\n结果已保存到 RedBlackTreeResult.txt 文件中" << std::endl;
    
    return 0;
} 