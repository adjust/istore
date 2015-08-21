#ifndef ISTORECOMMON_H
#define ISTORECOMMON_H

#define BUFLEN_OFFSET 8
#define MAX(_a, _b) (_a > _b) ? _a : _b
#define MIN(_a ,_b) (_a < _b) ? _a : _b
#define SAMESIGN(a,b)   (((a) < 0) == ((b) < 0))

#define INT32 int32
#define ISTOREPAIR IStorePair

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

#define FINALIZE_ISTORE(_istore, _pairs, _pairtype)                                    \
    do {                                                                    \
        istore_pairs_sort(_pairs);                                              \
        FINALIZE_ISTORE_NOSORT(_istore, _pairs, _pairtype);                            \
    } while(0)

#define FINALIZE_ISTORE_NOSORT(_istore, _pairs, _pairtype)                             \
    do {                                                                    \
        _istore = palloc0(ISHDRSZ + PAYLOAD_SIZE(_pairs, _pairtype));                  \
        _istore->buflen = _pairs->buflen;                                   \
        _istore->len    = _pairs->used;                                     \
        SET_VARSIZE(_istore, ISHDRSZ + PAYLOAD_SIZE(_pairs, _pairtype));               \
        memcpy(FIRST_PAIR(_istore, _pairtype), _pairs->pairs, PAYLOAD_SIZE(_pairs, _pairtype)); \
        istore_pairs_deinit(_pairs);                                            \
    } while(0)

#define ISTORE_SIZE(x, _pairtype) (ISHDRSZ + x->len * sizeof(_pairtype))
#define FIRST_PAIR(x, _pairtype) ((_pairtype*)((char *) x + ISHDRSZ))

#define FILLREMAINING(_creator, _index1, _is1, pairs1, _index2, _is2, _pairs2)     \
    while (_index1 < _is1->len)                                                    \
    {                                                                              \
        istore_pairs_insert(_creator, pairs1[_index1].key, pairs1[_index1].val);   \
        ++_index1;                                                                 \
    }                                                                              \
    while (_index2 < _is2->len)                                                    \
    {                                                                              \
        istore_pairs_insert(_creator, _pairs2[_index2].key, _pairs2[_index2].val); \
        ++_index2;                                                                 \
    }                                                                              \


#endif // ISTORECOMMON_H
