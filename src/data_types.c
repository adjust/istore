#include "istore.h"

static inline int
height(Position p)
{
    if (p == NULL)
        return -1;
    else
        return p->height;
}

static inline int
max(int lhs, int rhs)
{
    return lhs > rhs ? lhs : rhs;
}

static inline int
min(int lhs, int rhs)
{
    return lhs < rhs ? lhs : rhs;
}

AvlTree
make_empty(AvlTree t)
{
    if (t != NULL)
    {
        make_empty(t->left);
        make_empty(t->right);
        pfree(t);
    }
    return NULL;
}

int
compare(int key, AvlTree node)
{
    if (key == node->key)
        return 0;
    else if (key < node->key)
        return -1;
    else
        return 1;
}

Position
tree_find(int key, AvlTree t)
{
    int cmp;

    if (t == NULL)
        return NULL;

    cmp = compare(key, t);
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
static Position
singleRotateWithLeft(Position k2)
{
    Position k1;

    k1 = k2->left;
    k2->left = k1->right;
    k1->right = k2;

    k2->height = max(height(k2->left), height(k2->right)) + 1;
    k1->height = max(height(k1->left), k2->height) + 1;

    return k1;  /* New root */
}


/* This function can be called only if k1 has a right child */
/* Perform a rotate between a node (k1) and its right child */
/* Update heights, then return new root */
static Position
singleRotateWithRight(Position k1)
{
    Position k2;

    k2 = k1->right;
    k1->right = k2->left;
    k2->left = k1;

    k1->height = max(height(k1->left), height(k1->right)) + 1;
    k2->height = max(height(k2->right), k1->height) + 1;

    return k2;  /* New root */
}


/* This function can be called only if k3 has a left */
/* child and k3's left child has a right child */
/* Do the left-right double rotation */
/* Update heights, then return new root */
static Position
doubleRotateWithLeft(Position k3)
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
static Position
doubleRotateWithRight(Position k1)
{
    /* Rotate between k3 and k2 */
    k1->right = singleRotateWithLeft(k1->right);

    /* Rotate between k1 and k2 */
    return singleRotateWithRight(k1);
}

AvlTree
insert(int key, int value, AvlTree t)
{
    if(t == NULL)
    {
        /* Create and return a one-node tree */
        t = palloc0(sizeof(struct AvlNode));
        if (t == NULL)
            elog(ERROR, "AvlTree insert: could not allocate memory");
        else
        {
            t->key = key;
            t->value = value;
            t->height = 0;
            t->left = NULL;
            t->right = NULL;
        }
    }
    else
    {
        int cmp = compare(key, t);
        if (cmp < 0)
        {
            t->left = insert(key, value, t->left);
            if (height(t->left) - height(t->right) == 2)
            {
                if (compare( key, t->left))
                    t = singleRotateWithLeft(t);
                else
                    t = doubleRotateWithLeft(t);
            }
        }
        else if(cmp > 0)
        {
            t->right = insert(key, value, t->right);
            if (height(t->right) - height(t->left) == 2)
            {
                if (compare(key, t->right))
                    t = singleRotateWithRight(t);
                else
                    t = doubleRotateWithRight(t);
            }
        }
        else
        {
            t->value += value;
        }
    }

    t->height = max(height(t->left), height(t->right)) + 1;
    return t;
}

// return number of nodes
int
tree_length(Position p)
{
    int n;
    if(p == NULL)
        return 0;

    n = tree_length(p->left);
    ++n;
    n += tree_length(p->right);
    return n;
}

int
tree_to_pairs(Position p, ISPairs *pairs, int n)
{
    if(p == NULL)
        return n;
    n = tree_to_pairs(p->left, pairs, n);
    Pairs_insert(pairs, p->key, p->value);
    ++n;
    n = tree_to_pairs(p->right, pairs, n);
    return n;
}
