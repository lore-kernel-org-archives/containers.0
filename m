From: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
Subject: Re: [C/R ARM][PATCH 2/3] ARM: Add the eclone system call
Date: Wed, 24 Mar 2010 20:42:41 +0100
Message-ID: <7d08b87d1003241242k62cd125ex4b0fa0e24879fddb__19526.2823756368$1269459886$gmane$org@mail.gmail.com>
References: <1269219965-23923-1-git-send-email-christofferdall@christofferdall.dk>
	<1269219965-23923-3-git-send-email-christofferdall@christofferdall.dk>
	<20100323210616.GB19572@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100323210616.GB19572-l+eeeJia6m9vn6HldHNs0ANdhmdF6hFW@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, libc-ports <libc-ports-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Mar 23, 2010 at 10:06 PM, Russell King - ARM Linux
<linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org> wrote:
> On Sun, Mar 21, 2010 at 09:06:04PM -0400, Christoffer Dall wrote:
>> In addition to doing everything that clone() system call does, the
>> eclone() system call:
>
> Some comments...
>
>> +sys_eclone_wrapper:
>> + =A0 =A0 =A0 =A0 =A0 =A0 add =A0 =A0 ip, sp, #S_OFF
>> + =A0 =A0 =A0 =A0 =A0 =A0 str =A0 =A0 ip, [sp, #0]
>> + =A0 =A0 =A0 =A0 =A0 =A0 b =A0 =A0 =A0 sys_eclone
>> +ENDPROC(sys_eclone_wrapper)
>
> I'm curious why, if you want the entire set of registers, you don't just
> do:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0add =A0 =A0 r0, sp, #S_OFF
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0b =A0 =A0 =A0 sys_eclone
>
> and load the syscall arguments out of regs->ARM_foo. =A0This avoids the n=
eed
> for additional stores.
>

I simply copied the code from sys_clone. Do you prefer that I change
it in both places?

>> +
>> =A0sys_sigreturn_wrapper:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 add =A0 =A0 r0, sp, #S_OFF
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 b =A0 =A0 =A0 sys_sigreturn
>> diff --git a/arch/arm/kernel/sys_arm.c b/arch/arm/kernel/sys_arm.c
>> index ae4027b..fd8199d 100644
>> --- a/arch/arm/kernel/sys_arm.c
>> +++ b/arch/arm/kernel/sys_arm.c
>> @@ -183,6 +183,45 @@ asmlinkage int sys_clone(unsigned long clone_flags,=
 unsigned long newsp,
>> =A0 =A0 =A0 return do_fork(clone_flags, newsp, regs, 0, parent_tidptr, c=
hild_tidptr);
>> =A0}
>>
>> +asmlinkage int sys_eclone(unsigned flags_low, struct clone_args __user =
*uca,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int args_size, pid_t __use=
r *pids,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct pt_regs *regs)
>> +{
>> + =A0 =A0 int rc;
>> + =A0 =A0 struct clone_args kca;
>> + =A0 =A0 unsigned long flags;
>> + =A0 =A0 int __user *parent_tidp;
>> + =A0 =A0 int __user *child_tidp;
>> + =A0 =A0 unsigned long __user stack;
>
> __user on an integer type doesn't make any sense; integer types do not
> have address spaces.
>

thanks, will follow Sukadev's changes...

>> + =A0 =A0 unsigned long stack_size;
>> +
>> + =A0 =A0 rc =3D fetch_clone_args_from_user(uca, args_size, &kca);
>> + =A0 =A0 if (rc)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return rc;
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* TODO: Convert 'clone-flags' to 64-bits on all architectur=
es.
>> + =A0 =A0 =A0* TODO: When ->clone_flags_high is non-zero, copy it in to =
the
>> + =A0 =A0 =A0* =A0 =A0 =A0 higher word(s) of 'flags':
>> + =A0 =A0 =A0*
>> + =A0 =A0 =A0* =A0 =A0 =A0 =A0 =A0 =A0 =A0flags =3D (kca.clone_flags_hig=
h << 32) | flags_low;
>> + =A0 =A0 =A0*/
>> + =A0 =A0 flags =3D flags_low;
>> + =A0 =A0 parent_tidp =3D (int *)(unsigned long)kca.parent_tid_ptr;
>> + =A0 =A0 child_tidp =3D (int *)(unsigned long)kca.child_tid_ptr;
>
> This will produce sparse errors. =A0Is there a reason why 'clone_args'
> tid pointers aren't already pointers marked with __user ?
>
>> +
>> + =A0 =A0 stack_size =3D (unsigned long)kca.child_stack_size;
>
> Shouldn't this already be of integer type?
>
>> + =A0 =A0 if (stack_size)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
>
> So the stack must have a zero size? =A0Is this missing a '!' ?
>
>> +
>> + =A0 =A0 stack =3D (unsigned long)kca.child_stack;
>> + =A0 =A0 if (!stack)
>> + =A0 =A0 =A0 =A0 =A0 =A0 stack =3D regs->ARM_sp;
>> +
>> + =A0 =A0 return do_fork_with_pids(flags, stack, regs, stack_size, paren=
t_tidp,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 child_tidp, kc=
a.nr_pids, pids);
>
> Hmm, so let me get this syscall interface right. =A0We have some arguments
> passed in registers and others via a (variable sized?) structure. =A0It s=
eems
> really weird to have, eg, a pointer to the pids and the number of pids
> passed in two separate ways.
>
> The grouping between what's passed in registers and via this clone_args
> structure seems to be random. =A0Can it be sanitized?
>

Thanks for you feedback. I will let the people behind eclone deal with
the eclone specifics.
