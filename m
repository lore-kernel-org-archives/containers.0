From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] netns: Delete virtual interfaces during namespace cleanup
Date: Tue, 07 Oct 2008 03:41:24 -0700
Message-ID: <m1ej2s7kmj.fsf@frodo.ebiederm.org>
References: <m18wt6v7eb.fsf@frodo.ebiederm.org> <48EB36FC.4000008@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48EB36FC.4000008-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> (Daniel Lezcano's message of "Tue,
	07 Oct 2008 12:16:28 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:

> I agree that will make the life easier for user space developer :)
>
> I have a few questions about this new behaviour.
>
> After discussing with Benjamin, this patch means an user can no longer manage a
> pool of virtual devices because they will be automatically destroyed when the
> namespace exits. I don't think it is a big concern, but just in case I am asking
> :)
>
> Another point, at present, the virtual devices go back to the initial network
> namespace when the namespace dies, and this behaviour is used to track the
> namespace life cycle. With this patch we have no way to know when the network
> namespace has exited. So we can have the last process exiting the network
> namespace, but the network namespace can stay alive (eg. some sockets still have
> buffer to send) ?

Depending on the network interfaces going back to the initial network namespace
is problematic in the long term because is breaks recursive containers.  I can't
see any behavior that does that as anything other than a bug.  Especially
as I already have production uses for recursive containers.

> AFAIR, Pavel told us about a patch extending the "wait" semantic and pass
> namespace options to wait for. Is that right Pavel ? Shouldn't we apply this
> path before deleting the virtual network devices ?

Tell you what.  I will post in a bit my patchset that makes /proc/net
it's own filesystem, that magically mounts on /proc/self/net.  It is a
long stupid story why I haven't posted it publicly.  At which point we have
complete visibility into when a network namespace exits and if we need to
be able to wait for it we can just implement a poll method on the root
directory.

That is simple and will work quite nicely in the long term, and gives
us a lot more visibility than a simple this namespace has exited bit.

Eric
