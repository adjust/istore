#ifndef ISTORECOMMON_H
#define ISTORECOMMON_H

#define BUFLEN_OFFSET 8
#define MAX(_a, _b) (_a > _b) ? _a : _b
#define MIN(_a ,_b) (_a < _b) ? _a : _b
#define SAMESIGN(a,b)   (((a) < 0) == ((b) < 0))

#define COMPARE(_a,_b) (_a - _b)
#define DIGIT_WIDTH(_digit, _width, _dtype)       \
    do {                                  \
        _dtype _local = _digit;            \
        _width = 0;                       \
        if (_local <= 0)                  \
            ++_width;                     \
        for (; _local != 0; _local /= 10) \
            ++_width;                     \
    } while (0)

#define PAIRS_MAX(_pairtype) (MaxAllocSize / sizeof(_pairtype))
#define PAYLOAD_SIZE(_pairs, _pairtype) (_pairs->used * sizeof(_pairtype))
#define ISHDRSZ VARHDRSZ + sizeof(int32) + sizeof(int32)

#define ISTORE_SIZE(x, _pairtype) (ISHDRSZ + x->len * sizeof(_pairtype))
#define FIRST_PAIR(x, _pairtype) ((_pairtype*)((char *) x + ISHDRSZ))

#define FILLREMAINING(_creator, _index1, _is1, pairs1, _index2, _is2, _pairs2, _insert_func)     \
    while (_index1 < _is1->len)                                                    \
    {                                                                              \
        _insert_func(_creator, pairs1[_index1].key, pairs1[_index1].val);   \
        ++_index1;                                                                 \
    }                                                                              \
    while (_index2 < _is2->len)                                                    \
    {                                                                              \
        _insert_func(_creator, _pairs2[_index2].key, _pairs2[_index2].val); \
        ++_index2;                                                                 \
    }                                                                              \


#endif // ISTORECOMMON_H
