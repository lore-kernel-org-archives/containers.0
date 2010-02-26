From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Thu, 25 Feb 2010 17:26:41 -0800
Message-ID: <m1mxywyege.fsf__20836.5332139239$1267147665$gmane$org@fess.ebiederm.org>
References: <1263568754.23480.142.camel@bigi>
	<m13a0tf17t.fsf@fess.ebiederm.org> <1266875729.3673.12.camel@bigi>
	<m1wry46es9.fsf@fess.ebiederm.org> <1266931623.3973.643.camel@bigi>
	<m1iq9ocafv.fsf@fess.ebiederm.org> <1266934817.3973.654.camel@bigi>
	<m1r5obbu2w.fsf@fess.ebiederm.org> <1266966581.3973.675.camel@bigi>
	<m1pr3t2fvl.fsf_-_@fess.ebiederm.org>
	<20100226010915.GA20106@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100226010915.GA20106-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org> (Matt Helsley's
	message of "Thu\, 25 Feb 2010 17\:09\:15 -0800")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>, Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Netfilter Development Mailinglist <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

> On Thu, Feb 25, 2010 at 12:57:02PM -0800, Eric W. Biederman wrote:
>> 
>> Introduce two new system calls:
>> int nsfd(pid_t pid, unsigned long nstype);
>> int setns(unsigned long nstype, int fd);
>> 
>> These two new system calls address three specific problems that can
>> make namespaces hard to work with.
>> - Namespaces require a dedicated process to pin them in memory.
>> - It is not possible to use a namespace unless you are the
>>   child of the original creator.
>> - Namespaces don't have names that userspace can use to talk
>>   about them.
>> 
>> The nsfd() system call returns a file descriptor that can
>> be used to talk about a specific namespace, and to keep
>> the specified namespace alive.
>> 
>> The fd returned by nsfd() can be bind mounted as:
>> mount --bind /proc/self/fd/N /some/filesystem/path
>> to keep the namespace alive indefinitely as long as
>> it is mounted.
>> 
>> open works on the fd returned by nsfd() so another
>> process can get a hold of it and do interesting things.
>> 
>> Overall that allows for persistent naming of namespaces
>> according to userspace policy.
>> 
>> setns() allows changing the namespace of the current process
>> to a namespace that originates with nsfd().
>> 
>> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> ---
>> 
>> This is just my first pass at this, and not yet compiled tested.
>> I was pleasantly surprised at how easy all of this was to implement.
>
> <snip>
>
>> +SYSCALL_DEFINE2(setns, unsigned long, nstype, int, fd)
>> +{
>> +	struct file *file;
>> +
>> +	if (!capable(CAP_SYS_ADMIN))
>> +		return -EPERM;
>
> Is this check preliminary? In the future would we check against the
> owner of the target namespace too? Naturally that will require tagging
> each namespace with an owner but I thought that was already part of the
> plan...

We aren't modifying the namespace here so namespace owners are
irrelevant here.

We are modifying the process so we need to have CAP_SYS_ADMIN in the
processes credential/uid namespace.

Eric
