From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] fill vdso with syscall32_setup_pages if TIF_IA32
	on x86_64
Date: Wed, 27 Jan 2010 14:10:37 -0600
Message-ID: <20100127201037.GA23119@us.ibm.com>
References: <20100127071636.GA16624@us.ibm.com>
	<Pine.LNX.4.64.1001270954120.8974@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.1001270954120.8974-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> Cool !
> 
> So what do we have working now for 64 bit kernel (for 32 bit kernel
> we know it works...):
> 
> 	'restart'	checkpointed
> 	 program	  program
> 	----------------------------------------
> 	  64bit		  64bit		-> works
> 	  32bit		  32bit		-> works
> 
> 	  64bit		  32bit		-> ?????

Actually the other way around works - /bin/restart_32 < 64bit.out
works just fine.  /bin/restart_64 < 32bit.out does not.  The reason
is that destroy_mm() ends up calling do_munmap on a 64-bit mapping
after the switch to 32-bit had been made, and it refuses bc
vma->vm_start > TASK_SIZE.

Perhaps getting it to work will be as simple as temporarily switching
back to 64-bit during destroy_mm().

> Does it make sense to allow the opposite transition: 'restart' starts
> as a 32bit and becomes a 64bit after it restores the state from the
> image ?
> 
> And what about if you checkpoint on a 32 bit kernel and try to 
> restart on a 64 bit kernel, and vice versa ?  (in both cases, the
> program of course is 32bit, and we can assume same physical host
> for now). 

I have no hw right now where I could test such a thing.  Do you?
