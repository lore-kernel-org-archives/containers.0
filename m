From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][patch 0/1] fix allnoconfig for net-2.6.24
Date: Wed, 12 Sep 2007 11:45:23 -0600
Message-ID: <m1hclz93rg.fsf@ebiederm.dsl.xmission.com>
References: <20070912170739.187625566@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070912170739.187625566-WECHFHqYCmGD/CxQmPlnQ0FT0OZdM7KVQQ4Iyu8u01E@public.gmane.org>
	(dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org's message of "Wed, 12 Sep 2007 19:07:39 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org writes:

> The kernel compilation fails with allnoconfig with an unresolved to init_net.
> I tryed to figure out how to fix that. The problem is raised because the
> init_net
> variable is defined as extern in net_namespace.h while the variable is declared
> in net_namespace.c. This file is not compiled because of the config options and
> that leads to the compilation error.

Ok.  We seem to have the same issue with the ipc namespace.
And it uses the INIT_IPC_NS macro to handle it.

I wonder if we can do something similar here.

It looks like the initialization of nsproxy is the big gotcha.

> I noticed the uts namespace defines the init_uts_ns in init/version.c, so I
> moved
> the init_net to this file too. The compilation error is fixed.
>
> But I don't like really this approach because:
> 	1 - we fall under a part not covered by the network
> 	2 - we add a new include net_namespace.h in version.c
>
> Does this fix seems correct ? I just want to fix it for now to have net-2.6.24
> compiling for all configs.

I think we can probably spend a couple more hours and fix things cleanly.
If that we can't figure out a clean solution I'm happy to deal with the
hack.  But if we can find something clean and maintainable I would
very much prefer that.

So do you think you can come up with something based on the model
of INIT_IPC_NS?

Eric
