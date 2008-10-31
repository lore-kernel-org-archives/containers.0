From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [BIG RFC] Filesystem-based checkpoint
Date: Fri, 31 Oct 2008 13:51:53 -0700
Message-ID: <m1r65wpjx2.fsf@frodo.ebiederm.org>
References: <1225219047.12673.182.camel@nimitz>
	<m163n9y7yb.fsf@frodo.ebiederm.org>
	<1225411757.12673.383.camel@nimitz>
	<m1k5bpwj8j.fsf@frodo.ebiederm.org>
	<1225462902.12673.398.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1225462902.12673.398.camel@nimitz> (Dave Hansen's message of
	"Fri, 31 Oct 2008 07:21:42 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:

>> I was thinking about restore.  Creating objects with a certain id can
>> easily be a security risk if you are not creating the namespace those
>> objects live in at the same time.  There is currently the downside
>> that we can't create namespaces as unprivileged users ( The
>> implementation of suid is so annoying). But the general concept still
>> applies, and if we ever get the uid namespace correct we will be able
>> to create namespaces as unprivileged users.
>
> Eric, you were saying that my interface had way too many "dangerous
> syscalls".  How does this relate to user namespaces and creating objects
> with particular ids?  Surely if the true problem with my suggested
> approach has to do with creating empty namespaces, the same problem
> exists with the sys_checkpoint() approach.

Ok. Some concrete examples to put this in context.

First the class of problem I am talking about is the classic unix temp file
security hole.

A specific example is fork_and_set_child_pid();

Suppose there is a important system daemon that dies and it's pid is 23.
It dies and doesn't delete it's pid file.
A malicious user notices this and does for_and_set_child_pid(23);
Later someone checks to see if the important system daemon is running,
sees a process at pid 23, and so does not restart it.
A DOS attack.

In a sys_restore() scenario at the very start you can check to make
certain that the reference count for the namespaces is 1 and that they
are empty.  Which means there is no chance of confusing user space.

With fork_and_set_child_pid() what is a simple cheap one time check
becomes an expensive painful one, if you can even implement it at all.

The difference is that with a bunch of small pieces you loose atomicity. 

Eric
