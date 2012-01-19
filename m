From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Subject: Re: [RESEND, PATCH 4/6] memcg: fix broken boolean expression
Date: Thu, 19 Jan 2012 14:44:25 +0100
Message-ID: <20120119134425.GQ24386__35682.5072005906$1326980688$gmane$org@cmpxchg.org>
References: <1325883472-5614-1-git-send-email-kirill@shutemov.name>
	<1325883472-5614-4-git-send-email-kirill@shutemov.name>
	<20120109140404.GG3588@cmpxchg.org>
	<20120116115416.GA25687@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120116115416.GA25687-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jan 16, 2012 at 01:54:16PM +0200, Kirill A. Shutemov wrote:
> On Mon, Jan 09, 2012 at 03:04:04PM +0100, Johannes Weiner wrote:
> > On Fri, Jan 06, 2012 at 10:57:50PM +0200, Kirill A. Shutemov wrote:
> > > From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> > > 
> > > action != CPU_DEAD || action != CPU_DEAD_FROZEN is always true.
> > > 
> > > Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> > > Cc: <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> > 
> > I think you don't need to actually CC stable via email.  If you
> > include that tag, they will pick it up once the patch hits mainline.
> 
> I don't think it's a problem for stable@.
> 
> > 
> > The changelog is too terse, doubly so for a patch that should go into
> > stable.  How is the code supposed to work?  What are the consequences
> > of the bug?
> 
> Is it enough?

I think so, thank you.

> >From fe1c2f2dc1abf63cce12017e2d9031cf67f0a161 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> Date: Sat, 24 Dec 2011 04:12:53 +0200
> Subject: [PATCH 4/6] memcg: fix broken boolean expression
> 
> action != CPU_DEAD || action != CPU_DEAD_FROZEN is always true.
> 
> We should return at the point if CPU doesn't go away. Otherwise drain
> all counters and stocks from the CPU.
> 
> Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> Cc: <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> Acked-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

Acked-by: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>

But without the stable Cc, I guess :)
