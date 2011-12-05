From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/1][V3] Handle reboot in a child pid namespace
Date: Mon, 5 Dec 2011 21:51:37 +0100
Message-ID: <20111205205137.GA7916@redhat.com>
References: <1323030290-22216-1-git-send-email-daniel.lezcano@free.fr>
	<20111204212756.GB16362@khazad-dum.debian.net>
	<4EDBFD67.1040009@free.fr> <4EDD2E5C.1050107@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4EDD2E5C.1050107-GANU6spQydw@public.gmane.org>
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
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Henrique de Moraes Holschuh <hmh-N3TV7GIv+o9fyO9Q7EP/yw@public.gmane.org>
List-Id: containers.vger.kernel.org

On 12/05, Daniel Lezcano wrote:
>
> On 12/05/2011 12:08 AM, Daniel Lezcano wrote:
> > On 12/04/2011 10:27 PM, Henrique de Moraes Holschuh wrote:
> >> On Sun, 04 Dec 2011, Daniel Lezcano wrote:
> >>>  * V3
> >>>    - removed lock and serialization of pid_ns_reboot
> >>>  * V2
> >>>    - added a lock for the pid namespace to prevent racy call
> >>>      to the 'reboot' syscall
> >>>    - Moved 'reboot' command assigned in zap_pid_ns_processes
> >>>      instead of wait_task_zombie
> >>>    - added tasklist lock around force_sig
> >>>    - added do_exit in pid_ns_reboot
> >>>    - used task_active_pid_ns instead of declaring a new variable in sys_reboot
> >>>    - moved code up before POWER_OFF changed to HALT in sys_reboot
>
> Oleg ? Are you fine with this patch ?

I already sent my reviwed-by ;)

Oleg.
