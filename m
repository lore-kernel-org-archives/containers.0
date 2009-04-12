From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] Add a multi-process IPC test
Date: Sat, 11 Apr 2009 20:42:38 -0400
Message-ID: <49E138FE.5000805@cs.columbia.edu>
References: <1239299170-14827-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1239299170-14827-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org


Thanks, added to user-cr.git for next version.

Oren.

Dan Smith wrote:
> This test forks off several children in various states to ensure that the
> IPC namespace information is properly restored after restart.
> 
> Cc: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  Makefile           |    2 +-
>  tst_ipcshm_multi.c |  266 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 267 insertions(+), 1 deletions(-)
>  create mode 100644 tst_ipcshm_multi.c
> 
> diff --git a/Makefile b/Makefile
> index c847a0c..2da03bb 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -19,7 +19,7 @@ CFLAGS += -g $(WARNS) $(PATHS) $(DEBUG)
>  
>  PROGS =	self ckpt rstr mktree
>  TESTS=	tst_onetask tst_multitask tst_bigmem tst_pipes tst_pipes2 tst_shmem \
> -	tst_ipcshm tst_ipcmsq
> +	tst_ipcshm tst_ipcmsq tst_ipcshm_multi
>  
>  LDLIBS = -lm
>  
> diff --git a/tst_ipcshm_multi.c b/tst_ipcshm_multi.c
> new file mode 100644
> index 0000000..1ef31f7
> --- /dev/null
> +++ b/tst_ipcshm_multi.c
> @@ -0,0 +1,266 @@
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <unistd.h>
> +#include <errno.h>
> +#include <sys/ipc.h>
> +#include <sys/shm.h>
> +
> +#include <linux/sched.h>
> +#include <sched.h>
> +
> +#define OUTFILE  "/tmp/cr-test.out"
> +#define SEG_SIZE (20 * 4096)
> +#define DELAY 20
> +
> +int attach(unsigned char **seg, int num)
> +{
> +	int id;
> +
> +	id = shmget(123, SEG_SIZE, 0700|IPC_EXCL);
> +	if (id < 0) {
> +		printf("[CHILD %i] shmget: %m\n", num);
> +		return -1;
> +	}
> +
> +	*seg = shmat(id, NULL, 0);
> +	if (!*seg) {
> +		printf("[CHILD %i] shmat: %m\n", num);
> +		return -1;
> +	}
> +
> +	printf("[CHILD %i] Attached\n", num);
> +
> +	return 0;
> +}
> +
> +int validate(unsigned char *seg, int num)
> +{
> +	int i;
> +
> +	for (i = 1; i < SEG_SIZE; i++) {
> +		if (seg[i] != (unsigned char)(i % 256)) {
> +			printf("[CHILD %i] Mismatch at %hhu: %hhu\n",
> +			       num, i, seg[i]);
> +			return -1;
> +		}
> +	}
> +
> +	printf("[CHILD %i] Validated\n", num);
> +
> +	return 0;
> +}
> +
> +void track(unsigned char *seg, int num)
> +{
> +	int i;
> +
> +	for (i = 0; i < 20; i++) {
> +		printf("[CHILD %i] Seg[0]: %i\n", num, seg[0]);
> +		sleep(1);
> +	}
> +}
> +
> +/*
> + * Attach to the shared segment *before* the checkpoint and then track
> + * the changing seg[0] position afterwards.
> + */
> +int child1(void)
> +{
> +	unsigned char *seg;
> +	int num = 1;
> +
> +	printf("[CHILD %i] Running\n", num);
> +
> +	sleep(1); /* Allow master to finish initializing the array */
> +
> +	if (attach(&seg, num))
> +		return -1;
> +
> +	if (validate(seg, num))
> +		return -1;
> +
> +	sleep(DELAY - 1); /* Wait until after the checkpoint */
> +
> +	track(seg, num);
> +
> +	return 0;
> +}
> +
> +/*
> + * Attempt to attach to the shared segment *after* the checkpoint to
> + * verify that things are hooked up properly after restart by tracking
> + * seg[0].
> + */
> +int child2(void)
> +{
> +	unsigned char *seg;
> +	int num = 2;
> +  
> +	printf("[CHILD %i] Running\n", num);
> +
> +	sleep(DELAY); /* Wait until after the checkpoint */
> +
> +	if (attach(&seg, num))
> +		return -1;
> +
> +	if (validate(seg, num))
> +		return -1;
> +
> +	track(seg, num);
> +
> +	return 0;
> +}
> +
> +int child4(void);
> +
> +/*
> + * Detach from the parent's IPC namespace and verify that:
> + * 1. We can't attach to the parent's segment
> + * 2. We can create our own of the same ID without conflict
> + * 3. We do not see the parent's changing seg[0] after restart
> + */
> +int child3(void)
> +{
> +	unsigned char *seg;
> +	int num = 3;
> +
> +	if (unshare(CLONE_NEWIPC) != 0) {
> +		printf("[CHILD %i] unshare(CLONE_NEWIPC): %m", num);
> +		return -1;
> +	}
> +
> +	if (fork() == 0)
> +		return child4();
> +
> +	printf("[CHILD %i] Running (new IPC NS)\n", num);
> +
> +	printf("[CHILD %i] Attempting parent attach (should fail)\n", num);
> +	if (!attach(&seg, num)) {
> +		printf("[CHILD %i] Attached to parent's IPC!\n", num);
> +		return -1;
> +	}
> +
> +	if (shmget(123, SEG_SIZE, 0700|IPC_CREAT|IPC_EXCL) < 0) {
> +		printf("[CHILD %i] Failed to create shm in namespace: %m\n",
> +		       num);
> +		return -1;
> +	}
> +
> +	if (attach(&seg, num))
> +		return -1;
> +
> +	seg[0] = 123;
> +
> +	sleep(DELAY); /* Wait until after checkpoint, then attach */
> +
> +	track(seg, num);
> +  
> +	return 0;
> +}
> +
> +/*
> + * This child is forked from child3 under the new IPC namespace.
> + * Verify that post-restart, we do not see the changing seg[0]
> + */
> +int child4(void)
> +{
> +	unsigned char *seg;
> +	int num = 4;
> +
> +	printf("[CHILD %i] Running (new IPC NS)\n", num);
> +
> +	sleep(DELAY); /* Wait past my parent creating the IPC */
> +
> +	if (attach(&seg, num))
> +		return -1;
> +
> +	track(seg, num);
> +
> +	return 0;
> +}
> +
> +void shm_destroy(void)
> +{
> +	int id;
> +
> +	id = shmget(123, SEG_SIZE, 0700);
> +	if (id < 0)
> +		return;
> +
> +	if (shmctl(id, IPC_RMID, NULL) == 0)
> +		printf("Deleted SHM %i\n", id);
> +}
> +
> +int main(int argc, char *argv[])
> +{
> +	int id;
> +	unsigned char *seg;
> +	int i;
> +	int pid1, pid2, pid3;
> +#ifndef TEST
> +	FILE *file;
> +
> +	close(0);
> +	close(1);
> +	close(2);
> +
> +	unlink(OUTFILE);
> +	file = fopen(OUTFILE, "w+");
> +	if (!file) {
> +		perror("open");
> +		exit(1);
> +	}
> +	if (dup2(0,2) < 0) {
> +		perror("dup2");
> +		exit(2);
> +	}
> +	stdout = file;
> +	setlinebuf(file);
> +#endif
> +	shm_destroy();
> +
> +	pid1 = fork();
> +	if (pid1 == 0)
> +		return child1();
> +
> +	pid2 = fork();
> +	if (pid2 == 0)
> +		return child2();
> +
> +	pid3 = fork();
> +	if (pid3 == 0)
> +		return child3();
> +
> +	id = shmget(123, SEG_SIZE, 0700|IPC_CREAT|IPC_EXCL);
> +	if (id < 0) {
> +		perror("shmget");
> +		exit(1);
> +	}
> +
> +	seg = (unsigned char *) shmat(id, NULL, 0);
> +	if(seg == ((void *) -1)) {
> +		perror("shmat");
> +		exit(1);
> +	}
> +	
> +	for (i = 0; i < SEG_SIZE; i++)
> +		seg[i] = i;
> +
> +	printf("[MSTER] Waiting for checkpoint\n");
> +	sleep(DELAY);
> +	printf("[MSTER] Woke\n");
> +
> +	for (i = 0; i < 15; i++) {
> +		seg[0] = i;
> +		sleep(1);
> +	}
> +
> +	if (shmdt(seg) < 0)
> +		perror("shmdt");
> +
> +	shm_destroy();
> +
> +	printf("[MSTER] Completed\n");
> +
> +	return 0;
> +}
