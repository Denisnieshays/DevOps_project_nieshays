#include <fcgi_stdio.h>
#include <stdlib.h>

int main(void) {
  while (FCGI_Accept() >= 0) {
    printf("Content-type: text/html\r\n");
    printf("\r\n");

    printf("<!DOCTYPE html>\n");
    printf("<html>\n");
    printf("<head>\n");
    printf("    <title>Hello World</title>\n");
    printf("</head>\n");
    printf("<body>\n");
    printf("    <h1>Hello& World!</h1>\n");
    printf("    <p>FastCGI Server is working!</p>\n");
    printf("</body>\n");
    printf("</html>\n");
  }
  return 0;
}