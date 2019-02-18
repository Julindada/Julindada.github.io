---
title: 剑指Offer题解
date: 2019-02-18 20:55:23
categories: 
	- Algorithms
---


## 1.二叉树的镜像

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

## 2.链表中环的入口节点

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