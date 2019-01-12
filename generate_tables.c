const char* AUTHOR = "Mathieu CAROFF";
const char* LAST_UPDATE = "2018-19-04";
const char* DESCRIPTION = "Generate GF(2^8) multiplication tables";

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

/*
 * Credit to dhuertas
 * https://github.com/dhuertas/AES/blob/master/aes.c
 * for the below `gmult` function
 * 
 * A very similar code can be found on Wikipedia (2019-01-12):
 * https://en.wikipedia.org/wiki/Rijndael_MixColumns
 */
/*
 * Multiplication in GF(2^8)
 * http://en.wikipedia.org/wiki/Finite_field_arithmetic
 * Irreducible polynomial m(x) = x8 + x4 + x3 + x + 1
 */
uint8_t gmult(uint8_t a, uint8_t b) {

    uint8_t p = 0, i = 0, hbs = 0;

    for (i = 0; i < 8; i++) {
        if (b & 1) {
            p ^= a;
        }

        hbs = a & 0x80; // carry
        a <<= 1;
        if (hbs) // carry?
            a ^= 0x1b; // 0001 1011
        b >>= 1;
    }

    return (uint8_t)p;
}


int main(int argc, char* argv[]) {
    uint8_t vector[] = {2, 3, 9, 11, 13, 14};
    uint8_t * interesting = vector;
    uint8_t interesting_length = sizeof(vector);
    if (argc > 1) {
        interesting = (uint8_t *) argv;
        interesting_length = argc - 1;
        for (int k = 1; k < argc; k++) {
            interesting[k - 1] = (uint8_t) atoi(argv[k]);
        }
    }
    // printf("type lut256 is array(0 to 255) of bit8;\n");
    printf(
        "-- %s\n"
        "-- %s\n"
        "-- GF multiplication tables\n"
        "\n",
        AUTHOR,
        LAST_UPDATE
    );
    for(uint8_t i = 0; i < interesting_length; i++) {
        uint8_t a = interesting[i];
    }
    for(uint8_t i = 0; i < interesting_length; i++) {
        uint8_t a = interesting[i];
        
        printf(
            "library ieee;\n"
            "use ieee.std_logic_1164.all;\n"
            "use ieee.numeric_std.all;\n"
            "use work.util_type.all;\n"
            "entity gftimes%dbox is\n"
            "    port (\n"
            "        byte_i : in  bit8;\n"
            "        byte_o : out bit8\n"
            "    );\n"
            "end gftimes%dbox;\n"
            "\n",
            a, a
        );
        printf(
            //"\n"
            //"\n"
            //"library ieee;\n"
            //"use ieee.std_logic_1164.all;\n"
            //"use ieee.numeric_std.all;\n"
            //"use work.util_type.all;\n"
            "\n"
            "architecture gftimes%dbox_arch of gftimes%dbox is\n"
            "\n"
            "    constant times%d_lut : lut256 := (\n",
            a, a, a
        );
        printf("        -- ");
        for (uint8_t k = 0; k < 16; ++k) {
            if (k != 0) {
                printf("      ");
            }
            printf("%X", k);
        }
        printf("\n");
        for (uint8_t i = 0;; ++i) {
            uint8_t res = gmult(a, i);
            if (i % 16 == 0) {
                printf("        ");
            }
            printf("x\"%02X\"", res);
            printf(i != 255 ? "," : " ");
            if ((i + 1) % 16) {
                printf(" ");
            } else {
                printf(" -- %X\n", i / 16);
            }
            if (i == 255) {
                break;
            }
        }
        printf(
            "    );\n"
            "\n"
            "begin\n"
            "\n"
            "    byte_o <= times%d_lut(to_integer(unsigned(byte_i(7 downto 0))));\n"
            "\n"
            "end gftimes%dbox_arch;\n",
            a, a
        );
    }
    return 0;
}
