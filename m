From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [C/R] sleepers don't wake up on restart
Date: Thu, 2 Apr 2009 15:43:42 -0700
Message-ID: <20090402224342.GA7613@us.ibm.com>
References: <20090402002005.GA22375@us.ibm.com>
	<49D539B5.7060305@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="wac7ysb48OaltWcw"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49D539B5.7060305-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
| 
| Suka,
| 
| can you please post the entire test program so I can try to reproduce
| it here ?

Sure. Attached.

Suka

--wac7ysb48OaltWcw
Content-Type: text/x-csrc; charset=us-ascii
Content-Description: ptree1.c
Content-Disposition: attachment; filename="ptree1.c"

#include <stdio.h>
#include <unistd.h>
#include <wait.h>
#include <errno.h>

#define NUM_PROCS	10
#define CKPT_READY	"ckpt-ready"
#define CKPT_DONE	"ckpt-done"
#define TEST_DONE	"test-done"
#define LOG_FILE	"log.ptree1"

FILE *logfp;

void do_exit(int status)
{
	if (logfp) {
		fflush(logfp);
		fclose(logfp);
	}
	_Exit(status);
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

do_child(int cnum)
{
	int i;
	FILE *cfp;
	char cfile[256];

	sprintf(cfile, "child-log-%d", cnum);

	i = 0;
	while (!test_done()) {
		cfp = fopen(cfile, "a");
		if (!cfp) {
			fprintf(logfp, "fopen(%s) failed, error %s\n", cfile,
					strerror(errno));
			do_exit(1);
		}
		fprintf(cfp, "i = %d\n", i++);
		fflush(cfp);
		fclose(cfp);
		sleep(1);
	}

	do_exit(0);
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

main(int argc, char *argv[])
{
	int i;
	int status;
	int pid_list[NUM_PROCS];

	if (test_done()) {
		printf("Remove %s before running test\n", TEST_DONE);
		do_exit(1);
	}

	logfp = fopen(LOG_FILE, "w");
	if (!logfp) {
		fprintf(stderr, "fopen(%s) failed, %s\n", LOG_FILE,
					strerror(errno));
		fflush(stderr);
		do_exit(1);
	}
	close(0);close(1);close(2);

	for (i = 0; i < NUM_PROCS; i++) {
		if ((pid_list[i] = fork()) == 0)
			do_child(i);
	}

	/*
 	 * Now that we closed the special files and created process tree
	 * tell any wrapper scripts, we are ready for checkpoint
	 */
	checkpoint_ready();

	while(!checkpoint_done())
		sleep(1);

	for (i = 0; i < NUM_PROCS; i++) {
		if (waitpid(pid_list[i], &status, 0) < 0) {
			fprintf(logfp, "waitpid(%d) failed, error %s\n",
					pid_list[i], strerror(errno));
		}

		if (!WIFEXITED(status) || WEXITSTATUS(status) != 0)
			print_exit_status(pid_list[i], status);	
	}
}

--wac7ysb48OaltWcw
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--wac7ysb48OaltWcw--
