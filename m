From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14-rc][PATCH 04/23] General infrastructure for
	checkpoint restart
Date: Fri, 20 Mar 2009 16:42:48 -0500
Message-ID: <20090320214248.GA16845@us.ibm.com>
References: <1237574868-3371-1-git-send-email-orenl@cs.columbia.edu>
	<1237574868-3371-5-git-send-email-orenl@cs.columbia.edu>
	<20090320212400.GA15946@us.ibm.com>
	<49C40BDC.7050304@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49C40BDC.7050304-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> 
> Serge E. Hallyn wrote:
> > Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >> Changelog[v14]:
> >>   - Define sys_checkpoint(0,...) as asking for a self-checkpoint (Serge)
> > 
> > Thanks.
> > 
> >>   - Revert use of 'pr_fmt' to avoid tainting whom includes us (Nathan Lynch)
> >>   - Explicitly indicate length of UTS fields in header
> >>   - Discard field 'h->parent'
> > 
> > Nice.
> > 
> >> +	uts = utsname();
> >> +	ret = cr_write_buffer(ctx, uts->release, __NEW_UTS_LEN);
> >> +	if (ret < 0)
> >> +		return ret;
> >> +	ret = cr_write_buffer(ctx, uts->version, __NEW_UTS_LEN);
> >> +	if (ret < 0)
> >> +		return ret;
> >> +	ret = cr_write_buffer(ctx, uts->machine, __NEW_UTS_LEN);
> > 
> > ...
> > 
> >> +	/* FIX: verify compatibility of release, version and machine */
> >> +	ret = cr_read_obj_type(ctx, uts_buf, __NEW_UTS_LEN, CR_HDR_BUFFER);
> >> +	if (ret < 0)
> >> +		goto out;
> >> +	ret = cr_read_obj_type(ctx, uts_buf, __NEW_UTS_LEN, CR_HDR_BUFFER);
> >> +	if (ret < 0)
> >> +		goto out;
> >> +	ret = cr_read_obj_type(ctx, uts_buf, __NEW_UTS_LEN, CR_HDR_BUFFER);
> > 
> > The new_utsname fields actually have __NEW_UTS_LEN+1 chars.  So
> > if hostname happens to be full (__NEW_UTS_LEN chars plus a final
> > null), won't you end up without the trailing null here?
> 
> Using cr_write_buffer() instead of cr_write_string() ensures that it
> saves and restores exactly __NEW_UTS_LEN bytes, regardless of the null,
> so I'd think it's safe (yeah, we could save a few bytes - like a drop
> in the ocean).

No, I'm saying you have one less byte here than what is in the actual
kernel structures.  Each of those has 65 bytes.  __NEW_UTS_LEN is
64.  I realize that these fields should never get that long, but
it's a risk.

-serge
