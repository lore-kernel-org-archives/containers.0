From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH RFC] audit: provide namespace information in user
	originated records
Date: Tue, 19 Mar 2013 17:00:50 -0700
Message-ID: <874ng7gcst.fsf@xmission.com>
References: <1363619405-6419-1-git-send-email-arozansk@redhat.com>
	<877gl48iaz.fsf@xmission.com> <20130319122408.GC20187@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130319122408.GC20187-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Aristeu Rozanski's message
	of "Tue, 19 Mar 2013 08:24:08 -0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Aristeu Rozanski <arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Aristeu Rozanski <arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On Mon, Mar 18, 2013 at 03:16:52PM -0700, Eric W. Biederman wrote:
>> Adding the containers list so folks with container expertise can see
>> what is being proposed.
>> 
>> Aristeu Rozanski <arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
>> 
>> > This patchset introduces a new audit record to follow all USER records which
>> > provides namespace information of the process. The idea is to allow processes
>> > in containers to create records in the host system while providing means to be
>> > filtered out.
>> 
>> It looks like this mechanism makes it easy for an unprivileged program
>> to spam and overwhelm the audit log.
>> 
>> > For each new namespace, a unique procfs inode number is allocated and this
>> > number has been used by userspace to determine which processes belong to the
>> > same namespace. These numbers are used in the new audit record.
>> >
>> > Applications such as libvirt-sandbox and lxc can then report the same numbers
>> > when a container is created and destroyed allowing to map records to a certain
>> > container. Maybe the next step would be having a record for whenever a new
>> > namespace is created?
>> >
>> > First 6 patches are needed in order to get each namespace's inode number.
>> 
>> Grumble the existing methods can be used you don't have to introduce a
>> whole new set of methods.  Grumble.  Besides the bug of assuming that
>> the inodes now and forever will be the same across all instances of
>> proc.
>
> the existing methods are for procfs use and I didn't want to abuse it.
> like I said the other email, the fact that it's not a reliable way to
> indefinitely describe a namespace due to multiple procfs instances or
> migration, the whole idea is flawed.

It is always possible to pick the instance of /proc connected to the
initial pid namespace.  And there is a device number you can use to say
that.

Usually designs that need global identifiers for namespaces suffer from
the need for a namespace of namespaces (which we sort of have in /proc),
and I push back by default to get people to think if what they are
trying to do really makes sense.

>> > Patch 7 properly defines the new record that is related to the USER
>> > record
>> 
>> Not agmenting the current user records seems a little odd to me.
>> 
>> You also continue in this my current policy of not allowing any audit
>> records in the container itself, so I a don't quite know what the point
>> of all of this is.
>
> your current policy wasn't known to me and
> 	/* Only support the initial namespaces for now. */
> sounds like something that didn't happen for other reasons

The reasons were simply that to my knowledge no one has thought through
how audit records and namespaces make sense to interact.

My expectation would be that an extention of audit records would be
logged on a per container basis.  But I don't have any motivating
examples.

>> > Patch 8 allows USER records to be generated from different namespaces
>> 
>> Which essentially allows any user to create any USER record they want
>> whenever they want.
>> 
>> > Here's an example of output:
>> > type=CRED_DISP msg=audit(1363528861.403:311): pid=20016 uid=0 auid=0 ses=45 subj=system_u:system_r:crond_t:s0-s0:c0.c1023 msg='op=PAM:setcred acct="root" exe="/usr/sbin/crond" hostname=? addr=? terminal=cron res=success'
>> 
>> Ok.  This seems totally bizarre.  You are running a container with a
>> user namespace with some uid mapped to uid 0?
>
> on the notes section:
> 	- while the last patch allows a new userns to send audit records, I haven't
> 	  look yet on making sure it has proper capabilities so regular users'
> 	  containers can create records
>
> so I haven't tried it with userns. It's a RFC. 

I though you would have taken the time to run it at least once, or to
perhaps have manually edited your example to see how things would fit
together.

> That's a regular record
> to show the related records, using initial namespaces. like I stated in
> the email, I wasn't sure how I'd handle capabilities but the idea would be
> to allow containers to log to the system's auditd. since inode numbers
> aren't more reliable for more than a moment, I guess there's no other
> way than having an audit namespace and run an audit daemon inside the
> container (and communicate over the network like an individual host).

What was really missing from your RFC is a motivating example.  I sort
of see that in your paragraph above but it isn't clear to me.

What is lost by not allowing USER audit records from processes in
containers?  What is gained by implementing user process to have them?
And of course what are your thoughts on preventing unprivileged users
overwhelming the audit subsystem.

My minimal experience with the audit subsystem roughly feels like hardly
anyone really cares.  Although I may be wrong.

Eric
