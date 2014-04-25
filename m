From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: pid ns feature request
Date: Fri, 25 Apr 2014 12:37:29 -0700
Message-ID: <87ha5h42va.fsf@x220.int.ebiederm.org>
References: <CALCETrVSaboa0Y2v_sTbSz3xOxOZ-6jSq_D7DyQXMRB9VXJB8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CALCETrVSaboa0Y2v_sTbSz3xOxOZ-6jSq_D7DyQXMRB9VXJB8w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Andy Lutomirski's message of "Fri, 25 Apr 2014 08:58:15 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Serge E. Hallyn" <serge-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Id: containers.vger.kernel.org

Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:

> Unless I'm missing some trick, it's currently rather painful to mount
> a namespace /proc.  You have to actually be in the pid namespace to
> mount the correct /proc instance, and you can't unmount the old /proc
> until you've mounted the new /proc.  This means that you have to fork
> into the new pid namespace before you can finish setting it up.

Yes.  You have to be inside just about all namespaces before you can
finish setting them up.

I don't know the context in which needed to be inside the pid namespace
is a burden.

> Would it make sense to add a mount option to procfs to request a mount
> for pid_ns_for_children instead of task_active_pid_ns?

This is about the using setns and unshare?

Adding a proc amount option that takes a pid namespace file descriptor
would be the general solution, and might be worth implementing.

Getting a pid namespace file descriptors when there are no pids might be
a challenge.

Eric
