From: Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] new cgroup controller "fork"
Date: Thu, 3 Nov 2011 19:30:18 +0100
Message-ID: <20111103183018.GA28318@rabbit.intern.cm-ag>
References: <20111103162238.27609.11515.stgit@rabbit.intern.cm-ag>
	<20111103164302.GE8198@somewhere.redhat.com>
	<20111103171645.GA27887@rabbit.intern.cm-ag>
	<4EB2CEB2.7050800@parallels.com>
	<20111103174809.GA28108@rabbit.intern.cm-ag>
	<4EB2D451.4010607@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4EB2D451.4010607-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On 2011/11/03 18:50, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:
> That still seems to be up to admin. If no processes are removed from
> the cgroup or included in the cgroup, the only action/verb the
> counter
> is concerned about is to fork. Under this circumstance, both seem
> equivalent from my PoV.

I'm confused.  One of us misunderstands the whole thing.

Examples of both controllers:

task_counter: task.limit=2.  Let's say the only process in that group
forks, then you have two processes.  Forking is disallowed from now
on.  The child process exits, and there's only one left - which is
allowed to fork!  The group may bounce between 0 and 2 processes
forever.

cgroup_fork: fork.remaining=2.  Now let's say we have one thousand
processes in that group!  One of those forks (allowed).  And it forks
again (allowed).  And tries again - blocked because "fork.remaining"
has reached zero.  We have 1002 processes; when 1001 of those
processes exit, one remains, but it is still disallowed to fork,
because "fork.remaining" is still zero.  It will remaing zero until
somebody with write permissions raises it again.

Did I get it wrong?  To me, that is not look equivalent at all.

Max
