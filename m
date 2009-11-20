From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH] clone_with_pids()^w eclone() for x86_64
Date: Thu, 19 Nov 2009 23:29:14 -0800
Message-ID: <20091120072914.GA4291@us.ibm.com>
References: <20091119004838.AD278DE0@kernel>
	<20091119095844.GP4379@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091119095844.GP4379-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Louis Rilling [Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org] wrote:
| > 
| >         __asm__ __volatile__(
| >                  "syscall\n\t"  /* Linux/x86_64 system call */
| >                  "testq %0,%0\n\t"      /* check return value */
| >                  "jne 1f\n\t"           /* jump if parent */
| >                  "popq %%rbx\n\t"       /* get subthread function */
| >                  "call *%%rbx\n\t"      /* start subthread function */
| >                  "movq %2,%0\n\t"
| >                  "syscall\n"            /* exit system call: exit subthread */
| >                  "1:\n\t"
| >                  "popq %%rbp\t"         /* restore parent's ebp */
| >                 :"=a" (retval)
| >                 :"0" (__NR_clone3), "i" (__NR_exit)
| >                 :"ebx", "ecx", "edx"
| >                 );
| 
| 2. You should probably not separate this into two asm statements. In particular,
|    the compiler has no way to know that r10 should be preserved between the two
|    statements, and may be confused by the change of rsp.
| 

Don't know enough asm, but can we leave them as two asm statements if we
add all registers with parameters to the clobbered list ? The i386 code that
Dave is referring to adds 3 (%ebx, %ecx, %edx) to the clobbered list, but is
the missing the fourth, %edi.

Sukadev

| 3. r10 and r11 should be listed as clobbered.
| 
| 4. I fail to see the magic that puts the subthread function pointer in the
|    stack.
| 
| 5. Maybe rdi should contain the subthread argument before calling the subthread?
| 
| 6. rdi, rsi, rdx, rcx, r8 and r9 should be added to the clobber list because of
|    the call to the subthread function.
| 
| 7. rsi could be used in place of rbx to hold the function pointer, which would
|    allow you to remove ebx from the clobber list.
| 
| 8. I don't see why rbp should be saved. The ABI says it must be saved by the
|    callee.
| 
| 9. Before calling exit(), maybe put some exit code in rdi?
| 
| > 
| >         if (retval < 0) {
| >                 errno = -retval;
| >                 retval = -1;
| >         }
| >         return retval;
| > }
| 
| Thanks,
| 
| Louis
| 
| [...]
| 
| -- 
| Dr Louis Rilling			Kerlabs
| Skype: louis.rilling			Batiment Germanium
| Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
| http://www.kerlabs.com/			35700 Rennes



| _______________________________________________
| Containers mailing list
| Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
| https://lists.linux-foundation.org/mailman/listinfo/containers
