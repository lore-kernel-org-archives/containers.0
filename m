From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC] Restrict size of page_cgroup->flags
Date: Thu, 7 Oct 2010 08:44:59 +0530
Message-ID: <20101007031459.GL4195__16879.3702185669$1286421425$gmane$org@balbir.in.ibm.com>
References: <20101006142314.GG4195@balbir.in.ibm.com>
	<20101007095458.a992969e.nishimura@mxp.nes.nec.co.jp>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20101007095458.a992969e.nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Cc: "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

* nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org> [2010-10-07 09:54:58]:

> On Wed, 6 Oct 2010 19:53:14 +0530
> Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> 
> > I propose restricting page_cgroup.flags to 16 bits. The patch for the
> > same is below. Comments?
> > 
> > 
> > Restrict the bits usage in page_cgroup.flags
> > 
> > From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> > 
> > Restricting the flags helps control growth of the flags unbound.
> > Restriciting it to 16 bits gives us the possibility of merging
> > cgroup id with flags (atomicity permitting) and saving a whole
> > long word in page_cgroup
> > 
> I agree that reducing the size of page_cgroup would be good and important.
> But, wouldn't it be better to remove ->page, if possible ?
>

Without the page pointer, how do we go from pc to page for reclaim? 

-- 
	Three Cheers,
	Balbir
