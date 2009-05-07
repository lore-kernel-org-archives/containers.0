From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v14][PATCH 53/54] Detect resource leaks for
	whole-containercheckpoint
Date: Wed, 6 May 2009 23:24:02 -0700
Message-ID: <20090507062402.GA14208@linux.vnet.ibm.com>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
	<1240961064-13991-54-git-send-email-orenl@cs.columbia.edu>
	<20090507035026.GB6003@linux.vnet.ibm.com>
	<4A025F7D.3050403@cs.columbia.edu>
	<20090507061321.GA13725@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="C7zPtVaVf+AK4Oqc"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090507061321.GA13725-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org


--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

| 
| Attached (ptree2.c).  I ran it as:
| 
| 	$ ./ptree2 -n 1 -d 2

Now, really attached :-)


--C7zPtVaVf+AK4Oqc
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="ptree2.c"

#include <stdio.h>
#include <unistd.h>
#include <wait.h>
#include <errno.h>
#include <string.h>

int max_depth = 3;
int num_children = 3;

#define CKPT_READY		"checkpoint-ready"
#define CKPT_DONE		"checkpoint-done"
#define TEST_DONE		"test-done"
#define LOG_FILE		"log-ptree2"

#define SYS_GETGPID		1

#ifdef SYS_GETGPID
static inline int sys_getgpid()
{
#define	__NR_getgpid	335
        return syscall(__NR_getgpid);
}
#endif

FILE *logfp;

void do_exit(int status)
{
	if (logfp) {
		fflush(logfp);
		fclose(logfp);
	}
	_Exit(status);
}

int get_my_global_pid()
{
}

int test_done()
{
	int rc;

	rc = access(TEST_DONE, F_OK);
	if (rc == 0)
		return 1;
	else if (errno == ENOENT)
		return 0;

	fprintf(logfp, "access(%s) failed, %s\n", TEST_DONE, strerror(errno));
	do_exit(1);
}

int checkpoint_done()
{
	int rc;

	rc = access(CKPT_DONE, F_OK);
	if (rc == 0)
		return 1;
	else if (errno == ENOENT)
		return 0;

	fprintf(logfp, "access(%s) failed, %s\n", CKPT_DONE, strerror(errno));
	do_exit(1);
}

void checkpoint_ready()
{
	int fd;

	fd = creat(CKPT_READY, 0666, 0);
	if (fd < 0) {
		fprintf(logfp, "creat(%s) failed, %s\n", CKPT_READY,
				strerror(errno));
		do_exit(1);
	}
	close(fd);
}

print_exit_status(int pid, int status)
{
	fprintf(logfp, "Pid %d unexpected exit - ", pid);
	if (WIFEXITED(status)) {
		fprintf(logfp, "exit status %d\n", WEXITSTATUS(status));
	} else if (WIFSIGNALED(status)) {
		fprintf(logfp, "got signal %d\n", WTERMSIG(status));
	} else {
		fprintf(logfp, "stopped/continued ?\n");
	}
}

void do_wait()
{
	int rc;
	int n;
	int status;

	n = 0;
	while(1) {
		rc = waitpid(-1, &status, 0);
		if (rc < 0)
			break;

		n++;
		if (!WIFEXITED(status) || WEXITSTATUS(status) != 0)
			print_exit_status(rc, status);	
	}

	if (errno != ECHILD) {
		fprintf(logfp, "waitpid(%d) failed, error %s\n",
					rc, strerror(errno));
		do_exit(1);
	}

	if (getpid() == 1 && n != num_children * max_depth) {
		fprintf(logfp, "Only %d of %d children exited ?\n",
			num_children, num_children * max_depth);
		do_exit(1);
	}

	do_exit(0);
}

static do_child(int depth, char *suffix);

create_children(int depth, char *parent_suffix)
{
	int i;
	int child_pid;
	char suffix[1024];

	for (i = 0; i < num_children; i++) {
		sprintf(suffix, "%s-%d", parent_suffix, i);

		child_pid = fork();
		if (child_pid == 0)
			do_child(depth, suffix);
		else if (child_pid < 0) {
			fprintf(logfp, "fork() failed, depth %d, "
				"child %d, error %s\n", depth, i,
				strerror(errno));
			do_exit(1);
		}
	}
}

do_child(int depth, char *suffix)
{
	int i;
	FILE *cfp;
	char cfile[256];
	char *mode = "w";

	/*
	 * Recursively calls do_child() and both parent and child
	 * execute the code below
	 */
	if (depth < max_depth)
		create_children(depth+1, suffix);

	sprintf(cfile, "%s%s", LOG_FILE, suffix);

	i = 0;
	while (!test_done()) {
		/* truncate the first time, append after that */
		cfp = fopen(cfile, mode);
		mode = "a";
		if (!cfp) {
			fprintf(logfp, "fopen(%s) failed, error %s\n", cfile,
					strerror(errno));
			do_exit(1);
		}
		fprintf(cfp, "gpid %d, pid %d: i %d\n", sys_getgpid(),
				getpid(), i++);
		fflush(cfp);
		sleep(1);
		fprintf(cfp, "gpid %d: woke up from sleep(1)\n", sys_getgpid());
		fflush(cfp);
		fclose(cfp);
	}

	/* Wait for any children that pre-deceased us */
	do_wait();

	do_exit(0);
}

static void usage(char *argv[])
{
	printf("%s [h] [-d max-depth] [-n max-children]\n", argv[0]);
	printf("\t <max-depth> max depth of process tree, default 3\n");
	printf("\t <num-children> # of children per process, default 3\n");
	do_exit(1);
}

main(int argc, char *argv[])
{
	int c;
	int i;
	int status;

	if (test_done()) {
		printf("Remove %s before running test\n", TEST_DONE);
		do_exit(1);
	}

	while ((c = getopt(argc, argv, "hd:n:")) != EOF) {
		switch (c) {
		case 'd': max_depth = atoi(optarg); break;
		case 'n': num_children = atoi(optarg); break;
		case 'h':
		default:
			usage(argv);
		}
	};


	logfp = fopen(LOG_FILE, "w");
	if (!logfp) {
		fprintf(stderr, "fopen(%s) failed, %s\n", LOG_FILE,
					strerror(errno));
		fflush(stderr);
		do_exit(1);
	}
	close(0);close(1);close(2);

	create_children(1, "");

	/*
 	 * Now that we closed the special files and created process tree
	 * tell any wrapper scripts, we are ready for checkpoint
	 */
	checkpoint_ready();

#if 0
	while(!checkpoint_done())
		sleep(1);
#endif

	do_wait();
}

--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--C7zPtVaVf+AK4Oqc--
