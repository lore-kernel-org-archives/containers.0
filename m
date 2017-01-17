From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] FS jitter testing, network caching,
	Lustre, cluster filesystems.
Date: Tue, 17 Jan 2017 06:56:01 -0800
Message-ID: <1484664961.2433.29.camel__45590.0513603867$1484665003$gmane$org@HansenPartnership.com>
References: <D863EDBD-277B-4CC3-854F-D57FF4501542@linuxhacker.ru>
	<1484587952.2540.42.camel@HansenPartnership.com>
	<F7FABA22-8B7D-4C77-A360-4454A5571C8F@linuxhacker.ru>
	<1484590862.2540.51.camel@HansenPartnership.com>
	<9CA51BCE-7FF9-4212-9C43-B8B3667E7E6D@linuxhacker.ru>
	<1484600330.2540.69.camel@HansenPartnership.com>
	<AE738992-D640-48B1-B7C3-E4E798504F7A@linuxhacker.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AE738992-D640-48B1-B7C3-E4E798504F7A-SOTZviwpzew/JUsKyNonYw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Drokin <green-SOTZviwpzew/JUsKyNonYw@public.gmane.org>
Cc: linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lsf-pc-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2017-01-17 at 02:00 -0500, Oleg Drokin wrote:
> On Jan 16, 2017, at 3:58 PM, James Bottomley wrote:
> 
> > On Mon, 2017-01-16 at 13:39 -0500, Oleg Drokin wrote:
> > > It's all relatively easy when you have a separate mount there, so
> > > you can store the credentials in the superblock, but we lose on 
> > > the cache sharing, for example (I don't know how important that
> > > is).
> > 
> > It depends what you mean by "cache sharing". If you're thinking of 
> > the page cache, then it all just works, provided the underlying 
> > inode doesn't change.  If you're in the situation where the
> > container
> 
> It only "just works" if the superblock is the same, if there's a 
> separate mount per container with separate superblock, then there's 
> no sharing at all. Accounting of said "shared" cache might be 
> interesting too, which of the containers would you account against?
> All of them?

Well, caching is done per address_space, which is can be per inode and 
 as you found, inodes are usually per superblock.  There are (dirty) tr
icks you can do to force sharing at the address space level if you know
it's the same file.  There was also mention of a ksm like mechanism to
force the sharing.  Like I said, it was the VZ people who had patches.

James
