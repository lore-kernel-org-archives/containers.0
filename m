From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 3/6] userns: Recommend use of memory control groups.
Date: Mon, 28 Jan 2013 00:14:30 -0800
Message-ID: <87k3qxu3kp.fsf__28078.7370903001$1359360902$gmane$org@xmission.com>
References: <87ehh8it9s.fsf@xmission.com> <87txq4hedl.fsf@xmission.com>
	<51062AB5.9060203@parallels.com> <51062DA8.1060804@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <51062DA8.1060804-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> (Lord Glauber Costa of Sealand's
	message of "Mon, 28 Jan 2013 11:50:00 +0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Lord Glauber Costa of Sealand <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Lord Glauber Costa of Sealand <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:

> I just saw in a later patch of yours that your concern here seems not
> limited to backed ram by tmpfs, but with things like the internal
> structures for userns , to avoid patterns in the form: 'for (;;)
> unshare(...)'
>
> Humm, it does seem sensible. The kernel memory controller aims to
> prevent exactly things like that. But they all exist already before
> userns: there are destructive patterns like that with sockets, dentries,
> processes, and pretty much every other resource in the kernel. So
> Although the recommendation per-se makes sense, I am wondering if it is
> worth it to mention anything in the user_ns config?

The config might be overkill.  However I have already gotten bug reports
about there being no limits.

So someone needs to stop and connect the dots and say: "If you care this
is what you can do."  Especially since the familiar old limits that can
kind of sort of prevent memory abuses are not generally available with
user namespaces.

Eric
