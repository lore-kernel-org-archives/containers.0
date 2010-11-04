From: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>
Subject: Re: [PATCH] cgroup: Avoid a memset by using vzalloc
Date: Thu, 4 Nov 2010 22:43:56 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1011042240340.15856__40536.3182108433$1288908291$gmane$org@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1010302333130.1572@swampdragon.chaosbits.net>
	<AANLkTi=nMU3ezNFD8LKBhJxr6CmW6-qHY_Mo3HRt6Os0@mail.gmail.com>
	<20101031173336.GA28141@balbir.in.ibm.com>
	<alpine.LNX.2.00.1011010639410.31190@swampdragon.chaosbits.net>
	<alpine.DEB.2.00.1011030937580.10599@router.home>
	<AANLkTinhAQ7mNQWtjWCOWEHHwgUf+BynMM7jnVBMG32-@mail.gmail.com>
	<1288799284.15729.27.camel@Joe-Laptop>
	<alpine.DEB.2.00.1011031108260.11625@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.1011031108260.11625-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Cc: jovi zhang <bookjovi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 3 Nov 2010, Christoph Lameter wrote:

> On Wed, 3 Nov 2010, Joe Perches wrote:
> 
> > On Wed, 2010-11-03 at 23:20 +0800, jovi zhang wrote:
> > > On Wed, Nov 3, 2010 at 10:38 PM, Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org> wrote:
> > > > On Mon, 1 Nov 2010, Jesper Juhl wrote:
> > > >
> > > >> On Sun, 31 Oct 2010, Balbir Singh wrote:
> > > >
> > > >> > > There are so many placed need vzalloc.
> > > >> > > Thanks, Jesper.
> > > >
> > > >
> > > > Could we avoid this painful exercise with a "semantic patch"?
> >
> > There's an existing cocci kmalloc/memset script.
> 
> I have it in
> /usr/share/doc/coccinelle/examples/janitorings/kzalloc-orig.cocci.gz
> 
> (Ubuntu coccinelle package)
> 
> > Perhaps this is good enough?
> >
> > cp scripts/coccinelle/api/alloc/kzalloc-simple.cocci scripts/coccinelle/api/alloc/vzalloc-simple.cocci
> > sed -i -e 's/kmalloc/vmalloc/g' -e 's/kzalloc/vzalloc/g' scripts/coccinelle/api/alloc/vzalloc-simple.cocci
> 
> Not sure if that is the same script but certainly a good start. Try it and
> see if it catches all the locations that you know of?
> 

I'm aware of coccinelle, but I've never used it and it looks like it'll 
take more than just a few hours to learn, so I'm sticking with 
bash+egrep+manual inspection for now until I get a bit more time on my 
hands to learn coccinelle/spatch.

I assume that not using spatch is not going to be an obstacle to patches 
such as this one getting merged...?


-- 
Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>             http://www.chaosbits.net/
Plain text mails only, please      http://www.expita.com/nomime.html
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
