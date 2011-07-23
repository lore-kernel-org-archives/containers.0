From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Reply #2: [TOOLS] To make use of the patches
Date: Fri, 22 Jul 2011 17:40:45 -0700
Message-ID: <20110723004045.GC21563@count0.beaverton.ibm.com>
References: <4E204466.8010204@parallels.com> <4E204554.6040901@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4E204554.6040901-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jul 15, 2011 at 05:49:08PM +0400, Pavel Emelyanov wrote:

<snip>

> static void kill_imgfiles(int pid)
> {
> 	/* FIXME */
> }
> 
> static int stop_task(int pid)
> {
> 	return kill(pid, SIGSTOP);
> }

Shouldn't you wait() on the task too? Otherwise I think you'll race
with it. Alternately, you could introduce a wait() phase after the loop
calls stop_task() below...

<snip>

> 
> static int __dump_all_tasks(void)
> {
> 	int i, pid;
> 
> 	printf("Dumping tasks' images for");
> 	for (i = 0; i < nr_pids; i++)
> 		printf(" %d", pids[i]);
> 	printf("\n");
> 
> 	printf("Stopping tasks\n");
> 	for (i = 0; i < nr_pids; i++)
> 		if (stop_task(pids[i]))
> 			goto err;

(see the wait() note above)

> 
> 	for (i = 0; i < nr_pids; i++) {
> 		if (dump_one_task(pids[i], 0))
> 			goto err;
> 	}
> 
> 	printf("Resuming tasks\n");
> 	for (i = 0; i < nr_pids; i++)
> 		continue_task(pids[i]);
> 
> 	return 0;
> 
> err:
> 	for (i = 0; i < nr_pids; i++)
> 		continue_task(pids[i]);

nit: Seems like you could simplify this using a variable with
the return value.

> 	return 1;
> 
> }

<snip>
 
> 
> static int fixup_pages_data(int pid, int fd)
> {
> 	char path[128];
> 	int shfd;
> 	__u32 mag;
> 	__u64 vaddr;
> 
> 	sprintf(path, "pages-%d.img", pid);
> 	shfd = open(path, O_RDONLY);
> 	if (shfd < 0) {
> 		perror("Can't open shmem image");
> 		return 1;
> 	}
> 
> 	read(shfd, &mag, sizeof(mag));
> 	if (mag != PAGES_MAGIC) {
> 		fprintf(stderr, "Bad shmem image\n");
> 		return 1;
> 	}
> 
> 	lseek(fd, -sizeof(struct binfmt_page_image), SEEK_END);
> 	read(fd, &vaddr, sizeof(vaddr));
> 	if (vaddr != 0) {
> 		printf("SHIT %lx\n", (unsigned long)vaddr);

Typo?

Cheers,
	-Matt Helsley
