#include "istore.h"
#include "intutils.h"
#include "avl.h"
#include "utils/memutils.h"

AvlTree
istore_make_empty(AvlTree t)
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


Position
istore_tree_find(int32 key, AvlTree t)
{
    int32 cmp;

    if (t == NULL)
        return NULL;

    cmp = COMPARE(key, t->key);
    if (cmp < 0)
        return istore_tree_find(key, t->left);
    else if (cmp > 0)
        return istore_tree_find(key, t->right);
    else
        return t;
}

/* This function can be called only if k2 has a left child */
/* Perform a rotate between a node (k2) and its left child */
/* Update heights, then return new root */
static inline Position
singleRotateWithLeft(Position k2)
{
    Position k1;

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
static inline Position
singleRotateWithRight(Position k1)
{
    Position k2;

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
static inline Position
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
static inline Position
doubleRotateWithRight(Position k1)
{
    /* Rotate between k3 and k2 */
    k1->right = singleRotateWithLeft(k1->right);

    /* Rotate between k1 and k2 */
    return singleRotateWithRight(k1);
}

AvlTree
istore_insert(AvlTree t, int32 key, int32 value)
{
    if(t == NULL)
    {
        /* Create and return a one-node tree */
        t = palloc0(sizeof(struct AvlNode));
        if (t == NULL)
            elog(ERROR, "AvlTree istore_insert: could not allocate memory");
        else
            ROOT(t,key,value);
    }
    else
    {
        int32 cmp = COMPARE(key, t->key);
        if (cmp < 0)
        {
            t->left = istore_insert(t->left, key, value);
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
            t->right = istore_insert(t->right, key, value);
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
            t->value = int32add(t->value, value);
            return t;
        }
    }

    t->height = MAX(height(t->left), height(t->right)) + 1;
    return t;
}

// return number of nodes
int
istore_tree_length(Position p)
{
    int n;
    if(p == NULL)
        return 0;
    n = istore_tree_length(p->left);
    ++n;
    n += istore_tree_length(p->right);
    return n;
}

int
istore_tree_to_pairs(Position p, IStorePairs *pairs, int n)
{
    if(p == NULL)
        return n;
    n = istore_tree_to_pairs(p->left, pairs, n);

    istore_pairs_insert(pairs, p->key, p->value);
    ++n;
    n = istore_tree_to_pairs(p->right, pairs, n);
    return n;
}

void
istore_pairs_init(IStorePairs *pairs, size_t initial_size)
{
    pairs->pairs   = palloc0(initial_size * sizeof(IStorePair));
    pairs->used    = 0;
    pairs->size    = initial_size;
    pairs->buflen  = 0;
}

void
istore_pairs_insert(IStorePairs *pairs, int32 key, int32 val)
{
    int keylen,
        vallen;

    if (pairs->size == pairs->used) {
        if (pairs->used == PAIRS_MAX(IStorePair))
            elog(ERROR, "istore can't have more than %lu keys", PAIRS_MAX(IStorePair));

        pairs->size *= 2;
        // overflow check pairs->size should have been grown but not exceed PAIRS_MAX(IStorePair)
        if (pairs->size < pairs->used || pairs->size > PAIRS_MAX(IStorePair))
            pairs->size = PAIRS_MAX(IStorePair);

        pairs->pairs = repalloc(pairs->pairs, pairs->size * sizeof(IStorePair));
    }

    pairs->pairs[pairs->used].key  = key;
    pairs->pairs[pairs->used].val  = val;

    DIGIT_WIDTH(key, keylen, int32);
    DIGIT_WIDTH(val, vallen, int32);
    pairs->buflen += keylen + vallen + BUFLEN_OFFSET;
    if (pairs->buflen < 0)
        elog(ERROR, "istore buffer overflow");
    pairs->used++;
}

int
istore_pairs_cmp(const void *a, const void *b)
{
    IStorePair *_a = (IStorePair *)a;
    IStorePair *_b = (IStorePair *)b;
    if (_a->key < _b->key)
        return -1;
    else if (_a->key > _b->key)
        return 1;
    else
        return 0;
}