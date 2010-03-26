From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Testing lxc 0.6.5 in Fedora 13
Date: Fri, 26 Mar 2010 14:56:22 +0100
Message-ID: <20100326135622.GC15790__43673.7969321713$1269611917$gmane$org@redhat.com>
References: <20100321195044.GA23757@megiteam.pl>
	<20100323212834.GH20796@count0.beaverton.ibm.com>
	<20100325213356.GB20541@megiteam.pl>
	<20100326111131.GA8604@redhat.com>
	<20100326115357.GA3345@count0.beaverton.ibm.com>
	<20100326124522.GD17113@megiteam.pl>
	<20100326125459.GD3345@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100326125459.GD3345-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 03/26, Matt Helsley wrote:
>
> That said there are
> plenty of #ifdefs in strace and patching it to use GETEVENTMSG is quite
> a small patch.

Not really, unless I missed something. See my another email, strace
doesn't even use the notification from do_fork(), not only it doesn't
read ->ptrace_message.

> However, as I said, that still doesn't "fix" strace so that it can
> be used to trace tasks in child pid namespaces.

Yes. Looks like, the necessary change in kernel is simple (and btw,
it is well known fact the reported pid is not ns-friendly). What
should be really fixed is strace/etc.

> Especially when the
> traced tasks are more than one namepace deeper. :(

Hmm... I guess, you mean setns() idea? Otherwise, I _think_ that the
deeper namepaces are fine wrt pid_nr.

> I don't think the kernel provides special out-of-band methods for fetching
> pids related to traced tasks except during fork and clone. Not wait*().

Could you clarify? I think wait*() is already namespace-friendly?

Oleg.
