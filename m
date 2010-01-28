From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: almost ckpt-v19-rc3
Date: Wed, 27 Jan 2010 18:48:06 -0600
Message-ID: <20100128004806.GA4618@us.ibm.com>
References: <4B60B1E9.4060005@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B60B1E9.4060005-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> Hi,
> 
> I pushed ckpt-v19-rc2.9 which has all patches (*) inside and folded
> to a clean set. It passes basic tests here.
> 
> (*) except the recent fix to s390 restart-blocks
> 
> Next step is to rebase it to a recent kernel and push again as v19-rc3.
> 
> Please give it a try, see if I missed anything.

Doh, actually, there is still a problem with IA32 tasks on x86-64:
if COMPAT_VDSO=y then the do_munmap() in destroy_mm() fails bc
vma->end > TASK_SIZE (vma->start == TASK_SIZE).  The reason this
doesn't cause a problem on x86-32, actually, is only bc the vdso
page doesn't seem to be in the list of vma's at all!  At least a
printk in destroy_mm() (a few days ago) never showed it running
across the vdso page.

So, perhaps the way to simultaneously solve both this and the unmaps
of 64-bit mappings in /bin/restart_64 after it has switched to
TIF_IA32 is to move destroy_mm() to a proper helper in mm/mmap.c,
and have it tell do_munmap() to avoid the TASK_SIZE check.

-serge
