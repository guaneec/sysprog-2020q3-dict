
#include <stdio.h>
#include <time.h>
#include "bloom.h"
#include "tst.h"

#define INFILE "cities_split_uniq.txt"
#define WORDMAX 256
#define N_STEP 4000
#define PROBE_LENGTH 2000
#define BLOOM_M 40000

typedef enum match {
    MATCH_FULL,
    MATCH_ALMOST,
    MATCH_NONE,
} match_t;


bloom_t bloom;
match_t match;
char out_filename[256];

double tvgetf()
{
    struct timespec ts;
    double sec;

    clock_gettime(CLOCK_REALTIME, &ts);
    sec = ts.tv_nsec;
    sec /= 1e9;
    sec += ts.tv_sec;

    return sec;
}

int bench_len()
{
    return 0;
}

int bench_n()
{
    FILE *in_file = fopen(INFILE, "r");
    FILE *probe_file = fopen(INFILE, "r");
    if (!in_file || !probe_file) {
        fprintf(stderr, "cannot open %s\n", INFILE);
        return 1;
    }
    FILE *log_file = fopen(out_filename, "w");
    if (!log_file) {
        fclose(in_file);
        fclose(probe_file);
        fprintf(stderr, "cannot open %s\n", out_filename);
        return 1;
    }
    char *word = malloc(WORDMAX);
    tst_node *root = NULL;
    size_t _n;
    int n = 0;
    int wordlen = 0;
    double t1, t2;

    char *probes[PROBE_LENGTH] = {0};
    int n_probe = 0;
    while (n_probe < PROBE_LENGTH &&
           (wordlen = getline(probes + n_probe, &_n, probe_file))) {
        if (wordlen < 2)
            continue;
        char *probe = probes[n_probe];
        probe[wordlen - 1] = '\0';
        if (match == MATCH_ALMOST) {
            probe[wordlen - 2] = '#';
        } else if (match == MATCH_NONE) {
            probe[0] = '#';
        }
        ++n_probe;
    }
    printf("nprobe %d\n", n_probe);

    while ((wordlen = getline(&word, &_n, in_file)) > 1) {
        ++n;
        word[wordlen - 1] = '\0';
        tst_ins_del(&root, word, 0, 1);
        if (bloom) {
            bloom_add(bloom, word);
        }
        if (n && !(n % PROBE_LENGTH)) {
            printf("testing with n=%d\n", n);
            for (int j = 0; j < 1000; ++j) {
                t1 = tvgetf();
                for (int i = 0; i < n_probe; ++i) {
                    if (!bloom || bloom_test(bloom, probes[i]))
                        tst_search(root, probes[i]);
                }
                t2 = tvgetf();
                fprintf(log_file, "%d %f\n", n / 1000, (t2 - t1) * 1000);
            }
        }
    }
    fclose(in_file);
    fclose(probe_file);
    fclose(log_file);
    free(word);
    bloom_free(bloom);
    for (int i = 0; i < n_probe; ++i) {
        free(probes[i]);
    }
    return 0;
}

int main(int argc, char **argv)
{
    if (argc != 4) {
        fprintf(stderr, "Expected 3 arguments, got %d\n", argc - 1);
        return 1;
    }

    sprintf(out_filename, "measurement/%s_%s_%s.txt", argv[1], argv[2],
            argv[3]);

    if (!strcmp(argv[2], "full")) {
        match = MATCH_FULL;
    } else if (!strcmp(argv[2], "almost")) {
        match = MATCH_ALMOST;
    } else if (!strcmp(argv[2], "none")) {
        match = MATCH_NONE;
    } else {
        fprintf(stderr, "Expected full | almost | none, got %s\n", argv[2]);
        return 1;
    }

    if (!strcmp(argv[3], "bloom")) {
        bloom = bloom_create(BLOOM_M);
    } else if (strcmp(argv[3], "nobloom")) {
        fprintf(stderr, "Expected bloom | nobloom, got %s\n", argv[3]);
        return 1;
    }

    if (!strcmp(argv[1], "n")) {
        return bench_n();
    }
    if (!strcmp(argv[1], "l")) {
        return bench_len();
    }
    fprintf(stderr, "Expected n | l, got %s\n", argv[1]);
    return 1;
}