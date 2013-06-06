From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Requirements for CAP_SYS_ADMIN on setns() ?
Date: Thu, 06 Jun 2013 09:26:40 -0700
Message-ID: <87txlb8atb.fsf@xmission.com>
References: <20130606100149.GG30217@redhat.com> <20130606134802.GA2930@ac100>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130606134802.GA2930@ac100> (Serge Hallyn's message of "Thu, 6
	Jun 2013 08:48:03 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Daniel P. Berrange (berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
>> IIUC, currently, in order to be able to invoke setns() the calling
>> process is required to have CAP_SYS_ADMIN capability. Alternatively
>> with user namespaces, access is allowed if the process' effective
>> uid matches the uid of the owner of the namespace.
>> 
>> I have a scenario though that isn't dealt with by those rules. I have
>> a container that was spawned by uid == 0, and I have an unprivileged
>> process uid != 0 in the initial namespace that I wish to allow to enter
>> the namespaces associated with the container.
>> 
>> With the CAP_SYS_ADMIN rule on setns(), it seems that the unprivileged
>> process will need to execute some setuid binary in order to gain the
>> CAP_SYS_ADMIN capability required to call setns().
>> 
>> Of course you can't call setns() without first obtaining a file
>> descriptor corresponding to the /proc/$CONTAINERPID/ns/XXXX namespace
>> you wish to join. This appears to require elevated privileges too.
>> 
>> Is it not sufficient to rely on the permissions on the /proc/$PID/ns/XXX
>> file to control access to a namespace, and thus allow setns() without
>> a CAP_SYS_ADMIN check ?   ie setns() is basically useless unless you
>> already have sufficient privileges to get a file descriptor for the
>> namespace, so why does setns need an additional privilege check beyond
>> that done at time of open() on the proc file.
>> 
>> In my scenario this would allow for a privileged daemon to open the
>> /proc/$PID/ns/XXX file, and then pass the file descriptor back to the
>> unprivileged process using SCM_RIGHTS, which could then invoke setns().
>> This kind of privilege separation is perferrable to requiring the
>> unprivileged process to run some kind of setuid program to gain the
>> CAP_SYS_ADMIN capability.
>> 
>> Regards,
>> Daniel
>
> Hey Daniel,
>
> it's possible that as things settle down we can find ways to relax this,
> but note that this behavior was very specifically added by the commit
> below.  Very unfortunate that this is a feature regression over the
> CONFIG_USER_NS=n case :(

No this is not a feature regression over the CONFIG_USER_NS=n case.  The
patch was a setns bug fix. The situation Daniel wants to use is
exploitable.

Allowing an unprivileged user to call setns allows confusing suid root
processes.

It is completely possible for Daniels situation to work of the
unprivileged user calls setns first.  That is allowed.

Eric
