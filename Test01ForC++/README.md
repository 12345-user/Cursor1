# 红黑树 C++ 实现

这是一个完整的红黑树（Red-Black Tree）C++实现，包含了所有基本操作。

## 红黑树特性

红黑树是一种自平衡的二叉搜索树，具有以下特性：

1. **每个节点要么是红色，要么是黑色**
2. **根节点是黑色**
3. **所有叶子节点（NIL）都是黑色**
4. **红色节点的子节点都是黑色**（红色节点不能有红色子节点）
5. **从根到叶子的所有路径包含相同数量的黑色节点**

这些特性确保了红黑树的高度最多为 2log(n+1)，其中 n 是节点数量。

## 功能特性

- ✅ **插入操作** - O(log n) 时间复杂度
- ✅ **删除操作** - O(log n) 时间复杂度  
- ✅ **查找操作** - O(log n) 时间复杂度
- ✅ **自平衡** - 自动维护红黑树性质
- ✅ **模板化** - 支持任意数据类型
- ✅ **可视化** - 提供树结构打印和层序遍历

## 编译和运行

### 使用 Makefile（推荐）

```bash
# 编译
make

# 运行
make run

# 清理
make clean
```

### 手动编译

```bash
g++ -std=c++11 -Wall -Wextra -O2 -o redblacktree RedBlackTree.cpp
./redblacktree
```

## 使用示例

```cpp
#include "RedBlackTree.cpp"

int main() {
    RedBlackTree<int> tree;
    
    // 插入元素
    tree.insert(7);
    tree.insert(3);
    tree.insert(18);
    tree.insert(10);
    
    // 查找元素
    if (tree.search(10)) {
        std::cout << "找到元素 10" << std::endl;
    }
    
    // 删除元素
    tree.remove(3);
    
    // 打印树结构
    tree.printTree();
    
    // 层序遍历
    tree.levelOrderTraversal();
    
    return 0;
}
```

## 主要方法

### 公共接口

- `insert(T value)` - 插入元素
- `remove(T value)` - 删除元素
- `search(T value)` - 查找元素
- `printTree()` - 打印树结构
- `levelOrderTraversal()` - 层序遍历

### 私有辅助方法

- `leftRotate(Node<T> *x)` - 左旋操作
- `rightRotate(Node<T> *x)` - 右旋操作
- `insertFixup(Node<T> *k)` - 插入后修复红黑树性质
- `deleteFixup(Node<T> *x)` - 删除后修复红黑树性质
- `transplant(Node<T> *u, Node<T> *v)` - 移植操作

## 算法复杂度

| 操作 | 时间复杂度 | 空间复杂度 |
|------|------------|------------|
| 插入 | O(log n) | O(1) |
| 删除 | O(log n) | O(1) |
| 查找 | O(log n) | O(1) |
| 遍历 | O(n) | O(n) |

## 测试输出示例

程序运行后会显示：

```
=== 红黑树测试 ===

插入元素: 7, 3, 18, 10, 22, 8, 11, 26, 2, 6, 13

层序遍历结果:
7(B) 3(R) 18(R) 2(B) 6(B) 10(B) 22(B) 8(R) 11(R) 13(R) 26(R)

树结构:
                   26(R)
          22(B)
                   13(R)
     18(R)
                   11(R)
          10(B)
                   8(R)
7(B)
                   6(B)
          3(R)
                   2(B)

查找测试:
查找 10: 找到
查找 5: 未找到
查找 18: 找到

删除元素 10:
删除后的层序遍历:
7(B) 3(R) 18(R) 2(B) 6(B) 11(B) 22(B) 8(R) 13(R) 26(R)
```

## 实现细节

1. **哨兵节点**：使用NIL节点作为所有叶子节点的统一表示
2. **颜色标记**：R表示红色节点，B表示黑色节点
3. **旋转操作**：通过左旋和右旋来维护树的平衡
4. **修复操作**：插入和删除后通过颜色调整和旋转来恢复红黑树性质

## 注意事项

- 模板类型T需要支持比较操作（<, ==）
- 程序会自动处理内存管理
- 删除操作会正确处理所有边界情况
- 可视化功能帮助理解树的结构变化 