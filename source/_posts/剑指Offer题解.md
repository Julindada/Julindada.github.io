---
title: 剑指Offer题解
date: 2019-02-18 20:55:23
categories: 
	- Algorithms
---

## 数组中重复的数字

> 在一个长度为n的数组里的所有数字都在0到n-1的范围内。 数组中某些数字是重复的，但不知道有几个数字是重复的。也不知道每个数字重复几次。请找出数组中任意一个重复的数字。 例如，如果输入长度为7的数组{2,3,1,0,2,5,3}，那么对应的输出是第一个重复的数字2。

思路：

1. 哈希表,时间复杂度为O(N)，空间复杂度为O(N)

2. 数组中数字都在0到n-1范围内。如果没有重复数字，则每个数字对应其下标。时间复杂度为O(N)，空间复杂度为O(1)

``` java
    public boolean duplicate(int numbers[],int length,int [] duplication) {
        if (length<=1 || numbers.length<=1)
            return false;
        for (int i=0; i<length; i++){
            if (numbers[i] != i){
                if (numbers[numbers[i]]==numbers[i]){
                    duplication[0]=numbers[i];
                    return true;
                }else {
                    int temp = numbers[numbers[i]];
                    numbers[numbers[i]] = numbers[i];
                    numbers[i] = temp;
                    i--;
                }
            }
        }
        return false;
    }
```



## 二维数组中的查找

> 在一个二维数组中（每个一维数组的长度相同），每一行都按照从左到右递增的顺序排序，每一列都按照从上到下递增的顺序排序。请完成一个函数，输入这样的一个二维数组和一个整数，判断数组中是否含有该整数。

思路：先检查数组左上角，若大于target，则排除最左列，若小于target，则排除最顶行。


``` java
    public boolean Find(int target, int [][] array) {
        int x = 0;
        int y = array[0].length-1;
        while (x <= array.length-1 && y >= 0){
            if (array[x][y] == target){
                return true;
            }else if (array[x][y] > target){
                y--;
            }else { // array[x][y] < target
                x++;
            }
        }
        return false;
    }
```



##替换空格

> 请实现一个函数，将一个字符串中的每个空格替换成“%20”。例如，当字符串为We Are Happy.则经过替换之后的字符串为We%20Are%20Happy。

思路：先遍历计算空格数量，从后到前移动字符(以保证所有字符只移动一次)。

``` java
    public String replaceSpace(StringBuffer str) {
        int length = str.length()-1;
        for (int i=0; i<=length; i++)
            if (str.charAt(i) == ' ')
                str.append("  ");
        for (int i=str.length()-1, j=length; i>=0 && j>=0;){
            if (str.charAt(j)==' '){
                str.setCharAt(i--,'0');
                str.setCharAt(i--,'2');
                str.setCharAt(i--,'%');
                j--;
            }else {
                str.setCharAt(i,str.charAt(j));
                i--;
                j--;
            }
        }
        return str.toString();
    }
```



## 从尾到头打印链表

> 输入一个链表，按链表值从尾到头的顺序返回一个ArrayList。

思路：栈的特点是先进后出

``` java
    public ArrayList<Integer> printListFromTailToHead(ListNode listNode) {
        Stack<Integer> stack = new Stack<>();
        ArrayList<Integer> ret = new ArrayList<>();
        while (listNode != null){
            stack.push(listNode.val);
            listNode=listNode.next;
        }
        while (!stack.empty()){
            ret.add(stack.pop());
        }
        return ret;
    }
```



## 重建二叉树

> 输入某二叉树的前序遍历和中序遍历的结果，请重建出该二叉树。假设输入的前序遍历和中序遍历的结果中都不含重复的数字。例如输入前序遍历序列{1,2,4,7,3,5,6,8}和中序遍历序列{4,7,2,1,5,3,8,6}，则重建二叉树并返回。

思路：前序遍历的第一个值为根节点的值，这个值将中序遍历结果分成两部分，递归。

具体细节：利用HashMap快速查找中序遍历数组的下标

``` java
	Map<Integer, Integer> inMap = new HashMap<>();
    public TreeNode reConstructBinaryTree(int [] pre, int [] in) {
        for (int i=0; i< in.length; i++)
            inMap.put(in[i],i);
        binaryTree(pre, 0,pre.length-1,0);
    }
    public TreeNode binaryTree(int [] pre, int pL, int pR, int inIndex) {
        if (pL>pR) return null;
        TreeNode root = new TreeNode(pre[pL]);
        int rootIndex = inMap.get(pre[pL]);
        int leftTreeLen = rootIndex-inIndex;
        root.left=binaryTree(pre,pL+1, pL+leftTreeLen, inIndex);
        root.right=binaryTree(pre, pL+1+leftTreeLen, pR, rootIndex+1);
        return root;
    }
```



## 二叉树的下一个节点

> 给定一个二叉树和其中的一个结点，请找出中序遍历顺序的下一个结点并且返回。注意，树中的结点不仅包含左右子结点，同时包含指向父结点的指针。

思路：分两种情况：1.该节点的右节点不为null时，寻找该右节点的最左子节点/该节点的右节点。2.该节点的右节点为null时，寻找第一个左链接指向的节点包含该节点的祖先节点

``` java
    public TreeLinkNode GetNext(TreeLinkNode pNode){
        if (pNode.right != null){
            pNode=pNode.right;
            while (pNode.left != null){
                pNode=pNode.left;
            }
            return pNode;
        }else {// pNode.right==null
            while (pNode.next != null){
                TreeLinkNode parent = pNode.next;
                if (parent.left == pNode)
                    return parent;
                pNode=parent;
            }
        }
        return null;
    }
```



##用两个栈实现队列

> 用两个栈来实现一个队列，完成队列的Push和Pop操作。 队列中的元素为int类型。

思路：一个出栈，一个入栈。若出栈为空，则将入栈倒入到出栈中。

``` java
	Stack<Integer> in = new Stack<Integer>();
    Stack<Integer> out = new Stack<Integer>();

    public void push(int node) {
        in.push(node);
    }

    public int pop() {
        if (out.isEmpty())
            while (!in.isEmpty())
                out.push(in.pop());
        if (out.isEmpty())
            return 0;
        return out.pop();
    }
```



## 斐波那契数列

> 大家都知道斐波那契数列，现在要求输入一个整数n，请你输出斐波那契数列的第n项（从0开始，第0项为0，第1项为1）。

思路：递归效率太低，且占用大量栈内存，使用动态规划来做。

``` java
    public int Fibonacci(int n) {
        if (n<2) return n;
        int[] x=new int[]{0,1};
        for (int i=2; i<=n; i++)
            x[i&1]=x[0]+x[1];
        return x[n&1];
    }
```

## 旋转数组的最小数字

> 把一个数组最开始的若干个元素搬到数组的末尾，我们称之为数组的旋转。 输入一个非减排序的数组的一个旋转，输出旋转数组的最小元素。 例如数组{3,4,5,1,2}为{1,2,3,4,5}的一个旋转，该数组的最小值为1。 NOTE：给出的所有元素都大于0，若数组大小为0，请返回0。

思路：二分法，若mid<high，后半为升序，最小值在前半。否则，最小值在后半。还要考虑low、mid、high位置的值相等的情况使用顺序查找。

``` java
    public int minNumberInRotateArray(int [] array) {
        if (array.length==0) return 0;
        int low=0, high=array.length-1;
        while (low<high){
            int mid=(low+high)/2;
            if (array[low]==array[mid]&&array[mid]==array[high]){
                return minNum(array, low, high);
            }else if (array[mid]<=array[high]){
                high=mid;
            }else {//array[mid]>array[high]
                low=mid+1;
            }
        }
        return array[low];
    }
	//顺序查找
    private int minNum(int [] array, int low, int high){
        int min=low;
        for (int i=low+1; i<=high; i++){
            if (array[i]<array[min]){
                min=i;
            }
        }
        return array[min];
    }
```



## 矩阵中的路径



> 请设计一个函数，用来判断在一个矩阵中是否存在一条包含某字符串所有字符的路径。路径可以从矩阵中的任意一个格子开始，每一步可以在矩阵中向左，向右，向上，向下移动一个格子。如果一条路径经过了矩阵中的某一个格子，则之后不能再次进入这个格子。 例如 a b c e s f c s a d e e 这样的3 X 4 矩阵中包含一条字符串"bcced"的路径，但是矩阵中不包含"abcb"路径，因为字符串的第一个字符b占据了矩阵中的第一行第二个格子之后，路径不能再次进入该格子。



思路：通过二维数组{% raw %}{{0, -1}, {0, 1}, {-1, 0}, {1, 0}}{% endraw %}来上下左右移动，boolean数组判断是否走过



```java
private final static int[][] next = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}};
private int rows;
private int cols;

public boolean hasPath(char[] array, int rows, int cols, char[] str) {
    if (rows == 0 || cols == 0)
        return false;
    this.rows = rows;
    this.cols = cols;
    boolean[][] marked = new boolean[rows][cols];
    char[][] matrix = buildMatrix(array);
    for (int i = 0; i < rows; i++)
        for (int j = 0; j < cols; j++)
            if (backtracking(matrix, str, marked, 0, i, j))
                return true;
    return false;
}

private boolean backtracking(char[][] matrix, char[] str, boolean[][] marked, int pathLen, int r, int c) {
    if (pathLen == str.length)
        return true;
    if (r < 0 || r >= rows || c < 0 || c >= cols || matrix[r][c] != str[pathLen] || marked[r][c])
        return false;
    marked[r][c] = true;
    for (int[] n : next)
        if (backtracking(matrix, str, marked, pathLen + 1, r + n[0], c + n[1]))
            return true;
    marked[r][c] = false;
    return false;
}

private char[][] buildMatrix(char[] array) {
    char[][] matrix = new char[rows][cols];
    for (int i = 0, idx = 0; i < rows; i++)
        for (int j = 0; j < cols; j++)
            matrix[i][j] = array[idx++];
    return matrix;
}
```



## 机器人的运动范围



> 地上有一个m行和n列的方格。一个机器人从坐标0,0的格子开始移动，每一次只能向左，右，上，下四个方向移动一格，但是不能进入行坐标和列坐标的数位之和大于k的格子。 例如，当k为18时，机器人能够进入方格（35,37），因为3+5+3+7 = 18。但是，它不能进入方格（35,38），因为3+5+3+8 = 19。请问该机器人能够达到多少个格子？



思路：



```java
    static boolean[][] marked;
    final static int[][] next = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}};

    public static int movingCount(int threshold, int rows, int cols){
        if (rows<=0||cols<=0||threshold<0) return 0;
        marked = new boolean[rows][cols];
        return movingCountCore(threshold, rows, cols, 0, 0);
    }

    private static int movingCountCore(int threshold, int rows, 
                                       int cols, int row, int col){
        marked[row][col]=true;
        int ret = 1;
        for (int[] n : next){
            int nextRow = row+n[0];
            int nextCol = col+n[1];
            if (nextRow < rows && nextRow >= 0 && nextCol < cols && nextCol >= 0 &&
                    !marked[nextRow][nextCol] && getDigitSum(nextRow, nextCol) <= threshold)
                ret+=movingCountCore(threshold, rows, cols, nextRow, nextCol);
        }
        return ret;
    }
    private static int getDigitSum(int row, int col){
        String r = String.valueOf(row);
        String c = String.valueOf(col);
        int ret=0;
        for (char a:r.toCharArray()) {
            int b=a-48;
            ret+=b;
        }
        for (char a:c.toCharArray()) {
            int b=a-48;
            ret+=b;
        }
        return ret;
    }
```





## 二叉树的镜像

思路：先递归遍历二叉树，再交换左右节点，返回当前根节点


``` java
	public TreeNode Mirror(TreeNode root) {
		if (root == null)
		    return null;
		TreeNode right = null;
		TreeNode left = null;
		if (root.left != null)
		    left = Mirror(root.left);
		if (root.right != null)
		    right = Mirror(root.right);
		root.right = left;
		root.left = right;
		return root;
	}
```



## 链表中环的入口节点

思路：快慢指针，指针指向地址相等时，将其中一个指针指向头节点，两指针速度相等遍历，相遇时的节点就是环的入口节点

``` java
    public ListNode EntryNodeOfLoop(ListNode pHead){
        if (pHead==null||pHead.next==null)
            return null;
        ListNode slow=pHead, fast=pHead;
        do {
            slow=slow.next;
            fast=fast.next.next;
        }while (slow!=fast);
        slow=pHead;
        while (slow!=fast){
            slow=slow.next;
            fast=fast.next;
        }
        return slow;
    }
```
