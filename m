From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 18/38] C/R: core stuff
Date: Fri, 29 May 2009 10:01:31 +0400
Message-ID: <20090529060131.GA5504__31077.7209852406$1243579387$gmane$org@x200.localdomain>
References: <1242968132-1044-1-git-send-email-adobriyan@gmail.com>
	<1242968132-1044-18-git-send-email-adobriyan@gmail.com>
	<20090526131644.GA20920@hallyn.com>
	<20090526193503.GB11909@x200.localdomain>
	<4A1DA8FB.3000306@cs.columbia.edu>
	<20090527221753.GB8321@x200.localdomain>
	<4A1DC270.8080807@cs.columbia.edu>
	<20090528153322.GB18256@x200.localdomain>
	<4A1F0E29.2040506@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A1F0E29.2040506-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, May 28, 2009 at 06:20:25PM -0400, Oren Laadan wrote:
> Alexey Dobriyan wrote:
> > Price in loose case is strictly bigger than price in strict case
> > because set of loose states is strict superset of set of strict cases.
> 
> The code to enforce full-container approach is a *superset* of the
> code without this requirement.
> 
> If you can checkpoint a full container, surely you can checkpoint a
> sub-hierarchy of processes.

No!

To checkpoint uts_ns reliably, in strict case, one doesn't even need
uts_sem.

In loose case, one needs uts_sem.

	static int dump_uts_ns(struct kstate_context *ctx, struct kstate_object *obj)
	{
		struct uts_namespace *uts_ns = obj->o_obj;
		struct kstate_image_uts_ns *i;
		int rv;
	
		i = kstate_prepare_image(KSTATE_OBJ_UTS_NS, sizeof(*i));
		if (!i)
			return -ENOMEM;
	
		if (ctx->dump_live)
			down_read(&uts_sem);
		strncpy(i->sysname, (const char *)uts_ns->name.sysname, 64);
		strncpy(i->nodename, (const char *)uts_ns->name.nodename, 64);
		strncpy(i->release, (const char *)uts_ns->name.release, 64);
		strncpy(i->version, (const char *)uts_ns->name.version, 64);
		strncpy(i->machine, (const char *)uts_ns->name.machine, 64);
		strncpy(i->domainname, (const char *)uts_ns->name.domainname, 64);
		if (ctx->dump_live)
			up_read(&uts_sem);

		rv = kstate_write_image(ctx, i, sizeof(*i), obj);
		kfree(i);
		return rv;
	}
