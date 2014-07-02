#ifndef _DATA_TYPES_H
#define _DATA_TYPES_H

#include "istore.h"

struct AvlNode;
typedef struct AvlNode AvlNode;
typedef struct AvlNode *Position;
typedef struct AvlNode *AvlTree;

struct AvlNode
{
    union
    {
        char *key;
        int   intkey;
    };
    int keylen;
    long value;

    AvlTree  left;
    AvlTree  right;
    int      height;
};

AvlTree make_empty( AvlTree t );

int int_compare( int key, AvlTree node );

Position int_find( int key, AvlTree t );

AvlTree int_insert( int key, int value, AvlTree t );

int tree_length(Position p);
int int_tree_to_pairs(Position p, ISPairs *pairs, int4* buflen, int n);
#endif // _DATA_TYPES_H
