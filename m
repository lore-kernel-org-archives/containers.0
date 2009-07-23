From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFCv2][PATCH] flexible array implementation
Date: Wed, 22 Jul 2009 22:41:37 -0700
Message-ID: <1248327697.24021.661.camel__7100.40358030728$1248327786$gmane$org@nimitz>
References: <20090721220017.60A219D3@kernel>
	<2f86c2480907221357j5a09fd9au890f815db3750187@mail.gmail.com>
	<1248299464.24021.334.camel@nimitz>
	<2f86c2480907221620u6da3a8e3h8273f6a9ee156f86@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2f86c2480907221620u6da3a8e3h8273f6a9ee156f86-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: vda.linux-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2009-07-22 at 16:20 -0700, Benjamin Blum wrote:
> 
> >> How about a resize() function that can be
> >> used to either grow or shrink the array?
> >
> > I think growing is out of the question.  It has a fixed maximum size
> > already.  As for shrinking, there's probably a use case for when
> > something is large, then shrinks back down.  But, I think I'd want to
> > see a user for it, otherwise I'm just guessing at it too much.
> 
> Check out the reallocate logic in pidlist_uniq from my patch (the
> series you linked).

To me, it seems like you should just replace the cgroup_pidlist->list
with a 'struct flex_array *'.  It sounds like you're concerned that a
large cgroup_pidlist that was later shrunk would take up too much space.

That's a valid concern and it would be quite possible to make a
flex_array_clean() or truncate() or something similar.  Such a function,
given an index, could clean out the array at all points past the given
index.  Kinda the opposite of prealloc().

At the same time, you could get the same effect by allocating a new flex
array and doing copies like you are now with the normal arrays.  

-- Dave
