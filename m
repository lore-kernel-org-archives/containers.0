From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: [patch -mm 1/5] mqueue namespace : add struct mq_namespace
Date: Tue, 2 Oct 2007 09:30:20 -0700
Message-ID: <20071002163020.GA11207@us.ibm.com>
References: <20071002084608.149781400@fr.ibm.com>
	<20071002084906.477406083@fr.ibm.com> <47020A29.9060403@sw.ru>
	<470219BC.3050702@fr.ibm.com>
	<m1ir5plr3c.fsf@ebiederm.dsl.xmission.com>
	<470237C7.5000902@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <470237C7.5000902-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Cedric Le Goater [clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org] wrote:
| 
| >> however, we have an issue with the signal notification in __do_notify()
| >> we could kill a process in a different pid namespace.
| > 
| > So I took a quick look at the code as it is (before this patchset)
| > and the taking a reference to a socket and the taking a reference to
| > a struct pid should do the right thing when we intersect with other
| > namespaces.  It certainly does not look like a fundamental issue.

| 
| right. this should be covered when the pid namespace signal handling is 
| complete. kill_pid_info() should fail to send a signal to a sibling or 
| a parent pid namespace. 
| 
| I guess we should add a WARNING() to say that we're attempting to do so.

Just want to clarify how a signal is sent to a parent ns.

	A process P1 sets itself up to be notified when a message arrives
	on a queue.

	P1 then clones P2 with CLONE_NEWPID.

	P2 writes to the message queue and thus signals P1

What should the semantics be here ?

I guess it makes less sense for two namespaces to be dependent on the same
message queue this way.  But, if P2 writes to the queue, technically, the
queue is not empty, so P1 should be notified, no ? 

This sounds similar to the SIGIO signal case (F_SETOWN). My understanding
was that we would notify whoever was set to receive the notification, even
if they were in a parent ns (again my reasoning was its based on the state
of a file).

IOW,  should we change kill_pid_info() ?  If the caller can 'see' the
'struct pid' they can signal it. The expectation was that callers would
call find_vpid() and thus only see processes in their namespace.

| 
| > In practice the patchset as written  does conflict with the network
| > namespace work in the net-2.6.24 tree so some adjustments will need
| > to be made.
| 
| I think no more than fixing the CLONE flags in sched.h and the conflicts
| in nsproxy.c.  
| 
| Thanks !
| 
| C.
