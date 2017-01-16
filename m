From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] FS jitter testing, network caching,
	Lustre, cluster filesystems.
Date: Mon, 16 Jan 2017 10:21:02 -0800
Message-ID: <1484590862.2540.51.camel__10582.8392472633$1484590890$gmane$org@HansenPartnership.com>
References: <D863EDBD-277B-4CC3-854F-D57FF4501542@linuxhacker.ru>
	<1484587952.2540.42.camel@HansenPartnership.com>
	<F7FABA22-8B7D-4C77-A360-4454A5571C8F@linuxhacker.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <F7FABA22-8B7D-4C77-A360-4454A5571C8F-SOTZviwpzew/JUsKyNonYw@public.gmane.org>
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

On Mon, 2017-01-16 at 13:02 -0500, Oleg Drokin wrote:
> On Jan 16, 2017, at 12:32 PM, James Bottomley wrote:
> 
> > On Sun, 2017-01-15 at 18:38 -0500, Oleg Drokin wrote:
> > >   A container support from filesystems is also very relevant to
> > > us 
> > > since Lustre    is used more and more in such settings.
> > 
> > I've added the containers ML to the cc just in case.  Can you add
> > more
> > colour to this, please?  What container support for filesystems do
> > you
> > think we need beyond the user namespace in the superblock?
> 
> Namespace access is necessary, we might need it before the superblock 
> is there too (say during mount we might need kerberos credentials 
> fetched to properly authenticate this mount instance to the server).

The superblock namespace is mostly for uid/gid changes across the
kernel <-> filesystem boundary.

The actual container namespaces will already be set up by the time the
mount is done (assuming mount within a container), so you have them all
present.  Usually you get the information for credentials from a
combination of the UTS namespace (host/domain name) and the mount
namespace (credentials provisioned to container filesystem).

Perhaps if you described the actual problem you're seeing rather than
try to relate it to what I said about superblock namespace (which is
probably irrelevant), we could figure out what the issue is.

James
