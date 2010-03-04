From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: selinux prevents msgrcv on restore message queues?
Date: Wed, 3 Mar 2010 21:05:25 -0600
Message-ID: <20100304030525.GA8875@us.ibm.com>
References: <1267565774.11828.15.camel@localhost.localdomain>
	<20100303004727.GA8272@us.ibm.com>
	<20100303011941.GA10429@us.ibm.com>
	<1267639445.11828.19.camel@localhost.localdomain>
	<20100303194910.GC12379@us.ibm.com>
	<1267653386.3559.9.camel@localhost.localdomain>
	<20100303234448.GA27869@us.ibm.com>
	<1267661777.3559.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1267661777.3559.11.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> On Wed, 2010-03-03 at 17:44 -0600, Serge E. Hallyn wrote:
> > Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> > > On Wed, 2010-03-03 at 13:49 -0600, Serge E. Hallyn wrote:
> > > > Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> > > > > On Tue, 2010-03-02 at 19:19 -0600, Serge E. Hallyn wrote:
> > > > > > Can you try the following patch?
> > > > > > 
> > > > > > Also, to actually restore the LSM labels you need to add -k to your
> > > > > > restart flags, but without the -k you should get a sane default
> > > > > > security label.
> > > > > 
> > > > > Thanks, the ipc/mq tests pass with this patch and restart -k.  Without
> > > > > -k the tests still fail in the same manner (msgrcv fails).  Is that the
> > > > > behavior you'd expect?
> > > > 
> > > > Not really - the test runs as unconfined_u right?
> > > 
> > > I added a ps -Z to test-mq.sh before thawing:
> > > 
> > > # PATH=/root/cr/user-cr.git:$PATH bash test-mq.sh 
> > > Using output dir ./cr_mq_6T8KIG6
> > > XXX Test 1: simple restart with SYSVIPC msq
> > > check-mq: no process killed
> > > ../common.sh: line 45:  5173 Killed                  ( sleep $1; kill -s USR1 $$ )
> > > LABEL                             PID TTY          TIME CMD
> > > unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 4358 pts/1 00:00:00 bash
> > > unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 5151 pts/1 00:00:00 bash
> > > unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 5172 pts/1 00:00:00 nsexec
> > > unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 5175 pts/1 00:00:00 sleep
> > > unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 5178 pts/1 00:00:00 check-
> > > unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 5183 pts/1 00:00:00 ps
> > > PASS
> > 
> > Can you try the following patch?
> > 
> > (this is on top of the last one - I'd sent)
> > 
> > The problem is that selinux does not assign a label to a msg_msg
> > until you do msgsnd.  So it may be best to special-case the
> > msg_msg object type and always have it restore the msgtype.  One
> > reason *NOT* to do that woudl be that the restarter might not have
> > msg_msg:restore permission...  But pls let me know if this patch
> > fixes your problem.
> 
> Yes, with both patches applied to ckpt-v19-dev
> (261322990a4ed23c8475c232423845f998dd4f89) the tests pass with and
> without the -k flag.

Cool.  The main alternative would be to rip the core of
ipc/msg.c:do_msgsnd() out and re-use that in place of the bulk of
restore_msg_contents_one().

Since a user can't specify a security context on an msg_msg (but
can on msgq) I think the end-result would be fine.  It's a lot more
work and may cause some other problems, but OTOH we'd be using one
code path for msgsnd and its restore which would be a win.

thanks,
-serge
