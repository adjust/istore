#include "avl.h"

AvlNode*
istore_make_empty(AvlNode *t)
{
    if (t != NULL)
    {
        istore_make_empty(t->left);
        istore_make_empty(t->right);
        pfree(t);
        t = NULL;
    }
    return NULL;
}


AvlNode*
tree_find(int32 key, AvlNode *t)
{
    int32 cmp;

    if (t == NULL)
        return NULL;

    cmp = COMPARE(key, t->key);
    if (cmp < 0)
        return tree_find(key, t->left);
    else if (cmp > 0)
        return tree_find(key, t->right);
    else
        return t;
}

/* This function can be called only if k2 has a left child */
/* Perform a rotate between a node (k2) and its left child */
/* Update heights, then return new root */
static inline AvlNode*
singleRotateWithLeft(AvlNode *k2)
{
    AvlNode *k1;

    k1 = k2->left;
    k2->left = k1->right;
    k1->right = k2;

    k2->height = MAX(height(k2->left), height(k2->right)) + 1;
    k1->height = MAX(height(k1->left), k2->height) + 1;

    return k1;  /* New root */
}


/* This function can be called only if k1 has a right child */
/* Perform a rotate between a node (k1) and its right child */
/* Update heights, then return new root */
static inline AvlNode*
singleRotateWithRight(AvlNode *k1)
{
    AvlNode *k2;

    k2 = k1->right;
    k1->right = k2->left;
    k2->left = k1;

    k1->height = MAX(height(k1->left), height(k1->right)) + 1;
    k2->height = MAX(height(k2->right), k1->height) + 1;

    return k2;  /* New root */
}


/* This function can be called only if k3 has a left */
/* child and k3's left child has a right child */
/* Do the left-right double rotation */
/* Update heights, then return new root */
static inline AvlNode*
doubleRotateWithLeft(AvlNode *k3)
{
    /* Rotate between k1 and k2 */
    k3->left = singleRotateWithRight(k3->left);

    /* Rotate between k3 and k2 */
    return singleRotateWithLeft(k3);
}

/* This function can be called only if k1 has a right */
/* child and k1's right child has a left child */
/* Do the right-left double rotation */
/* Update heights, then return new root */
static inline AvlNode*
doubleRotateWithRight(AvlNode *k1)
{
    /* Rotate between k3 and k2 */
    k1->right = singleRotateWithLeft(k1->right);

    /* Rotate between k1 and k2 */
    return singleRotateWithRight(k1);
}

// return number of nodes
int
tree_length(AvlNode* t)
{
    int n;
    if(t == NULL)
        return 0;
    n = tree_length(t->left);
    ++n;
    n += tree_length(t->right);
    return n;
}

AvlNode*
tree_insert(AvlNode *t, int32 key, int64 value)
{
    if(t == NULL)
    {
        /* Create and return a one-node tree */
        t = palloc0(sizeof(struct AvlNode));
        if (t == NULL)
            elog(ERROR, "AvlTree tree_insert: could not allocate memory");
        else{
            t->key = key;
            t->value = value;
            t->height = 0;
            t->left = NULL;
            t->right = NULL;
        }
    }
    else
    {
        int32 cmp = COMPARE(key, t->key);
        if (cmp < 0)
        {
            t->left = tree_insert(t->left, key, value);
            if (height(t->left) - height(t->right) == 2)
            {
                if (COMPARE(key, t->left->key) < 0)
                    t = singleRotateWithLeft(t);
                else
                    t = doubleRotateWithLeft(t);
            }
        }
        else if(cmp > 0)
        {
            t->right = tree_insert(t->right, key, value);
            if (height(t->right) - height(t->left) == 2)
            {
                if (COMPARE(key, t->right->key) > 0 )
                    t = singleRotateWithRight(t);
                else
                    t = doubleRotateWithRight(t);
            }
        }
        else
        {
            t->value = int64add(t->value, value);
            return t;
        }
    }

    t->height = MAX(height(t->left), height(t->right)) + 1;
    return t;
}
