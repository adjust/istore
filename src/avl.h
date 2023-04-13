#ifndef ISTORE_AVL_H
#define ISTORE_AVL_H

#include "postgres.h"


typedef struct AvlNode AvlNode;

struct AvlNode
{
    int32    key;
    int64    value;
    AvlNode  *left;
    AvlNode  *right;
    int      height;
};

AvlNode* istore_make_empty(AvlNode *t);
AvlNode* is_tree_find(int32 key, AvlNode *t);
AvlNode* is_tree_insert(AvlNode *t, int32 key, int64 value);
int is_tree_length(AvlNode* t);
#endif // ISTORE_AVL_H
