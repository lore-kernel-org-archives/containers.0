From: Tim Deegan <Tim.Deegan-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Xen-devel] Possible shadow bug
Date: Fri, 10 Jun 2011 11:01:39 +0100
Message-ID: <20110610100139.GG5098__33745.4016357244$1307700222$gmane$org@whitby.uk.xensource.com>
References: <4DE66BEB.7040502@redhat.com>
	<BANLkTimbqHPeUdue=_Z31KVdPwcXtbLpeg@mail.gmail.com>
	<4DE8D50F.1090406@redhat.com>
	<BANLkTinMamg_qesEffGxKu3QkT=zyQ2MRQ@mail.gmail.com>
	<4DEE26E7.2060201@redhat.com>
	<20110608123527.479e6991.kamezawa.hiroyu@jp.fujitsu.com>
	<4DF0801F.9050908@redhat.com>
	<alpine.DEB.2.00.1106091311530.12963@kaball-desktop>
	<20110609150133.GF5098@whitby.uk.xensource.com>
	<4DF0F90D.4010900@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4DF0F90D.4010900-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Igor Mammedov <imammedo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, Keir Fraser <keir-LM2mM/qkH7s@public.gmane.org>, Stefano Stabellini <stefano.stabellini-mvvWK6WmYclDPfheJLI6IQ@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Keir Fraser <keir.xen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi, 

At 18:47 +0200 on 09 Jun (1307645229), Igor Mammedov wrote:
> It's rhel5.6 xen. I've tried to test on SLES 11 that has 4.0.1 xen, however
> wasn't able to reproduce problem. (I'm not sure if hap was turned
> off in this case). More detailed info can be found at RHBZ#700565

The best way to be sure whether HAP is in use is to connect to the
serial line, hit ^A^A^A to switch input to Xen, and hit 'q' to dump
per-domain state.  The printout for the guest domain should either say 
"paging assistance: shadow refcounts translate external"
or 
"paging assistance: hap refcounts translate external".

(If you don't have serial you can get the same info by running 
"xm debug-keys q" and then "xm dmesg" to read the output.)

> >you're willing to try recompiling Xen with some small patches that
> >disable the "cleverer" parts of the shadow pagetable code that might
> >indicate something.  (Of course, it might just change the timing to
> >obscure a real linux bug too.)
> >
> Haven't got to this part yet. But looks like it's the only option left.

Actually, looking at the disassembly you posted, it looks more like it
might be an emulator bug in Xen; if Xen finds itself emulating the IMUL
instruction and either gets the logic wrong or does the memory access
wrong, it could cause that failure.  And one reason that Xen emulates
instructions is if the memory operand is on a pagetable that's shadowed
(which might be a page that was recently a pagetable). 

ISTR that even though the RHEL xen reports a 3.0.x version it has quite
a lot of backports in it.  Does it have this patch?
http://hg.uk.xensource.com/xen-3.1-testing.hg/rev/e8fca4c42d05

Cheers,

Tim.

-- 
Tim Deegan <Tim.Deegan-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Principal Software Engineer, Xen Platform Team
Citrix Systems UK Ltd.  (Company #02937203, SL9 0BG)
