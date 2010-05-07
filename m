From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: pid namespace bug ?
Date: Fri, 7 May 2010 10:46:46 -0700
Message-ID: <20100507174646.GA3484@us.ibm.com>
References: <8739y6ikjr.fsf@tac.ki.iif.hu> <4BE178BC.4030201@free.fr>
	<87ljbyh1zv.fsf@tac.ki.iif.hu> <4BE18E01.3090103@free.fr>
	<87hbml2uf3.fsf@tac.ki.iif.hu> <4BE2A479.3060805@free.fr>
	<87ocgt12fb.fsf@tac.ki.iif.hu> <4BE322F1.5030500@free.fr>
	<20100506205233.GA23542@us.ibm.com> <87aasbsszn.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87aasbsszn.fsf-/U8DR9OPLL8grVaPS+uXcA@public.gmane.org>
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
| Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
| 
| > Daniel Lezcano [daniel.lezcano-GANU6spQydw@public.gmane.org] wrote:
| >
| >> Ferenc Wagner wrote:
| >>
| >>> That is, the jailed sleep process could be killed by SIGKILL only, even
| >>> though (according to strace) SIGTERM was delivered and it isn't handled
| >>> specially.  Why does this happen?
| >
| > Yes, SIGKILL is the only reliable way to terminate a container-init.
| > container-init needs to be immune to signals from within the container
| > but be open to receiving signals from parent container.  These requirements
| > complicate the implementation of allowing SIGINT/SIGTERM etc to
| > container-init from parent container.
| >
| > Besides a realistic container-init would block such signals, in which case
| > the complexity in the kernel could be viewed as unnecessary.
| 
| For full-system containers this is acceptable, but for running batch
| jobs this may prove problematic.  Is this behaviour documented somewhere?
| Is this specific to SIGINT/SIGTERM or are other signals affected as well?

Let me clarify - if the container-init has a handler for the signal, the
signal will be delivered. _Unhandled_ signals whose default is to terminate/
stop the process will be ignored by cinit unless the signal is SIGKILL/SIGSTOP
and sender is from parent container.

So to terminate a cinit from parent namespace you need SIGKILL. But other
signals will be delivered to cinit only if it has a handler.

| They are used for communication (job control) with the container running
| the job.  Such batch jobs are typically run under the supervision of
| some kind of "shepherd" process, which acts as "init" for the job
| environment; in my case it's the container-init.  It's the reaper or
| possible orphaned processes and the same time it communicates with the
| job scheduler (outside of the container) via signals.

So can this job scheduler install handlers for SIGINIT/SIGTERM/SIGQUIT ?

| So I'd consider
| at least some kernel complexity necessary for Linux containers becoming
| a viable tool for batch job segregation.

Yes, it is annoying that we can't CTRL-C a cinit running /bin/sleep, but
this behavior should not be too limiting to a more functional cinit.

I had submitted a verbose man page patch for kill(2) to describe these
semantics. but following para in the notes section of kill(2) does
allude to this behavior:

       The only signals that can be sent to process ID 1, the init
       process, are those for which init has explicitly installed signal
       handlers.  This is done to assure the system is not brought down
       accidentally.

See: 
	http://www.kernel.org/doc/man-pages/online/pages/man2/kill.2.html


Thanks,

Sukadev
