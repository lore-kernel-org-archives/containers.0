From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 3/4] Add test case ptree1 - process tree using fileio
Date: Thu, 21 May 2009 10:24:06 -0700
Message-ID: <20090521172406.GA30650@us.ibm.com>
References: <20090521171754.GC18281@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090521171754.GC18281-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| Quoting sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
| > From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
| > 
| > The test case continously copies a given input-file to an output-file,
| > one record at a time. After copying, the test verifies that the two files
| > have the same data (i.e ensures if test was checkpointed/restarted, the
| > copy was still correct).  The test ends when the 'test_done()' condition
| > is TRUE.
| > 
| > The accompanying wrapper runs the test in a loop and checkpoints/restarts
| > the test.
| > 
| > Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
| > ---
| >  Makefile                   |    3 +-
| >  process-tree/Makefile      |   13 +++
| >  process-tree/ptree1.c      |  150 +++++++++++++++++++++++++++
| >  process-tree/run-ptree1.sh |  244 ++++++++++++++++++++++++++++++++++++++++++++
| >  4 files changed, 409 insertions(+), 1 deletions(-)
| >  create mode 100644 process-tree/Makefile
| >  create mode 100644 process-tree/ptree1.c
| >  create mode 100755 process-tree/run-ptree1.sh
| > 
| > diff --git a/Makefile b/Makefile
| > index f59c89b..d709f7f 100644
| > --- a/Makefile
| > +++ b/Makefile
| > @@ -1,4 +1,5 @@
| > -SUBDIRS = counterloop fileio simple cr-ipc-test userns sleep libcrtest
| > +SUBDIRS = counterloop fileio simple cr-ipc-test userns sleep libcrtest \
| > +	  process-tree
| > 
| >  targets = ns_exec
| > 
| > diff --git a/process-tree/Makefile b/process-tree/Makefile
| > new file mode 100644
| > index 0000000..f76f60d
| > --- /dev/null
| > +++ b/process-tree/Makefile
| > @@ -0,0 +1,13 @@
| > +
| > +targets		= ptree1
| > +
| > +INCLUDE		= ../libcrtest
| > +LIBCRTEST	= ../libcrtest/common.o
| > +
| > +CFLAGS		= -I $(INCLUDE)
| > +LDFLAGS		= $(LIBCRTEST) -lpthread 
| > +
| > +all: $(LIBCRTEST) $(targets)
| > +
| > +clean:
| > +	rm -f *.o $(targets)
| > diff --git a/process-tree/ptree1.c b/process-tree/ptree1.c
| > new file mode 100644
| > index 0000000..7df7c8e
| > --- /dev/null
| > +++ b/process-tree/ptree1.c
| > @@ -0,0 +1,150 @@
| > +#include <stdio.h>
| > +#include <unistd.h>
| > +#include <wait.h>
| > +#include <errno.h>
| > +#include <string.h>
| > +#include "common.h"
| > +
| > +/*
| > + * Create a simple process tree and have each process in the tree
| > + * (except the main) make a private copy of a given input * file,
| > + * When the copy is done, compare the private copy with the input
| > + * file and fail if they differ. If not, truncate the private copy
| > + * and repeat the copying until test_done() is TRUE.
| > + *
| > + * Note: To avoid touching restart-blocks, don't sleep().
| > + */
| > +
| > +int max_depth = 2;
| > +int num_children = 2;
| > +FILE *logfp;
| > +char *src = "input.data";
| > +#define LOG_FILE	"logs.d/log-ptree1"
| > +
| > +static void do_work(char *idstr)
| > +{
| > +	char dest[1024];
| > +
| > +	sprintf(dest, "log-%s.data", idstr);
| 
| not sure 'log-' is the right prefix... how about copy-%s.data
| or something?

Ok.

| 
| > +	copy_data(src, dest);
| > +
| > +	do_exit(0);
| > +}
| > +
| > +static do_child(int depth, char *suffix);
| > +
| > +create_children(int depth, char *parent_suffix)
| > +{
| > +	int i;
| > +	int child_pid;
| > +	char suffix[1024];
| > +
| > +	for (i = 0; i < num_children; i++) {
| > +		sprintf(suffix, "%s-%d", parent_suffix, i);
| 
| Since the depth is taken on command line, you need to either
| malloc the char[]s, or do snprintf(suffix, 1024, ...) here
| and elsewhere.

Yep

| 
| > +
| > +		child_pid = fork();
| > +		if (child_pid == 0)
| > +			do_child(depth, suffix);
| > +		else if (child_pid < 0) {
| > +			fprintf(logfp, "fork() failed, depth %d, "
| > +				"child %d, error %s\n", depth, i,
| > +				strerror(errno));
| > +			do_exit(1);
| > +		}
| > +	}
| > +}
| > +
| > +do_child(int depth, char *suffix)
| > +{
| > +	int i;
| > +	FILE *cfp;
| > +	char cfile[256];
| > +	char *mode = "w";
| > +
| > +	/*
| > +	 * Recursively calls do_child() and both parent and child
| > +	 * execute the code below
| > +	 */
| > +	fprintf(logfp, "do_child: depth %d, max_depth %d\n", depth, max_depth);
| > +	fflush(logfp);
| > +
| > +	if (depth < max_depth)
| > +		create_children(depth+1, suffix);
| > +
| > +	sprintf(cfile, "%s%s", LOG_FILE, suffix);
| > +
| > +	i = 0;
| > +	while (!test_done()) {
| > +		/* truncate the first time, append after that */
| > +		cfp = fopen(cfile, mode);
| > +		mode = "a";
| > +		if (!cfp) {
| > +			fprintf(logfp, "fopen(%s) failed, error %s\n", cfile,
| > +					strerror(errno));
| > +			do_exit(1);
| > +		}
| > +		fprintf(cfp, "pid %d: i %d\n", getpid(), i++);
| > +		fflush(cfp);
| > +
| > +		do_work(suffix);
| > +
| > +		fflush(cfp);
| > +		fclose(cfp);
| > +	}
| > +
| > +	/* Wait for any children that pre-deceased us */
| > +	do_wait(num_children);
| > +
| > +	do_exit(0);
| > +}
| > +
| > +static void usage(char *argv[])
| > +{
| > +	printf("%s [h] [-d max-depth] [-n max-children]\n", argv[0]);
| > +	printf("\t <max-depth> max depth of process tree, default 3\n");
| > +	printf("\t <num-children> # of children per process, default 3\n");
| > +	do_exit(1);
| > +}
| > +
| > +main(int argc, char *argv[])
| > +{
| > +	int c;
| > +	int i;
| > +	int status;
| > +
| > +	logfp = fopen(LOG_FILE, "w");
| > +	if (!logfp) {
| > +		fprintf(stderr, "fopen(%s) failed, %s\n", LOG_FILE,
| > +					strerror(errno));
| > +		fflush(stderr);
| > +		do_exit(1);
| > +	}
| > +
| > +	if (test_done()) {
| > +		printf("Remove %s before running test\n", TEST_DONE);
| > +		do_exit(1);
| > +	}
| > +
| > +	while ((c = getopt(argc, argv, "hd:n:")) != EOF) {
| > +		switch (c) {
| > +		case 'd': max_depth = atoi(optarg); break;
| > +		case 'n': num_children = atoi(optarg); break;
| > +		case 'h':
| > +		default:
| > +			usage(argv);
| > +		}
| > +	};
| > +
| > +	close(0);close(1);close(2);
| > +
| > +	create_children(1, "");
| > +
| > +	/*
| > +	 * Now that we closed the special files and created process tree
| > +	 * tell any wrapper scripts, we are ready for checkpoint
| > +	 */
| > +	checkpoint_ready();
| 
| How do you know a checkpoint is ready?
| 
| (Or is that not what this means?  :)

It sets the state to 'I am ready for checkpoint'.

How about renaming the interfaces to: set_checkpoint_ready(),
test_checkpoint_ready(), set_checkpoint_done() and test_checkpoint_done() ?

Sukadev
