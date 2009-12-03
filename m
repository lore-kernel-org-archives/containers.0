From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: ckpt-v19-rc2
Date: Thu, 03 Dec 2009 17:15:36 -0500
Message-ID: <4B183888.7070103@cs.columbia.edu>
References: <Pine.LNX.4.64.0912012352420.5665@takamine.ncl.cs.columbia.edu>
	<1259875869.8693.30.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1259875869.8693.30.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


Oh ... maybe that's what why checkpoint fails on my experimental
x86-64 port: it worked well on 2.6.31 but fails with "bad address"
on 2.6.32.

It may be related to a change between 2.6.31 and 2.6.32 in
the arguments to follow_page(), see commit:

	mm: FOLL_DUMP replace FOLL_ANON
	8e4b9a60718970bbc02dfd3abd0b956ab65af231

?

Oren.

Nathan Lynch wrote:
> On Wed, 2009-12-02 at 00:23 -0500, Oren Laadan wrote:
>> I put together ckpt-v19-rc2 (kernel and user)
> 
> I'm not sure yet whether this is a regression, but checkpoint seems to
> be unable to handle file mappings that extend past the end of the file.
> I noticed this with Fedora 11 userspace on powerpc (ld.so sometimes maps
> libraries this way).  I did not see this failure with a v19-rc1-based
> kernel I tested earlier this week, but I haven't retested with that yet.
> 
> Here's an example - 8K mapping of a 4K file:
> 
> # stat -c%s /tmp/myfile 
> 4096
> 
> # grep myfile /proc/5164/maps
> f7e2b000-f7e2d000 r--p 00000000 08:06 5103709                            /tmp/myfile
> 
> # checkpoint 5164 > /tmp/mmap.ckpt
> checkpoint: Bad address
> 
> When we try to follow the mapping past the end of the file, we get
> VM_FAULT_SIGBUS from handle_mm_fault(); the stack trace from debugging
> code I added is:
> 
> .__get_dirty_page+0x4c/0x164 (unreliable)
> .checkpoint_memory_contents+0x134/0x5a4
> .private_vma_checkpoint+0xf4/0x120
> .filemap_checkpoint+0x198/0x1d0
> .checkpoint_mm+0x3c4/0x4fc
> .checkpoint_obj+0x17c/0x1d0
> .checkpoint_obj_mm+0x50/0x88
> .checkpoint_task+0x710/0xaa0
> .do_checkpoint+0x9c0/0xb24
> .SyS_checkpoint+0xd0/0x11c
> 
> Attached is a testcase.
> 
> 
