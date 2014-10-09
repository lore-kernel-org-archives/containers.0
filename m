From: "Chen, Hanxiao" <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: RE: [PATCH RFC] setns: return 0 directly if try to reassociate with
	current namespace
Date: Thu, 9 Oct 2014 04:14:23 +0000
Message-ID: <5871495633F38949900D2BF2DC04883E5E0FAC@G08CNEXMBPEKD02.g08.fujitsu.local>
References: <1412759587-21320-1-git-send-email-chenhanxiao@cn.fujitsu.com>
	<20141008145740.GD30569@ubuntumail>
	<87r3yih2e2.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87r3yih2e2.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
Content-Language: zh-CN
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org



> -----Original Message-----
> From: Eric W. Biederman [mailto:ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org]
> Sent: Thursday, October 09, 2014 1:56 AM
> 
> Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Quoting Chen Hanxiao (chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
> >> We could use setns to join the current ns,
> >> which did a lot of unnecessary work.
> >> This patch will check this senario and
> >> return 0 directly.
> >>
> >> Signed-off-by: Chen Hanxiao <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> >
> > Plus it's just asking for trouble.
> >
> > I would ack this, except you need to fclose(file) on the
> > return paths.  So just set err = 0 and goto out.
> 
> I completely disagree.
> 
> Nacked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> This patch adds a new code path to test, and gets that new code path
> wrong.  So unless there is a performance advantage for some real world
> case I don't see the point.  Is there real software that is rejoining
> the a current namespace.
> 
> This patch changes the behavior of CLONE_NEWNS (which always does a
> chdir and chroot) when you change into the current namespace.
> 
> This patch changes the behavior of CLONE_NEWUSER which current errors
> out.
> 

As reentering the same namespace looks meaningless,
and handling reentering same ns we behaved differently,
 
How about just *reject* the behaviour of setns to current namespace?

+	switch (ops->type) {
+	case CLONE_NEWIPC:
+		if (ei->ns == tsk->nsproxy->ipc_ns) {
+            err = -EINVAL;
+			goto out;
+        }
...

And things became easy, 6 simply cases could cover the whole scenario
and will not bring troubles to users.

Thanks,
- Chen

> This code adds a big switch statement to code that is otherwise table
> driven.  With the result that two pieces of code must be looked at
> and modified whenever we want to tweak the behavior of setns for a
> namespace.
> 
> So in general I think this piece of code is a maintenance disaster,
> with no apparent redeem virtues.
> 
> Eric
