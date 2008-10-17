From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 5/9] Restore memory address space
Date: Fri, 17 Oct 2008 08:39:34 -0700
Message-ID: <1224257974.1848.49.camel__26317.6367887811$1224258213$gmane$org@nimitz>
References: <20081016181414.934C4FCC@kernel> <20081016181421.3BA319FA@kernel>
	<1224233070.2634.114.camel@frecb000730.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1224233070.2634.114.camel-okVqAf2pJUFftS2PfwdgCzWMkbuR3peG@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-mm <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2008-10-17 at 10:44 +0200, Nadia Derbey wrote:
> On Thu, 2008-10-16 at 11:14 -0700, Dave Hansen wrote:
> > +static int cr_page_read(struct cr_ctx *ctx, struct page *page, char *buf)
> > +{
> > +	void *ptr;
> > +	int ret;
> > +
> > +	ret = cr_kread(ctx, buf, PAGE_SIZE);
> > +	if (ret < 0)
> > +		return ret;
> > +
> > +	ptr = kmap_atomic(page, KM_USER1);
> > +	memcpy(ptr, buf, PAGE_SIZE);
> > +	kunmap_atomic(page, KM_USER1);
> 
> Here too, I think this should be changed to 
> kunmap_atomic(ptr, KM_USER1);

Thanks, Nadia.

These fixes will show up in the git tree shortly:

http://git.kernel.org/gitweb.cgi?p=linux/kernel/git/daveh/linux-2.6-cr.git;a=summary

I just created it, so it may take a few moments for the gitweb script to
find it.

-- Dave
