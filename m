From: Kent Overstreet <koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 04/11] cgroup: use kzalloc() and list_del_init()
Date: Wed, 12 Jun 2013 19:43:10 -0700
Message-ID: <20130613024310.GC10979__40590.8241206363$1371091405$gmane$org@localhost>
References: <1371070996-20613-1-git-send-email-tj@kernel.org>
	<1371070996-20613-5-git-send-email-tj@kernel.org>
	<51B93038.9010202@huawei.com> <20130613023831.GB10979@localhost>
	<CAOS58YPv_uKeTqZSNF=sXTEnLn=LTbsdpBPM5K_ykXoVT-+CpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAOS58YPv_uKeTqZSNF=sXTEnLn=LTbsdpBPM5K_ykXoVT-+CpA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Jun 12, 2013 at 07:41:15PM -0700, Tejun Heo wrote:
> Hello,
> 
> On Wed, Jun 12, 2013 at 7:38 PM, Kent Overstreet <koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> > IMO, list_del() is preferred when the object shouldn't be reused (i.e.
> > it gets taken off a list and then it's freed). list_del_init() could
> > hide bugs.
> 
> Nah... use-after-frees are detected much more reliably by poisoning
> anyway. Using list_del() instead of list_del_init() to hunt down
> use-after-free isn't a good idea because you're likely to corrupt the
> memory of unrelated area. I really don't see much point in using
> list_del().

list_del() does do poisoning - and list debugging is cheaper to enable
than full slab debugging.
