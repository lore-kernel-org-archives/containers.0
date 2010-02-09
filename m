From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH] Make AT_VECTOR_SIZE_ARCH 2 for x86-32
Date: Mon, 8 Feb 2010 20:07:20 -0600
Message-ID: <20100209020720.GB13571@us.ibm.com>
References: <20100208203440.GA27389@us.ibm.com>
	<20100208204837.GA27904@us.ibm.com>
	<4B708A73.9010306@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B708A73.9010306-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
> >Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> >>[ RFC:  Am I on crack? ]
> >>
> >>Both x86-32 and x86-64 with 32-bit compat use ARCH_DLINFO_IA32,
> >>which defines two saved_auxv entries.  But system.h only defines
> >>AT_VECTOR_SIZE_ARCH as 2 for CONFIG_IA32_EMULATION, not for
> >>CONFIG_X86_32.  Fix that.
> >
> >To be clear, this patch if right would be for pushing upstream
> >immediately.  It still leaves open the question of what we want
> >to do about saved_auxv.  We currently just write it out as a
> >buffer, but since it is actually an array of longs, and therefore
> >differently sized on x86-32 and x86-64-compat, we would need to
> >write them out entry-by-entry (and validate no overflows for
> >TIF_IA32 tasks).  Does that seem warranted?
> 
> Yes: iterate over entries and copy them.
> 
> From a brief look at the code, I don't think the contents of the
> saved_auxv is used anywhere inside the kernel (it's exported via
> /proc), except for the reliance on a trailing AT_NULL record
> which is easy to test for.
> 
> Would it be wrong or insecure to export whatever garbage the user
> may have put in that array (assuming it is null terminated) ?

I don't know which tools use the /proc/$$/auxv output, but I don't
see why it would be unsafe so long as we (as I do) only copy
AT_VECTOR_SIZE unsigned longs.

I suppose we could try and be more knowledgable about the internals
and restore them to values that make sense, using code we'd share
with fs/binfmt_elf.c...  

-serge
