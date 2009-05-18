From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: failure to restart bash with ckpt-v15-dev
Date: Mon, 18 May 2009 16:46:20 -0500
Message-ID: <m3d4a6hyoj.fsf@pobox.com>
References: <m3iqjykvvf.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m3iqjykvvf.fsf-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org> (Nathan Lynch's message of "Mon\, 18
	May 2009 15\:18\:44 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org> writes:

> Last commit is ed3b275 "allow error string during checkpoint while
> holding a spinlock".
>
> The failure seems to involve a vma corresponding to
> /usr/lib/gconv/gconv-modules.cache which is mapped read-only and shared,
> e.g.
>
> open("/usr/lib/gconv/gconv-modules.cache", O_RDONLY) = 3
> mmap2(NULL, 26048, PROT_READ, MAP_SHARED, 3, 0) = 0xb7f52000
>
> I believe the second check in filemap_restore() is where the restart
> goes awry; the object is of type CKPT_VMA_SHM_FILE but doesn't have
> VM_SHARED set in the flags (it does have VM_MAY_SHARE set, however).

As Serge suggested in other bug report, updated to latest user-cr and
got same result.

Also, I forgot to mention that if I modify the check in filemap_restore
to allow VM_MAY_SHARE, the restart operation appears to complete
successfully but the kernel gets an oops on an address in that vma when
the task runs.
