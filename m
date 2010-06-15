From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH][cr][nit]: eclone() - Remove extra __user and add a comment
Date: Tue, 15 Jun 2010 15:43:53 -0700
Message-ID: <20100615224353.GA4985@us.ibm.com>
References: <20100504020439.GA5098@us.ibm.com>
	<4C16EBB1.7000806@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4C16EBB1.7000806-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org, linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org
List-Id: containers.vger.kernel.org

Oh, well, Albert pointed out we could make all architectures specify
stack as base and offset so applications won't need #ifdefs. I am
planning on resending the eclone patchset with that change. So
the following change is not needed now.

Sukadev

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
| 
| Applied in ckpt-v22-dev (will be pushed soon)
| 
| Thanks,
| 
| Oren.
| 
| On 05/03/2010 10:04 PM, Sukadev Bhattiprolu wrote:
| > 
| > Sorry, I thought I had sent this minor patch out earlier, but I just
| > realized I had not.
| > ---
| > 
| > From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
| > Date: Mon, 3 May 2010 11:38:16 -0700
| > Subject: [PATCH 1/1] eclone(): Remove extra __user and add a comment
| > 
| > As pointed out by Russel King, '__user' does not make sense on an integer
| > type. Remove it. Also add a comment on why we want 'stack_size' to be 0
| > on x86 and s390.
| > 
| > Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
| > ---
| >  arch/s390/kernel/process.c |    5 ++++-
| >  arch/x86/kernel/process.c  |    5 ++++-
| >  2 files changed, 8 insertions(+), 2 deletions(-)
| > 
| > diff --git a/arch/s390/kernel/process.c b/arch/s390/kernel/process.c
| > index efc7e8a..b00ffad 100644
| > --- a/arch/s390/kernel/process.c
| > +++ b/arch/s390/kernel/process.c
| > @@ -276,7 +276,7 @@ SYSCALL_DEFINE4(eclone, unsigned int, flags_low, struct clone_args __user *,
| >  	int __user *parent_tid_ptr;
| >  	int __user *child_tid_ptr;
| >  	unsigned long flags;
| > -	unsigned long __user child_stack;
| > +	unsigned long child_stack;
| >  	unsigned long stack_size;
| >  
| >  	rc = fetch_clone_args_from_user(uca, args_size, &kca);
| > @@ -288,6 +288,9 @@ SYSCALL_DEFINE4(eclone, unsigned int, flags_low, struct clone_args __user *,
| >  	child_tid_ptr =  (int __user *) kca.child_tid_ptr;
| >  
| >  	stack_size = (unsigned long) kca.child_stack_size;
| > +	/*
| > +	 * s390 does not need/use the stack_size. Ensure it is unused.
| > +	 */
| >  	if (stack_size)
| >  		return -EINVAL;
| >  
| > diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
| > index 5abad20..8b1699a 100644
| > --- a/arch/x86/kernel/process.c
| > +++ b/arch/x86/kernel/process.c
| > @@ -268,7 +268,7 @@ sys_eclone(unsigned flags_low, struct clone_args __user *uca,
| >  	unsigned long flags;
| >  	int __user *parent_tidp;
| >  	int __user *child_tidp;
| > -	unsigned long __user stack;
| > +	unsigned long stack;
| >  	unsigned long stack_size;
| >  
| >  	rc = fetch_clone_args_from_user(uca, args_size, &kca);
| > @@ -286,6 +286,9 @@ sys_eclone(unsigned flags_low, struct clone_args __user *uca,
| >  	parent_tidp = (int *)(unsigned long)kca.parent_tid_ptr;
| >  	child_tidp = (int *)(unsigned long)kca.child_tid_ptr;
| >  
| > +	/*
| > +	 * x86 does not need/use the stack_size. Ensure it is unused.
| > +	 */
| >  	stack_size = (unsigned long)kca.child_stack_size;
| >  	if (stack_size)
| >  		return -EINVAL;
| > 
| > 
