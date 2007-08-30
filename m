From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: unshare() pid ns
Date: Thu, 30 Aug 2007 09:35:18 -0500
Message-ID: <20070830143518.GA5878@sergelap.austin.ibm.com>
References: <20070830052928.GA27864@us.ibm.com> <46D67B8B.2000606@openvz.org>
	<20070830133422.GA28129@sergelap.austin.ibm.com>
	<46D6D00F.7090303@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <46D6D00F.7090303-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Pavel Emelyanov (xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org):
> Serge E. Hallyn wrote:
> > Quoting Pavel Emelyanov (xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org):
> >> sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> >>> Pavel,
> >>> unshare() of pid ns seems to fail with -EINVAL in 2.6.23-rc3-mm1.
> >>> I thought we supported it in the earlier patchsets.  I guess
> >>> I missed that in the review of recent patchsets.
> >> I disabled unsharing of pid namespaces because it's almost
> >> impossible. Look - you have to reattach all the pids to the
> >> task with saving its ids as seen in previous namespaces.
> > 
> > We agree, but thought you for some perverse reason preferred unshare to
> > clone for pidns :)
> 
> I did that in my first version of patches, but then realized
> that such problem (the need in reattaching pids) makes the
> unsharing ugly.
> 
> BTW, unsharing of a pid namespace is a valid operation, so I
> think I will enable it in the nearest future. I have some
> thought on how to make such a reattach ;)

Alrighty  :)

Of course it's not just the kernel ugliness, but also the userspace
ugliness, for instance the rumored (I haven't looked to confirm) caching
of pids by glibc.

But in the end if we can achieve symmetry between all the CLONE_NEW*
flags all the better.

-serge
