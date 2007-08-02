From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [PATCH 14/15] Destroy pid namespace on init's death
Date: Thu, 2 Aug 2007 20:08:51 +0400
Message-ID: <20070802160851.GA137@tv-sign.ru>
References: <46A8B663.9040206@openvz.org> <20070729104145.GC120@tv-sign.ru>
	<46ADD202.9030502@openvz.org> <20070730154639.GA127@tv-sign.ru>
	<20070731061917.GB17013@us.ibm.com>
	<20070731090721.GA110@tv-sign.ru>
	<20070801061616.GA5405@us.ibm.com>
	<1185984030.18414.234.camel@localhost>
	<20070801195123.GB196@tv-sign.ru> <46B197E3.3040309@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <46B197E3.3040309-3ImXcnM4P+0@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kirill Korotaev <dev-3ImXcnM4P+0@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On 08/02, Kirill Korotaev wrote:
>
> Oleg Nesterov wrote:
> > On 08/01, Dave Hansen wrote:
> > 
> >>>	If the main thread is exiting, but is not the last thread in the
> >>>	group, should we let it exit and let the next thread in the group
> >>>	the reaper of the pid ns ?
> >>
> >>Well, what happens with a multithreaded init today?
> > 
> > 
> > As it was already discussed, the current code is buggy, and should be
> > fixed.
> 
> I'm not that sure it MUST be fixed. There are no multi-threaded init's anywhere.
> Oleg, does it worth changing without reasons?

I don't know. But the kernel already tries to support multi-threaded init's.
Look at de_thread(), it could be simplified a bit (and we don't need tasklist
lock for zap_other_threads()) if we forbid them.

Still. A non-root user does clone(CLONE_PIDNS), then clone(CLONE_THREAD),
and sys_exit() from the main thread, then proceeds with fork()s. Now this
ns has the global init as a child reaper, and admin can't kill entire pid_ns
by killing its init. Worse, (see the reply to Sukadev' message), we should
not reset pid_ns->child_reaper before zap_pid_ns_processes(). In that case
->child_reaper points to the freed task when the last thread exits, this
means the non-root user can crash the kernel.

Or, some embedded system uses multi-threaded init, and the kernel panics
when the main thread exits.

Perhaps this is just a "quality of implementation" question. sys_exit()
from the main thread should be OK, why /sbin/init should be special?

That said, I personally do not think that multi-threaded init is terribly
useful.

Oleg.
