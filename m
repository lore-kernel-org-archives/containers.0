From: Igor Mammedov <imammedo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Xen-devel] Possible shadow bug
Date: Thu, 09 Jun 2011 18:47:09 +0200
Message-ID: <4DF0F90D.4010900__45981.7345640205$1307638438$gmane$org@redhat.com>
References: <4DE64F0C.3050203@redhat.com>
	<20110601152039.GG4266@tiehlicka.suse.cz>
	<4DE66BEB.7040502@redhat.com>
	<BANLkTimbqHPeUdue=_Z31KVdPwcXtbLpeg@mail.gmail.com>
	<4DE8D50F.1090406@redhat.com>
	<BANLkTinMamg_qesEffGxKu3QkT=zyQ2MRQ@mail.gmail.com>
	<4DEE26E7.2060201@redhat.com>
	<20110608123527.479e6991.kamezawa.hiroyu@jp.fujitsu.com>
	<4DF0801F.9050908@redhat.com>
	<alpine.DEB.2.00.1106091311530.12963@kaball-desktop>
	<20110609150133.GF5098@whitby.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110609150133.GF5098-uBdcGoUfBNNYtxbxJUhB2Dgeux46jI+i@public.gmane.org>
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
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, Keir Fraser <keir-LM2mM/qkH7s@public.gmane.org>, Stefano Stabellini <stefano.stabellini-mvvWK6WmYclDPfheJLI6IQ@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Keir Fraser <keir.xen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 06/09/2011 05:01 PM, Tim Deegan wrote:
> At 13:40 +0100 on 09 Jun (1307626812), Stefano Stabellini wrote:
>> CC'ing xen-devel and Tim.
>>
>> This is a comment from a previous email in the thread:
>>
>>> It most easily reproduced only on xen hvm 32bit guest under heavy vcpus
>>> contention for real cpus resources (i.e. I had to overcommit cpus and
>>> run several cpu hog tasks on host to make guest crash on reboot cycle).
>>> And from last experiments, crash happens only on on hosts that doesn't
>>> have hap feature or if hap is disabled in hypervisor.
>> it makes me think that it is a shadow pagetables bug; see details below.
>> You can find more details on it following this thread on the lkml.
> Oh dear.  I'm having a look at the linux code now to try and understand
> the behaviour.  In the meantime, what version of Xen was this on?  If
It's rhel5.6 xen. I've tried to test on SLES 11 that has 4.0.1 xen, however
wasn't able to reproduce problem. (I'm not sure if hap was turned off in 
this
case). More detailed info can be found at RHBZ#700565

> you're willing to try recompiling Xen with some small patches that
> disable the "cleverer" parts of the shadow pagetable code that might
> indicate something.  (Of course, it might just change the timing to
> obscure a real linux bug too.)
>
Haven't got to this part yet. But looks like it's the only option left.

> The only time I've seen a corruption like this, with a mapping
> transiently going to the wrong frame, it turned out to be caused by
> 32-bit pagetable-handling code writing a PAE PTE with a single 64-bit
> write (which is not atomic on x86-32), and the TLB happening to see the
> intermediate, half-written entry.  I doubt that there's any bug like
> that in linux, though, or we'd surely have seen it before now.
>
> Cheers,
>
> Tim.
>


-- 
Thanks,
  Igor
