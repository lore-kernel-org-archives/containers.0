From: Matthew Wilcox <willy-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [RFC][PATCH] ipc: Remove IPCMNI
Date: Thu, 29 Mar 2018 12:32:54 -0700
Message-ID: <20180329193254.GA22300__36952.677431009$1522351899$gmane$org@bombadil.infradead.org>
References: <87o9jru3bf.fsf@xmission.com>
	<935a7c50-50cc-2dc0-33bb-92c000d039bc@redhat.com>
	<87woyego2u.fsf_-_@xmission.com>
	<047c6ed6-6581-b543-ba3d-cadc543d3d25@redhat.com>
	<87h8ph6u67.fsf@xmission.com>
	<7d3a1f93-f8e5-5325-f9a7-0079f7777b6f@redhat.com>
	<20180329021409.gcjjrmviw2lckbfk@linux-n805>
	<3e201de2-bed2-6f7d-0783-700d095142e0@colorfullife.com>
	<20180329105601.GA597@bombadil.infradead.org>
	<05772f83-d680-aea1-b222-cef2430dcc83@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <05772f83-d680-aea1-b222-cef2430dcc83-nhLOkwUX5cPe2c5cEj3t2g@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Manfred Spraul <manfred-nhLOkwUX5cPe2c5cEj3t2g@public.gmane.org>
Cc: Davidlohr Bueso <dave-h16yJtLeMjHk1uMJSBkQmQ@public.gmane.org>, Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "Luis R. Rodriguez" <mcgrof-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Waiman Long <longman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Mar 29, 2018 at 08:07:44PM +0200, Manfred Spraul wrote:
> Hello Mathew,
> 
> On 03/29/2018 12:56 PM, Matthew Wilcox wrote:
> > On Thu, Mar 29, 2018 at 10:47:45AM +0200, Manfred Spraul wrote:
> > > > > > > > This can be implemented trivially with the current code
> > > > > > > > using idr_alloc_cyclic.
> > > Is there a performance impact?
> > > Right now, the idr tree is only large if there are lots of objects.
> > > What happens if we have only 1 object, with id=INT_MAX-1?
> > The radix tree uses a branching factor of 64 entries (6 bits) per level.
> > The maximum ID is 31 bits (positive signed 32-bit integer).  So the
> > worst case for a single object is 6 pointer dereferences to find the
> > object anywhere in the range (INT_MAX/2 - INT_MAX].  That will read 12
> > cachelines.  If we were to constrain ourselves to a maximum of INT_MAX/2
> > (30 bits), we'd reduce that to 5 pointer dereferences and 10 cachelines.
> I'm concerned about the up to 6 branches.
> But this is just guessing, we need a test with a realistic workload.

Yes, and once there's a realistic workload, I'll be happy to prioritise
adapting the data structure to reduce the pointer chases.

FWIW, the plan is this:

There's currently an unused 32-bit field (on 64-bit machines) which I plan
to make the 'base' field.  So at each step down the tree, one subtracts
that field from the index in order to decide which slot to look at next.
Something like this:

index=0x3000'0000
(root) -> order=24
          offset=48 -> order=18
                       offset=0 -> order=12
                                   offset=0 -> order=6
                                               offset=0 -> order=0
                                                           offset=0 -> data

compresses to a single node:
(root) -> order=0
          base=3000'0000
          offset=0 -> data

If one has one entry at 5 and another entry at 0x3000'0000, the tree
looks like this (three nodes):

(root) -> order=24
          base=0
          offset=0  -> order=0
                       base=0
                       offset=5 -> entry1
          offset=48 -> order=0
                       base=0
                       offset=0 -> entry2

The trick is making sure that looking up offset 0x300'1000 returns NULL
and not entry2, but I can make that work.

An alternative is to go to something a little more libJudy and have
mutating internal nodes in the tree that can represent this kind of
situation in a more compact form.  There's a tradeoff to be made between
simplicity of implementation, cost of insertion, cost of lookup and
memory consumption.  I don't know where the right balance point is yet.
