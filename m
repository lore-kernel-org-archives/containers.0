From: Guenter Roeck <groeck-gvzKVTG1yJJBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC v14][PATCH 08/54] Dump memory address space
Date: Tue, 28 Apr 2009 23:42:41 -0700
Message-ID: <20090429064241.GA17482@redback.com>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
	<1240961064-13991-9-git-send-email-orenl@cs.columbia.edu>
	<20090429041128.GA28018@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090429041128.GA28018-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Apr 28, 2009 at 09:11:28PM -0700, Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> > +#if CONFIG_CHEKCPOINT
                ^^^^^^^^^^
CONFIG_CHECKPOINT ? 

Guenter

> > +static int special_mapping_checkpoint(struct ckpt_ctx *ctx,
> > +				      struct vm_area_struct *vma)
> > +{
> > +	char *name;
> > +
> > +	/*
> > +	 * Currently, we only handle VDSO/vsyscall special handling.
> > +	 * Even that, is very basic - we just skip the contents and
> > +	 * hope for the best in terms of compatilibity upon restart.
> > +	 */
> > +
> > +	if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED)
> > +		return -ENOSYS;
> > +
> > +	name = arch_vma_name(vma);
> > +	if (!name || strcmp(vma_name, "[vdso]"))
> 
> Not important except for bisect-safety, as it's fixed in the next
> patch, but this should be name, not vma_name.
> 
> -serge
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
