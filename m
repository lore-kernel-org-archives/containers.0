From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cr_tests: Add two testcases for epoll checkpoint/restart.
Date: Mon, 31 Aug 2009 10:24:44 -0500
Message-ID: <20090831152443.GA9673@us.ibm.com>
References: <1250744745-1360-1-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1250744745-1360-1-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
...
> diff --git a/epoll/Makefile b/epoll/Makefile
> new file mode 100644
> index 0000000..e1e3351
> --- /dev/null
> +++ b/epoll/Makefile
> @@ -0,0 +1,21 @@
> +.PHONY: clean all
> +
> +LIBS := ../libcrtest/libcrtest.a
> +CFLAGS := -Wall $(ARCHOPTS) -I./libfutex -I../ -I../libcrtest

libfutex?

You also mention futexes in several places where i think you mean
epoll.

> diff --git a/epoll/empty.c b/epoll/empty.c
> new file mode 100644
> index 0000000..c8c2109
> --- /dev/null
> +++ b/epoll/empty.c
> @@ -0,0 +1,83 @@
> +/*
> + * Make sure epoll sets stay empty across c/r.
> + *
> + * epoll create
> + * checkpoint
> + * close epoll
> + */
> +/* pretty standard stuff really */
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <errno.h>
> +#include <unistd.h>
> +#include <string.h>
> +
> +/* open() */
> +#include <sys/types.h>
> +#include <sys/stat.h>
> +#include <fcntl.h>
> +
> +/* waitpid() and W* status macros */
> +#include <sys/wait.h>
> +
> +/* epoll syscalls */
> +#include <sys/epoll.h>
> +
> +#include "libcrtest/libcrtest.h"
> +
> +#define LOG_FILE	"log.empty"
> +FILE *logfp = NULL;
> +
> +/*
> + * Log output with a tag (INFO, WARN, FAIL, PASS) and a format.
> + * Adds information about the thread originating the message.
> + *
> + * Flush the log after every write to make sure we get consistent, and
> + * complete logs.
> + */
> +#define log(tag, fmt, ...) \
> +do { \
> +	pid_t __tid = getpid(); \

gettid()?

> +	fprintf(logfp, ("%s: thread %d: " fmt), (tag), __tid, ##__VA_ARGS__ ); \
> +	fflush(logfp); \
> +	fsync(fileno(logfp)); \
> +} while(0)
> +
> +/* like perror() except to the log */
> +#define log_error(s) log("FAIL", "%s: %s\n", (s), strerror(errno))
> +
> +int main (int argc, char **argv)
> +{
> +	int efd;
> +
> +	/* FIXME eventually stdio streams should be harmless */
> +	close(0);
> +	logfp = fopen(LOG_FILE, "w");
> +	if (!logfp) {
> +		perror("could not open logfile");
> +		exit(1);
> +	}
> +	dup2(fileno(logfp), 1); /* redirect stdout and stderr to the log file */
> +	dup2(fileno(logfp), 2);

Hmm?  Does dup2 automatically close first?  Manpage suggests not,
so shouldn't you do so?

No other comments...  will wait to apply until the updated kernel
patches hit the list - and the tree.

thanks,
-serge
