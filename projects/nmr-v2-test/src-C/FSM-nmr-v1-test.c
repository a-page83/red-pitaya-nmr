#define _BSD_SOURCE

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/ioctl.h>

#include "functions.h"

#define CMA_ALLOC _IOWR('Z', 0, uint32_t)

int main(int argc, char **argv)
{
  int fd;
  volatile uint8_t *rst;
  volatile void    *cfg, *sts;
  volatile int16_t *ram;
  volatile uint8_t *fsm_sts;
  
  uint32_t size;
  uint16_t value[2];
  uint32_t nb_of_Samples = 1024; //MAX = 1048576 pts 
  uint32_t nb_of_Bytes;
  uint32_t decimation = 100;
  int number_of_files = 1;
  int gainValue = 0;
  uint16_t amplitude = 1024;
  uint32_t frequency = 1e+6;
  uint32_t excitation_time_clk_cycles = 125e+6*0.2;
  uint32_t acquisition_time = 125e+6*2;

  char nomFichier[64] = "test1.bin";

  int phase_step = atoi(argv[1]);

  if((fd = open("/dev/mem", O_RDWR)) < 0)
  {
    perror("open");
    return EXIT_FAILURE;
  }

  cfg = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40000000);
  sts = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x41000000);

  close(fd);

  if((fd = open("/dev/cma", O_RDWR)) < 0)
  {
    perror("open");
    return EXIT_FAILURE;
  }

  size = 1024*sysconf(_SC_PAGESIZE);
  printf("Size = %d\n",size);

  
  if(ioctl(fd, CMA_ALLOC, &size) < 0)
  {
    perror("ioctl");
    return EXIT_FAILURE;
  }

  ram = mmap(NULL, 1024*sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
  
  ////Create file
  FILE *fichier = fopen(nomFichier, "wb+");
    printf("fichier crée : ");
    puts(nomFichier);
    if (fichier == NULL) {
        perror("Erreur lors de l'ouverture du fichier\n");
        return -1; // Quitte le programme avec erreur
    }
    if (build_file(fichier, nb_of_Samples, decimation, number_of_files, gainValue)){
        perror("Erreur de creation fichier\n");
        return -1;
    }
  
  nb_of_Bytes = nb_of_Samples * 4; // *2 (16bits) *2 (2 channels) 
  rst         = (uint8_t *)(cfg + 0);     //8 bits of reset
  fsm_sts     = (uint8_t *)(sts + 0);  //8bits vector status
                
  
  //amplitude
  *(uint32_t *)(cfg + 2) = amplitude ;

  // set writer address
  *(uint32_t *)(cfg + 4) = size; //change the value at the adress cfg + 4 (Jump of 4 Bytes)

  // set number of samples
  *(uint32_t *)(cfg + 8) = nb_of_Bytes - 1; //change the value at the addr cfg + 8 = nb of samples

  // set phase step in the FPGA
  *(uint32_t *)(cfg + 12) = (uint32_t) phase_step;

  // excitation time
  *(uint32_t *)(cfg + 16) = excitation_time_clk_cycles;

  // acquisition time
  *(uint32_t *)(cfg + 20) = acquisition_time;

  *rst |= 1;
  printf("reset\n");
  *rst &= ~1;
  *rst &= ~2;
  usleep(100);
  *rst |= 1;
  
  usleep(100);
  *rst |= 2;
  usleep(100);
  *rst &= ~2;

  printf("waiting...\n");
  while (((*fsm_sts) & 1) == 0) {
    usleep(200);
  }
  printf("done\n");
  // print IN1 and IN2 samples
  for(uint32_t i = 0; i < nb_of_Samples; ++i)
  {
    value[0] = ram[2 * i + 0];
    value[1] = ram[2 * i + 1];
    printf("%5d, %5d, %5d\n", value[0], value[1],i);
  }
  add_to_file(fichier, ram, nb_of_Samples);
  
  return EXIT_SUCCESS;
}