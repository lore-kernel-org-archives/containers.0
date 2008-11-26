From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 2/5] ftrace: use code patching for ftrace graph tracer
Date: Wed, 26 Nov 2008 01:05:03 -0800
Message-ID: <20081126010503.747871b3.akpm@linux-foundation.org>
References: <20081126051622.134970943@goodmis.org>
	<20081126051709.774546196@goodmis.org>
	<20081125213546.ff4eddf4.akpm@linux-foundation.org>
	<1227682349.5511.47.camel@brick>
	<20081126000430.5c19e189.akpm@linux-foundation.org>
	<1227688024.5511.56.camel@brick>
	<20081126003553.12d38150.akpm@linux-foundation.org>
	<1227689088.5511.62.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1227689088.5511.62.camel@brick>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Harvey Harrison <harvey.harrison-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Ingo-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, Steven Rostedt <srostedt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 26 Nov 2008 00:44:48 -0800 Harvey Harrison <harvey.harrison-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> On Wed, 2008-11-26 at 00:35 -0800, Andrew Morton wrote:
> > On Wed, 26 Nov 2008 00:27:04 -0800 Harvey Harrison <harvey.harrison-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > 
> > > if (code[0] != 0xe9 || old_offset != load32_noalign(&code[1]))
> > > 
> > > This is similar to the new API in -mm load_le32_noalign, but I
> > > don't think it would be worth load_u32_noalign...load32 should
> > > be enough.
> > > 
> > > > > > > +		return -EINVAL;
> > > > > > > +
> > > > > > > +	*(int *)(&code[1]) = new_offset;
> > > > > > 
> > > > > > Might be able to use put_unaligned_foo() here.
> > > > > > 
> > > > > 
> > > > > 	put_unaligned(new_offset, (int *)(&code[1]));
> > > > > 
> > > 
> > > In a similar vein to above, this becomes:
> > > 
> > > 	store32_noalign(&code[1], new_offset);
> > > 
> > 
> > yes, that's much better than the party tricks with magical sizeof,
> > which forces you to run around and check the types of everything.
> > 
> > I've seen people doing get_user() on `long' types and such things
> > occasionally.
> > 
> 
> Do you want to carry the patches to move to the new helpers until they
> hit mainline, or would you rather I waited until they can go through
> maintainer trees?

I don't know what that means, really.

> I've got the pile ready removing all of the get/put_{endian} and moving
> to the load/store API.  Not much left after that to just remove the
> magical sizeof versions too.  Just let me know what timing you'd prefer.

I don't understand the dependencies and relationships here.

If you have a bunch of patches which are applicable to current mainline
then just spray 'em out with suitable cc's and we'll see which bits
stick where.  Or is it more complicated than that?

> Also, all of this ends up being so intertwined in the aligned/unaligned
> cases that I'd like to move most of Documentation/unaligned_memory_access.txt
> into a new alignment_and_byteorder.txt to cover all of these new helpers.
> 
> I started most of a byteorder document, but constantly referring to the other
> file made it a bit tiresome, would you mind a consolidated document?

Whatever you think is best.  Propose something...
