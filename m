From: Matthew Wilcox <willy-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [RFC][PATCH] ipc: Remove IPCMNI
Date: Thu, 29 Mar 2018 03:56:01 -0700
Message-ID: <20180329105601.GA597__13443.1448801935$1522320890$gmane$org@bombadil.infradead.org>
References: <87woyfyh57.fsf@xmission.com>
	<5d4a858a-3136-5ef4-76fe-a61e7f2aed56@redhat.com>
	<87o9jru3bf.fsf@xmission.com>
	<935a7c50-50cc-2dc0-33bb-92c000d039bc@redhat.com>
	<87woyego2u.fsf_-_@xmission.com>
	<047c6ed6-6581-b543-ba3d-cadc543d3d25@redhat.com>
	<87h8ph6u67.fsf@xmission.com>
	<7d3a1f93-f8e5-5325-f9a7-0079f7777b6f@redhat.com>
	<20180329021409.gcjjrmviw2lckbfk@linux-n805>
	<3e201de2-bed2-6f7d-0783-700d095142e0@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <3e201de2-bed2-6f7d-0783-700d095142e0-nhLOkwUX5cPe2c5cEj3t2g@public.gmane.org>
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

On Thu, Mar 29, 2018 at 10:47:45AM +0200, Manfred Spraul wrote:
> > > > > > This can be implemented trivially with the current code
> > > > > > using idr_alloc_cyclic.
>
> Is there a performance impact?
> Right now, the idr tree is only large if there are lots of objects.
> What happens if we have only 1 object, with id=INT_MAX-1?

The radix tree uses a branching factor of 64 entries (6 bits) per level.
The maximum ID is 31 bits (positive signed 32-bit integer).  So the
worst case for a single object is 6 pointer dereferences to find the
object anywhere in the range (INT_MAX/2 - INT_MAX].  That will read 12
cachelines.  If we were to constrain ourselves to a maximum of INT_MAX/2
(30 bits), we'd reduce that to 5 pointer dereferences and 10 cachelines.

I have plans to make the representation more efficient and bring
the specific case of one element with a high ID down to one pointer
dereference and 2 cachelines, but I have not yet had time to implement
those plans.

From a memory consumption point of view, 6 layers of tree will consume
6/7 of a page on a 64-bit x86 kernel.  I'm aiming to bring that down to
1/7 of a page.  We get 7 radix_tree_nodes per 4kB page.

(The old IDR tree had 256 entries per level which would have taken only
four layers to get us to 31 bits, but the cost was getting only 3 layers
per 8kB order-1 page, so we'd've taken 2 + 2/3 page to accomplish the
same goal).
