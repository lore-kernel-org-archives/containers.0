From: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 5/9] unprivileged mounts: allow unprivileged bind mounts
Date: Tue, 08 Jan 2008 11:15:10 -0800
Message-ID: <1199819710.9834.74.camel@localhost>
References: <20080108113502.184459371@szeredi.hu>
	 <20080108113626.895583537@szeredi.hu> <1199815958.9834.58.camel@localhost>
	 <E1JCJoQ-0003g9-Nk@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <E1JCJoQ-0003g9-Nk-8f8m9JG5TPIdUIPVzhDTVZP2KDSNp7ea@public.gmane.org>
Sender: util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, kzak-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, util-linux-ng-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2008-01-08 at 20:08 +0100, Miklos Szeredi wrote:
> 
> The logic behind EPERM, is that this failure is only for unprivileged
> callers.  ENOMEM is too specifically about OOM.  It could be changed
> to ENOSPC, ENFILE, EMFILE, or it could remain EPERM.  What do others
> think? 

Since you're patching mount anyway, maybe you could add a little pointer
for people to go check the sysctl if they get a certain error code back
from here.

-- Dave
