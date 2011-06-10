From: Igor Mammedov <imammedo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Xen-devel] Possible shadow bug
Date: Fri, 10 Jun 2011 17:38:58 +0200
Message-ID: <4DF23A92.8050909__29548.0730747387$1307720425$gmane$org@redhat.com>
References: <BANLkTinMamg_qesEffGxKu3QkT=zyQ2MRQ@mail.gmail.com>
	<4DEE26E7.2060201@redhat.com>
	<20110608123527.479e6991.kamezawa.hiroyu@jp.fujitsu.com>
	<4DF0801F.9050908@redhat.com>
	<alpine.DEB.2.00.1106091311530.12963@kaball-desktop>
	<20110609150133.GF5098@whitby.uk.xensource.com>
	<4DF0F90D.4010900@redhat.com>
	<20110610100139.GG5098@whitby.uk.xensource.com>
	<20110610101011.GH5098@whitby.uk.xensource.com>
	<20110610114821.GB32595@reaktio.net>
	<20110610124034.GI5098@whitby.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110610124034.GI5098-uBdcGoUfBNNYtxbxJUhB2Dgeux46jI+i@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tim Deegan <Tim.Deegan-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, Keir Fraser <keir-LM2mM/qkH7s@public.gmane.org>, Stabellini <stefano.stabellini-mvvWK6WmYclDPfheJLI6IQ@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Pasi K?rkk?inen <pasik-X3B1VOXEql0@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Keir Fraser <keir.xen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, "akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 06/10/2011 02:40 PM, Tim Deegan wrote:
> At 14:48 +0300 on 10 Jun (1307717301), Pasi K?rkk?inen wrote:
>> On Fri, Jun 10, 2011 at 11:10:11AM +0100, Tim Deegan wrote:
>>> At 11:01 +0100 on 10 Jun (1307703699), Tim Deegan wrote:
>>>> ISTR that even though the RHEL xen reports a 3.0.x version it has quite
>>>> a lot of backports in it.  Does it have this patch?
>>>> http://hg.uk.xensource.com/xen-3.1-testing.hg/rev/e8fca4c42d05
>>> Oops, that URL doesn't work; I meant this:
>>> http://xenbits.xen.org/xen-3.1-testing.hg/rev/e8fca4c42d05
>>>
>> RHEL5 Xen (hypervisor) reports version as 3.1.2-xyz..
> Based on a quick scrobble through the CentOS 5.6 SRPMs it looks like a
> 3.1.0 hypervisor with a bunch of extra patches, but not this one.  This
> is very likely the cause of the crash in mem_cgroup_create(), and
> probably the corruptions too.  That would explain why they didn't happen
> on a 4.0.x SLES11 Xen, but not really why the original patch in this
> thread made it go away.
>
Maybe it changes timing so that imul is executed with correct memory 
content?
Putting extra printk inside zone loop or flushing tlb before it also 
make problem
go away. Or may be problem just becomes invisible and memory is corrupted at
another place.

PS:
Well, never mind. I do not know what I'm talking about.
> Cheers,
>
> Tim.
>


-- 
Thanks,
  Igor
