From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] fill vdso with syscall32_setup_pages if TIF_IA32
	on x86_64
Date: Fri, 5 Feb 2010 17:38:00 -0600
Message-ID: <20100205233800.GA17057@us.ibm.com>
References: <20100127071636.GA16624@us.ibm.com>
	<Pine.LNX.4.64.1001270954120.8974@takamine.ncl.cs.columbia.edu>
	<20100127201037.GA23119@us.ibm.com>
	<4B60A763.4030806@cs.columbia.edu>
	<20100127211052.GA27579@us.ibm.com>
	<4B60AC7E.2010908@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B60AC7E.2010908-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
> > Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >>
> >> Serge E. Hallyn wrote:
> >>> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >>>> Cool !
> >>>>
> >>>> So what do we have working now for 64 bit kernel (for 32 bit kernel
> >>>> we know it works...):
> >>>>
> >>>> 	'restart'	checkpointed
> >>>> 	 program	  program
> >>>> 	----------------------------------------
> >>>> 	  64bit		  64bit		-> works
> >>>> 	  32bit		  32bit		-> works
> >>>>
> >>>> 	  64bit		  32bit		-> ?????

s/?????/Rejected/

CKPT_ARCH_ID is of course different for X86_32 than X86_64, so
we refuse restart in restore_read_header().

-serge
