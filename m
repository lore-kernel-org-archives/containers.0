From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 1/1] freezer: change ptrace_stop/do_signal_stop to use
	freezable_schedule()
Date: Fri, 26 Oct 2012 14:29:09 -0700
Message-ID: <20121026212909.GW11442__26347.2952101894$1351286969$gmane$org@htj.dyndns.org>
References: <20121023153919.GA16201@redhat.com>
	<20121026180149.GA22421@redhat.com>
	<2566006.UzAQbpOjNQ@vostro.rjw.lan>
	<2718983.vORnrfWdbE@vostro.rjw.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <2718983.vORnrfWdbE-sKB8Sp2ER+y1GS7QM15AGw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Fri, Oct 26, 2012 at 11:29:56PM +0200, Rafael J. Wysocki wrote:
> Actually, what tree is it supposed to apply to?
> 
> The change in kernel/cgroup_freezer.c doesn't look like anything in
> the current Linus' tree to me.

Ooh, right.  This depends on the earlier cgroup_freezer changes.
Sorry about the confusion.  I'll apply it to the following branch (the
same one used for the previous cgroup_freezer updates).

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git cgroup-freezer

Thanks.

-- 
tejun
