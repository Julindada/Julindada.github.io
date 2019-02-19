---
title: 剑指Offer题解
date: 2019-02-18 20:55:23
categories: 
	- Algorithms
---


## 1.数组中重复的数字

> 在一个长度为n的数组里的所有数字都在0到n-1的范围内。 数组中某些数字是重复的，但不知道有几个数字是重复的。也不知道每个数字重复几次。请找出数组中任意一个重复的数字。 例如，如果输入长度为7的数组{2,3,1,0,2,5,3}，那么对应的输出是第一个重复的数字2。

思路：

1. 哈希表,时间复杂度为O(N)，空间复杂度为O(N)

2. 数组中数字都在0到n-1范围内。如果没有重复数字，则每个数字对应其下标。时间复杂度为O(N)，空间复杂度为O(1)

``` Java
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

## 2.二维数组中的查找

> 在一个二维数组中（每个一维数组的长度相同），每一行都按照从左到右递增的顺序排序，每一列都按照从上到下递增的顺序排序。请完成一个函数，输入这样的一个二维数组和一个整数，判断数组中是否含有该整数。

思路：先检查数组左上角，若大于target，则排除最左列，若小于target，则排除最顶行。


``` Java
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

## 二叉树的镜像

思路：先递归遍历二叉树，再交换左右节点，返回当前根节点


``` Java
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

``` Java
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
