#include "istore.h"
#include "intutils.h"
#include "utils/memutils.h"
#define DIGIT_WIDTH(_digit, _width)       \
    do {                                  \
        int32 _local = _digit;            \
        _width = 0;                       \
        if (_local <= 0)                  \
            ++_width;                     \
        for (; _local != 0; _local /= 10) \
            ++_width;                     \
    } while (0)

#define PAIRS_MAX (MaxAllocSize / sizeof(IStorePair))

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

/*static inline int
min(int lhs, int rhs)
{
    return lhs < rhs ? lhs : rhs;
}
*/

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

int
istore_compare(int32 key, AvlTree node)
{
    if (key == node->key)
        return 0;
    else if (key < node->key)
        return -1;
    else
        return 1;
}

Position
istore_tree_find(int32 key, AvlTree t)
{
    int cmp;

    if (t == NULL)
        return NULL;

    cmp = istore_compare(key, t);
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
istore_insert(AvlTree t, int32 key, int32 value)
{
    if(t == NULL)
    {
        /* Create and return a one-node tree */
        t = palloc0(sizeof(struct AvlNode));
        if (t == NULL)
            elog(ERROR, "AvlTree istore_insert: could not allocate memory");
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
        int cmp = istore_compare(key, t);
        if (cmp < 0)
        {
            t->left = istore_insert(t->left, key, value);
            if (height(t->left) - height(t->right) == 2)
            {
                if (istore_compare( key, t->left))
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
                if (istore_compare(key, t->right))
                    t = singleRotateWithRight(t);
                else
                    t = doubleRotateWithRight(t);
            }
        }
        else
        {
            t->value = int32add(t->value, value);
        }
    }

    t->height = max(height(t->left), height(t->right)) + 1;
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
        if (pairs->used == PAIRS_MAX)
            elog(ERROR, "istore can't have more than %lu keys", PAIRS_MAX);

        pairs->size *= 2;
        // overflow check pairs->size should have been grown but not exceed PAIRS_MAX
        if (pairs->size < pairs->used || pairs->size > PAIRS_MAX)
            pairs->size = PAIRS_MAX;

        pairs->pairs = repalloc(pairs->pairs, pairs->size * sizeof(IStorePair));
    }

    pairs->pairs[pairs->used].key  = key;
    pairs->pairs[pairs->used].val  = val;

    DIGIT_WIDTH(key, keylen);
    DIGIT_WIDTH(val, vallen);
    pairs->buflen += keylen + vallen + BUFLEN_OFFSET;
    if (pairs->buflen < 0)
        elog(ERROR, "buffer overflow");
    pairs->used++;
}

int
istore_pairs_cmp(const void *a, const void *b)
{
    IStorePair *_a = (IStorePair *)a;
    IStorePair *_b = (IStorePair *)b;
    return (int)(_a->key - _b->key);
}

void inline
istore_pairs_sort(IStorePairs *pairs)
{
    qsort(pairs->pairs, pairs->used, sizeof(IStorePair), istore_pairs_cmp);
}

void
istore_pairs_deinit(IStorePairs *pairs)
{
    pfree(pairs->pairs);
}

void
istore_pairs_debug(IStorePairs *pairs)
{
    int i;
    for (i = 0; i < pairs->used; ++i)
    {
        elog(INFO, "key: %d, val: %d", pairs->pairs[i].key, pairs->pairs[i].val);
    }
}
