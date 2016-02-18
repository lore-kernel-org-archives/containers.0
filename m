From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: call_usermodehelper in containers
Date: Thu, 18 Feb 2016 14:45:03 -0600
Message-ID: <87r3g9ychc.fsf@x220.int.ebiederm.org>
References: <20131111071825.62da01d1@tlielax.poochiereds.net>
	<20131112004703.GB15377@kroah.com>
	<20131112061201.04cf25ab@tlielax.poochiereds.net>
	<528226EC.4050701@parallels.com>
	<20131112083043.0ab78e67@tlielax.poochiereds.net>
	<5285FA0A.2080802@parallels.com> <871u2incyo.fsf@xmission.com>
	<20131118172844.GA10005@redhat.com>
	<1455149857.2903.9.camel@themaw.net>
	<8737sq4teb.fsf@x220.int.ebiederm.org>
	<56C53DE3.1070108@jp.fujitsu.com>
	<1455777387.3188.24.camel@themaw.net>
	<1455781033.2908.5.camel@themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1455781033.2908.5.camel-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org> (Ian Kent's message of "Thu,
	18 Feb 2016 15:37:13 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ian Kent <raven-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org>
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Ian Kent <raven-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org> writes:

> On Thu, 2016-02-18 at 14:36 +0800, Ian Kent wrote:
>> On Thu, 2016-02-18 at 12:43 +0900, Kamezawa Hiroyuki wrote:
>> > On 2016/02/18 11:57, Eric W. Biederman wrote:
>> > > 
>> > > Ccing The containers list because a related discussion is
>> > > happening
>> > > there
>> > > and somehow this thread has never made it there.
>> > > 
>> > > Ian Kent <raven-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org> writes:
>> > > 
>> > > > On Mon, 2013-11-18 at 18:28 +0100, Oleg Nesterov wrote:
>> > > > > On 11/15, Eric W. Biederman wrote:
>> > > > > > 
>> > > > > > I don't understand that one.  Having a preforked thread with
>> > > > > > the
>> > > > > > proper
>> > > > > > environment that can act like kthreadd in terms of spawning
>> > > > > > user
>> > > > > > mode
>> > > > > > helpers works and is simple.
>> > > > 
>> > > > Forgive me replying to such an old thread but ...
>> > > > 
>> > > > After realizing workqueues can't be used to pre-create threads
>> > > > to
>> > > > run
>> > > > usermode helpers I've returned to look at this.
>> > > 
>> > > If someone can wind up with a good implementation I will be happy.
>> > > 
>> > > > > Can't we ask ->child_reaper to create the non-daemonized
>> > > > > kernel
>> > > > > thread
>> > > > > with the "right" ->nsproxy, ->fs, etc?
>> > > > 
>> > > > Eric, do you think this approach would be sufficient too?
>> > > > 
>> > > > Probably wouldn't be quite right for user namespaces but should
>> > > > provide
>> > > > what's needed for other cases?
>> > > > 
>> > > > It certainly has the advantage of not having to maintain a
>> > > > plague
>> > > > of
>> > > > processes waiting around to execute helpers.
>> > > 
>> > > That certainly sounds attractive.  Especially for the case of
>> > > everyone
>> > > who wants to set a core pattern in a container.
>> > > 
>> > > I am fuzzy on all of the details right now, but what I do remember
>> > > is
>> > > that in the kernel the user mode helper concepts when they
>> > > attempted
>> > > to
>> > > scrub a processes environment were quite error prone until we
>> > > managed to
>> > > get kthreadd(pid 2) on the scene which always had a clean
>> > > environment.
>> > > 
>> > > If we are going to tie this kind of thing to the pid namespace I
>> > > recommend simplying denying it if you are in a user namespace
>> > > without
>> > > an approrpriate pid namespace.  AKA simply not allowing thigns to
>> > > be
>> > > setup
>> > > if current->pid_ns->user_ns != current->user_ns.
>> > > 
>> > Can't be handled by simple capability like CAP_SYS_USERMODEHELPER ?

I wasn't talking about a capability I was talking about how to identify
where the user mode helper lives.

>> > User_ns check seems not to allow core-dump-cather in host will not
>> > work if user_ns is used.

The bottom line is all of this approaches non-sense if user namespaces
are not used.  If you just have a pid namespace or a mount namespace (or
perhaps both) and your fire off a new fangled user mode helper you get a
deep problem.  The user space process started to handle your core dump or
your nfs callback will have a full set of capabilities (because it is
still in the root user namespace).  With a full set of capabilities
and perhaps a little luck there is no containment.

The imperfect solution that currently exists for the core dump helper
is to provide enough information to the user space application that
it can query and find out the context of the core dumping application
and keep everything in that application sandbox if it so desires.
I expect something similar could be done for other user mode helper
style callbacks.

To make starting the user space application other than how we do today
needs a good argument that you are you can allow a lesser privileged
process set things up and that it can be exploited to gain privielge.

>> I don't think so but I'm not sure.
>> 
>> The approach I was talking about assumes the init process of the
>> caller
>> (say within a container, corresponding to ->child_reaper) is an
>> appropriate template for umh thread execution.
>> 
>> But I don't think that covers the case where unshare has created
>> different namespaces, like a mount namespace for example.
>> 
>> The current workqueue sub system can't be used to pre-create a thread
>> to
>> be used for umh execution so, either is needs changes or yet another
>> mechanism needs to be implemented.
>> 
>> For uses other than core dumping capturing a reference to the struct
>> pid
>> of the environment init process and using that as an execution
>> template
>> should be sufficient and takes care of environment existence problems
>> with some extra checks, not to mention eliminating the need for a
>> potentially huge number of kernel threads needing to be created to
>> provide execution templates.
>> 
>> Where to store this and how to access it when needed is another
>> problem.
>> 
>> Not sure a usermode helper capability is the right thing either as I
>> thought one important use of user namespaces was to allow unprivileged
>> users to perform operations they otherwise can't.
>> 
>> Maybe a CAP_SYS_USERNSCOREDUMP or similar would be sensible ....
>> 
>> Still an appropriate execution template would be needed and IIUC we
>> can't trust getting that from within a user created namespace
>> environment.
>
> Perhaps, if a struct cred could be captured at some appropriate time
> that could be used to cater for user namespaces.
>
> Eric, do you think that would be possible to do without allowing users
> to circumvent security?

The general problem with capturing less than a full process is that
we always mess it up and forget to capture something important.

In a lot of ways this is a very simpilar problem to setting up an at job
or a cron job.  You build a script you test it then you tell at to run
it at a certain time and it fails, because your working environment did
not include something important that was in your actuall environment.

Unfortunately in this case the failures we are talking about are
container escapes and privilege escalation, so we do need to tread
carefully.

We might be able to safely define the context as the context of the
currently running init process (Which we can identifiy with a struct
pid).  Justifying that looks a little trickier but doable.

After a mechanism is picked it simply becomes a case of making certain
your permission checks for starting something are in sync with your
mechanism.

Personally I am a fan of the don't be clever and capture a kernel thread
approach as it is very easy to see you what if any exploitation
opportunities there are.  The justifications for something more clever
is trickier.  Of course we do something that from this perspective would
be considered ``clever'' today with kthreadd and user mode helpers.

Eric
