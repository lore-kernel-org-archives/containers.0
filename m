From: Roland McGrath <roland@redhat.com>
Subject: Re: [PATCH 7/7][v8] SI_USER: Masquerade si_pid when crossing pid ns boundary
Date: Thu, 19 Feb 2009 15:51:59 -0800 (PST)
Message-ID: <20090219235159.6A542FC3BE@magilla.sf.frob.com>
References: <20090219030207.GA18783@us.ibm.com>
	<20090219030743.GG18990@us.ibm.com>
	<m1y6w21k6d.fsf@fess.ebiederm.org>
	<20090219185159.GA374@redhat.com>
	<m1fxiayss9.fsf@fess.ebiederm.org>
	<20090219223137.GA10378@redhat.com>
	<m1fxiaxbb5.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757477AbZBSXxT@vger.kernel.org>
In-Reply-To: Eric W. Biederman's message of  Thursday, 19 February 2009 15:21:34 -0800 <m1fxiaxbb5.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, Andrew Morton <akpm@osdl.org>, daniel@hozac.com, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

> Suppose I have 3 processes in a process group in three separate pid
> namespaces.
> 
> Looking from the init pid namespace I have:
>      pid pgrp ppid
>       10 10    1
>       11 10    10
>       12 10    11
> 
> Looking from the pid namespace of pid 11 I have:
>      pid pgrp ppid
>       0  0     0
>       1  0     0
>       2  0     1
> 
> Looking from the pid namespace of pid 12 I have:
>      pid pgrp ppid
>       0  0     0
>       0  0     0
>       1  0     0
> 
> So if the process with pid 12 in the initial pid namespace
> sends to process group 0.

There is no "process group 0".  0 means "the sender's pgrp".

One possibility is that perhaps what people really want the pid_ns to mean
is that "the sender's pgrp" in the view of the sender does not include any
processes outside its pid_ns scope.  That would be consistent with the
behavior of kill (kill_something_info) on -1; it's described as "all
processes", but in fact means "all processes within my pid_ns scope".

What I mean to describe there is changing kill_something_info, so that
e.g. killpg() inside the NS would affect only the NS init itself but e.g.
^Z (effectively an implicit killpg() that's always from the global NS)
would also go to that init's "mother" pgrp in the outer NS.

Another possibility is to decide that's just not worth having at all, and
CLONE_NEWNS should just implicitly reset pgrp to self.  That is simple.
But perhaps today someone has a script running a pid_ns-world whose init is
gracefully killed by ^C of the whole script and we wouldn't want to break
that if it is actually useful now.

> pid 10 should see si_pid 12.
> pid 11 should see si_pid 2.

We indeed have this problem if we think it's useful to continue to have
a concept of pgrp for the sub-init that can see outside its own NS.

> Neither should see si_pid 0, as from_ancestor_ns will not be true.

Perhaps replace from_ancestor_ns with struct pid_namespace *sender_ns?
(I don't know if there was already a can of worms with such an idea before.)
Then si_pid could be translated as appropriate for each recipient.
(Or perhaps just struct pid *sender and reset si_pid from that.)


Thanks,
Roland
