From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [PATCH 1/2] signals: kill(-1) should only signal processes in the
	same namespace
Date: Thu, 17 Jul 2008 21:32:54 +0400
Message-ID: <20080717173254.GA20948__14111.6685736508$1216315907$gmane$org@tv-sign.ru>
References: <487F5D6B.1090007@hozac.com> <487F5EDB.1000008@openvz.org>
	<43011.192.168.102.6.1216308280.squirrel@intranet>
	<487F6B2E.40101@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <487F6B2E.40101-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On 07/17, Pavel Emelyanov wrote:
>
> Daniel Hokka Zakrisson wrote:
> > 
> > The way zap_pid_ns_processes does it is worse, since it signals every
> > thread in the namespace rather than every thread group. So either we walk
> 
> It's questionable whether there are more "threads in a pid namespace" than
> "processes in a system".
> 
> E.g. on my notebook there are ~110 processes and ~150 threads. So having 
> this setup launched in 10 containers you'll have to walk 1100 tasks, while
> zap_pid_ns_processes only 150 ;)
> 
> Some real-life example with containers: on one of our servers with 10 
> containers serving as git repo, bulding system and some other stuff there 
> are ~200 process totally and ~20 threads in each container. See?
> 
> I tend to believe that walking threads in a container is cheaper then
> walking processes in a system...

kill_something_info() can't walk threads, think about the realtime signals.

Anyway, I think we should change kill_something_info(-1) to use rcu_read_lock()
instead of tasklist.

Oleg.
