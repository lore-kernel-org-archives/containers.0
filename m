From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] fill vdso with syscall32_setup_pages if TIF_IA32
	on x86_64
Date: Tue, 9 Feb 2010 08:54:24 -0600
Message-ID: <20100209145424.GB13854@us.ibm.com>
References: <20100127201037.GA23119@us.ibm.com>
	<4B60A763.4030806@cs.columbia.edu>
	<20100127211052.GA27579@us.ibm.com>
	<4B60AC7E.2010908@cs.columbia.edu>
	<20100205233800.GA17057@us.ibm.com>
	<4B6CC00C.2090509@cs.columbia.edu>
	<20100206170902.GA20497@hallyn.com>
	<4B7022FE.4060704@cs.columbia.edu>
	<20100208153145.GB9120@us.ibm.com>
	<4B703936.3010200@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B703936.3010200-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
> 
> Serge E. Hallyn wrote:
> >Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >>
> >>Serge E. Hallyn wrote:
> >>>Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >>>>Serge E. Hallyn wrote:
> >>>>>Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >>>>>>Serge E. Hallyn wrote:
> >>>>>>>Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >>>>>>>>Serge E. Hallyn wrote:
> >>>>>>>>>Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >>>>>>>>>>Cool !
> >>>>>>>>>>
> >>>>>>>>>>So what do we have working now for 64 bit kernel (for 32 bit kernel
> >>>>>>>>>>we know it works...):
> >>>>>>>>>>
> >>>>>>>>>>	'restart'	checkpointed
> >>>>>>>>>>	 program	  program
> >>>>>>>>>>	----------------------------------------
> >>>>>>>>>>	  64bit		  64bit		-> works
> >>>>>>>>>>	  32bit		  32bit		-> works
> >>>>>>>>>>
> >>>>>>>>>>	  64bit		  32bit		-> ?????
> >>>>>s/?????/Rejected/
> >>>>>
> >>>>>CKPT_ARCH_ID is of course different for X86_32 than X86_64, so
> >>>>>we refuse restart in restore_read_header().
> >>>>>
> >>>>>-serge
> >>>>>
> >>>>lol ... that's actually funny !
> >>>>
> >>>>Anyway, in light of the IRC discussions, here are the cases again:
> >>>>
> >>>>
> >>>>original	original	restart		target
> >>>>program		kernel		program		kernel
> >>>>--------	---------	--------	--------
> >>>>64 bit		64 bit		64 bit		64 bit	  [0] works
> >>>>
> >>>>32 bit		32 bit		32 bit		32 bit	  [0] works
> >>>>32 bit		64 bit		32 bit		64 bit	  [0] works
> >>>>
> >>>>32 bit		32 bit		32 bit		64 bit	  [1]
> >>>>32 bit		64 bit		32 bit		32 bit	  [1]
> >>>>
> >>>>32 bit		any		64 bit		64 bit	  [2]
> >>>>64 bit		64 bit		32 bit		64 bit	  [2]
> >>>>
> >>>>[0] The first 3 cases are "homogeneous", with conditions equal at
> >>>>checkpoint and restart. AFAIK, they work.
> >>>>
> >>>>[1] The next two cases consider 32 bit program, and vary only the
> >>>>environment - the kernel may change from 32 to 64 or back. We want
> >>>>them to work.
> >>>>
> >>>>IIUC, your comment above means that they don't work because the
> >>>>CKPT_ARCH_ID is a mismatch. The fix should be trivial - either
> >>>>make 'restart' modify it, or make the kernel tolerate it.
>      ^^^^^^^^^^^^^^^^^^^^^^^^
> ---->
> 
> >>>Well, you'd think so, but we also check for uts->machine, and want
> >>>to eventually check for kernel config, both of which are obviously
> >>>different.
> >>Then we'll have to take that in account when we get to also
> >>check those other fields.
> >>
> >>>After I comment out the obvious offending checks, it still fails to
> >>>restart from x8632->x86-64.  I can spend some time next week figuring
> >>>out what we're not quite doing right as there shouldn't be a
> >>>problem really.  But do we definately want to go out of our way to try
> >>>and mask out the differences in this case, while trying to detect
> >>>cpu differences between two x86-32's for instance?
> >>I agree, there shouldn't be a problem really, and I expect this to
> >>be a very useful feature for migration/fault-tolerance.
> >
> >May be, but then perhaps this is the first case where we should be
> >using a userspace checkpoing image rewriter to help us out.  Otherwise
> >we'll need to hardcode in the kernel that a task which was
> >checkpointed on X86_32 should, on x86_64, have TIF_IA32 added to
> >the thread_flags but may be restarted;  etc.  Should be doable, but
> >kind of ugly...
> 
> Indeed. I offered that path above :)
> 
> Since we are going to need the bit-ness of a task for the tree
> creation as well, how about:
> 
> 1) Add the bit-ness property to the pids_arr[], e.g. as a flags
> field (we may need use it for other stuff later).
> 
> 2) 'restart' already examines and possibly modifies pids_arr[],
> so in transition from 32->64 it will add that flag, and in the
> opposite transition it will check/remove that flag.
>
> 3) 'restart' will also change the header architecture as needed.
> 
> 4) The kernel will verify that the bitness reported in pids_arr[]
> is the same as the actual process. (This is just a sanity check,
> of course).
> 
> Later we'll also make 'restart' use that bit-ness information to
> decide whether an exec() is needed to change own bit-ness.

It'll mean yet another arch-dependent hook used early in the
checkpoint path, but if we want to restarted mixed-bit containers
i guess it's what we'll need.

Still I really don't think it's all that mean to just say we
don't support it:  at checkpoint we refuse with a meaningful
log message including pids of task which are COMPAT, and the
end-user can use that info to checkpoint those applications
separately as subtrees, kill them, then checkpoint the container,
then restart the applications.

If to my surprise there turn out to be people who care, then
we can make the necessary changes to accomodate them.  But IMO
we have enough to worry about right now.

-serge
