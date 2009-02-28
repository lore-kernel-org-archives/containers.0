From: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [RFC][PATCH 5/8] add f_op for checkpointability
Date: Sat, 28 Feb 2009 15:53:29 -0500
Message-ID: <20090228205329.GB4254__7123.75066145814$1235854540$gmane$org@infradead.org>
References: <20090227203425.F3B51176@kernel> <20090227203431.D1E697CB@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090227203431.D1E697CB@kernel>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Feb 27, 2009 at 12:34:31PM -0800, Dave Hansen wrote:
> 
> We have set up sane defaults for how filesystems should
> be checkpointed.  However, as usual in the VFS, there
> are specialized places that will always need an ability
> to override these defaults.
> 
> This adds a new 'file_operations' function for
> checkpointing a file.  I did this under the assumption
> that we should have a dirt-simple way to make something
> (un)checkpointable that fits in with current code.
> 
> As you can see in the /dev/null patch in a second, all
> that we have to do to make something like /dev/null
> supported is add a single "generic" f_op entry.

Please don't do the fallback to allow checkpointing without file
operations.  We've never had luck with these fallbacks, and I'm
in the process of getting of the last default file operation (llseek,
which has a very bad default) currently.

Incidentally that should also allow you to get rid of the per-fs flag
by just checking for the presence of the operation to check if
checkpointing is allowed.

Also the double-use of the op seem not very nice to me.  Is there any
real life use case were you would have the operation on a file but
sometimes not allow checkpoiting?
