From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/1][V3] Handle reboot in a child pid namespace
Date: Mon, 5 Dec 2011 21:50:35 +0100
Message-ID: <20111205205035.GB7422@redhat.com>
References: <1323030290-22216-1-git-send-email-daniel.lezcano@free.fr>
	<20111204212756.GB16362@khazad-dum.debian.net>
	<4EDBFD67.1040009@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4EDBFD67.1040009-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Henrique de Moraes Holschuh <hmh-N3TV7GIv+o9fyO9Q7EP/yw@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On 12/05, Daniel Lezcano wrote:
>
> On 12/04/2011 10:27 PM, Henrique de Moraes Holschuh wrote:
> > On Sun, 04 Dec 2011, Daniel Lezcano wrote:
> > Daniel, can you address Miquel's concern?  Is it a valid concern, or
> > not?  I assume CAP_REBOOT functionality is still in place inside the
> > container, so it really does look like userspace would need to know
> > whether it should drop CAP_REBOOT or not, in order to automatically use
> > the new feature.
>
> Hmm, I missed its email.

Me too... so I am not sure I really understand the problem.

> I would like to address this in a separate patch in order to discuss the
> best way to do that.

Agreed.

> Adding a fake 'reboot' parameter returning EINVAL
> or 0 seems a good solution to detect at runtime if the shutdown is
> correctly supported inside a container.

Or, perhaps, we can implement sys_reboot(REBOOT_SHOULD_NOT_WORK),
sub-init can call it to disable the shutdown ?

This needs the trivial modifications in zap_pid_ns_processes()
and reboot_pid_ns().

Oleg.
