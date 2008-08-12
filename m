From: James.Smart-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org
Subject: RE: RFC: I/O bandwidth controller
Date: Tue, 12 Aug 2008 11:03:24 -0400
Message-ID: <D1D4C3FF75F9354393DB8314DF43DEF2E7F7ED__18196.9217527241$1218554339$gmane$org@xbl3.emulex.com>
References: <1218117578.11703.81.camel@sebastian.kern.oss.ntt.co.jp><48A0A689.40908@gmail.com>	<loom.20080812T071504-212@post.gmane.org><20080812.201025.57762305.taka@valinux.co.jp><48A18854.9020000@gmail.com>
	<48A18B1F.6080000@gmail.com>
	<1218549276.4456.100.camel@sebastian.kern.oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
content-class: urn:content-classes:message
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Fernando Luis V=E1zquez Cao wrote:
> > BTW as I said in a previous email, an interesting path to =

> be explored
> > IMHO could be to think in terms of IO time. So, look at the =

> time an IO
> > request is issued to the drive, look at the time the =

> request is served,
> > evaluate the difference and charge the consumed IO time to the
> > appropriate cgroup. Then dispatch IO requests in function of the
> > consumed IO time debts / credits, using for example a token-bucket
> > strategy. And probably the best place to implement the IO time
> > accounting is the elevator.
> Please note that the seek time for a specific IO request is strongly
> correlated with the IO requests that preceded it, which means that the
> owner of that request is not the only one to blame if it =

> takes too long
> to process it. In other words, with the algorithm you propose =

> we may end
> up charging the wrong guy.

I assume all of these discussions are focused on simple storage - disks
direct attached to a single server - and are not targeted at SANs with
arrays, multi-initiator accesses, and fabric/network impacts. True ? =

Such algorithms can be seriously off-base in these latter configurations.

-- james s
