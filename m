From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: CAP_SYS_ADMIN on restart(2)
Date: Thu, 16 Apr 2009 19:35:13 +0400
Message-ID: <20090416153513.GA7876__11335.6295777068$1239896255$gmane$org@x200.localdomain>
References: <49E4108A.8050201@cs.columbia.edu>
	<20090414145830.GA27461@x200.localdomain>
	<49E4D115.5080601@cs.columbia.edu>
	<20090414204912.GA28458@x200.localdomain>
	<20090414213934.GB17986@us.ibm.com>
	<20090415192150.GC26994@x200.localdomain>
	<1239827033.32604.167.camel@nimitz>
	<20090415203920.GA5475@us.ibm.com>
	<49E64BFF.5080002@cs.columbia.edu>
	<20090415211609.GA6704@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090415211609.GA6704-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Apr 15, 2009 at 04:16:09PM -0500, Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> > 
> > 
> > Serge E. Hallyn wrote:
> > > Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> > >> On Wed, 2009-04-15 at 23:21 +0400, Alexey Dobriyan wrote:
> > >>> Is sysctl to control CAP_SYS_ADMIN on restart(2) OK?
> > >> If the point is not to let users even *try* restarting things if it
> > >> *might* not work, then I guess this might be reasonable.  
> > >>
> > >> If the goal is to increase security by always requiring CAP_SYS_ADMIN
> > >> for "dangerous" operations, I fear it will be harmful.  We may have
> > >> people adding features that are not considering the security impact of
> > >> what they're doing just because the cases they care about all require
> > >> privilege.
> > > 
> > > Nah, I disagree.  (Or put another way, that wouldn't be the goal)
> > > There are two administrators we want to satisfy:
> > > 
> > > 1. the one who wants his users to do partial checkpoints, but doesn't
> > > want to risk giving away any privilege at all in the process.  He'll
> > > be satisified by setting restart(2) to not require cap_sys_admin,
> > > and his users just won't be able to do a whole container.  A lot of
> > > users will be happy with that (though no SYSVIPC support, then).
> > 
> > There is also a middle way: use setuid program to allow creation
> > of a new namespace (under your favorite policy), then drop the
> > privileges and continue as unprivileged inside that container.
> > 
> > IOW, don't make the initial container-creation a barrier for the
> > entire operation.
> 
> That is still possible here.  But I don't think it's relevant.
> 
> What Alexey wants, I believe, is for users to be able to not have
> to worry about there being exploitable bugs in restart(2) which
> unprivileged users can play with.  And for the usual distro-kernel
> reasons, saying use 'CONFIG_CHECKPOINT=n' is not an option.

This is correct, yes. If I would be a sysadmin who knows a bit about
kernel internals, I'd never trust restart(2) to get it right.
