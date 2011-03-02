From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [RFC] Payloads and transient filesystem support for user-cr
Date: Wed, 02 Mar 2011 23:05:24 +0100
Message-ID: <4D6EBF24.4000601@free.fr>
References: <1299101725-17603-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1299101725-17603-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

On 03/02/2011 10:35 PM, Dan Smith wrote:
> This adds payload support to user-cr for stashing things in the image.
> The first type of payload supported is a transient filesystem image,
> for things like /dev/shm.
>
> When I put "/dev/shm" into args.save_fs[] (and restore_fs), I am able
> to checkpoint and restart programs that are using POSIX sem_* operations
> successfully.

The posix semaphore use the mapped deleted hardlinked files.

...

sem_open("sem.dummy_sem_open", O_CREAT | O_EXCL, 0600, 1);

...

lstat("/dev/shm/sem.zaptW5", 0x7ffff086f530) = -1 ENOENT (No such file 
or directory)
open("/dev/shm/sem.zaptW5", O_RDWR|O_CREAT|O_EXCL, 0600) = 3
write(3, 
"\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0", 32) = 32
mmap(NULL, 32, PROT_READ|PROT_WRITE, MAP_SHARED, 3, 0) = 0x7f1dda7b3000
link("/dev/shm/sem.zaptW5", "/dev/shm/sem.dummy_sem_open") = 0
fstat(3, {st_mode=S_IFREG|0600, st_size=32, ...}) = 0
brk(0)                                  = 0x238e000
brk(0x23af000)                          = 0x23af000
unlink("/dev/shm/sem.zaptW5")           = 0
close(3)                                = 0

...

AFAIK, the current implementation do not support that, no ?
How is it possible to CR programs using sem_* operations in this case ?

Thanks
   -- Daniel
