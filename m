From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 16/29] A new file type (CR_FD_OBJREF) for a
	file descriptor already setup
Date: Fri, 03 Apr 2009 08:46:08 -0700
Message-ID: <87y6uhyc3j.fsf@caffeine.danplanet.com>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
	<1238477349-11029-17-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1238477349-11029-17-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> (Oren
	Laadan's message of "Tue, 31 Mar 2009 01:28:56 -0400")
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

OL> @@ -86,46 +132,44 @@ static int cr_read_file(struct cr_ctx *ctx, int objref)
OL>  		goto out;

OL>  	ret = -EINVAL;
OL> +	if (hh->fd_objref < 0)
OL> +		goto out;

As far as I can tell, hh->fd_objref never gets set anywhere.  On my
system, this causes restart to always fail because there is garbage in
that field, thus triggering the above check.  If I remove this,
restart completes successfully.  The following grep tells me that
maybe this check isn't valid:

  % grep fd_objref checkpoint/*.c include/linux/checkpoint*.h
  checkpoint/rstr_file.c: file = cr_obj_get_by_ref(ctx, hh->fd_objref, CR_OBJ_FILE);
  checkpoint/rstr_file.c: file = cr_obj_add_file(ctx, fds[1-which], hh->fd_objref);
  checkpoint/rstr_file.c:static int cr_read_fd_objref(struct cr_ctx *ctx, struct cr_hdr_file *hh)
  checkpoint/rstr_file.c: file = cr_obj_get_by_ref(ctx, hh->fd_objref, CR_OBJ_FILE);
  checkpoint/rstr_file.c: if (hh->fd_objref < 0)
  checkpoint/rstr_file.c:	fd = cr_read_fd_objref(ctx, hh);
  include/linux/checkpoint_hdr.h:	__s32 fd_objref;

I haven't looked into the surrounding bits yet, so maybe I'm missing
something, but this seems to be causing a spurious failure on s390 at
least.

I'm doing this on a clone of your repository's ckpt-v14-rc2 branch.
Perhaps that repo is missing a patch?

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
