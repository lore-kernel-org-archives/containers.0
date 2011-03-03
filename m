From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [RFC] Payloads and transient filesystem support for user-cr
Date: Thu, 03 Mar 2011 09:35:43 +0100
Message-ID: <4D6F52DF.1040808@free.fr>
References: <1299101725-17603-1-git-send-email-danms@us.ibm.com>	<4D6EBF24.4000601@free.fr>
	<877hch6oi2.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <877hch6oi2.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
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

On 03/03/2011 01:23 AM, Dan Smith wrote:
> DL>  The posix semaphore use the mapped deleted hardlinked files.
>
> DL>  AFAIK, the current implementation do not support that, no ?
> DL>  How is it possible to CR programs using sem_* operations in this case ?
>
> You're right.  This addresses the problem of /dev/shm/sem.foo going away
> when the container's /dev/shm mount is destroyed.  It does not address
> the fact that the mmap()'d unlinked file is restored as an anonymous
> region and therefore becomes disjoint with the one on-disk.  I expect
> the evolution of the unlinked files patches will resolve that.

The mapped file is deleted but hardlinked.

> Our naive tests are not discriminating enough to make this distinction
> at the moment, which certainly needs to be resolved :)

Well a simple test program doing sem_* operations should have spotted 
the problem.

Let me know for this one:

#include <stdio.h>
#include <semaphore.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define SEM "/dummy_sem_open"
int main(int argc, char *argv[])
{
         sem_t *sem1, *sem2;

         sem_unlink(SEM);
         sem1 = sem_open(SEM, O_CREAT | O_EXCL, 0600, 1);
         if (sem1 == SEM_FAILED) {
                 perror("sem_open (1)");
                 return -1;
         }

         printf("checkpoint/restart and press enter");
         getchar();

         sem2 = sem_open(SEM, 0);
         if (sem2 == SEM_FAILED) {
                 perror("sem_open (2)");
                 return -1;
         }

         {
                 int val;
                 if (sem_getvalue(sem2, &val)) {
                         perror("sem_getvalue");
                         return -1;
                 }

                 printf("value is %d\n", val);
         }

         if (sem1 != sem2) {
                 fprintf(stderr, "sem addresses differ %p <> %p\n", 
sem1, sem2);
                 return -1;
         }

         return 0;
}
