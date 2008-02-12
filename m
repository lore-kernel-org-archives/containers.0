From: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>
Subject: Re: [PATCH 7/8] Do not recompute msgmni anymore if explicitely set
 by user
Date: Tue, 12 Feb 2008 16:15:00 +0100
Message-ID: <47B1B7F4.8080009__38827.6170277551$1202829502$gmane$org@bull.net>
References: <20080211141646.948191000@bull.net>	<20080211141816.094061000@bull.net>	<20080211122408.5008902f.akpm@linux-foundation.org>	<47B167AF.6010008@bull.net>
	<20080212014444.8bc3791b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080212014444.8bc3791b.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cmm-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Andrew Morton wrote:
> On Tue, 12 Feb 2008 10:32:31 +0100 Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org> wrote:
> 
> 
>>it builds fine, modulo some changes in ipv4 and ipv6 (see attached patch 
>>- didn't find it in the hot fixes).
> 
> 
> OK, thanks for checking.  Did you confirm that we don't have unneeded code
> in vmlinux when CONFIG_PROCFS=n?  I guess before-and-after comparison of
> the size(1) output would tell us.
> 
> Those networking build problems appear to have already been fixed.
> 
> In future, please quote the compiler error output in the changelog when
> sending build fixes or warning fixes, thanks.
> 
> 
> 

BEFORE:

lkernel@akt$ size vmlinux
    text    data     bss     dec     hex filename
4318525  454484  462848 5235857  4fe491 vmlinux


AFTER:

lkernel@akt$ size vmlinux
    text    data     bss     dec     hex filename
4323161  454484  462848 5240493  4ff6ad vmlinux

which makes it +4636 = +0.11%

I've got the details for */built-in.o if needed.


Regards,
Nadia
