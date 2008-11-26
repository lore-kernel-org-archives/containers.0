From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 0/2] In-kernel process restart
Date: Wed, 26 Nov 2008 15:44:24 +0400
Message-ID: <200811261444.26345.major__6627.06913794882$1227700013$gmane$org@openvz.org>
References: <1227541175-30301-1-git-send-email-major@openvz.org>
	<492C59DD.5070401@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <492C59DD.5070401-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tuesday 25 November 2008 23:02 Oren Laadan wrote:
> Andrey Mirkin wrote:
> > These patchset introduces OpenVZ kernel based restart procedure on top of
> > Oren's checkpoint/restart patchset v9.
> >
> > For restarting a set of processes one will need to call sys_restart()
> > once with new flag CR_CTX_RSTR_IN_KERNEL. All work will be done in kernel
> > in this case.
> >
> > Small changes to image format are required to make in-kernel process
> > creation more easy.
> >
> > Oren, please take a look on this patchset. I've tried to port OpenVZ
> > functionality on top of yours with minimal changes.
>
> Thanks, Andrey. The patch looks simple and good.
>
> Did you look at my (user-space) process creation code ?  specifically, it
> uses the task-pids array (that is saved during checkpoint) to figure out
> how many children a task has to spawn and their corresponding pids.

Yes, I've take a look on mktree tool. The algorithm of process creation is 
quite clear.

> Is there a particular reason that you chose not to use that data during
> restart ?  eventually, you'll need to add the rest of it, too, to the task
> data, like you did with the number of children in this patch.

Agree, I'll rework my patchset to use already existing data.

> Instead, since the data is available and the logic is available, we can
> have each new thread call do_restart_task(), and the container init
> should call do_restart_root().
>
> What do you think ?  I can go ahead and make the changes on top of your
> patch.

I'll take a closer look on these functions and maybe we can use them for 
created threads too. But from our experience during in-kernel process 
creation and restore it is needed to perfrorm some restore procedures when 
process is inactive. That is why I think we can't reuse all existing code for 
in-kernel restart. Anyway I'll check everything once again.

Andrey
