From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: selinux prevents msgrcv on restore message queues?
Date: Thu, 4 Mar 2010 09:05:57 -0600
Message-ID: <20100304150557.GA25017@hallyn.com>
References: <1267565774.11828.15.camel@localhost.localdomain>
 <20100303004727.GA8272@us.ibm.com>
 <20100303011941.GA10429@us.ibm.com>
 <1267639445.11828.19.camel@localhost.localdomain>
 <20100303194910.GC12379@us.ibm.com>
 <1267653386.3559.9.camel@localhost.localdomain>
 <20100303234448.GA27869@us.ibm.com>
 <1267661777.3559.11.camel@localhost.localdomain>
 <20100304030525.GA8875@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100304030525.GA8875@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Nathan Lynch <ntl@pobox.com>, Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>
List-Id: containers.vger.kernel.org

[
cc:ing SELinux and LSM lists bc this somewhat changes the
ipc msg_msg restore behavior - which was previously broken,
and now is hopefully merely dubious.  The original email
in this thread can be seen at
https://lists.linux-foundation.org/pipermail/containers/2010-March/023266.html
]

Quoting Serge E. Hallyn (serue@us.ibm.com):
> Quoting Nathan Lynch (ntl@pobox.com):
> > On Wed, 2010-03-03 at 17:44 -0600, Serge E. Hallyn wrote:
> > > Quoting Nathan Lynch (ntl@pobox.com):
> > > > On Wed, 2010-03-03 at 13:49 -0600, Serge E. Hallyn wrote:
> > > > > Quoting Nathan Lynch (ntl@pobox.com):
> > > > > > On Tue, 2010-03-02 at 19:19 -0600, Serge E. Hallyn wrote:
> > > > > > > Can you try the following patch?
> > > > > > > 
> > > > > > > Also, to actually restore the LSM labels you need to add -k to your
> > > > > > > restart flags, but without the -k you should get a sane default
> > > > > > > security label.
> > > > > > 
> > > > > > Thanks, the ipc/mq tests pass with this patch and restart -k.  Without
> > > > > > -k the tests still fail in the same manner (msgrcv fails).  Is that the
> > > > > > behavior you'd expect?
> > > > > 
> > > > > Not really - the test runs as unconfined_u right?
> > > > 
> > > > I added a ps -Z to test-mq.sh before thawing:
> > > > 
> > > > # PATH=/root/cr/user-cr.git:$PATH bash test-mq.sh 
> > > > Using output dir ./cr_mq_6T8KIG6
> > > > XXX Test 1: simple restart with SYSVIPC msq
> > > > check-mq: no process killed
> > > > ../common.sh: line 45:  5173 Killed                  ( sleep $1; kill -s USR1 $$ )
> > > > LABEL                             PID TTY          TIME CMD
> > > > unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 4358 pts/1 00:00:00 bash
> > > > unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 5151 pts/1 00:00:00 bash
> > > > unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 5172 pts/1 00:00:00 nsexec
> > > > unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 5175 pts/1 00:00:00 sleep
> > > > unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 5178 pts/1 00:00:00 check-
> > > > unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 5183 pts/1 00:00:00 ps
> > > > PASS
> > > 
> > > Can you try the following patch?
> > > 
> > > (this is on top of the last one - I'd sent)
> > > 
> > > The problem is that selinux does not assign a label to a msg_msg
> > > until you do msgsnd.  So it may be best to special-case the
> > > msg_msg object type and always have it restore the msgtype.  One
> > > reason *NOT* to do that woudl be that the restarter might not have
> > > msg_msg:restore permission...  But pls let me know if this patch
> > > fixes your problem.
> > 
> > Yes, with both patches applied to ckpt-v19-dev
> > (261322990a4ed23c8475c232423845f998dd4f89) the tests pass with and
> > without the -k flag.
> 
> Cool.  The main alternative would be to rip the core of
> ipc/msg.c:do_msgsnd() out and re-use that in place of the bulk of
> restore_msg_contents_one().
> 
> Since a user can't specify a security context on an msg_msg (but
> can on msgq) I think the end-result would be fine.  It's a lot more

Except it wouldn't be fine, because SELinux chooses a label for the
new msg_msg based on both the task's and the queue's contexts.  And
we have no idea whether the task's context has changed since the
msg was sent.

Now, it seems like letting restart choose the labels may promote
bypassing of assured pipelines, but then you can't guarantee original
security guarantees anyway unless you have an assured pipeline
from checkpoint->restart, whether enforced through SELinux
policy or through TPM.  And if you have that, then the msg_msg
context can't be surruptitiously changed before restart.

So there is no ideal solution for SELinux, but always doing label
restore for msg_msg, with the requirement that the restarter be
allowed msg_msg:restore permission to the restored msg_msg type,
seems the best answer.

thanks,
-serge
