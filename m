From: Marc Aymerich <glicerinu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Containers vs. OpenVZ
Date: Wed, 18 Aug 2010 12:42:48 +0200
Message-ID: <AANLkTinLMVV21pW_icDriWbrZ1U8NgfKYWMhFLBD5XS-@mail.gmail.com>
References: <20100817103339.GA8495@nibiru.local>
	<20100818002416.GG3648@count0.beaverton.ibm.com>
	<4C6B3082.2070802@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4C6B3082.2070802-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Enrico Weigelt <weigelt-EU+a56NjgY8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Aug 18, 2010 at 2:59 AM, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> wrote:

>
>
> On 08/17/2010 08:24 PM, Matt Helsley wrote:
> > On Tue, Aug 17, 2010 at 12:33:40PM +0200, Enrico Weigelt wrote:
> >>
> >> Hi folks,
> >>
> >>
> >> could anyone please point out the difference main difference
> >> between linux-containers and openvz ? It is possible to replace
> >> ovz by linux-containers yet ?
> >>
> >> thx
> >
> > Hi,
> >
> >       At the very least there is no kernel code in mainline for
> > checkpoint/restart of containers at this time. We're still working on
> > patches for that feature. So that's one major difference between
> > "linux-containers" and openvz.
>
> To be fair, there is not kernel code in mainline for openvz either...



really? http://wiki.openvz.org/File:Kernel_patches_stats.png

-- 
Marc
