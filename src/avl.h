#define height(_p) ((_p == NULL) ? -1 : _p->height)
#define ROOT(_t, _k, _v)  \
    do {                  \
        _t->key = _k;     \
        _t->value = _v;   \
        _t->height = 0;   \
        _t->left = NULL;  \
        _t->right = NULL; \
    } while(0)