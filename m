From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: [PATCH 14/15] Destroy pid namespace on init's death
Date: Thu, 2 Aug 2007 11:36:08 -0700
Message-ID: <20070802183608.GB15332@us.ibm.com>
References: <46ADD202.9030502@openvz.org> <20070730154639.GA127@tv-sign.ru>
	<20070731061917.GB17013@us.ibm.com>
	<20070731090721.GA110@tv-sign.ru>
	<20070801061616.GA5405@us.ibm.com>
	<20070801194811.GA196@tv-sign.ru> <20070802072958.GA729@us.ibm.com>
	<20070802154018.GA93@tv-sign.ru> <20070802172033.GA8011@us.ibm.com>
	<20070802173128.GA2616@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070802173128.GA2616-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Oleg Nesterov [oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org] wrote:
| On 08/02, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
| >
| > Oleg Nesterov [oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org] wrote:
| > | > | > | > +		if (pid_ns != &init_pid_ns) {
| > | > | > | > +			zap_pid_ns_processes(pid_ns);
| > | > | > | > +			pid_ns->child_reaper = init_pid_ns.child_reaper;
| > | 
| > | OOPS. I didn't notice this before, but this is not right too (regardless
| > | of multi-threaded init problems).
| > | 
| > | We should not "reset" ->child_reaper here, we may have exiting tasks
| > | which will re-parent their ->children to global init.
| > | 
| > | No, we are still /sbin/init of this namespace even if we are exiting,
| > | ->child_reaper should point to us, at least until zap_pid_ns_processes()
| > | completes.
| > 
| > Yes, we are resetting the reaper _after_ zap_pid_ns_processes() completes
| > right ? (all other processes in the namespace must have exited).
| 
| OOPS again :) Can't understand how I managed to misread this code.
| 
| This means that we should take care about multi-thread init exit,
| otherwise the non-root user can crash the kernel.
| 
| >From reply to Kirill's message:
| 
| 	> Still. A non-root user does clone(CLONE_PIDNS), then clone(CLONE_THREAD),

Agree we should fix the crash. But we need CAP_SYS_ADMIN to clone
pid or other namespaces - this is enforced in copy_namespaces() and
unshare_nsproxy_namespaces()

Suka
