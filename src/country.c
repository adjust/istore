#include "country.h"

static int country_cmp_internal(country a, country b);

PG_FUNCTION_INFO_V1(country_in);
Datum
country_in(PG_FUNCTION_ARGS)
{
    char *str = PG_GETARG_CSTRING(0);
    country result;

    if (str == NULL)
        elog(ERROR, "NULL input is not allowed for country type");

    LOWER_STRING(str);
    result = get_country_num(str);
    if (result == 0)
        elog(ERROR, "unknown input country type");
    PG_RETURN_COUNTRY(result);
}

PG_FUNCTION_INFO_V1(country_out);
Datum
country_out(PG_FUNCTION_ARGS)
{
    country a = PG_GETARG_COUNTRY(0);
    PG_RETURN_POINTER(get_country_string(a));
}

PG_FUNCTION_INFO_V1(country_recv);
Datum
country_recv(PG_FUNCTION_ARGS)
{
    StringInfo buf = (StringInfo) PG_GETARG_POINTER(0);
    country result = pq_getmsgbyte(buf);
    PG_RETURN_COUNTRY(result);
}

PG_FUNCTION_INFO_V1(country_send);
Datum
country_send(PG_FUNCTION_ARGS)
{
    country a = PG_GETARG_COUNTRY(0);
    StringInfoData buf;

    pq_begintypsend(&buf);
    pq_sendbyte(&buf, a);
    PG_RETURN_BYTEA_P(pq_endtypsend(&buf));
}

PG_FUNCTION_INFO_V1(country_lt);
Datum
country_lt(PG_FUNCTION_ARGS)
{
    country a = PG_GETARG_COUNTRY(0);
    country b = PG_GETARG_COUNTRY(1);
    PG_RETURN_BOOL(country_cmp_internal(a,b) < 0);
}

PG_FUNCTION_INFO_V1(country_le);
Datum
country_le(PG_FUNCTION_ARGS)
{
    country a = PG_GETARG_COUNTRY(0);
    country b = PG_GETARG_COUNTRY(1);
    PG_RETURN_BOOL(country_cmp_internal(a,b) <= 0);
}

PG_FUNCTION_INFO_V1(country_eq);
Datum
country_eq(PG_FUNCTION_ARGS)
{
    country a = PG_GETARG_COUNTRY(0);
    country b = PG_GETARG_COUNTRY(1);
    PG_RETURN_BOOL(country_cmp_internal(a,b) == 0);
}

PG_FUNCTION_INFO_V1(country_neq);
Datum
country_neq(PG_FUNCTION_ARGS)
{
    country a = PG_GETARG_COUNTRY(0);
    country b = PG_GETARG_COUNTRY(1);
    PG_RETURN_BOOL(country_cmp_internal(a,b) != 0);
}

PG_FUNCTION_INFO_V1(country_ge);
Datum
country_ge(PG_FUNCTION_ARGS)
{
    country a = PG_GETARG_COUNTRY(0);
    country b = PG_GETARG_COUNTRY(1);
    PG_RETURN_BOOL(country_cmp_internal(a,b) >= 0);
}

PG_FUNCTION_INFO_V1(country_gt);
Datum
country_gt(PG_FUNCTION_ARGS)
{
    country a = PG_GETARG_COUNTRY(0);
    country b = PG_GETARG_COUNTRY(1);
    PG_RETURN_BOOL(country_cmp_internal(a,b) > 0);
}

PG_FUNCTION_INFO_V1(country_cmp);
Datum
country_cmp(PG_FUNCTION_ARGS)
{
    country a = PG_GETARG_COUNTRY(0);
    country b = PG_GETARG_COUNTRY(1);
    PG_RETURN_INT32(country_cmp_internal(a,b));
}

uint8
get_country_num(char *str)
{
    if (strlen(str) != 2)
        elog(ERROR, "invalid length for country input");

    switch (str[0])
    {
        case 'a': return get_country_num_a(str);
        case 'b': return get_country_num_b(str);
        case 'c': return get_country_num_c(str);
        case 'd': return get_country_num_d(str);
        case 'e': return get_country_num_e(str);
        case 'f': return get_country_num_f(str);
        case 'g': return get_country_num_g(str);
        case 'h': return get_country_num_h(str);
        case 'i': return get_country_num_i(str);
        case 'j': return get_country_num_j(str);
        case 'k': return get_country_num_k(str);
        case 'l': return get_country_num_l(str);
        case 'm': return get_country_num_m(str);
        case 'n': return get_country_num_n(str);
        case 'o': return get_country_num_o(str);
        case 'p': return get_country_num_p(str);
        case 'q': return get_country_num_q(str);
        case 'r': return get_country_num_r(str);
        case 's': return get_country_num_s(str);
        case 't': return get_country_num_t(str);
        case 'u': return get_country_num_u(str);
        case 'v': return get_country_num_v(str);
        case 'w': return get_country_num_w(str);
        case 'y': return get_country_num_y(str);
        case 'z': return get_country_num_z(str);
        default : return 0;
    }
}

char *
get_country_string(uint8 num)
{
    switch (num)
    {
        case 1:   return create_string(CONST_STRING("ad"));
        case 2:   return create_string(CONST_STRING("ae"));
        case 3:   return create_string(CONST_STRING("af"));
        case 4:   return create_string(CONST_STRING("ag"));
        case 5:   return create_string(CONST_STRING("ai"));
        case 6:   return create_string(CONST_STRING("al"));
        case 7:   return create_string(CONST_STRING("am"));
        case 8:   return create_string(CONST_STRING("ao"));
        case 9:   return create_string(CONST_STRING("aq"));
        case 10:  return create_string(CONST_STRING("ar"));
        case 11:  return create_string(CONST_STRING("as"));
        case 12:  return create_string(CONST_STRING("at"));
        case 13:  return create_string(CONST_STRING("au"));
        case 14:  return create_string(CONST_STRING("aw"));
        case 15:  return create_string(CONST_STRING("ax"));
        case 16:  return create_string(CONST_STRING("az"));
        case 17:  return create_string(CONST_STRING("ba"));
        case 18:  return create_string(CONST_STRING("bb"));
        case 19:  return create_string(CONST_STRING("bd"));
        case 20:  return create_string(CONST_STRING("be"));
        case 21:  return create_string(CONST_STRING("bf"));
        case 22:  return create_string(CONST_STRING("bg"));
        case 23:  return create_string(CONST_STRING("bh"));
        case 24:  return create_string(CONST_STRING("bi"));
        case 25:  return create_string(CONST_STRING("bj"));
        case 26:  return create_string(CONST_STRING("bl"));
        case 27:  return create_string(CONST_STRING("bm"));
        case 28:  return create_string(CONST_STRING("bn"));
        case 29:  return create_string(CONST_STRING("bo"));
        case 30:  return create_string(CONST_STRING("bq"));
        case 31:  return create_string(CONST_STRING("br"));
        case 32:  return create_string(CONST_STRING("bs"));
        case 33:  return create_string(CONST_STRING("bt"));
        case 34:  return create_string(CONST_STRING("bv"));
        case 35:  return create_string(CONST_STRING("bw"));
        case 36:  return create_string(CONST_STRING("by"));
        case 37:  return create_string(CONST_STRING("bz"));
        case 38:  return create_string(CONST_STRING("ca"));
        case 39:  return create_string(CONST_STRING("cc"));
        case 40:  return create_string(CONST_STRING("cd"));
        case 41:  return create_string(CONST_STRING("cf"));
        case 42:  return create_string(CONST_STRING("cg"));
        case 43:  return create_string(CONST_STRING("ch"));
        case 44:  return create_string(CONST_STRING("ci"));
        case 45:  return create_string(CONST_STRING("ck"));
        case 46:  return create_string(CONST_STRING("cl"));
        case 47:  return create_string(CONST_STRING("cm"));
        case 48:  return create_string(CONST_STRING("cn"));
        case 49:  return create_string(CONST_STRING("co"));
        case 50:  return create_string(CONST_STRING("cr"));
        case 51:  return create_string(CONST_STRING("cu"));
        case 52:  return create_string(CONST_STRING("cv"));
        case 53:  return create_string(CONST_STRING("cw"));
        case 54:  return create_string(CONST_STRING("cx"));
        case 55:  return create_string(CONST_STRING("cy"));
        case 56:  return create_string(CONST_STRING("cz"));
        case 57:  return create_string(CONST_STRING("de"));
        case 58:  return create_string(CONST_STRING("dj"));
        case 59:  return create_string(CONST_STRING("dk"));
        case 60:  return create_string(CONST_STRING("dm"));
        case 61:  return create_string(CONST_STRING("do"));
        case 62:  return create_string(CONST_STRING("dz"));
        case 63:  return create_string(CONST_STRING("ec"));
        case 64:  return create_string(CONST_STRING("ee"));
        case 65:  return create_string(CONST_STRING("eg"));
        case 66:  return create_string(CONST_STRING("eh"));
        case 67:  return create_string(CONST_STRING("er"));
        case 68:  return create_string(CONST_STRING("es"));
        case 69:  return create_string(CONST_STRING("et"));
        case 70:  return create_string(CONST_STRING("fi"));
        case 71:  return create_string(CONST_STRING("fj"));
        case 72:  return create_string(CONST_STRING("fk"));
        case 73:  return create_string(CONST_STRING("fm"));
        case 74:  return create_string(CONST_STRING("fo"));
        case 75:  return create_string(CONST_STRING("fr"));
        case 76:  return create_string(CONST_STRING("ga"));
        case 77:  return create_string(CONST_STRING("gb"));
        case 78:  return create_string(CONST_STRING("gd"));
        case 79:  return create_string(CONST_STRING("ge"));
        case 80:  return create_string(CONST_STRING("gf"));
        case 81:  return create_string(CONST_STRING("gg"));
        case 82:  return create_string(CONST_STRING("gh"));
        case 83:  return create_string(CONST_STRING("gi"));
        case 84:  return create_string(CONST_STRING("gl"));
        case 85:  return create_string(CONST_STRING("gm"));
        case 86:  return create_string(CONST_STRING("gn"));
        case 87:  return create_string(CONST_STRING("gp"));
        case 88:  return create_string(CONST_STRING("gq"));
        case 89:  return create_string(CONST_STRING("gr"));
        case 90:  return create_string(CONST_STRING("gs"));
        case 91:  return create_string(CONST_STRING("gt"));
        case 92:  return create_string(CONST_STRING("gu"));
        case 93:  return create_string(CONST_STRING("gw"));
        case 94:  return create_string(CONST_STRING("gy"));
        case 95:  return create_string(CONST_STRING("hk"));
        case 96:  return create_string(CONST_STRING("hm"));
        case 97:  return create_string(CONST_STRING("hn"));
        case 98:  return create_string(CONST_STRING("hr"));
        case 99:  return create_string(CONST_STRING("ht"));
        case 100: return create_string(CONST_STRING("hu"));
        case 101: return create_string(CONST_STRING("id"));
        case 102: return create_string(CONST_STRING("ie"));
        case 103: return create_string(CONST_STRING("il"));
        case 104: return create_string(CONST_STRING("im"));
        case 105: return create_string(CONST_STRING("in"));
        case 106: return create_string(CONST_STRING("io"));
        case 107: return create_string(CONST_STRING("iq"));
        case 108: return create_string(CONST_STRING("ir"));
        case 109: return create_string(CONST_STRING("is"));
        case 110: return create_string(CONST_STRING("it"));
        case 111: return create_string(CONST_STRING("je"));
        case 112: return create_string(CONST_STRING("jm"));
        case 113: return create_string(CONST_STRING("jo"));
        case 114: return create_string(CONST_STRING("jp"));
        case 115: return create_string(CONST_STRING("ke"));
        case 116: return create_string(CONST_STRING("kg"));
        case 117: return create_string(CONST_STRING("kh"));
        case 118: return create_string(CONST_STRING("ki"));
        case 119: return create_string(CONST_STRING("km"));
        case 120: return create_string(CONST_STRING("kn"));
        case 121: return create_string(CONST_STRING("kp"));
        case 122: return create_string(CONST_STRING("kr"));
        case 123: return create_string(CONST_STRING("kw"));
        case 124: return create_string(CONST_STRING("ky"));
        case 125: return create_string(CONST_STRING("kz"));
        case 126: return create_string(CONST_STRING("la"));
        case 127: return create_string(CONST_STRING("lb"));
        case 128: return create_string(CONST_STRING("lc"));
        case 129: return create_string(CONST_STRING("li"));
        case 130: return create_string(CONST_STRING("lk"));
        case 131: return create_string(CONST_STRING("lr"));
        case 132: return create_string(CONST_STRING("ls"));
        case 133: return create_string(CONST_STRING("lt"));
        case 134: return create_string(CONST_STRING("lu"));
        case 135: return create_string(CONST_STRING("lv"));
        case 136: return create_string(CONST_STRING("ly"));
        case 137: return create_string(CONST_STRING("ma"));
        case 138: return create_string(CONST_STRING("mc"));
        case 139: return create_string(CONST_STRING("md"));
        case 140: return create_string(CONST_STRING("me"));
        case 141: return create_string(CONST_STRING("mf"));
        case 142: return create_string(CONST_STRING("mg"));
        case 143: return create_string(CONST_STRING("mh"));
        case 144: return create_string(CONST_STRING("mk"));
        case 145: return create_string(CONST_STRING("ml"));
        case 146: return create_string(CONST_STRING("mm"));
        case 147: return create_string(CONST_STRING("mn"));
        case 148: return create_string(CONST_STRING("mo"));
        case 149: return create_string(CONST_STRING("mp"));
        case 150: return create_string(CONST_STRING("mq"));
        case 151: return create_string(CONST_STRING("mr"));
        case 152: return create_string(CONST_STRING("ms"));
        case 153: return create_string(CONST_STRING("mt"));
        case 154: return create_string(CONST_STRING("mu"));
        case 155: return create_string(CONST_STRING("mv"));
        case 156: return create_string(CONST_STRING("mw"));
        case 157: return create_string(CONST_STRING("mx"));
        case 158: return create_string(CONST_STRING("my"));
        case 159: return create_string(CONST_STRING("mz"));
        case 160: return create_string(CONST_STRING("na"));
        case 161: return create_string(CONST_STRING("nc"));
        case 162: return create_string(CONST_STRING("ne"));
        case 163: return create_string(CONST_STRING("nf"));
        case 164: return create_string(CONST_STRING("ng"));
        case 165: return create_string(CONST_STRING("ni"));
        case 166: return create_string(CONST_STRING("nl"));
        case 167: return create_string(CONST_STRING("no"));
        case 168: return create_string(CONST_STRING("np"));
        case 169: return create_string(CONST_STRING("nr"));
        case 170: return create_string(CONST_STRING("nu"));
        case 171: return create_string(CONST_STRING("nz"));
        case 172: return create_string(CONST_STRING("om"));
        case 173: return create_string(CONST_STRING("pa"));
        case 174: return create_string(CONST_STRING("pe"));
        case 175: return create_string(CONST_STRING("pf"));
        case 176: return create_string(CONST_STRING("pg"));
        case 177: return create_string(CONST_STRING("ph"));
        case 178: return create_string(CONST_STRING("pk"));
        case 179: return create_string(CONST_STRING("pl"));
        case 180: return create_string(CONST_STRING("pm"));
        case 181: return create_string(CONST_STRING("pn"));
        case 182: return create_string(CONST_STRING("pr"));
        case 183: return create_string(CONST_STRING("ps"));
        case 184: return create_string(CONST_STRING("pt"));
        case 185: return create_string(CONST_STRING("pw"));
        case 186: return create_string(CONST_STRING("py"));
        case 187: return create_string(CONST_STRING("qa"));
        case 188: return create_string(CONST_STRING("re"));
        case 189: return create_string(CONST_STRING("ro"));
        case 190: return create_string(CONST_STRING("rs"));
        case 191: return create_string(CONST_STRING("ru"));
        case 192: return create_string(CONST_STRING("rw"));
        case 193: return create_string(CONST_STRING("sa"));
        case 194: return create_string(CONST_STRING("sb"));
        case 195: return create_string(CONST_STRING("sc"));
        case 196: return create_string(CONST_STRING("sd"));
        case 197: return create_string(CONST_STRING("se"));
        case 198: return create_string(CONST_STRING("sg"));
        case 199: return create_string(CONST_STRING("sh"));
        case 200: return create_string(CONST_STRING("si"));
        case 201: return create_string(CONST_STRING("sj"));
        case 202: return create_string(CONST_STRING("sk"));
        case 203: return create_string(CONST_STRING("sl"));
        case 204: return create_string(CONST_STRING("sm"));
        case 205: return create_string(CONST_STRING("sn"));
        case 206: return create_string(CONST_STRING("so"));
        case 207: return create_string(CONST_STRING("sr"));
        case 208: return create_string(CONST_STRING("ss"));
        case 209: return create_string(CONST_STRING("st"));
        case 210: return create_string(CONST_STRING("sv"));
        case 211: return create_string(CONST_STRING("sx"));
        case 212: return create_string(CONST_STRING("sy"));
        case 213: return create_string(CONST_STRING("sz"));
        case 214: return create_string(CONST_STRING("tc"));
        case 215: return create_string(CONST_STRING("td"));
        case 216: return create_string(CONST_STRING("tf"));
        case 217: return create_string(CONST_STRING("tg"));
        case 218: return create_string(CONST_STRING("th"));
        case 219: return create_string(CONST_STRING("tj"));
        case 220: return create_string(CONST_STRING("tk"));
        case 221: return create_string(CONST_STRING("tl"));
        case 222: return create_string(CONST_STRING("tm"));
        case 223: return create_string(CONST_STRING("tn"));
        case 224: return create_string(CONST_STRING("to"));
        case 225: return create_string(CONST_STRING("tr"));
        case 226: return create_string(CONST_STRING("tt"));
        case 227: return create_string(CONST_STRING("tv"));
        case 228: return create_string(CONST_STRING("tw"));
        case 229: return create_string(CONST_STRING("tz"));
        case 230: return create_string(CONST_STRING("ua"));
        case 231: return create_string(CONST_STRING("ug"));
        case 232: return create_string(CONST_STRING("uk"));
        case 233: return create_string(CONST_STRING("um"));
        case 234: return create_string(CONST_STRING("us"));
        case 235: return create_string(CONST_STRING("uy"));
        case 236: return create_string(CONST_STRING("uz"));
        case 237: return create_string(CONST_STRING("va"));
        case 238: return create_string(CONST_STRING("vc"));
        case 239: return create_string(CONST_STRING("ve"));
        case 240: return create_string(CONST_STRING("vg"));
        case 241: return create_string(CONST_STRING("vi"));
        case 242: return create_string(CONST_STRING("vn"));
        case 243: return create_string(CONST_STRING("vu"));
        case 244: return create_string(CONST_STRING("wf"));
        case 245: return create_string(CONST_STRING("ws"));
        case 246: return create_string(CONST_STRING("ye"));
        case 247: return create_string(CONST_STRING("yt"));
        case 248: return create_string(CONST_STRING("za"));
        case 249: return create_string(CONST_STRING("zm"));
        case 250: return create_string(CONST_STRING("zw"));
        case 255: return create_string(CONST_STRING("zz"));
        default : elog(ERROR, "unknown output countrytype");
    }
}

static int
country_cmp_internal(country a, country b)
{
    if (a < b)
        return -1;
    if (a > b)
        return 1;
    return 0;
}

uint8
get_country_num_a(char *str)
{
    switch (str[1])
   {
        case 'd': return 1;
        case 'e': return 2;
        case 'f': return 3;
        case 'g': return 4;
        case 'i': return 5;
        case 'l': return 6;
        case 'm': return 7;
        case 'o': return 8;
        case 'q': return 9;
        case 'r': return 10;
        case 's': return 11;
        case 't': return 12;
        case 'u': return 13;
        case 'w': return 14;
        case 'x': return 15;
        case 'z': return 16;
        default : return 0;
    }
}

uint8
get_country_num_b(char *str)
{
    switch (str[1])
   {
        case 'a': return 17;
        case 'b': return 18;
        case 'd': return 19;
        case 'e': return 20;
        case 'f': return 21;
        case 'g': return 22;
        case 'h': return 23;
        case 'i': return 24;
        case 'j': return 25;
        case 'l': return 26;
        case 'm': return 27;
        case 'n': return 28;
        case 'o': return 29;
        case 'q': return 30;
        case 'r': return 31;
        case 's': return 32;
        case 't': return 33;
        case 'v': return 34;
        case 'w': return 35;
        case 'y': return 36;
        case 'z': return 37;
        default : return 0;
    }
}

uint8
get_country_num_c(char *str)
{
    switch (str[1])
   {
        case 'a': return 38;
        case 'c': return 39;
        case 'd': return 40;
        case 'f': return 41;
        case 'g': return 42;
        case 'h': return 43;
        case 'i': return 44;
        case 'k': return 45;
        case 'l': return 46;
        case 'm': return 47;
        case 'n': return 48;
        case 'o': return 49;
        case 'r': return 50;
        case 'u': return 51;
        case 'v': return 52;
        case 'w': return 53;
        case 'x': return 54;
        case 'y': return 55;
        case 'z': return 56;
        default : return 0;
    }
}

uint8
get_country_num_d(char *str)
{
    switch (str[1])
   {
        case 'e': return 57;
        case 'j': return 58;
        case 'k': return 59;
        case 'm': return 60;
        case 'o': return 61;
        case 'z': return 62;
        default : return 0;
    }
}

uint8
get_country_num_e(char *str)
{
    switch (str[1])
   {
        case 'c': return 63;
        case 'e': return 64;
        case 'g': return 65;
        case 'h': return 66;
        case 'r': return 67;
        case 's': return 68;
        case 't': return 69;
        default : return 0;
    }
}

uint8
get_country_num_f(char *str)
{
    switch (str[1])
   {
        case 'i': return 70;
        case 'j': return 71;
        case 'k': return 72;
        case 'm': return 73;
        case 'o': return 74;
        case 'r': return 75;
        default : return 0;
    }
}

uint8
get_country_num_g(char *str)
{
    switch (str[1])
   {
        case 'a': return 76;
        case 'b': return 77;
        case 'd': return 78;
        case 'e': return 79;
        case 'f': return 80;
        case 'g': return 81;
        case 'h': return 82;
        case 'i': return 83;
        case 'l': return 84;
        case 'm': return 85;
        case 'n': return 86;
        case 'p': return 87;
        case 'q': return 88;
        case 'r': return 89;
        case 's': return 90;
        case 't': return 91;
        case 'u': return 92;
        case 'w': return 93;
        case 'y': return 94;
        default : return 0;
    }
}

uint8
get_country_num_h(char *str)
{
    switch (str[1])
   {
        case 'k': return 95;
        case 'm': return 96;
        case 'n': return 97;
        case 'r': return 98;
        case 't': return 99;
        case 'u': return 100;
        default : return 0;
    }
}

uint8
get_country_num_i(char *str)
{
    switch (str[1])
   {
        case 'd': return 101;
        case 'e': return 102;
        case 'l': return 103;
        case 'm': return 104;
        case 'n': return 105;
        case 'o': return 106;
        case 'q': return 107;
        case 'r': return 108;
        case 's': return 109;
        case 't': return 110;
        default : return 0;
    }
}

uint8
get_country_num_j(char *str)
{
    switch (str[1])
   {
        case 'e': return 111;
        case 'm': return 112;
        case 'o': return 113;
        case 'p': return 114;
        default : return 0;
    }
}

uint8
get_country_num_k(char *str)
{
    switch (str[1])
   {
        case 'e': return 115;
        case 'g': return 116;
        case 'h': return 117;
        case 'i': return 118;
        case 'm': return 119;
        case 'n': return 120;
        case 'p': return 121;
        case 'r': return 122;
        case 'w': return 123;
        case 'y': return 124;
        case 'z': return 125;
        default : return 0;
    }
}

uint8
get_country_num_l(char *str)
{
    switch (str[1])
   {
        case 'a': return 126;
        case 'b': return 127;
        case 'c': return 128;
        case 'i': return 129;
        case 'k': return 130;
        case 'r': return 131;
        case 's': return 132;
        case 't': return 133;
        case 'u': return 134;
        case 'v': return 135;
        case 'y': return 136;
        default : return 0;
    }
}

uint8
get_country_num_m(char *str)
{
    switch (str[1])
   {
        case 'a': return 137;
        case 'c': return 138;
        case 'd': return 139;
        case 'e': return 140;
        case 'f': return 141;
        case 'g': return 142;
        case 'h': return 143;
        case 'k': return 144;
        case 'l': return 145;
        case 'm': return 146;
        case 'n': return 147;
        case 'o': return 148;
        case 'p': return 149;
        case 'q': return 150;
        case 'r': return 151;
        case 's': return 152;
        case 't': return 153;
        case 'u': return 154;
        case 'v': return 155;
        case 'w': return 156;
        case 'x': return 157;
        case 'y': return 158;
        case 'z': return 159;
        default : return 0;
    }
}

uint8
get_country_num_n(char *str)
{
    switch (str[1])
   {
        case 'a': return 160;
        case 'c': return 161;
        case 'e': return 162;
        case 'f': return 163;
        case 'g': return 164;
        case 'i': return 165;
        case 'l': return 166;
        case 'o': return 167;
        case 'p': return 168;
        case 'r': return 169;
        case 'u': return 170;
        case 'z': return 171;
        default : return 0;
    }
}

uint8
get_country_num_o(char *str)
{
    switch (str[1])
    {
        case 'm': return 172;
        default : return 0;
    }
}

uint8
get_country_num_p(char *str)
{
    switch (str[1])
   {
        case 'a': return 173;
        case 'e': return 174;
        case 'f': return 175;
        case 'g': return 176;
        case 'h': return 177;
        case 'k': return 178;
        case 'l': return 179;
        case 'm': return 180;
        case 'n': return 181;
        case 'r': return 182;
        case 's': return 183;
        case 't': return 184;
        case 'w': return 185;
        case 'y': return 186;
        default : return 0;
    }
}

uint8
get_country_num_q(char *str)
{
    switch (str[1])
   {
        case 'a': return 187;
        default : return 0;
    }
}

uint8
get_country_num_r(char *str)
{
    switch (str[1])
    {
        case 'e': return 188;
        case 'o': return 189;
        case 's': return 190;
        case 'u': return 191;
        case 'w': return 192;
        default : return 0;
    }
}

uint8
get_country_num_s(char *str)
{
    switch (str[1]) {
        case 'a': return 193;
        case 'b': return 194;
        case 'c': return 195;
        case 'd': return 196;
        case 'e': return 197;
        case 'g': return 198;
        case 'h': return 199;
        case 'i': return 200;
        case 'j': return 201;
        case 'k': return 202;
        case 'l': return 203;
        case 'm': return 204;
        case 'n': return 205;
        case 'o': return 206;
        case 'r': return 207;
        case 's': return 208;
        case 't': return 209;
        case 'v': return 210;
        case 'x': return 211;
        case 'y': return 212;
        case 'z': return 213;
        default : return 0;
    }
}

uint8
get_country_num_t(char *str)
{
    switch (str[1])
    {
        case 'c': return 214;
        case 'd': return 215;
        case 'f': return 216;
        case 'g': return 217;
        case 'h': return 218;
        case 'j': return 219;
        case 'k': return 220;
        case 'l': return 221;
        case 'm': return 222;
        case 'n': return 223;
        case 'o': return 224;
        case 'r': return 225;
        case 't': return 226;
        case 'v': return 227;
        case 'w': return 228;
        case 'z': return 229;
        default : return 0;
    }
}

uint8
get_country_num_u(char *str)
{
    switch (str[1])
    {
        case 'a': return 230;
        case 'g': return 231;
        case 'k': return 232;
        case 'm': return 233;
        case 's': return 234;
        case 'y': return 235;
        case 'z': return 236;
        default : return 0;
    }
}

uint8
get_country_num_v(char *str)
{
    switch (str[1])
    {
        case 'a': return 237;
        case 'c': return 238;
        case 'e': return 239;
        case 'g': return 240;
        case 'i': return 241;
        case 'n': return 242;
        case 'u': return 243;
        default : return 0;
    }
}

uint8
get_country_num_w(char *str)
{
    switch (str[1])
    {
        case 'f': return 244;
        case 's': return 245;
        default : return 0;
    }
}

uint8
get_country_num_y(char *str)
{
    switch (str[1]) {
        case 'e': return 246;
        case 't': return 247;
        default : return 0;
    }
}

uint8
get_country_num_z(char *str)
{
    switch (str[1]) {
        case 'a': return 248;
        case 'm': return 249;
        case 'w': return 250;
        case 'z': return 255;
        default : return 0;
    }
}

PG_FUNCTION_INFO_V1(hashcounry);
Datum
hashcountry(PG_FUNCTION_ARGS)
{
    return hash_uint32((int32) PG_GETARG_CHAR(0));
}