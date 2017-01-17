From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] FS jitter testing, network caching,
	Lustre, cluster filesystems.
Date: Tue, 17 Jan 2017 06:26:07 -0800
Message-ID: <1484663167.2433.8.camel@HansenPartnership.com>
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
> > > On Jan 16, 2017, at 1:21 PM, James Bottomley wrote:
> > > 
> > > > On Mon, 2017-01-16 at 13:02 -0500, Oleg Drokin wrote:
> > > > > On Jan 16, 2017, at 12:32 PM, James Bottomley wrote:
> > > > > 
> > > > > > On Sun, 2017-01-15 at 18:38 -0500, Oleg Drokin wrote:
> > > > > > > A container support from filesystems is also very 
> > > > > > > relevant to us since Lustre    is used more and more in 
> > > > > > > such settings.
> > > > > > 
> > > > > > I've added the containers ML to the cc just in case.  Can 
> > > > > > you add more colour to this, please?  What container 
> > > > > > support for filesystems do you think we need beyond the 
> > > > > > user namespace in the superblock?
> > > > > 
> > > > > Namespace access is necessary, we might need it before the 
> > > > > superblock is there too (say during mount we might need 
> > > > > kerberos credentials fetched to properly authenticate this 
> > > > > mount instance to the server).
> > > > 
> > > > The superblock namespace is mostly for uid/gid changes across 
> > > > the kernel <-> filesystem boundary.
> > > 
> > > That's on the kernel<->filesystem, but inside of the FS there 
> > > might be other considerations that you might want to attach 
> > > there. Say when you are encrypting the traffic to the server you 
> > > want to use the right keys.
> > 
> > So this is the keyring namespace?  It was mentioned at KS, but, as 
> > far as I can tell, not discussed in the Containers MC that 
> > followed, so I've no idea what the status is.
> 
> Could be keyring or other mechanisms.

OK, you need to agree on the mechanism first, then we can discuss if it
needs OS virtualization.  A large number of mechanisms in the kernel
actually don't (because the current OS protections are strong enough)
like file descriptors.  After you understand the mechanism there are
usually four main ways to do OS virtualization:

   1. Do nothing becuase the object doesn't need it (fd)
   2. Label Namespace because it needs isolation (network)
   3. add to user namespace because you need privileged access (setns
      call)
   4. add to cgroup because the resource needs to be accounted (mem)

But before we get into that we need to know the properties of the
mechanism.

James
