#ifndef AJ_TYPES_COUNTRY_H
#define AJ_TYPES_COUNTRY_H

#include "aj_types.h"

typedef uint8 country;

PG_FUNCTION_INFO_V1(country_in);
PG_FUNCTION_INFO_V1(country_out);
PG_FUNCTION_INFO_V1(country_lt);
PG_FUNCTION_INFO_V1(country_le);
PG_FUNCTION_INFO_V1(country_eq);
PG_FUNCTION_INFO_V1(country_ge);
PG_FUNCTION_INFO_V1(country_gt);
PG_FUNCTION_INFO_V1(country_cmp);

Datum country_in(PG_FUNCTION_ARGS);
Datum country_out(PG_FUNCTION_ARGS);
Datum country_lt(PG_FUNCTION_ARGS);
Datum country_le(PG_FUNCTION_ARGS);
Datum country_eq(PG_FUNCTION_ARGS);
Datum country_ge(PG_FUNCTION_ARGS);
Datum country_gt(PG_FUNCTION_ARGS);
Datum country_cmp(PG_FUNCTION_ARGS);

uint8 get_country_num(char *str);
char * get_country_string(uint8 *num);

static int country_cmp_internal(country *a, country *b);

uint8 get_country_num_a(char *str);
uint8 get_country_num_b(char *str);
uint8 get_country_num_c(char *str);
uint8 get_country_num_d(char *str);
uint8 get_country_num_e(char *str);
uint8 get_country_num_f(char *str);
uint8 get_country_num_g(char *str);
uint8 get_country_num_h(char *str);
uint8 get_country_num_i(char *str);
uint8 get_country_num_j(char *str);
uint8 get_country_num_k(char *str);
uint8 get_country_num_l(char *str);
uint8 get_country_num_m(char *str);
uint8 get_country_num_n(char *str);
uint8 get_country_num_o(char *str);
uint8 get_country_num_p(char *str);
uint8 get_country_num_q(char *str);
uint8 get_country_num_r(char *str);
uint8 get_country_num_s(char *str);
uint8 get_country_num_t(char *str);
uint8 get_country_num_u(char *str);
uint8 get_country_num_v(char *str);
uint8 get_country_num_w(char *str);
uint8 get_country_num_y(char *str);
uint8 get_country_num_z(char *str);

#endif // AJ_TYPES_COUNTRY_H
