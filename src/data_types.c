#include "istore.h"

void is_pairs_init(ISPairs *pairs, size_t initial_size, int type);
void is_pairs_insert(ISPairs *pairs, int key, long val, int type);
int  is_pairs_cmp(const void *a, const void *b);
void is_pairs_sort(ISPairs *pairs);
void is_pairs_deinit(ISPairs *pairs);
void is_pairs_debug(ISPairs *pairs);

int is_compare(int key, AvlTree node);
Position is_tree_find(int key, AvlTree t);
AvlTree is_insert(int key, int value, AvlTree t);
int is_tree_length(Position p);
int is_tree_to_pairs(Position p, ISPairs *pairs, int n);

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
is_make_empty(AvlTree t)
{
    if (t != NULL)
    {
        is_make_empty(t->left);
        is_make_empty(t->right);
        pfree(t);
        t = NULL;
    }
    return NULL;
}

int
is_compare(int key, AvlTree node)
{
    if (key == node->key)
        return 0;
    else if (key < node->key)
        return -1;
    else
        return 1;
}

Position
is_tree_find(int key, AvlTree t)
{
    int cmp;

    if (t == NULL)
        return NULL;

    cmp = is_compare(key, t);
    if (cmp < 0)
        return is_tree_find(key, t->left);
    else if (cmp > 0)
        return is_tree_find(key, t->right);
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
is_insert(int key, int value, AvlTree t)
{
    if(t == NULL)
    {
        /* Create and return a one-node tree */
        t = palloc0(sizeof(struct AvlNode));
        if (t == NULL)
            elog(ERROR, "AvlTree is_insert: could not allocate memory");
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
        int cmp = is_compare(key, t);
        if (cmp < 0)
        {
            t->left = is_insert(key, value, t->left);
            if (height(t->left) - height(t->right) == 2)
            {
                if (is_compare( key, t->left))
                    t = singleRotateWithLeft(t);
                else
                    t = doubleRotateWithLeft(t);
            }
        }
        else if(cmp > 0)
        {
            t->right = is_insert(key, value, t->right);
            if (height(t->right) - height(t->left) == 2)
            {
                if (is_compare(key, t->right))
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
is_tree_length(Position p)
{
    int n;
    if(p == NULL)
        return 0;
    n = is_tree_length(p->left);
    ++n;
    n += is_tree_length(p->right);
    return n;
}

int
is_tree_to_pairs(Position p, ISPairs *pairs, int n)
{
    if(p == NULL)
        return n;
    n = is_tree_to_pairs(p->left, pairs, n);
    is_pairs_insert(pairs, p->key, p->value, pairs->type);
    ++n;
    n = is_tree_to_pairs(p->right, pairs, n);
    return n;
}

void
is_pairs_init(ISPairs *pairs, size_t initial_size, int type)
{
    pairs->pairs  = palloc(initial_size * sizeof(ISPair));
    pairs->used   = 0;
    pairs->size   = initial_size;
    pairs->buflen = 0;
    pairs->type   = type;
}

void
is_pairs_insert(ISPairs *pairs, int key, long val, int type)
{
    int keylen,
        vallen;

    if (pairs->size == pairs->used) {
        pairs->size *= 2;
        pairs->pairs = repalloc(pairs->pairs, pairs->size * sizeof(ISPair));
    }

    pairs->pairs[pairs->used].key  = key;
    pairs->pairs[pairs->used].val  = val;
    switch (type)
    {
        case (PLAIN_ISTORE):
            DIGIT_WIDTH(key, keylen);
            DIGIT_WIDTH(val, vallen);
            pairs->pairs[pairs->used].null = false;
            pairs->buflen += keylen + vallen + 7;
            break;
        case (NULL_VAL_ISTORE):
            pairs->pairs[pairs->used].null = true;
            DIGIT_WIDTH(key, keylen);
            pairs->buflen += keylen + 10;
            break;
        case (DEVICE_ISTORE):
            keylen = get_device_type_length(key);
            DIGIT_WIDTH(val, vallen);
            pairs->pairs[pairs->used].null = false;
            pairs->buflen += keylen + vallen + 7;
            break;
        case (COUNTRY_ISTORE):
            keylen = 2;
            DIGIT_WIDTH(val, vallen);
            pairs->pairs[pairs->used].null = false;
            pairs->buflen += keylen + vallen + 7;
            break;
        case (OS_NAME_ISTORE):
            keylen = get_os_name_length(key);
            DIGIT_WIDTH(val, vallen);
            pairs->pairs[pairs->used].null = false;
            pairs->buflen += keylen + vallen + 7;
            break;
        default: elog(ERROR, "unknown pairs type");
    }
    pairs->used++;
}

int
is_pairs_cmp(const void *a, const void *b)
{
    ISPair *_a = (ISPair *)a;
    ISPair *_b = (ISPair *)b;
    if (_a->key < _b->key)
        return -1;
    else if (_a->key > _b->key)
        return 1;
    else
        return 0;
}

void inline
is_pairs_sort(ISPairs *pairs)
{
    qsort(pairs->pairs, pairs->used, sizeof(ISPair), is_pairs_cmp);
}

void
is_pairs_deinit(ISPairs *pairs)
{
    pfree(pairs->pairs);
}

void
is_pairs_debug(ISPairs *pairs)
{
    int i;
    for (i = 0; i < pairs->used; ++i)
    {
        elog(INFO, "key: %d, val: %ld", pairs->pairs[i].key, pairs->pairs[i].val);
    }
}
