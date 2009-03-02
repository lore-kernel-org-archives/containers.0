From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: thoughts on checkpointing /proc/mounts
Date: Mon, 02 Mar 2009 10:48:39 -0800
Message-ID: <1236019719.26788.505.camel@nimitz>
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
To: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
List-Id: containers.vger.kernel.org

Christoph's suggestion that we go add f_ops individually is a really
good way to get people thinking about individual cases that we have to
deal with.

Can we checkpoint an *open* /proc/mounts?  I don't think we want to.  It
could get really nasty really fast.  But, what if the f_pos is 0?  That
makes it a lot easier.

If the "may checkpoint" flag is per-container (as Alexey has said) and
one-way (as Ingo has said), does a single 'cat /proc/mounts' 5 days ago
keep a container from being checkpointed today?

I just don't think the container-wide flag works if it is one way.

I think making it per-process or per-resource (so it can be more easily
tracked at fork()/clone()/exec()) is the only way to go.  It makes it so
simple since only the 'cat /proc/mounts' process becomes
uncheckpointable.  Once it exits, we are OK and can checkpoint again.
That all seems right to me. 

-- Dave
