From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: pid namespace bug ?
Date: Fri, 7 May 2010 19:11:41 -0700
Message-ID: <20100508021141.GA2947@us.ibm.com>
References: <87ljbyh1zv.fsf@tac.ki.iif.hu> <4BE18E01.3090103@free.fr>
	<87hbml2uf3.fsf@tac.ki.iif.hu> <4BE2A479.3060805@free.fr>
	<87ocgt12fb.fsf@tac.ki.iif.hu> <4BE322F1.5030500@free.fr>
	<20100506205233.GA23542@us.ibm.com> <87aasbsszn.fsf@tac.ki.iif.hu>
	<20100507174646.GA3484@us.ibm.com> <87d3x7mnzz.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87d3x7mnzz.fsf-/U8DR9OPLL8grVaPS+uXcA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ferenc Wagner <wferi-eEbw3PyuezQ@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Ferenc Wagner [wferi-eEbw3PyuezQ@public.gmane.org] wrote:
| > So to terminate a cinit from parent namespace you need SIGKILL. But other
| > signals will be delivered to cinit only if it has a handler.
| 
| Thanks for clarifying.  How does the above apply to signalfds?  Will
| those deliver the signals which would otherwise been ignored by cinit,
| having no handler installed?

Yes, if the signal is blocked, the signal will still be queued regardless
of sender's namespace[1]. In this case the blocked+pending signal will be
available via the signalfd() until the signal is unblocked.

If the signal is not blocked and the handler is either SIG_DFL or
SIG_IGN, the signal is not queued and will not be available via signalfd.

[1] Blocked signals have some special cases even without signalfd() - If
the signal is queued and later unblocked and the handler is SIG_DFL/SIG_IGN,
the signal will be silently discarded (regardless of sender's namespace).

If the user specifies a handler before unblocking the signal, the signal
will be delivered (regardless of sender's namespace)

| 
| >| They are used for communication (job control) with the container running
| >| the job.  Such batch jobs are typically run under the supervision of
| >| some kind of "shepherd" process, which acts as "init" for the job
| >| environment; in my case it's the container-init.  It's the reaper or
| >| possible orphaned processes and the same time it communicates with the
| >| job scheduler (outside of the container) via signals.
| >
| > So can this job scheduler install handlers for SIGINT/SIGTERM/SIGQUIT ?
| 
| The scheduler is outside of the container, so I suppose you mean the
| shepherd process, which is the container init.  Yes, it already has
| handlers for each signal it's interested in, so according to the above,
| everything should work as expected (once we get the signals forwarded to
| it).

Yes, I meant the shepherd process.

| 
| >| So I'd consider at least some kernel complexity necessary for Linux
| >| containers becoming a viable tool for batch job segregation.
| >
| > Yes, it is annoying that we can't CTRL-C a cinit running /bin/sleep, but
| > this behavior should not be too limiting to a more functional cinit.
| 
| Indeed.  I misunderstood you on first read.
| 
| > I had submitted a verbose man page patch for kill(2) to describe these
| > semantics. but following para in the notes section of kill(2) does
| > allude to this behavior:
| >
| >        The only signals that can be sent to process ID 1, the init
| >        process, are those for which init has explicitly installed signal
| >        handlers.  This is done to assure the system is not brought down
| >        accidentally.
| 
| I even read that paragraph recently.  I didn't think it would apply,
| though, as I was trying to kill cinit in the outer namespace, where it
| had a generic PID, not 1.  Your effort to expand the man page of kill(2)
| is most appreciated, I hope it will land soon!

I do see now that it is ambigous and incomplete - the special handling applies
to a process if it has a pid == 1 in *any* namespace.

Second it does not mention that SIGKILL/SIGSTOP are the only reliable signals
to a container-init from parent namespace.

Will submit a patch for the man page change.

Thanks,

Sukadev
