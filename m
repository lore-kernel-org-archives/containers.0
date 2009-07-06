From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add AF_UNIX support (v3)
Date: Mon, 06 Jul 2009 11:31:04 -0700
Message-ID: <87y6r1slxz.fsf@caffeine.danplanet.com>
References: <1245167716-28906-1-git-send-email-danms@us.ibm.com>
	<4A42E163.1080700@cs.columbia.edu>
	<871vp3x81s.fsf@caffeine.danplanet.com>
	<4A4C7AC7.3090004@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

OL> Because in the kernel: "->peer != NULL" if-and-only-if "h->raddr
OL> is meaningful" so I wonder whether you should detect such input
OL> and complain, in case a malicious user does that ?

Ah, sorry, I misunderstood.  Yep, agreed.  I was thinking I was
covered on that by the use of the regular functions but my makeaddr
function would let it slip by, so I've fixed that.

OL> Well, it should not be more than allowed by ->rcvbuf, or some
OL> other system limits (which I'm sure exists). At least apply the
OL> restrictions put by a regular read() syscall.

Relying on the stored rcvbuf doesn't help prevent a DoS, right?

OL> One exception is when a socket's rcvbuf fills with large amount of
OL> data, and then the user calls setsockopt() to reduce the buffer to
OL> a lower size... in which case relying on the restored value for
OL> -> rcvbuf limit is clearly wrong.

Hmm, I don't know why that's the case.  Even still, I don't see why we
should rely on the stored version of rcvbuf at all, aside from maybe
just checking that the socket buffers are smaller than the claimed
rcvbuf size of correctness' sake.  However, checking against an
existing sysctl or other limit (if there is one, still need to look)
is obvious a good idea.

OL> The connect() syscall will auto-bind only if the socket isn't
OL> already bound. And in the case of ad_unix, even that happens only
OL> when SOCK_PASSCRED bit is set in sock->flags.

Well, I'm not really sure why that makes sense (not arguing that it's
true).  Perhaps a comment about this potential issue will suffice for
now?

OL> Even an established socket may have a local address that needs to
OL> be saved, to make getsockname() consistent across c/r.

...right, but that's already restored properly, no?  My test case
shows that established STREAM sockets have the same output of
getsockname() before and after restart.

OL> s1 = socket(); bind(s1, addr); unlink(addr);
OL> s2 = socket(); bind(s1, addr);
OL> 			^^^^^^^^
OL>                    (s2, addr)    <-- should have been	

OL> Now with the fixed example, the problem is if s2 is restored first,
OL> the restore of s1 will fail, or succeed and make s1 unreachable.

I think you meant "restore of s1 will fail, or succeed and make *s2*
unreachable".

OL> However, we know that s1 is no longer reachable through connect()
OL> (or sendto() for dgram) - so during restart we want to manually
OL> set the local address, without the side-effect of creating an
OL> inode in the filesystem, for those sockets that are 1) bound with
OL> pathname address, and 2) the corresponding socket inode isn't
OL> unlinked.

Okay, done.

OL> I meant "cwd at the time of the bind()". To find it, you can
OL> "subtract" the sock-address from the total pathname of the inode
OL> (assuming, of course, that the address is relative).

Right, right.  I was thinking that the socket kept an inode which
would make it hard to determine the full path, but it's a dentry.
I'll work that in.

Thanks!

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
