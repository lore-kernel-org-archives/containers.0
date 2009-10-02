From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 1/3] cr: add generic LSM c/r support (v4)
Date: Fri, 2 Oct 2009 17:31:54 -0500
Message-ID: <20091002223154.GA8873@us.ibm.com>
References: <20091002034916.GA16871@us.ibm.com> <4AC6694F.3050509@librato.com> <20091002221349.GC7446@us.ibm.com> <4AC67D5F.2030908@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4AC67D5F.2030908@librato.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Oren Laadan <orenl@librato.com>
Cc: Linux Containers <containers@lists.osdl.org>, Casey Schaufler <casey@schaufler-ca.com>, linux-security-module@vger.kernel.org, Stephen Smalley <sds@epoch.ncsc.mil>, SELinux <selinux@tycho.nsa.gov>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl@librato.com):
> 
> 
> Serge E. Hallyn wrote:
> > Quoting Oren Laadan (orenl@librato.com):
> >>
> >> Serge E. Hallyn wrote:
> >>> (wasn't versioning the patchsets before, so randomly pick 4 as
> >>> the version for this patchset...)
> >>>
> >>> Documentation/checkpoint/readme.txt begins:
> >>> """
> >>> Application checkpoint/restart is the ability to save the state
> >>> of a running application so that it can later resume its execution
> >>> from the time at which it was checkpointed.
> >>> """
> >>>
> 
> [...]
> 
> >>> +	memset(ctx->lsm_name, 0, SECURITY_NAME_MAX + 1);
> >>> +	strlcpy(ctx->lsm_name, security_get_lsm_name(), SECURITY_NAME_MAX + 1);
> >>> +	ret = ckpt_write_buffer(ctx, ctx->lsm_name, SECURITY_NAME_MAX + 1);
> >>> +	if (ret < 0)
> >>> +		return ret;
> >>> +
> >>> +	ret = security_checkpoint_header(ctx);
> >>> +	if (ret < 0)
> >>> +		return ret;
> >>> +
> >> This is actually a case for a 'container-global' section that would
> >> appear after the header and before the rest of the image. (Would be
> >> useful also for network namespaces).
> > 
> > But LSM's are specifically not containerized, so this is a host
> > property, not a container one.
> 
> Hmmm... does that mean you can't apply one policy to one container
> and another policy to another ?

Yup.

> Anyway, it belongs to a 'global' section, that may have 2 parts:
> host and container. (Putting it between header and arch-header
> seems weird...)

Ok, then I'll add that in the next set.

> The header doesn't hold state, it is a declarative section about
> the properties of the original host (kernel and HW).

Ok, I see.

thanks,
-serge
