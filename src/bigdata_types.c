#include "bigistore.h"
#include "intutils.h"
#include "avl.h"
#include "utils/memutils.h"


BigAvlTree
bigistore_make_empty(BigAvlTree t)
{
    if (t != NULL)
    {
        bigistore_make_empty(t->left);
        bigistore_make_empty(t->right);
        pfree(t);
        t = NULL;
    }
    return NULL;
}


BigPosition
bigistore_tree_find(int32 key, BigAvlTree t)
{
    int32 cmp;

    if (t == NULL)
        return NULL;

    cmp = COMPARE(key, t->key);
    if (cmp < 0)
        return bigistore_tree_find(key, t->left);
    else if (cmp > 0)
        return bigistore_tree_find(key, t->right);
    else
        return t;
}

/* This function can be called only if k2 has a left child */
/* Perform a rotate between a node (k2) and its left child */
/* Update heights, then return new root */
static inline BigPosition
singleRotateWithLeft(BigPosition k2)
{
    BigPosition k1;

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
static inline BigPosition
singleRotateWithRight(BigPosition k1)
{
    BigPosition k2;

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
static inline BigPosition
doubleRotateWithLeft(BigPosition k3)
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
static inline BigPosition
doubleRotateWithRight(BigPosition k1)
{
    /* Rotate between k3 and k2 */
    k1->right = singleRotateWithLeft(k1->right);

    /* Rotate between k1 and k2 */
    return singleRotateWithRight(k1);
}

BigAvlTree
bigistore_insert(BigAvlTree t, int32 key, int64 value)
{
    if(t == NULL)
    {
        /* Create and return a one-node tree */
        t = palloc0(sizeof(struct BigAvlNode));
        if (t == NULL)
            elog(ERROR, "BigAvlTree bigistore_insert: could not allocate memory");
        else
            ROOT(t,key,value);
    }
    else
    {
        int32 cmp = COMPARE(key, t->key);
        if (cmp < 0)
        {
            t->left = bigistore_insert(t->left, key, value);
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
            t->right = bigistore_insert(t->right, key, value);
            if (height(t->right) - height(t->left) == 2)
            {
                if (COMPARE(key, t->right->key) > 0)
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
bigistore_tree_length(BigPosition p)
{
    int n;
    if(p == NULL)
        return 0;
    n = bigistore_tree_length(p->left);
    ++n;
    n += bigistore_tree_length(p->right);
    return n;
}

int
bigistore_tree_to_pairs(BigPosition p, BigIStorePairs *pairs, int n)
{
    if(p == NULL)
        return n;
    n = bigistore_tree_to_pairs(p->left, pairs, n);

    bigistore_pairs_insert(pairs, p->key, p->value);
    ++n;
    n = bigistore_tree_to_pairs(p->right, pairs, n);
    return n;
}

void
bigistore_pairs_init(BigIStorePairs *pairs, size_t initial_size)
{
    pairs->pairs   = palloc0(initial_size * sizeof(BigIStorePair));
    pairs->used    = 0;
    pairs->size    = initial_size;
    pairs->buflen  = 0;
}

void
bigistore_pairs_insert(BigIStorePairs *pairs, int32 key, int64 val)
{
    if (pairs->size == pairs->used) {
        if (pairs->used == PAIRS_MAX(IStorePair))
            elog(ERROR, "bigistore can't have more than %lu keys", PAIRS_MAX(IStorePair));

        pairs->size *= 2;
        // overflow check pairs->size should have been grown but not exceed PAIRS_MAX(IStorePair)
        if (pairs->size < pairs->used || pairs->size > PAIRS_MAX(IStorePair))
            pairs->size = PAIRS_MAX(IStorePair);

        pairs->pairs = repalloc(pairs->pairs, pairs->size * sizeof(BigIStorePair));
    }

    pairs->pairs[pairs->used].key  = key;
    pairs->pairs[pairs->used].val  = val;
    pairs->buflen += digits64(key) + digits64(val) + BUFLEN_OFFSET;

    if (pairs->buflen < 0)
        elog(ERROR, "bigistore buffer overflow");
    pairs->used++;
}

int
bigistore_pairs_cmp(const void *a, const void *b)
{
    BigIStorePair *_a = (BigIStorePair *)a;
    BigIStorePair *_b = (BigIStorePair *)b;

    if (_a->key < _b->key)
        return -1;
    else if (_a->key > _b->key)
        return 1;
    else
        return 0;
}